#!/usr/bin/env bash
# Fixture tests for the part of pr-cycle.sh that can be exercised without a live
# PR: the local gate.
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

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
