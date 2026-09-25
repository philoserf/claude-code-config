#!/usr/bin/env bash
# Reads and repairs the metadata that makes a backlog workable: milestone,
# severity label, blocked-by relations, and project-board fields.
#
# Usage:
#   issue-meta.sh audit [MILESTONE]        report gaps across open issues
#   issue-meta.sh milestone <TITLE> <N>... assign a milestone
#   issue-meta.sh block <BLOCKED> <BLOCKER>   record "BLOCKED is blocked by BLOCKER"
#   issue-meta.sh unblock <BLOCKED> <BLOCKER>
#   issue-meta.sh board <N>...             add to the project, set Status/Priority
#
# Environment (board only):
#   TRIAGE_PROJECT  project number (default 5)
#   TRIAGE_OWNER    project owner  (default: the repo's owner)
#   TRIAGE_STATUS   status option to set for new items (default Backlog)
#
# Exit: 0 success; 1 usage/gh failure; 2 audit found gaps.
#
# Two API facts this script exists to encapsulate:
#
#   The dependencies endpoint takes the blocking issue's DATABASE ID, not its
#   number — `{"id":5406149848,"number":71}`. Passing the number is rejected, or
#   worse, silently addresses a different issue. `block` resolves it.
#
#   `gh project item-list` defaults to 30 items and will hide a new one without
#   saying so. Every listing here passes an explicit high --limit.

set -uo pipefail

command -v gh >/dev/null || { echo "issue-meta: gh not on PATH" >&2; exit 1; }
die() { echo "issue-meta: $*" >&2; exit 1; }

TRIAGE_PROJECT="${TRIAGE_PROJECT:-5}"
TRIAGE_STATUS="${TRIAGE_STATUS:-Backlog}"
owner() { echo "${TRIAGE_OWNER:-$(gh repo view --json owner --jq .owner.login)}"; }

# severity label -> board priority, per the Workbench board README. P0 is high
# severity *and* silent data loss or corruption, a judgment no label carries, so
# high maps to P1 and the promotion to P0 is made by hand.
priority_for() {
  case "$1" in
    severity:critical) echo P0 ;;
    severity:high|severity:medium) echo P1 ;;
    severity:low)    echo P2 ;;
    *)               echo "" ;;
  esac
}

cmd_audit() {
  local ms="${1:-}" filter=() rc=0
  [ -n "$ms" ] && filter=(--milestone "$ms")

  local rows
  rows="$(gh issue list "${filter[@]}" --state open --limit 400 \
    --json number,title,labels,milestone \
    --jq '.[] | "\(.number)\t\(.milestone.title // "-")\t\((.labels|map(.name)|map(select(startswith("severity:")))|join(","))|if .=="" then "-" else . end)\t\(.labels|map(.name)|join(","))\t\(.title)"')" \
    || die "cannot list issues"

  [ -n "$rows" ] || { echo "no open issues"; return 0; }

  # Board membership, once, with an explicit limit.
  local onboard
  onboard="$(gh project item-list "$TRIAGE_PROJECT" --owner "$(owner)" --limit 400 --format json \
    --jq '.items[] | .content.number // empty' 2>/dev/null | sort -n)"

  printf '%-6s %-12s %-16s %-7s %s\n' ISSUE MILESTONE SEVERITY BOARD TITLE
  while IFS=$'\t' read -r n ms_t sev _labels title; do
    local on="no"
    printf '%s\n' "$onboard" | grep -qx "$n" && on="yes"
    printf '%-6s %-12s %-16s %-7s %s\n' "#$n" "$ms_t" "$sev" "$on" "${title:0:52}"
    [ "$ms_t" = "-" ] && { echo "GAP   #$n has no milestone"; rc=2; }
    [ "$sev"  = "-" ] && { echo "GAP   #$n has no severity label"; rc=2; }
    [ "$on"   = "no" ] && { echo "GAP   #$n is not on project $TRIAGE_PROJECT"; rc=2; }
  done <<< "$rows"
  return "$rc"
}

cmd_milestone() {
  local title="${1:?milestone title required}"; shift
  [ "$#" -ge 1 ] || die "at least one issue number required"
  for n in "$@"; do
    gh issue edit "$n" --milestone "$title" >/dev/null || die "cannot set milestone on #$n"
    echo "#$n -> milestone $title"
  done
}

cmd_block() {
  local blocked="${1:?blocked issue required}" blocker="${2:?blocking issue required}" id
  id="$(gh api "repos/{owner}/{repo}/issues/$blocker" --jq .id)" || die "cannot resolve #$blocker"
  [ -n "$id" ] || die "no database id for #$blocker"
  # -F, not -f: the endpoint types issue_id as an integer and rejects a string.
  gh api -X POST "repos/{owner}/{repo}/issues/$blocked/dependencies/blocked_by" \
    -F "issue_id=$id" >/dev/null || die "cannot record #$blocked blocked_by #$blocker"
  echo "#$blocked blocked_by #$blocker (id $id)"
}

cmd_unblock() {
  local blocked="${1:?}" blocker="${2:?}" id
  id="$(gh api "repos/{owner}/{repo}/issues/$blocker" --jq .id)" || die "cannot resolve #$blocker"
  gh api -X DELETE "repos/{owner}/{repo}/issues/$blocked/dependencies/blocked_by/$id" >/dev/null \
    || die "cannot remove #$blocked blocked_by #$blocker"
  echo "#$blocked no longer blocked_by #$blocker"
}

cmd_board() {
  [ "$#" -ge 1 ] || die "at least one issue number required"
  local own pid fields sf pf
  own="$(owner)"
  pid="$(gh project view "$TRIAGE_PROJECT" --owner "$own" --format json --jq .id)" \
    || die "cannot read project $TRIAGE_PROJECT"
  fields="$(gh project field-list "$TRIAGE_PROJECT" --owner "$own" --limit 100 --format json)" \
    || die "cannot list project fields"
  sf="$(printf '%s' "$fields" | jq -r '.fields[] | select(.name=="Status") | .id')"
  pf="$(printf '%s' "$fields" | jq -r '.fields[] | select(.name=="Priority") | .id')"

  for n in "$@"; do
    local url item sev prio sopt popt
    url="$(gh issue view "$n" --json url --jq .url)" || die "cannot read #$n"
    # item-add returns the item id; `gh issue create --project` does not, which
    # is why adding and editing are two steps here.
    item="$(gh project item-add "$TRIAGE_PROJECT" --owner "$own" --url "$url" --format json --jq .id)" \
      || die "cannot add #$n to project"

    if [ -n "$sf" ]; then
      sopt="$(printf '%s' "$fields" | jq -r --arg s "$TRIAGE_STATUS" \
        '.fields[] | select(.name=="Status") | .options[] | select(.name==$s) | .id')"
      [ -n "$sopt" ] && gh project item-edit --id "$item" --project-id "$pid" \
        --field-id "$sf" --single-select-option-id "$sopt" >/dev/null
    fi

    sev="$(gh issue view "$n" --json labels \
      --jq '.labels[].name | select(startswith("severity:"))' | head -1)"
    prio="$(priority_for "${sev:-}")"
    if [ -n "$prio" ] && [ -n "$pf" ]; then
      popt="$(printf '%s' "$fields" | jq -r --arg p "$prio" \
        '.fields[] | select(.name=="Priority") | .options[] | select(.name==$p) | .id')"
      [ -n "$popt" ] && gh project item-edit --id "$item" --project-id "$pid" \
        --field-id "$pf" --single-select-option-id "$popt" >/dev/null
    fi

    echo "#$n -> project $TRIAGE_PROJECT (Status=$TRIAGE_STATUS${prio:+, Priority=$prio from ${sev}})"
  done
}

case "${1:-}" in
  audit)     shift; cmd_audit "$@" ;;
  milestone) shift; cmd_milestone "$@" ;;
  block)     shift; cmd_block "$@" ;;
  unblock)   shift; cmd_unblock "$@" ;;
  board)     shift; cmd_board "$@" ;;
  *) sed -n '2,28p' "$0" >&2; exit 1 ;;
esac
