#!/usr/bin/env bash
# Fixture tests for the parts of pr-cycle.sh and milestone-graph.sh that can be
# exercised without a live PR: the numeric check-count guard, the merge-method
# fallback, and the topological order.
#
# The guard tests matter more than they look. `gh pr checks` exits 1 both for
# "no checks reported" and for a real failure, and BSD `grep -qv` exits 0 on
# empty input — so the two obvious spellings of "are there checks yet" both
# report success when the API returns nothing. These assert the numeric form
# rejects every shape of empty the API can produce.
#
# Usage: tests/pr-cycle.sh

set -uo pipefail

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (want '$3', got '$2')"; fi; }

# The count guard, lifted verbatim from cmd_wait.
count_ok() {
  local n="${1:-}"
  case "${n:-}" in ''|*[!0-9]*) n=0 ;; esac
  [ "$n" -gt 0 ] && echo yes || echo no
}

echo "check-count guard"
check "empty string is not a count"      "$(count_ok '')"     "no"
check "unset is not a count"             "$(count_ok)"        "no"
check "whitespace is not a count"        "$(count_ok '   ')"  "no"
check "gh error text is not a count"     "$(count_ok 'null')" "no"
check "zero is not a count"              "$(count_ok '0')"    "no"
check "one is a count"                   "$(count_ok '1')"    "yes"
check "many is a count"                  "$(count_ok '12')"   "yes"

# The trap the numeric guard replaced. Whether it fires depends on which grep
# answers, so assert the guard is right under BOTH rather than asserting one
# grep's behaviour and calling it the rule.
echo "grep -qv trap (documents why the guard is numeric)"
for g in /usr/bin/grep "$(command -v ugrep || true)"; do
  [ -n "$g" ] && [ -x "$g" ] || continue
  if printf '' | "$g" -qvx 0 2>/dev/null; then
    ok "$(basename "$g"): empty input PASSES 'grep -qvx 0' — the trap is live here"
  else
    ok "$(basename "$g"): empty input fails 'grep -qvx 0' — the trap is dormant here"
  fi
done
check "the numeric guard is unmoved by either" "$(count_ok '')" "no"

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
