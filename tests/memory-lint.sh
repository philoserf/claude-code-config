#!/usr/bin/env bash
# Fixture tests for bin/memory-lint.
#
# Each case builds a throwaway memory folder, runs the lint on it, and checks the
# exit status and the finding it prints. The clean fixture is the shape a real
# memory folder has: frontmatter with `name:`, an index line per file, and a
# [[link]] between two memories.
#
# Usage: tests/memory-lint.sh

set -uo pipefail

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (want '$3', got '$2')"; fi; }

LINT="$(cd "$(dirname "$0")/.." && pwd)/bin/memory-lint"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

memory() { # dir file name body
  mkdir -p "$1"
  printf -- '---\nname: %s\ndescription: d\nmetadata:\n  type: feedback\n---\n\n%s\n' "$3" "$4" > "$1/$2"
}
# A clean two-memory folder to start each case from.
fixture() {
  rm -rf "$TMP/m"
  memory "$TMP/m" a.md alpha "Links to [[beta]]."
  memory "$TMP/m" b.md beta "Plain fact."
  printf -- '- [A](a.md) — a\n- [B](b.md) — b\n' > "$TMP/m/MEMORY.md"
}
status() { bash "$LINT" "$TMP/m" >/dev/null 2>&1; echo $?; }
says()   { local out; out=$(bash "$LINT" "$TMP/m" 2>&1); grep -qF -- "$1" <<<"$out" && echo yes || echo no; }

echo "clean"
fixture
check "a clean folder passes" "$(status)" "0"
memory "$TMP/m" c.md "gamma" "Quoted name."
sed -i '' 's/^name: gamma$/name: "gamma"/' "$TMP/m/c.md"
printf -- '- [C](c.md) — c\n' >> "$TMP/m/MEMORY.md"
memory "$TMP/m" d.md delta "See [[gamma|the quoted one]]."
printf -- '- [D](d.md) — d\n' >> "$TMP/m/MEMORY.md"
check "a quoted name and an aliased link resolve" "$(status)" "0"

echo "index"
fixture
printf -- '- [Gone](gone.md) — g\n' >> "$TMP/m/MEMORY.md"
check "an index line with no file fails" "$(status)" "1"
check "it names the missing file" "$(says 'indexes missing file gone.md')" "yes"
fixture
memory "$TMP/m" c.md gamma "Unlisted."
check "a file with no index line fails" "$(status)" "1"
check "it names the unlisted file" "$(says 'c.md: not listed in MEMORY.md')" "yes"
fixture
rm "$TMP/m/MEMORY.md"
check "a folder with no index fails" "$(says 'no MEMORY.md index')" "yes"

echo "links"
fixture
memory "$TMP/m" a.md alpha "Links to [[beta]] and [[gone]]."
check "a dead link fails" "$(status)" "1"
check "it names the dead link" "$(says 'dead link [[gone]]')" "yes"
check "the live link is not reported" "$(says '[[beta]]')" "no"
# shellcheck disable=SC2016  # the backticks are literal markdown, not expansions
memory "$TMP/m" a.md alpha 'Links to [[beta]]; write `See also: [[A]], [[B]]` at the end.'
check "a link inside inline code is an example, not a link" "$(status)" "0"

echo "retired terms"
fixture
memory "$TMP/m" b.md beta "Update NEXT.md after each step."
check "a retired term fails" "$(status)" "1"
check "it names the term and line" "$(says "b.md:8: mentions retired term 'NEXT.md'")" "yes"
memory "$TMP/m" b.md beta "We moved off Prettier."
check "terms match case-insensitively" "$(says "retired term 'prettier'")" "yes"
memory "$TMP/m" b.md beta "Showboat is gone. <!-- memory-lint allow: showboat -->"
check "an allowed term passes" "$(status)" "0"
memory "$TMP/m" b.md beta "Showboat and prettier are gone. <!-- memory-lint allow: showboat -->"
check "the allow covers only the terms it names" "$(says "retired term 'prettier'")" "yes"

echo "usage"
check "an empty folder passes" "$(mkdir -p "$TMP/empty"; bash "$LINT" "$TMP/empty" >/dev/null 2>&1; echo $?)" "0"
check "a missing folder is a usage error" "$(bash "$LINT" "$TMP/nope" >/dev/null 2>&1; echo $?)" "2"
check "an unknown option is a usage error" "$(bash "$LINT" --bogus >/dev/null 2>&1; echo $?)" "2"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
