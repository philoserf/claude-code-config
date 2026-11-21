#!/usr/bin/env bash
# Prints the body of one version's CHANGELOG section — everything between its
# heading and the next "## " heading, with surrounding blank lines trimmed. Used
# by release-ship phase 8 to set GitHub release notes.
#
# Usage: extract-changelog.sh <VERSION> [CHANGELOG_PATH]
#   CHANGELOG_PATH is the plan's `changelog=` value, which release-ship passes.
#   Without it, CHANGELOG.md at the repo root.
#
# Exit 0: section found and printed.
# Exit 1: no such section, or the file is missing.
#
# The heading grammar lives in lib/changelog.sh, which gate check 11 also reads,
# so a heading the gate has passed can never be one this script rejects.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../lib/changelog.sh
. "$SCRIPT_DIR/../../../lib/changelog.sh"

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

changelog_section "$VERSION" "$CHANGELOG" || {
  echo "No '## $VERSION' section in $CHANGELOG" >&2
  exit 1
}
