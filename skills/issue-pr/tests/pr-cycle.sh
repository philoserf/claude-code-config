#!/usr/bin/env bash
# Fixture tests for the parts of pr-cycle.sh and milestone-graph.sh that can be
# exercised without a live PR: the local gate, the merge-method fallback, and
# the topological order.
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
echo "merge-method fallback"
pick() {
  case "$1" in
    squash) echo "--squash" ;; merge) echo "--merge" ;; rebase) echo "--rebase" ;; *) echo "--squash" ;;
  esac
}
check "squash allowed"        "$(pick squash)" "--squash"
check "merge-commit allowed"  "$(pick merge)"  "--merge"
check "rebase allowed"        "$(pick rebase)" "--rebase"
check "none reported"         "$(pick '')"     "--squash"

echo "topological order (the real v4.1.0 graph)"
E="$(mktemp)"; trap 'rm -f "$E"' EXIT
printf '62 64\n73 64\n62 65\n73 74\n67 75\n' > "$E"
for n in 61 62 64 65 67 68 69 71 72 73 74 75 78 79 80 81; do printf '%s %s\n' "$n" "$n" >> "$E"; done
ORDER="$(tsort "$E" | grep -x '[0-9]*')"
pos() { echo "$ORDER" | grep -n "^$1$" | cut -d: -f1; }
for pair in "62:64" "73:64" "62:65" "73:74" "67:75"; do
  a="${pair%%:*}"; b="${pair##*:}"
  if [ "$(pos "$a")" -lt "$(pos "$b")" ]; then ok "#$a before #$b"; else bad "#$a not before #$b"; fi
done
check "every issue is ordered" "$(echo "$ORDER" | grep -c .)" "16"

# tsort reports a cycle on stderr and still EXITS 0, printing what it could
# order. milestone-graph.sh therefore keys its warning on stderr being non-empty,
# never on the exit code; this pins that behaviour so the script's choice stays
# justified if a future coreutils changes it.
echo "cycle detection"
CE="$(mktemp)"
printf 'a b\nb a\n' | tsort >/dev/null 2>"$CE"; cyc_rc=$?
check "tsort exits 0 even on a cycle" "$cyc_rc" "0"
if [ -s "$CE" ]; then ok "tsort reports the cycle on stderr (what the script keys on)"
else bad "tsort said nothing on stderr; milestone-graph would miss the cycle"; fi
rm -f "$CE"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
