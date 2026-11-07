#!/usr/bin/env bash
# shellcheck disable=SC2016  # the commands under test are literal strings, not expansions
# Fixture tests for hooks/block-equals-word.sh.
#
# The tool shell is zsh, and an unquoted word beginning with `=` is `=cmd`
# expansion there: `echo ==` fails with "= not found" and aborts the command.
# The hook must block that and nothing else, so the passing cases are the
# shapes these sessions actually run: heredocs full of Python `==`, quoted
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

echo "blocked"
check "echo ==" "$(status 'echo ==')" "2"
check "a separator after a command" "$(status 'go test ./...; echo =====; ls')" "2"
check "== in a single-bracket test" "$(status '[ "$a" == "$b" ] && echo same')" "2"
check "=word as an argument" "$(status 'print =ls')" "2"

echo "allowed"
check "an assignment" "$(status 'x=1 y=2 env')" "0"
check "a flag with a value" "$(status 'git log --format=%h -n1')" "0"
check "== inside double quotes" "$(status 'echo "a == b"')" "0"
check "== inside single quotes" "$(status "awk '\$1 == \"x\"' f")" "0"
check "== inside [[ ]]" "$(status '[[ $a == b ]] && echo y')" "0"
check "== inside (( ))" "$(status '(( n == 2 )) && echo two')" "0"
check "a lone = in test" "$(status '[ a = b ] && echo y')" "0"
check "== in a comment" "$(status 'ls # a == b')" "0"
check "== in a heredoc body" "$(status "$(printf 'cat <<%sPYEOF%s\nif a == b:\n    pass\nPYEOF\necho done' "'" "'")")" "0"
check "== in a multi-line double-quoted string" "$(status "$(printf 'gh issue comment 1 --body "one\nx == y\n"')")" "0"
check "an empty command" "$(status '')" "0"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
