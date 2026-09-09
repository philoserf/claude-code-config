#!/usr/bin/env bash
# Fixture tests for the release-gate version/tag state machine and the ship
# skill's changelog extractor. Builds throwaway git repos in a temp dir —
# nothing here touches a real project.
#
# Assertions are row-level, not just on the aggregate exit code. A fixture repo
# cannot satisfy every check: `gh` has no remote to query (checks 4, 5, 12 WARN)
# and `bun audit` has no lockfile to audit (check 9 FAILs). Asserting only on the
# exit code would let these tests pass for the wrong reason — a scenario could
# "correctly" report BLOCKED because of the audit rather than because of the tag
# logic under test.
#
# Usage: tests/exit-codes.sh

set -uo pipefail

GATE="$HOME/.claude/skills/obsidian-gate/scripts/release-check.sh"
EXTRACT="$HOME/.claude/skills/obsidian-ship/scripts/extract-changelog.sh"
PASS=0
FAIL=0

ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n         %s\n' "$1" "$2"; }

assert() { # want got label
  if [ "$2" = "$1" ]; then ok "$3"; else bad "$3" "expected '$1', got '$2'"; fi
}

row() { # check-number  gate-output  -> status word
  printf '%s' "$2" | awk -v n="$1" -F'|' '$2 ~ "^ *"n" *$" {gsub(/ /,"",$4); print $4}'
}

make_repo() { # $1 = version written into the three files
  local dir; dir="$(mktemp -d)"
  cd "$dir" || exit 1
  git init -q .
  git config user.email t@example.com
  git config user.name Test
  printf '{"name":"fx","version":"%s","scripts":{"build":"true"}}\n' "$1" > package.json
  printf '{"version":"%s","minAppVersion":"1.0.0"}\n' "$1" > manifest.json
  mkdir -p .github/workflows
  printf 'name: Release\non:\n  push:\n    tags: ["*"]\n' > .github/workflows/release.yml
  printf '{"%s":"1.0.0"}\n' "$1" > versions.json
  printf '# Changelog\n\n## %s\n\n### Fixed\n\n- a thing\n\n## 0.9.0\n\n- older\n' "$1" > CHANGELOG.md
  printf 'import {test,expect} from "bun:test";\ntest("t",()=>{expect(1).toBe(1)});\n' > fx.test.ts
  git add -A && git commit -qm "fixture $1"
  echo "$dir"
}

run_gate() { ( cd "$1" && shift && "$GATE" "$@" 2>/dev/null ); }

echo "gate: version/tag state machine"

# 1. Version equals the latest tag -> the release was never prepared.
#    Must be INFO + exit 3, never a FAIL — checks 10/11/14 pass vacuously here.
D="$(make_repo 1.0.0)"; git -C "$D" tag 1.0.0
OUT="$(run_gate "$D")"; CODE=$?
assert "INFO" "$(row 13 "$OUT")" "released version: check 13 is INFO, not FAIL"
assert "3"    "$CODE"            "released version: exits 3 (NOT STARTED)"
printf '%s' "$OUT" | grep -q 'NOT STARTED' \
  && ok "released version: result line says NOT STARTED" \
  || bad "released version: result line says NOT STARTED" "not found"

# 2. Version bumped past the latest tag -> ready to proceed.
D="$(make_repo 1.0.0)"; git -C "$D" tag 0.9.0
OUT="$(run_gate "$D")"; CODE=$?
assert "PASS" "$(row 13 "$OUT")" "bumped version: check 13 PASS"
[ "$CODE" != "3" ] && ok "bumped version: not NOT STARTED" \
                   || bad "bumped version: not NOT STARTED" "got exit 3"

# 3. Version collides with an OLDER tag -> a real conflict, must block.
D="$(make_repo 1.0.0)"
git -C "$D" tag 1.0.0
git -C "$D" commit -q --allow-empty -m later
git -C "$D" tag 1.1.0
OUT="$(run_gate "$D" 1.0.0)"; CODE=$?
assert "FAIL" "$(row 13 "$OUT")" "older-tag collision: check 13 FAIL"
assert "1"    "$CODE"            "older-tag collision: exits 1 (BLOCKED)"

echo
echo "gate: build reproducibility"

# 4. A build that rewrites a tracked file must be caught after the build,
#    even though check 2 saw a clean tree before it.
D="$(make_repo 1.0.0)"; git -C "$D" tag 0.9.0
python3 - "$D" <<'PY'
import json,sys
p=sys.argv[1]+'/package.json'
d=json.load(open(p)); d['scripts']['build']='echo drift >> manifest.json'
json.dump(d,open(p,'w'))
PY
git -C "$D" commit -qam "non-reproducible build"
OUT="$(run_gate "$D")"
assert "PASS" "$(row 2 "$OUT")"  "drifting build: check 2 still PASS (ran before build)"
assert "FAIL" "$(row 16 "$OUT")" "drifting build: check 16 catches it"

echo
echo "gate: plugin-shape assertion"

# 5. A repo that is not an Obsidian plugin must be refused outright rather than
#    emitting 16 rows of nonsense.
D="$(make_repo 1.0.0)"; rm "$D/manifest.json"
run_gate "$D" >/dev/null 2>&1; assert "1" "$?" "no manifest.json: refused"
D="$(make_repo 1.0.0)"; rm "$D/.github/workflows/release.yml"
run_gate "$D" >/dev/null 2>&1; assert "1" "$?" "no release.yml: refused"

echo
echo "ship: changelog extraction"

D="$(make_repo 2.0.0)"; cd "$D" || exit 1
OUT="$("$EXTRACT" 2.0.0)"
assert "0" "$(printf '%s' "$OUT" | grep -c '^## ')" "newest section excludes the next heading"
printf '%s' "$OUT" | grep -q 'a thing' && ok "newest section keeps its body" \
                                       || bad "newest section keeps its body" "body missing"
printf '%s' "$OUT" | head -1 | grep -q '^###' && ok "leading blank lines trimmed" \
                                              || bad "leading blank lines trimmed" "starts: $(printf '%s' "$OUT" | head -1)"
"$EXTRACT" 0.9.0 | grep -q 'older' && ok "middle section extracted" \
                                   || bad "middle section extracted" "body missing"
"$EXTRACT" 9.9.9 >/dev/null 2>&1; assert "1" "$?" "missing version exits 1"
printf '# Changelog\n\n## 2x0x0\n\n- wildcard bait\n' > CHANGELOG.md
"$EXTRACT" 2.0.0 >/dev/null 2>&1; assert "1" "$?" "version dots are literal, not wildcards"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
