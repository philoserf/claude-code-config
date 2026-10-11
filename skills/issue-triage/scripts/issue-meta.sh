#!/usr/bin/env bash
# Reads and repairs the metadata that makes a backlog workable: milestone,
# severity label, and blocked-by relations.
#
# Usage:
#   issue-meta.sh audit [MILESTONE]        report gaps across open issues
#   issue-meta.sh milestone <TITLE> <N>... assign a milestone
#   issue-meta.sh block <BLOCKED> <BLOCKER>   record "BLOCKED is blocked by BLOCKER"
#   issue-meta.sh unblock <BLOCKED> <BLOCKER>
#
# Exit: 0 success; 1 usage/gh failure; 2 audit found gaps.
#
# One API fact this script exists to encapsulate:
#
#   The dependencies endpoint takes the blocking issue's DATABASE ID, not its
#   number — `{"id":5406149848,"number":71}`. Passing the number is rejected, or
#   worse, silently addresses a different issue. `block` resolves it.

set -uo pipefail

command -v gh >/dev/null || { echo "issue-meta: gh not on PATH" >&2; exit 1; }
die() { echo "issue-meta: $*" >&2; exit 1; }

cmd_audit() {
  local ms="${1:-}" filter=() rc=0
  [ -n "$ms" ] && filter=(--milestone "$ms")

  local rows
  rows="$(gh issue list "${filter[@]}" --state open --limit 400 \
    --json number,title,labels,milestone \
    --jq '.[] | "\(.number)\t\(.milestone.title // "-")\t\((.labels|map(.name)|map(select(startswith("severity:")))|join(","))|if .=="" then "-" else . end)\t\(.labels|map(.name)|join(","))\t\(.title)"')" \
    || die "cannot list issues"

  [ -n "$rows" ] || { echo "no open issues"; return 0; }

  printf '%-6s %-12s %-16s %s\n' ISSUE MILESTONE SEVERITY TITLE
  while IFS=$'\t' read -r n ms_t sev _labels title; do
    printf '%-6s %-12s %-16s %s\n' "#$n" "$ms_t" "$sev" "${title:0:60}"
    [ "$ms_t" = "-" ] && { echo "GAP   #$n has no milestone"; rc=2; }
    [ "$sev"  = "-" ] && { echo "GAP   #$n has no severity label"; rc=2; }
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

case "${1:-}" in
  audit)     shift; cmd_audit "$@" ;;
  milestone) shift; cmd_milestone "$@" ;;
  block)     shift; cmd_block "$@" ;;
  unblock)   shift; cmd_unblock "$@" ;;
  *) sed -n '2,17p' "$0" >&2; exit 1 ;;
esac
