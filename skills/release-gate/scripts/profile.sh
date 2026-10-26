#!/usr/bin/env bash
# shellcheck disable=SC2016  # backticks and $ in single quotes are literal Markdown or bash -c text, on purpose
# Project profile resolution. **Sourced, not executed** — by release-check.sh
# (the gate), release-plan.sh (the ship) and pr-cycle.sh (the PR gate). One
# definition so they cannot disagree about what kind of repo they are standing in.
#
# Contract for the caller: `set -uo pipefail` is in effect and the working
# directory is the repo root. On return everything below is set except the
# three marked (after resolve_version). Those need a version, which a PR gate
# has no use for and a repo may lack, so they are resolved only on request:
# set VERSION_ARG to the target version or empty, then call resolve_version.
# It exits the caller when no version can be found.
#
#   PROFILE           name for the header line
#   VERSION           (after resolve_version) the version under test — the
#                     argument, else what VERSION_CMD reports
#   VERSION_CMD       prints the project's version; the first semver in its
#                     stdout is taken. Where no profile names one, the newest
#                     release heading in CHANGELOG.md is the version: it is
#                     written by hand at release prep, so it names what is being
#                     prepared, or what last shipped when nothing is. Past that
#                     there is no fallback: a project whose version this cannot
#                     find is a setup gap, and defaulting to the last tag would
#                     make the gate's tag check self-satisfying and wedge every
#                     repo at NOT STARTED.
#   VERSION_FILES     space-separated `path[:spec]` entries. spec is one of
#                     `jq:<filter>`, `jqhas`, or `grep`; the default is
#                     jq:.version for .json and grep for anything else. On
#                     return every entry is spelled out in full, so consumers
#                     split it and never apply the defaults themselves.
#
#                     **The first entry is the primary source** — the file a
#                     human edits to change the version. Later entries are
#                     derived files or cross-checks, brought into line by
#                     VERSION_SYNC_CMD. The gate verifies they all agree; the
#                     ship edits the first and regenerates the rest. Both depend
#                     on that ordering, so keep the primary first when writing a
#                     .release-gate.
#   VERSION_SYNC_CMD  regenerates the derived version files after the primary
#                     edit. Empty where there are none. Write `{version}` where
#                     the target version goes: it is substituted once, by
#                     resolve_version. A bare `$VERSION` would be
#                     dead text by the time a consumer ran the string, and the
#                     silent result is a derived file written with an empty
#                     version rather than a failure.
#   DEPS_CMD          stdout: one line per outdated dependency, empty when
#                     current. Nonzero exit means the check could not run, so a
#                     profile that pipes through grep must end with `|| true`.
#   INSTALL_CMD       installs dependencies from the lockfile, before anything
#                     that runs the project's code. It must not change tracked
#                     files. Nonzero exit fails the build. Empty means there is
#                     nothing to install.
#   BUILD_CMD         nonzero exit fails the build. Empty means no build step.
#   TEST_CMD          nonzero exit fails the tests.
#   AUDIT_CMD         nonzero exit means findings.
#   GATE_CMD          the repo's own gate, the check a PR passes before merge.
#                     Nonzero exit, or a tree left dirty, fails it.
#   IS_GITHUB         1 when origin is a github.com remote, else 0. The one
#                     host test: the gate's PR check and the ship's GitHub steps
#                     key on it, so moving a repo off GitHub changes nothing else.
#   RELEASE_MODE      `workflow` — pushing the tag triggers a workflow that
#                     creates the GitHub release — `gh`, where the release is
#                     created directly with `gh release create`, or `tag`, where
#                     the annotated tag and the CHANGELOG are the whole release
#                     and nothing is created on a forge.
#   RELEASE_ASSETS    files the GitHub release must carry, attached by ship in
#                     `gh` mode. Empty means a notes-only release. In `workflow`
#                     mode the workflow attaches its own.
#   DEPLOY_CMD        run by the ship after the tag is pushed, from the tagged
#                     commit. Empty means the release is not deployed.
#   PREP_BRANCH       (after resolve_version) release/VERSION, the prep PR branch.
#   TAG_PREFIX        "" or "v", from the most recent tag. A .release-gate may
#                     assign it, "" included.
#   LAST_TAG          most recent tag reachable from HEAD, or empty.
#   TARGET_TAG        (after resolve_version) TAG_PREFIX + VERSION.
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
INSTALL_CMD=""
BUILD_CMD=""
TEST_CMD=""
AUDIT_CMD=""
GATE_CMD=""
IS_GITHUB=0
RELEASE_MODE=""
RELEASE_ASSETS=""
DEPLOY_CMD=""

# The fleet uses `task`'s default name, Taskfile.yml, and only that.
has_task() {
  grep -qE "^  $1:" Taskfile.yml 2>/dev/null
}

# --- Detection. Later blocks refine earlier ones; Taskfile wins on build/test
# --- because that is what the fleet actually standardises on.
if jq -e '.minAppVersion' manifest.json >/dev/null 2>&1 && [ -f package.json ]; then
  PROFILE="Obsidian plugin"
  VERSION_CMD="jq -r .version package.json"
  # package.json first: it is the file edited by hand, and version-bump.ts
  # regenerates the other two from it.
  VERSION_FILES="package.json:jq:.version manifest.json:jq:.version versions.json:jqhas"
  VERSION_SYNC_CMD='npm_package_version="{version}" bun run version'
  DEPS_CMD='out=$(bun outdated 2>&1) || exit 1; printf "%s\n" "$out" | grep -E "^\| " | grep -v "| Package" | grep -E "^\| [^-]" || true'
  BUILD_CMD="bun run build"
  TEST_CMD="bun test"
  AUDIT_CMD="bun audit --audit-level=critical"
  # CI's steps, run locally. The frozen install is what the other rows miss:
  # it fails when bun.lock no longer matches package.json.
  GATE_CMD="bun install --frozen-lockfile && bun run build && bun test"
  # Obsidian installs a plugin from these assets on the release, not from the
  # repo, so a release without them is a broken release.
  RELEASE_ASSETS="main.js manifest.json"
  [ -f styles.css ] && RELEASE_ASSETS="$RELEASE_ASSETS styles.css"
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
  # Only the modules the build and tests link. `all` also names modules a
  # dependency's go.mod merely mentions, which `go mod tidy` will not bump, so
  # their WARN could never clear. The template emits a line only when an
  # update exists, which is the contract above.
  DEPS_CMD='mods=$(go list -deps -test -f "{{with .Module}}{{if not .Main}}{{.Path}}{{end}}{{end}}" ./... | sort -u); [ -n "$mods" ] || exit 0; out=$(go list -m -u -f "{{if .Update}}{{.Path}} {{.Version}} -> {{.Update.Version}}{{end}}" $mods 2>&1) || exit 1; printf "%s\n" "$out" | grep -v "^$" || true'
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

# The repo's gate: the local check that replaced CI. `check` where the Taskfile
# names one; otherwise a `default` target whose desc calls it the gate, as the Go
# repos do. Bare `task` is never assumed: in some repos the default target
# commits and pushes.
if has_task check; then
  GATE_CMD="task check"
elif awk '/^  default:/{f=1;next} f&&/^  [a-z]/{exit} f&&/desc:.*gate/{g=1} END{exit !g}' Taskfile.yml 2>/dev/null; then
  GATE_CMD="task"
fi

has_task deploy && DEPLOY_CMD="task deploy"

case "$(git remote get-url origin 2>/dev/null)" in
  *github.com[:/]*) IS_GITHUB=1 ;;
esac

# How the release comes into being. A workflow that fires on tag push creates
# the GitHub release itself, assets and all, and the ship waits for it; with no
# such workflow the ship creates the release directly. Getting this wrong in
# either direction is visible: waiting for a run that will never appear, or
# creating a release the workflow is about to create again. Off GitHub there is
# no release to create, so the tag is the release — except for a repo with
# assets, which is broken without somewhere to attach them, and keeps `gh` so
# the ship fails loudly rather than shipping nothing installable.
if [ -f .github/workflows/release.yml ]; then
  RELEASE_MODE="workflow"
elif [ -n "$RELEASE_ASSETS" ] || [ "$IS_GITHUB" = "1" ]; then
  RELEASE_MODE="gh"
else
  RELEASE_MODE="tag"
fi

PROFILE="${PROFILE:-generic}"

# The CHANGELOG fallback (see VERSION_CMD above). The same heading shape check
# 11 accepts: `## 1.2.0`, `## v1.2.0`, `## [1.2.0]`, with or without a date after it.
if [ -z "$VERSION_CMD" ] && grep -qE '^## \[?v?[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md 2>/dev/null; then
  VERSION_CMD="grep -m1 -E '^## \[?v?[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md"
fi

# A fresh linked worktree has the lockfile and no node_modules, so without an
# install every row that runs the project's code fails for that reason alone.
# Frozen, so a lockfile out of step with package.json fails here rather than
# being rewritten. Go needs nothing: its commands fetch modules themselves.
[ -f package.json ] && [ -f bun.lock ] && INSTALL_CMD="bun install --frozen-lockfile"

# Tags are the only place the prefix convention is recorded, so this repo's own
# most recent tag is the authority unless .release-gate assigns TAG_PREFIX.
LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null)" || LAST_TAG=""
TAG_PREFIX=""
[[ "$LAST_TAG" =~ ^v[0-9] ]] && TAG_PREFIX="v"

# Repo-local overrides win over everything detected above.
if [ -f .release-gate ]; then
  # shellcheck disable=SC1091  # repo-local, not resolvable at lint time
  . ./.release-gate
  PROFILE="$PROFILE (.release-gate)"
fi

# Spell every VERSION_FILES entry out in full: a bare path takes its default
# spec, and a bare `jq` takes the .version filter.
vf=""
for entry in $VERSION_FILES; do
  case "$entry" in
    *.json) entry="$entry:jq:.version" ;;
    *:jq) entry="$entry:.version" ;;
    *:*) ;;
    *) entry="$entry:grep" ;;
  esac
  vf="${vf:+$vf }$entry"
done
VERSION_FILES="$vf"

# --- Version under test -----------------------------------------------------
resolve_version() {
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

  TARGET_TAG="${TAG_PREFIX}${VERSION}"
  PREP_BRANCH="release/$VERSION"
  VERSION_SYNC_CMD="${VERSION_SYNC_CMD//\{version\}/$VERSION}"
}
