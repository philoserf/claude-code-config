#!/usr/bin/env bash
# shellcheck disable=SC2016  # the commands under test are literal strings, not expansions
# Fixture tests for hooks/block-equals-word.sh.
#
# The tool shell is zsh, and an unquoted word beginning with `=` is `=cmd`
# expansion there: `echo ==` fails with "= not found" and aborts the command.
# The hook must quote that word where quoting prints the same thing, block it
# where it cannot tell, and leave everything else alone, so the passing cases are
# the shapes these sessions actually run: heredocs full of Python `==`, quoted
# strings, `[[ ]]` tests, assignments and `--flag=value`.
#
# Usage: tests/block-equals-word.sh

set -uo pipefail

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (want '$3', got '$2')"; fi; }

HOOK="$(cd "$(dirname "$0")/.." && pwd)/hooks/block-equals-word.sh"
status() { jq -n --arg c "$1" '{tool_input: {command: $c}}' | bash "$HOOK" >/dev/null 2>&1; echo $?; }
# What the command becomes: the rewritten command, or "unchanged" with no output.
becomes() {
  local out
  out=$(jq -n --arg c "$1" '{tool_input: {command: $c, description: "d"}}' | bash "$HOOK" 2>/dev/null)
  [ -z "$out" ] && { echo unchanged; return; }
  printf '%s' "$out" | jq -r '.hookSpecificOutput.updatedInput | "\(.command)|\(.description)"'
}

echo "quoted in place"
check "echo ==" "$(becomes 'echo ==')" 'echo "=="|d'
check "a separator after a command" "$(becomes 'go test ./...; echo =====; ls')" 'go test ./...; echo "====="; ls|d'
check "== in a single-bracket test" "$(becomes '[ "$a" == "$b" ] && echo same')" '[ "$a" "==" "$b" ] && echo same|d'
check "every occurrence" "$(becomes 'echo ===; echo ===')" 'echo "==="; echo "==="|d'
check "a rewrite exits 0" "$(status 'echo ==')" "0"

echo "blocked"
check "the word also inside a quoted string" "$(status 'echo ====; echo "a ==== b"')" "2"
check "the word also in a comment" "$(status 'echo ===  # ===')" "2"
check "a word carrying an expansion" "$(status 'echo =$x')" "2"

echo "allowed"
check "an assignment" "$(becomes 'x=1 y=2 env')" "unchanged"
check "a flag with a value" "$(becomes 'git log --format=%h -n1')" "unchanged"
check "== inside double quotes" "$(becomes 'echo "a == b"')" "unchanged"
check "== inside single quotes" "$(becomes "awk '\$1 == \"x\"' f")" "unchanged"
check "== inside [[ ]]" "$(becomes '[[ $a == b ]] && echo y')" "unchanged"
check "== inside (( ))" "$(becomes '(( n == 2 )) && echo two')" "unchanged"
check "a lone = in test" "$(becomes '[ a = b ] && echo y')" "unchanged"
check "== in a comment" "$(becomes 'ls # a == b')" "unchanged"
check "== in a heredoc body" "$(becomes "$(printf 'cat <<%sPYEOF%s\nif a == b:\n    pass\nPYEOF\necho done' "'" "'")")" "unchanged"
check "== in a multi-line double-quoted string" "$(becomes "$(printf 'gh issue comment 1 --body "one\nx == y\n"')")" "unchanged"
check "an empty command" "$(becomes '')" "unchanged"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
