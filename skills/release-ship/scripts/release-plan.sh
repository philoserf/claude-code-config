#!/usr/bin/env bash
# Prints the resolved release plan for the repo you are standing in, as
# key=value lines. The ship skill reads these instead of branching in prose, so
# the two skills cannot disagree about what kind of repo this is: the plan comes
# from the same profile.sh the gate uses.
#
# Usage: release-plan.sh [VERSION]
#   VERSION defaults to the project's current version — pass the TARGET version
#   when preparing a release, since prep_branch and tag are derived from it.
#
# Exit 0: plan printed. Exit 1: no version source (same refusal as the gate).
#
# Keys whose value is empty are still printed, so a consumer can tell "no build
# step" from "key not supported by this version of the script".

set -uo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Error: run from inside a git repo" >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1

# shellcheck disable=SC2034  # consumed by profile.sh, sourced below
VERSION_ARG="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../release-gate/scripts/profile.sh
. "$SCRIPT_DIR/../../release-gate/scripts/profile.sh"

# The first VERSION_FILES entry is the file a human edits; the rest are derived
# from it by VERSION_SYNC_CMD. See profile.sh for why that ordering is a
# contract rather than a convenience.
PRIMARY=""
PRIMARY_SPEC=""
DERIVED=""
for entry in $VERSION_FILES; do
  vpath="${entry%%:*}"
  if [ "$entry" = "$vpath" ]; then
    case "$vpath" in
      *.json) vspec="jq:.version" ;;
      *) vspec="grep" ;;
    esac
  else
    vspec="${entry#*:}"
  fi
  if [ -z "$PRIMARY" ]; then
    PRIMARY="$vpath"
    PRIMARY_SPEC="$vspec"
  else
    DERIVED="${DERIVED:+$DERIVED }$vpath"
  fi
done

CHANGELOG="absent"
[ -f CHANGELOG.md ] && CHANGELOG="CHANGELOG.md"
WALKTHROUGH="absent"
[ -f WALKTHROUGH.md ] && WALKTHROUGH="WALKTHROUGH.md"

# What the prep commit is expected to touch, before the build runs. Anything
# else the build rewrites is identified by diffing the tree around it, not
# predicted here — a fixed file list is how a new build output (a source map, a
# second stylesheet) gets silently left out of the release.
EXPECTED="$PRIMARY${DERIVED:+ $DERIVED}"
[ "$CHANGELOG" != "absent" ] && EXPECTED="$EXPECTED CHANGELOG.md"
[ "$WALKTHROUGH" != "absent" ] && EXPECTED="$EXPECTED WALKTHROUGH.md"

printf 'profile=%s\n'              "$PROFILE"
printf 'version=%s\n'              "$VERSION"
printf 'tag=%s\n'                  "$TARGET_TAG"
printf 'last_tag=%s\n'             "$LAST_TAG"
printf 'prep_branch=%s\n'          "$PREP_BRANCH"
printf 'primary_version_file=%s\n' "$PRIMARY"
printf 'primary_version_spec=%s\n' "$PRIMARY_SPEC"
printf 'derived_version_files=%s\n' "$DERIVED"
printf 'version_sync_cmd=%s\n'     "$VERSION_SYNC_CMD"
printf 'build_cmd=%s\n'            "$BUILD_CMD"
printf 'changelog=%s\n'            "$CHANGELOG"
printf 'walkthrough=%s\n'          "$WALKTHROUGH"
printf 'expected_changes=%s\n'     "${EXPECTED# }"
printf 'release_mode=%s\n'         "$RELEASE_MODE"
printf 'release_workflow=%s\n'     "$RELEASE_WORKFLOW"
