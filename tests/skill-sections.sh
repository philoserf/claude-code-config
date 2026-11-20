#!/usr/bin/env bash
# Every model-invoked skill ends with a `## Do not use when` section
# (.claude/rules/skill-authoring.md).
#
# The section routes: it names the sibling skill the model should pick instead.
# Only a skill the model can invoke on its own needs that, so a skill marked
# `disable-model-invocation: true` is exempt. So is rex, whose SKILL.md
# `rex skill setup` installs and overwrites.
#
# This runs against the real tree rather than fixtures: the tree is the thing
# that drifts from the rule.
#
# Usage: tests/skill-sections.sh

set -uo pipefail

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "skill sections"
for f in "$ROOT"/skills/*/SKILL.md "$ROOT"/.claude/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  rel=${f#"$ROOT"/}
  name=$(basename "$(dirname "$f")")
  [ "$name" = rex ] && continue
  grep -q '^disable-model-invocation: true' "$f" && continue
  if grep -q '^## Do not use when' "$f"; then
    ok "$rel has a Do not use when section"
  else
    bad "$rel has no Do not use when section"
  fi
done

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
