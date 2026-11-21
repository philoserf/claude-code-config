#!/usr/bin/env bash
# Unit tests for lib/changelog.sh, the one CHANGELOG heading parser. The release
# gate's check 11, the profile's version fallback and the ship's release notes
# all read headings through it, so these cases are the whole heading grammar:
# what a release heading is, and which version it names.
#
# Usage: tests/changelog.sh

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib/changelog.sh
. "$ROOT/lib/changelog.sh"

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n         %s\n' "$1" "$2"; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "want '$3', got '$2'"; fi; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
CL="$TMP/CHANGELOG.md"

echo "changelog_section"

printf '# Changelog\n\n## Unreleased\n\n## 2.0.0\n\n\n### Fixed\n\n- a thing\n\n\n## 0.9.0\n\n- older\n' > "$CL"
check "newest section: body only, blank lines trimmed" \
  "$(changelog_section 2.0.0 "$CL")" "$(printf '### Fixed\n\n- a thing')"
check "last section runs to end of file" "$(changelog_section 0.9.0 "$CL")" "- older"
changelog_section 9.9.9 "$CL" >/dev/null; check "a missing version returns 1" "$?" "1"
changelog_section 2.0.0 "$TMP/nope.md" >/dev/null 2>&1; check "a missing file returns 1" "$?" "1"

# Every spelling in the fleet: bare, dated, a v prefix, Keep a Changelog's
# brackets, and both together.
for heading in '3.0.0' '3.0.0 - 2026-01-01' 'v3.0.0 — 2026-01-01' '[3.0.0] - 2026-01-01' '[v3.0.0]' '3.0.0  ' "3.0.0	2026-01-01" '[3.0.0](https://example.com/compare)'; do
  printf '# Changelog\n\n## %s\n\n- body\n' "$heading" > "$CL"
  check "'## $heading' is the 3.0.0 section" "$(changelog_section 3.0.0 "$CL")" "- body"
  check "'## $heading' accepts a v-prefixed request" "$(changelog_section v3.0.0 "$CL")" "- body"
done

printf '# Changelog\n\n## 2x0x0\n\n- wildcard bait\n' > "$CL"
changelog_section 2.0.0 "$CL" >/dev/null; check "dots are literal, not wildcards" "$?" "1"
printf '# Changelog\n\n## 1.2.30\n\n- near miss\n' > "$CL"
changelog_section 1.2.3 "$CL" >/dev/null; check "1.2.30 does not answer for 1.2.3" "$?" "1"
printf '# Changelog\n\n## 1.2.3-rc.1\n\n- prerelease\n' > "$CL"
changelog_section 1.2.3 "$CL" >/dev/null; check "1.2.3-rc.1 does not answer for 1.2.3" "$?" "1"
check "a prerelease names its own section" "$(changelog_section 1.2.3-rc.1 "$CL")" "- prerelease"

echo
echo "changelog_latest"

printf '# Changelog\n\n## Unreleased\n\n## [Big release]\n\n## v1.3.0 — 2026-02-01\n\n## 1.2.0\n' > "$CL"
check "the newest release heading, past non-release ones" "$(changelog_latest "$CL")" "1.3.0"
for heading in '3.0.0' '3.0.0 - 2026-01-01' 'v3.0.0 — 2026-01-01' '[3.0.0] - 2026-01-01' '[v3.0.0]'; do
  printf '# Changelog\n\n## %s\n\n- body\n' "$heading" > "$CL"
  check "'## $heading' names 3.0.0" "$(changelog_latest "$CL")" "3.0.0"
done
# Whatever latest names must have a section, or the fallback version would
# fail check 11. A heading whose version runs into punctuation names neither.
for heading in '1.2.3, 2026' '1.2.3:' '1.2.3—2026'; do
  printf '# Changelog\n\n## %s\n\n- body\n\n## 1.0.0\n' "$heading" > "$CL"
  check "'## $heading' is no release: latest skips it" "$(changelog_latest "$CL")" "1.0.0"
  changelog_section 1.2.3 "$CL" >/dev/null; check "'## $heading' is no 1.2.3 section" "$?" "1"
done
printf '# Changelog\n\n## Unreleased\n\n- nothing shipped\n' > "$CL"
changelog_latest "$CL" >/dev/null; check "no release heading returns 1" "$?" "1"
changelog_latest "$TMP/nope.md" >/dev/null 2>&1; check "a missing file returns 1" "$?" "1"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
