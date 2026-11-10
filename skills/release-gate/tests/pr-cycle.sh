#!/usr/bin/env bash
# Fixture tests for the part of pr-cycle.sh that can be exercised without a live
# PR: the local gate, which gate it runs when given none, and the review ship needs.
#
# The gate is the only check before a merge, so its refusals matter most: a
# failing command, a tree dirty before the gate (it would test work that is not
# pushed), and a tree the gate leaves dirty (a formatter rewrote files).
#
# Usage: tests/pr-cycle.sh

set -uo pipefail

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (want '$3', got '$2')"; fi; }

echo "local gate"
CYCLE="$(cd "$(dirname "$0")/.." && pwd)/scripts/pr-cycle.sh"
R="$(mktemp -d)"
git -C "$R" init -q && git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
gate() { (cd "$R" && "$CYCLE" gate "$1" >/dev/null 2>&1); echo $?; }
check "a passing gate exits 0"              "$(gate true)"            "0"
check "a failing gate exits 3"              "$(gate false)"           "3"
check "a gate that dirties the tree exits 3" "$(gate 'touch fmt.txt')" "3"
check "a dirty tree refuses to gate (1)"    "$(gate true)"            "1"
rm -rf "$R"

# With no gate argument the gate is profile.sh's GATE_CMD. The Taskfile's
# `check` fails, so only the .release-gate override can make this pass.
echo "gate from the profile"
R="$(mktemp -d)"
git -C "$R" init -q
printf 'version: "3"\ntasks:\n  check:\n    cmds:\n      - "false"\n' >"$R/Taskfile.yml"
echo 'GATE_CMD="true"' >"$R/.release-gate"
git -C "$R" add -A && git -C "$R" -c user.name=t -c user.email=t@t commit -q -m init
check "no argument runs the .release-gate override" "$(gate '')" "0"
rm -rf "$R"

R="$(mktemp -d)"
git -C "$R" init -q && git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
check "no argument and no gate refuses (1)" "$(gate '')" "1"
rm -rf "$R"

# The files a branch adds against its base. A rename and an edit are not
# additions; a new file is, wherever it sits.
echo "added files"
R="$(mktemp -d)"
git -C "$R" init -q -b main
echo a >"$R/a.txt" && echo e >"$R/e.txt"
git -C "$R" add -A && git -C "$R" -c user.name=t -c user.email=t@t commit -q -m init
git -C "$R" checkout -q -b work
git -C "$R" mv a.txt c.txt && echo more >>"$R/e.txt"
mkdir "$R/docs" && echo stray >"$R/docs/stray.rows"
git -C "$R" add -A && git -C "$R" -c user.name=t -c user.email=t@t commit -q -m work
added() { (cd "$R" && PR_BASE=main "$CYCLE" added "$1" 2>/dev/null); }
check "a new file is listed, a rename and an edit are not" "$(added work)" "docs/stray.rows"
git -C "$R" checkout -q -b quiet main
git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m nothing
check "a branch that adds nothing lists nothing" "$(added quiet)" ""
rm -rf "$R"

# ship opens and merges in one go, so it refuses a branch head nobody marked
# reviewed. Each case gates with a command that fails, so a ship that gets past
# the review check stops at the gate (3) and never reaches a push.
echo "review before ship"
R="$(mktemp -d)"
git -C "$R" init -q -b main
git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
git -C "$R" checkout -q -b work
B="$(mktemp)"
ship() { (cd "$R" && "$CYCLE" ship work t "$B" "$1" >/dev/null 2>&1); echo $?; }
check "an unreviewed branch is refused (1)" "$(ship 'touch ran')" "1"
check "and the gate never ran" "$([ -e "$R/ran" ] && echo ran || echo not)" "not"
(cd "$R" && "$CYCLE" reviewed work >/dev/null)
check "a reviewed head passes to the gate (3)" "$(ship false)" "3"
git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m more
check "a commit after the review is refused (1)" "$(ship false)" "1"
check "PR_CYCLE_UNREVIEWED passes to the gate (3)" \
  "$(cd "$R" && PR_CYCLE_UNREVIEWED="test" "$CYCLE" ship work t "$B" false >/dev/null 2>&1; echo $?)" "3"
rm -rf "$R" "$B"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
