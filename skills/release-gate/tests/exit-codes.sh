#!/usr/bin/env bash
# Fixture tests for the release-gate version/tag state machine, the release plan
# the ship skill reads, and its changelog extractor. Builds throwaway git repos —
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

GATE="$HOME/.claude/skills/release-gate/scripts/release-check.sh"
EXTRACT="$HOME/.claude/skills/release-ship/scripts/extract-changelog.sh"
PLAN="$HOME/.claude/skills/release-ship/scripts/release-plan.sh"
PASS=0
FAIL=0

# Every throwaway directory this suite creates lands under one parent, so a single
# trap reclaims them. Fixture repos get an explicit mktemp template because Darwin's
# `mktemp -d` with no template ignores $TMPDIR and uses the per-user confstr dir.
WORK="$(mktemp -d)"
cleanup() {
  cd /
  # release-check.sh preserves its log dir whenever anything FAILed or WARNed and
  # announces the path on stderr. A fixture repo always trips that (no remote, no
  # lockfile), so reclaim those dirs by the announced name rather than by shape —
  # a shape sweep would also delete logs from a real gate run on this machine.
  if [ -f "$WORK/gate.err" ]; then
    sed -n 's/^Release check logs preserved at: //p' "$WORK/gate.err" |
      while IFS= read -r d; do [ -n "$d" ] && rm -rf "$d"; done
  fi
  rm -rf "$WORK"
}
trap cleanup EXIT

ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n         %s\n' "$1" "$2"; }

assert() { # want got label
  if [ "$2" = "$1" ]; then ok "$3"; else bad "$3" "expected '$1', got '$2'"; fi
}

row() { # check-number  gate-output  -> status word
  printf '%s' "$2" | awk -v n="$1" -F'|' '$2 ~ "^ *"n" *$" {gsub(/ /,"",$4); print $4}'
}

detail() { # check-number  gate-output  -> details column, trimmed
  printf '%s' "$2" | awk -v n="$1" -F'|' '$2 ~ "^ *"n" *$" {
    sub(/^ +/, "", $5); sub(/ +$/, "", $5); print $5 }'
}

plan() { # key  dir  [version]  -> that key's value from the release plan
  ( cd "$2" && "$PLAN" "${3:-}" 2>/dev/null ) | sed -n "s/^$1=//p"
}

make_repo() { # $1 = version written into the three files
  local dir; dir="$(mktemp -d "$WORK/fx.XXXXXX")"
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

run_gate() { ( cd "$1" && shift && "$GATE" "$@" 2>>"$WORK/gate.err" ); }

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
DET="$(detail 16 "$OUT")"
printf '%s' "$DET" | grep -q 'tracked files changed by build' \
  && ok "drifting build: named as a tracked change" \
  || bad "drifting build: named as a tracked change" "details: $DET"

# 4b. A build that emits a NEW file left untracked output, which is a different
#     diagnosis and a different fix -- gitignore it, or ship it from Phase 5.
#     Check 16 used to call it a tracked change.
D="$(make_repo 1.0.0)"; git -C "$D" tag 0.9.0
python3 - "$D" <<'PY2'
import json,sys
p=sys.argv[1]+'/package.json'
d=json.load(open(p)); d['scripts']['build']='echo x > out.js'
json.dump(d,open(p,'w'))
PY2
git -C "$D" commit -qam "build emits a new file"
OUT="$(run_gate "$D")"
assert "FAIL" "$(row 16 "$OUT")" "new artifact: check 16 FAIL"
DET="$(detail 16 "$OUT")"
printf '%s' "$DET" | grep -q 'untracked' \
  && ok "new artifact: reported as untracked" \
  || bad "new artifact: reported as untracked" "details: $DET"
printf '%s' "$DET" | grep -q 'tracked files changed by build' \
  && bad "new artifact: not called a tracked change" "details: $DET" \
  || ok "new artifact: not called a tracked change"

# 4c. The details column is cut by column, not split on whitespace, so a path
#     containing a space survives whole.
D="$(make_repo 1.0.0)"; git -C "$D" tag 0.9.0
printf 'x\n' > "$D/my file.txt"
python3 - "$D" <<'PY3'
import json,sys
p=sys.argv[1]+'/package.json'
d=json.load(open(p)); d['scripts']['build']='echo drift >> "my file.txt"'
json.dump(d,open(p,'w'))
PY3
git -C "$D" add -A; git -C "$D" commit -qm "build rewrites a spaced path"
OUT="$(run_gate "$D")"
DET="$(detail 16 "$OUT")"
printf '%s' "$DET" | grep -q 'my file.txt' \
  && ok "spaced path survives the details column" \
  || bad "spaced path survives the details column" "details: $DET"

echo
echo "gate: profile detection"

# 5. The gate is no longer plugin-shaped. A repo it cannot profile is refused
#    only when it cannot find a version — that is the one fact with no safe
#    default. Defaulting it to the last tag would make check 13 self-satisfying
#    and wedge every repo at NOT STARTED forever.
D="$(mktemp -d "$WORK/bare.XXXXXX")"
(
  cd "$D" || exit 1
  git init -q .
  git config user.email t@example.com
  git config user.name Test
  printf 'nothing to see\n' > README.md
  git add -A && git commit -qm bare
)
run_gate "$D" >/dev/null 2>&1; assert "1" "$?" "no version source: refused"
grep -q 'cannot determine the version' "$WORK/gate.err" \
  && ok "no version source: says why" \
  || bad "no version source: says why" "no such message on stderr"

# A plain Node package is a profile now, not a refusal: only the three-file
# version cross-check was ever Obsidian-specific.
D="$(make_repo 1.0.0)"; rm "$D/manifest.json"; git -C "$D" commit -qam "not a plugin"
git -C "$D" tag 0.9.0
OUT="$(run_gate "$D")"
printf '%s' "$OUT" | head -1 | grep -q 'Node' \
  && ok "no manifest.json: profiled as Node, not refused" \
  || bad "no manifest.json: profiled as Node, not refused" "header: $(printf '%s' "$OUT" | head -1)"
assert "PASS" "$(row 10 "$OUT")" "Node profile: version consistency reads package.json alone"

echo
echo "gate: Taskfile profile, no build, no CHANGELOG, v-prefixed tags"

# This fixture is cx: a tool whose version lives in its own source, a Taskfile
# with a test target and no build target, `v`-prefixed tags, and no CHANGELOG.
# It is the shape the cx v2.0.0 release actually had, and reproducing it is the
# point of generalising the gate at all.
make_task_repo() { # $1 = version the tool reports
  local dir; dir="$(mktemp -d "$WORK/task.XXXXXX")"
  (
    cd "$dir" || exit 1
    git init -q .
    git config user.email t@example.com
    git config user.name Test
    printf 'version: "3"\n\ntasks:\n  test:\n    cmds:\n      - "true"\n' > Taskfile.yml
    printf '#!/bin/sh\necho "fx %s"\n' "$1" > fx
    chmod +x fx
    printf 'VERSION_CMD="./fx"\nVERSION_FILES="fx:grep"\n' > .release-gate
    git add -A && git commit -qm "fixture $1"
  ) || exit 1
  echo "$dir"
}

# 6. The version the tool reports is the tag that already shipped. This is the
#    cx v2.0.0 mistake exactly: the source said 1.0.0 while a 2.0.0 tag was
#    about to be cut by hand, and nothing in the repo would have said so.
D="$(make_task_repo 1.0.0)"; git -C "$D" tag v1.0.0
OUT="$(run_gate "$D")"; CODE=$?
assert "INFO" "$(row 13 "$OUT")" "v-prefixed released version: check 13 INFO"
assert "3"    "$CODE"            "v-prefixed released version: exits 3 (NOT STARTED)"
printf '%s' "$OUT" | grep -q 'v1.0.0 is already released' \
  && ok "v-prefix carried into the tag name" \
  || bad "v-prefix carried into the tag name" "epilogue did not name v1.0.0"
assert "PASS" "$(row 10 "$OUT")" "grep spec finds the version in a source file"

# 7. Bumped past the tag: proceed, with the unprofiled rows named as skipped
#    rather than quietly counted as passes.
D="$(make_task_repo 1.1.0)"; git -C "$D" tag v1.0.0
OUT="$(run_gate "$D")"; CODE=$?
assert "PASS" "$(row 13 "$OUT")" "bumped: check 13 PASS on v1.1.0"
[ "$CODE" != "3" ] && ok "bumped: not NOT STARTED" || bad "bumped: not NOT STARTED" "got exit 3"
assert "SKIP" "$(row 1 "$OUT")"  "no dependency manifest: check 1 SKIP"
assert "SKIP" "$(row 6 "$OUT")"  "no build target: check 6 SKIP"
assert "SKIP" "$(row 9 "$OUT")"  "no audit command: check 9 SKIP"
assert "SKIP" "$(row 11 "$OUT")" "no CHANGELOG.md: check 11 SKIP, not FAIL"
assert "SKIP" "$(row 12 "$OUT")" "no workflows: check 12 SKIP, not WARN"
assert "SKIP" "$(row 16 "$OUT")" "no build: check 16 SKIP, not a second check 2"
printf '%s' "$OUT" | grep -q '^Skipped: ' \
  && ok "skips are named on the result line" \
  || bad "skips are named on the result line" "no Skipped: line"
printf '%s' "$OUT" | grep -qE 'Result: (READY|WARNINGS|BLOCKED).*skipped' \
  && ok "skip count reaches the result line" \
  || bad "skip count reaches the result line" "result: $(printf '%s' "$OUT" | grep '^Result:')"

# 8. A Taskfile with a test target supplies TEST_CMD. Without the task binary
#    the row would FAIL for an unrelated reason, so say so rather than assert.
if command -v task >/dev/null 2>&1; then
  assert "PASS" "$(row 7 "$OUT")" "Taskfile test target runs as check 7"
else
  echo "  skip Taskfile test target runs as check 7 (no task binary)"
fi

# 9. Build and test detection are independent. A static site has `task build`
#    and no test target, and a package.json carrying neither script; nesting the
#    build lookup inside the test lookup told it to run `bun run build`, which
#    fails for a reason that has nothing to do with release readiness.
D="$(mktemp -d "$WORK/site.XXXXXX")"
(
  cd "$D" || exit 1
  git init -q .
  git config user.email t@example.com
  git config user.name Test
  printf '{"name":"site","version":"1.1.0"}\n' > package.json
  printf 'version: "3"\n\ntasks:\n  build:\n    cmds:\n      - "true"\n' > Taskfile.yml
  git add -A && git commit -qm site
)
git -C "$D" tag 1.0.0
OUT="$(run_gate "$D")"
assert "SKIP" "$(row 7 "$OUT")" "no test anywhere: check 7 SKIP, not a bun failure"
DET6="$(detail 6 "$OUT")"
if command -v task >/dev/null 2>&1; then
  assert "PASS" "$(row 6 "$OUT")" "build target found without a test target"
  printf '%s' "$DET6" | grep -q 'task build' \
    && ok "build row names task build, not bun run build" \
    || bad "build row names task build, not bun run build" "details: $DET6"
else
  echo "  skip build target found without a test target (no task binary)"
fi
printf '%s' "$OUT" | grep -q "gap in the profile" \
  && ok "a skipped test row is called a profile gap" \
  || bad "a skipped test row is called a profile gap" "no gap note on the result line"


echo
echo "ship: release plan"

# The plan reads the same profile.sh the gate does, so a repo the gate profiles
# one way cannot be shipped another. These lock the fork that changes the shape
# of the release: whether pushing the tag creates the GitHub release, or whether
# ship has to.
D="$(make_repo 1.0.0)"; git -C "$D" tag 0.9.0
assert "workflow"     "$(plan release_mode "$D" 1.0.0)"          "plugin: release.yml means workflow mode"
assert "release.yml"  "$(plan release_workflow "$D" 1.0.0)"      "plugin: names the workflow to poll"
assert "package.json" "$(plan primary_version_file "$D" 1.0.0)"  "plugin: package.json is the primary, not manifest.json"
assert "manifest.json versions.json" "$(plan derived_version_files "$D" 1.0.0)" "plugin: the other two are derived"
[ -n "$(plan version_sync_cmd "$D" 1.0.0)" ] \
  && ok "plugin: a sync command regenerates them" \
  || bad "plugin: a sync command regenerates them" "version_sync_cmd empty"
assert "1.0.0"        "$(plan tag "$D" 1.0.0)"                   "plugin: bare tag, no v prefix"

D="$(make_task_repo 1.1.0)"; git -C "$D" tag v1.0.0
assert "gh"     "$(plan release_mode "$D" 1.1.0)"           "no workflow means ship creates the release"
assert ""       "$(plan release_workflow "$D" 1.1.0)"       "gh mode names no workflow"
assert "fx"     "$(plan primary_version_file "$D" 1.1.0)"   "primary is the file the version lives in"
assert ""       "$(plan derived_version_files "$D" 1.1.0)"  "nothing derived from it"
assert "v1.1.0" "$(plan tag "$D" 1.1.0)"                    "v prefix carried from the repo's own tags"
assert "absent" "$(plan changelog "$D" 1.1.0)"              "a missing CHANGELOG is reported, not assumed"
assert "release/1.1.0" "$(plan prep_branch "$D" 1.1.0)"     "prep branch derives from the TARGET version"

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
echo "pipeline: gate approves, ship extracts"

# The two scripts' only interesting property is that they agree, and nothing above
# tests that: the sections are split by script, so the extractor is never run against
# a repo the gate has just approved. Check 11 accepts "## <version>" followed by a
# space or end-of-line; whatever it passes, the extractor must handle. Otherwise the
# divergence surfaces at ship Phase 8 — after the tag is pushed and the GitHub
# release created.
D="$(make_repo 3.0.0)"
printf '# Changelog\n\n## 3.0.0 - 2026-01-01\n\n- dated heading\n' > "$D/CHANGELOG.md"
git -C "$D" commit -qam "dated heading"
git -C "$D" tag 2.9.0
OUT="$(run_gate "$D" 3.0.0)"
assert "PASS" "$(row 11 "$OUT")" "gate accepts the dated heading"
( cd "$D" && "$EXTRACT" 3.0.0 ) | grep -q 'dated heading' \
  && ok "extractor accepts what the gate accepted" \
  || bad "extractor accepts what the gate accepted" "gate passed, extractor found nothing"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
