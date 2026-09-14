#!/usr/bin/env bash
# Project profile resolution. **Sourced, not executed** — by release-check.sh
# (the gate) and release-plan.sh (the ship). One definition so the two cannot
# disagree about what kind of repo they are standing in.
#
# Contract for the caller: `set -uo pipefail` is in effect, the working
# directory is the repo root, and VERSION_ARG holds the target version or is
# empty. On return the following are set:
#
#   PROFILE           name for the header line
#   VERSION           the version under test — the argument, else what
#                     VERSION_CMD reports
#   VERSION_CMD       prints the project's version; the first semver in its
#                     stdout is taken. There is no fallback: a project whose
#                     version this cannot find is a setup gap, and defaulting to
#                     the last tag would make the gate's tag check
#                     self-satisfying and wedge every repo at NOT STARTED.
#   VERSION_FILES     space-separated `path[:spec]` entries. spec is one of
#                     `jq:<filter>`, `jqhas`, or `grep`; the default is
#                     jq:.version for .json and grep for anything else.
#
#                     **The first entry is the primary source** — the file a
#                     human edits to change the version. Later entries are
#                     derived files or cross-checks, brought into line by
#                     VERSION_SYNC_CMD. The gate verifies they all agree; the
#                     ship edits the first and regenerates the rest. Both depend
#                     on that ordering, so keep the primary first when writing a
#                     .release-gate.
#   VERSION_SYNC_CMD  regenerates the derived version files after the primary
#                     edit. Empty where there are none.
#   DEPS_CMD          stdout: one line per outdated dependency, empty when
#                     current. Nonzero exit means the check could not run, so a
#                     profile that pipes through grep must end with `|| true`.
#   BUILD_CMD         nonzero exit fails the build. Empty means no build step.
#   TEST_CMD          nonzero exit fails the tests.
#   AUDIT_CMD         nonzero exit means findings.
#   RELEASE_MODE      `workflow` — pushing the tag triggers a workflow that
#                     creates the GitHub release — or `gh`, where the release is
#                     created directly with `gh release create`.
#   RELEASE_WORKFLOW  that workflow's filename, in `workflow` mode.
#   PREP_BRANCH       branch name for the release prep PR.
#   TAG_PREFIX        "" or "v", from the most recent tag.
#   LAST_TAG          most recent tag reachable from HEAD, or empty.
#   TARGET_TAG        TAG_PREFIX + VERSION.
#
# Anything left empty makes its check SKIP rather than PASS. A repo's own
# `.release-gate` file, sourced from the root, overrides everything detected
# here — it is code from the repo, executed, which is no different in kind from
# the build and test commands these scripts already run out of that repo.

# Everything below is set for a consumer that sources this file, so shellcheck
# cannot see the use.
# shellcheck disable=SC2034

PROFILE=""
VERSION_CMD=""
VERSION_FILES=""
VERSION_SYNC_CMD=""
DEPS_CMD=""
BUILD_CMD=""
TEST_CMD=""
AUDIT_CMD=""
RELEASE_MODE=""
RELEASE_WORKFLOW=""
PREP_BRANCH=""
TAG_PREFIX=""
TAG_PREFIX_SET=0

has_task() {
  [ -f Taskfile.yml ] || [ -f Taskfile.yaml ] || [ -f taskfile.yml ] || return 1
  grep -qE "^  $1:" Taskfile.yml Taskfile.yaml taskfile.yml 2>/dev/null
}

# --- Detection. Later blocks refine earlier ones; Taskfile wins on build/test
# --- because that is what the fleet actually standardises on.
if jq -e '.minAppVersion' manifest.json >/dev/null 2>&1 && [ -f package.json ]; then
  PROFILE="Obsidian plugin"
  VERSION_CMD="jq -r .version package.json"
  # package.json first: it is the file edited by hand, and version-bump.ts
  # regenerates the other two from it.
  VERSION_FILES="package.json:jq:.version manifest.json:jq:.version versions.json:jqhas"
  VERSION_SYNC_CMD='npm_package_version="$VERSION" bun run version'
  DEPS_CMD='out=$(bun outdated 2>&1) || exit 1; printf "%s\n" "$out" | grep -E "^\| " | grep -v "| Package" | grep -E "^\| [^-]" || true'
  BUILD_CMD="bun run build"
  TEST_CMD="bun test"
  AUDIT_CMD="bun audit --audit-level=critical"
elif [ -f package.json ]; then
  PROFILE="Node"
  VERSION_CMD="jq -r .version package.json"
  VERSION_FILES="package.json:jq:.version"
  DEPS_CMD='out=$(bun outdated 2>&1) || exit 1; printf "%s\n" "$out" | grep -E "^\| " | grep -v "| Package" | grep -E "^\| [^-]" || true'
  AUDIT_CMD="bun audit --audit-level=critical"
  # Gated on the script existing, unlike the plugin branch above. Every plugin in
  # the fleet has both; a plain package.json may have neither, and `bun run build`
  # against a missing script fails the build row for a reason that has nothing to
  # do with release readiness.
  jq -e '.scripts.build' package.json >/dev/null 2>&1 && BUILD_CMD="bun run build"
  jq -e '.scripts.test' package.json >/dev/null 2>&1 && TEST_CMD="bun test"
fi

if [ -f go.mod ]; then
  PROFILE="${PROFILE:+$PROFILE + }Go"
  # `go list -m -u all` prints every module, outdated or not. The template
  # emits a line only when an update exists, which is the contract above.
  DEPS_CMD='out=$(go list -m -u -f "{{if .Update}}{{.Path}} {{.Version}} -> {{.Update.Version}}{{end}}" all 2>&1) || exit 1; printf "%s\n" "$out" | grep -v "^$" || true'
  BUILD_CMD="${BUILD_CMD:-go build ./...}"
  TEST_CMD="${TEST_CMD:-go test ./...}"
  AUDIT_CMD="${AUDIT_CMD:-govulncheck ./...}"
fi

# Independently: a repo can have a build target and no test target, or the
# reverse. Nesting one inside the other left a Hugo site with `task build` being
# told to run `bun run build`.
if has_task test || has_task build; then
  PROFILE="${PROFILE:+$PROFILE + }Taskfile"
  has_task test && TEST_CMD="task test"
  has_task build && BUILD_CMD="task build"
fi

# How the GitHub release comes into being. A workflow that fires on tag push
# creates the release itself, assets and all, and the ship waits for it; with no
# such workflow the ship creates the release directly. Getting this wrong in
# either direction is visible: waiting for a run that will never appear, or
# creating a release the workflow is about to create again.
if [ -f .github/workflows/release.yml ]; then
  RELEASE_MODE="workflow"
  RELEASE_WORKFLOW="release.yml"
else
  RELEASE_MODE="gh"
fi

PROFILE="${PROFILE:-generic}"

# Repo-local overrides win over everything detected above.
if [ -f .release-gate ]; then
  # shellcheck disable=SC1091  # repo-local, not resolvable at lint time
  . ./.release-gate
  PROFILE="$PROFILE (.release-gate)"
  [ -n "${TAG_PREFIX:-}" ] && TAG_PREFIX_SET=1
fi

# --- Version under test -----------------------------------------------------
VERSION="${VERSION_ARG:-}"
VERSION="${VERSION#v}"
if [ -z "$VERSION" ]; then
  if [ -z "$VERSION_CMD" ]; then
    echo "Error: cannot determine the version — no version source for this repo." >&2
    echo "Pass one as an argument, or set VERSION_CMD in a .release-gate file at" >&2
    echo "the repo root (see the header of skills/release-gate/scripts/profile.sh)." >&2
    exit 1
  fi
  if ! VERSION_OUT="$(bash -c "$VERSION_CMD" 2>&1)"; then
    echo "Error: VERSION_CMD failed: $VERSION_CMD" >&2
    printf '%s\n' "$VERSION_OUT" >&2
    exit 1
  fi
  VERSION="$(printf '%s' "$VERSION_OUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[A-Za-z0-9.+-]*' | head -1)"
  if [ -z "$VERSION" ]; then
    echo "Error: VERSION_CMD produced no semver: $VERSION_CMD" >&2
    echo "Got: $VERSION_OUT" >&2
    exit 1
  fi
fi

# Tags are the only place the prefix convention is recorded, so this repo's own
# most recent tag is the authority unless .release-gate says otherwise.
LAST_TAG=""
LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null)" || LAST_TAG=""
if [ "$TAG_PREFIX_SET" = "0" ] && [[ "$LAST_TAG" =~ ^v[0-9] ]]; then
  TAG_PREFIX="v"
fi
TARGET_TAG="${TAG_PREFIX}${VERSION}"
PREP_BRANCH="${PREP_BRANCH:-release/$VERSION}"
