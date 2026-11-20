#!/usr/bin/env bash
# Enforces the `## Do not use when` rule in .claude/rules/skill-authoring.md,
# which says which skills it covers and why: every SKILL.md whose frontmatter
# lacks `disable-model-invocation: true`, except rex. A covered skill has the
# section exactly once, as its last `##` heading.
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
HEADING='## Do not use when'

# The frontmatter alone: the lines between the first two `---` lines.
frontmatter() { awk 'NR==1 && $0=="---" {in_fm=1; next} in_fm && $0=="---" {exit} in_fm' "$1"; }

echo "skill sections"
for f in "$ROOT"/skills/*/SKILL.md "$ROOT"/.claude/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  rel=${f#"$ROOT"/}
  [ "$(basename "$(dirname "$f")")" = rex ] && continue
  frontmatter "$f" | grep -q '^disable-model-invocation: true' && continue
  count=$(grep -c "^$HEADING\$" "$f")
  last=$(grep '^## ' "$f" | tail -1)
  if [ "$count" -eq 0 ]; then
    bad "$rel has no Do not use when section"
  elif [ "$count" -gt 1 ]; then
    bad "$rel has $count Do not use when sections"
  elif [ "$last" != "$HEADING" ]; then
    bad "$rel ends with '$last', not the Do not use when section"
  else
    ok "$rel ends with one Do not use when section"
  fi
done

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
