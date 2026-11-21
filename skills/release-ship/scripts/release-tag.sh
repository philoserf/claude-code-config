#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Tags the merged prep commit for VERSION, or refuses. Run it on the default
# branch after the prep PR has merged and been pulled.
#
# It tags only when all of these hold:
#   1. The gate (release-check.sh VERSION) exits 0 on HEAD.
#   2. The prep merge for the plan's prep_branch is found.
#   3. That merge is HEAD, which is the commit the gate checked.
#
# Usage: release-tag.sh VERSION
#
# Exit 0: the annotated tag was created (not pushed).
# Exit 1: no tag was created; the output says why and what to ask the user.
#
# RELEASE_CHECK overrides the gate command. It exists for the fixture tests,
# which can never pass the real gate.

set -uo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  echo "Usage: release-tag.sh VERSION" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="${RELEASE_CHECK:-$SCRIPT_DIR/../../release-gate/scripts/release-check.sh}"

"$GATE" "$VERSION"
GATE_RC=$?
if [ "$GATE_RC" -ne 0 ]; then
  echo
  echo "Not tagging: the gate exited $GATE_RC, and only 0 proceeds."
  echo "Name the rows above that block, and stop."
  exit 1
fi

PLAN="$("$SCRIPT_DIR/release-plan.sh" "$VERSION")" || exit 1
plan() { printf '%s\n' "$PLAN" | sed -n "s/^$1=//p"; }
TAG="$(plan tag)"
PREP_BRANCH="$(plan prep_branch)"

HEAD_SHA="$(git rev-parse HEAD)"
MERGED_SHA=""
# On GitHub the lookup keys on the prep branch, not on a commit message: a human
# can reword the subject in the squash-merge dialog, but the branch name survives
# squash, rebase and subject rewrites. `// empty` turns "no merged PR" into an
# empty string rather than the word null.
# Off GitHub the subject is all git keeps of a squash, and it survives a rebase
# or a fast-forward too. If it was reworded, nothing matches and this stops,
# which is the safe way to fail. Dots in the version are escaped so 1.1.0
# cannot match 1x1y0.
SUBJECT_RE="^chore: prepare release ${VERSION//./\\.}( \\(#[0-9]+\\))?\$"
if [ "$(plan is_github)" = "1" ]; then
  MERGED_SHA="$(gh pr list --state merged --head "$PREP_BRANCH" --json mergeCommit |
    jq -r '.[0].mergeCommit.oid // empty')" || exit 1
elif git log -1 --format=%s HEAD | grep -qE "$SUBJECT_RE"; then
  MERGED_SHA="$HEAD_SHA"
else
  # A merge commit whose second parent is the pushed prep branch. Both sides must
  # resolve: with no merge and no pushed branch they are both empty, and equal.
  SECOND="$(git rev-parse -q --verify 'HEAD^2' 2>/dev/null)"
  PUSHED="$(git rev-parse -q --verify "refs/remotes/origin/$PREP_BRANCH" 2>/dev/null)"
  if [ -n "$SECOND" ] && [ "$SECOND" = "$PUSHED" ]; then
    MERGED_SHA="$HEAD_SHA"
  fi
fi

if [ -z "$MERGED_SHA" ]; then
  echo "No prep merge found for $PREP_BRANCH."
  echo "Look at 'git log --oneline -5' and ask which commit is the prep merge."
  exit 1
fi

# The gate ran against HEAD, and the lookup above resolved a commit on its own.
# Nothing makes them the same commit, and when they differ the tag would publish
# a tree no gate saw. Neither answer is automatically right, so stop and ask.
if [ "$MERGED_SHA" != "$HEAD_SHA" ]; then
  echo "Prep merge is not HEAD — the gate did not check the commit this would tag."
  echo "  prep merge: $MERGED_SHA"
  echo "  HEAD:       $HEAD_SHA"
  echo "Commits that landed after the prep merge:"
  git log --oneline "$MERGED_SHA..HEAD"
  echo "Stop. Ask which commit to tag; do not choose one."
  exit 1
fi

git tag -a "$TAG" -m "Release $VERSION" "$MERGED_SHA" || exit 1
echo "Tagged $TAG at $MERGED_SHA (not pushed)."
