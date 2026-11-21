#!/usr/bin/env bash
# shellcheck disable=SC2016  # the backticks in sed and grep patterns are literal Markdown
# Keeps repo-releaser's authority tied to release-ship's named checkpoints
# (issue #462). release-ship's `## Checkpoints` table names every place the
# workflow hands a step to the user, each `confirm` (a go-ahead) or `decide` (a
# call only the user can make), and the phases mark each one in place as
# (checkpoint `name`). repo-releaser pre-approves confirm checkpoints and stops
# at decide checkpoints, by name. This fails when the table, the markers and the
# agent's two lists disagree, so a change to what the agent may do without
# asking cannot land unnoticed.
#
# It runs against the real tree rather than fixtures: the tree is what drifts.
#
# Usage: skills/release-ship/tests/checkpoints.sh

set -uo pipefail

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
SKILL="$ROOT/skills/release-ship/SKILL.md"
AGENT="$ROOT/agents/repo-releaser.md"

# The lines of one `## ` section, heading excluded.
section() { awk -v h="$2" '$0==h {on=1; next} on && /^## / {exit} on' "$1"; }
# Everything except that section.
outside() { awk -v h="$2" '$0==h {on=1; next} on && /^## / {on=0} !on' "$1"; }

# Table rows: | `name` | kind | ... -> "name kind"
table=$(section "$SKILL" '## Checkpoints' |
  sed -n 's/^| *`\([a-z-]*\)` *| *\([^ |]*\) *|.*/\1 \2/p' | sort)
kind_set() { printf '%s\n' "$table" | awk -v k="$1" '$2==k {print $1}' | sort; }
# Joined into one line first: the formatter may wrap a marker across two.
markers=$(outside "$SKILL" '## Checkpoints' | tr '\n' ' ' |
  grep -o 'checkpoint `[a-z-]*`' | sed 's/.*`\(.*\)`/\1/' | sort -u)
bullets() { section "$AGENT" "$1" | sed -n 's/^- `\([a-z-]*\)`.*/\1/p' | sort; }

# Compare two sorted lists; report each side's extras.
same() {
  local label=$1 a=$2 b=$3 an=$4 bn=$5 only_a only_b
  only_a=$(comm -23 <(printf '%s\n' "$a") <(printf '%s\n' "$b") | tr '\n' ' ')
  only_b=$(comm -13 <(printf '%s\n' "$a") <(printf '%s\n' "$b") | tr '\n' ' ')
  if [ -z "$a" ]; then
    bad "$label: $an is empty"
  elif [ -z "$only_a$only_b" ]; then
    ok "$label"
  else
    bad "$label: only in $an: ${only_a:-none}; only in $bn: ${only_b:-none}"
  fi
}

echo "release-ship checkpoints"
bad_kinds=$(printf '%s\n' "$table" | awk 'NF && $2!="confirm" && $2!="decide" {print $1}')
if [ -n "$bad_kinds" ]; then
  bad "checkpoints with a kind other than confirm or decide: $bad_kinds"
else
  ok "every checkpoint is confirm or decide"
fi
same "table and in-phase markers agree" \
  "$(printf '%s\n' "$table" | awk 'NF {print $1}' | sort)" "$markers" "the table" "the markers"
same "repo-releaser pre-approves exactly the confirm checkpoints" \
  "$(kind_set confirm)" "$(bullets '## What is pre-approved')" "the skill" "the agent"
same "repo-releaser stops at exactly the decide checkpoints" \
  "$(kind_set decide)" "$(bullets '## When to stop instead')" "the skill" "the agent"

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
