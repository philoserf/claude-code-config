#!/usr/bin/env bash
# Prints the open issues of a milestone in an order that respects GitHub's
# blocked_by relations, plus the relations themselves and anything that could
# not be ordered.
#
# Usage: milestone-graph.sh <MILESTONE-TITLE>
# Exit:  0 ordered cleanly
#        1 usage / gh failure / no such milestone
#        2 a dependency cycle, or a blocker outside the milestone — printed, and
#          the order is still emitted for the part that could be sorted
#
# Output sections, each grepable by its first token:
#   ISSUE <n> <severity> <labels> <title>
#   DEP   <n> blocked_by <m> [in-milestone|OUTSIDE|CLOSED]
#   ORDER <position> <n>
#   WARN  <text>
#
# The ORDER is a topological sort, and it is a *starting point, not a plan*.
# It knows only what GitHub records. Two things it cannot see, both of which
# changed the real order the last time this was used:
#
#   - Sequencing stated in issue prose ("do this before #69") that nobody
#     entered as a relation.
#   - Issues that cannot be separate PRs at all, because one forbids an action
#     the other requires — an issue saying "do not re-pin the expected output
#     until #69 lands" makes its own PR red when shipped alone.
#
# Read the bodies. The graph tells you what is forbidden, not what is wise.

set -uo pipefail

command -v gh >/dev/null || { echo "milestone-graph: gh not on PATH" >&2; exit 1; }
MILESTONE="${1:-}"
[ -n "$MILESTONE" ] || { sed -n '2,30p' "$0" >&2; exit 1; }

issues="$(gh issue list --milestone "$MILESTONE" --state open --limit 200 \
  --json number,title,labels \
  --jq '.[] | "\(.number)\t\((.labels|map(.name)|map(select(startswith("severity:")))|join(","))|if .=="" then "severity:?" else . end)\t\(.labels|map(.name)|join(","))\t\(.title)"' 2>/dev/null)" \
  || { echo "milestone-graph: cannot list milestone '$MILESTONE'" >&2; exit 1; }

if [ -z "$issues" ]; then
  echo "WARN  milestone '$MILESTONE' has no open issues"
  exit 0
fi

nums="$(printf '%s\n' "$issues" | cut -f1 | sort -n)"
printf '%s\n' "$issues" | sort -n | while IFS=$'\t' read -r n sev labels title; do
  echo "ISSUE $n $sev [$labels] $title"
done

rc=0
edges="$(mktemp)"; trap 'rm -f "$edges"' EXIT

while IFS= read -r n; do
  [ -n "$n" ] || continue
  for d in $(gh api "repos/{owner}/{repo}/issues/$n/dependencies/blocked_by" --jq '.[].number' 2>/dev/null); do
    if printf '%s\n' "$nums" | grep -qx "$d"; then
      echo "DEP   $n blocked_by $d [in-milestone]"
      printf '%s %s\n' "$d" "$n" >> "$edges"
    else
      st="$(gh issue view "$d" --json state --jq .state 2>/dev/null || echo UNKNOWN)"
      if [ "$st" = "CLOSED" ]; then
        echo "DEP   $n blocked_by $d [CLOSED]"
      else
        echo "DEP   $n blocked_by $d [OUTSIDE]"
        echo "WARN  #$n is blocked by #$d, which is not in this milestone and is $st"
        rc=2
      fi
    fi
  done
done <<< "$nums"

# tsort emits a topological order; it reports a cycle on stderr and still
# prints what it could order.
order_err="$(mktemp)"; trap 'rm -f "$edges" "$order_err"' EXIT
if [ -s "$edges" ]; then
  # Seed with self-edges so unconstrained issues survive the sort.
  { cat "$edges"; while IFS= read -r n; do [ -n "$n" ] && printf '%s %s\n' "$n" "$n"; done <<< "$nums"; } \
    | tsort 2>"$order_err" | grep -x '[0-9]*' | awk 'NF{print "ORDER " NR " " $1}'
else
  printf '%s\n' "$nums" | awk 'NF{print "ORDER " NR " " $1}'
fi

if [ -s "$order_err" ]; then
  sed 's/^/WARN  tsort: /' "$order_err"
  rc=2
fi

exit "$rc"
