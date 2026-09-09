#!/usr/bin/env bash
# Prints the body of one version's CHANGELOG section — everything between
# "## <version>" and the next "## " heading, with surrounding blank lines
# trimmed. Used by obsidian-ship phase 8 to set GitHub release notes.
#
# Usage: extract-changelog.sh <VERSION> [CHANGELOG_PATH]
#   CHANGELOG_PATH defaults to CHANGELOG.md in the repo root.
#
# Exit 0: section found and printed.
# Exit 1: no such section, or the file is missing.
#
# A naive `sed -n '/^## X/,/^## /p'` is wrong twice over: it prints the heading
# line of the *next* release, and for the newest entry (no following heading) it
# runs to end of file only by accident of the range never closing. It also
# treats the version's dots as regex wildcards, so "1.2.3" matches "1a2b3".

set -uo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  echo "Usage: extract-changelog.sh <VERSION> [CHANGELOG_PATH]" >&2
  exit 1
fi

if [ -n "${2:-}" ]; then
  CHANGELOG="$2"
elif REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  CHANGELOG="$REPO_ROOT/CHANGELOG.md"
else
  CHANGELOG="CHANGELOG.md"
fi

if [ ! -f "$CHANGELOG" ]; then
  echo "No CHANGELOG at $CHANGELOG" >&2
  exit 1
fi

awk -v want="$VERSION" '
  # Match "## <version>" exactly — literal compare, not a regex, so dots in the
  # version cannot act as wildcards.
  /^## / {
    heading = substr($0, 4)
    sub(/[[:space:]]+$/, "", heading)
    if (inside) exit                 # next release heading ends the section
    if (heading == want) { inside = 1; next }
  }
  inside { body = body $0 "\n" }
  END {
    if (!inside) exit 1
    sub(/^\n+/, "", body)
    sub(/\n+$/, "", body)
    print body
  }
' "$CHANGELOG" || {
  echo "No '## $VERSION' section in $CHANGELOG" >&2
  exit 1
}
