#!/usr/bin/env bash
# Pre-release gate. Runs 16 mechanical checks against the repo you are standing
# in and prints a summary table.
#
# Exit codes:
#   0  READY       — all checks pass, safe to tag
#   1  BLOCKED     — one or more FAIL rows (also: cannot determine the version)
#   2  WARNINGS    — no FAIL rows, but one or more checks could not be confirmed.
#                    Not a green light: a warning is a check that did not reach a
#                    conclusion, and "CI still running" reads identically to "CI
#                    never ran". Clear them and re-run.
#   3  NOT STARTED — the target version is already released; the release has not
#                    been prepared yet. Bump, changelog and walkthrough on a prep
#                    branch, merge, then run this gate again.
#
# Usage: ~/.claude/skills/release-gate/scripts/release-check.sh [VERSION]
#   VERSION defaults to whatever the project's own version source reports.
#
# ---------------------------------------------------------------------------
# Project profile
#
# Eleven of the sixteen checks are the same everywhere: tree state, branch,
# remote, PRs, walkthrough, changelog, CI, tags. Five are not — deps, build,
# tests, audit, and where the version lives — so those come from a profile.
#
# A profile is detected from the repo's shape and can be overridden entirely by
# a `.release-gate` file in the repo root, which is sourced as shell. (It is
# code from the repo, executed: no different in kind from the build and test
# commands this script already runs out of that repo, but worth knowing.)
#
#   PROFILE        name shown in the header line
#   VERSION_CMD    prints the project's version; the first semver in its stdout
#                  is taken. There is no fallback: a project whose version this
#                  cannot find is a setup gap, and defaulting to the last tag
#                  would wedge the state machine at NOT STARTED forever.
#   VERSION_FILES  space-separated `path[:spec]` cross-checks. spec is one of
#                  `jq:<filter>` (filter's value must equal the version),
#                  `jqhas` (object must have the version as a key), or `grep`
#                  (file must mention the version). Default by extension:
#                  .json -> jq:.version, anything else -> grep.
#   DEPS_CMD       stdout: one line per outdated dependency, empty when current.
#                  Nonzero exit means the check could not run (WARN), so a
#                  profile that pipes through grep must end with `|| true`.
#   BUILD_CMD      nonzero exit fails the build row. Empty skips it, and skips
#                  the clean-after-build row with it.
#   TEST_CMD       nonzero exit fails the test row.
#   AUDIT_CMD      nonzero exit means findings.
#   TAG_PREFIX     "" or "v". Detected from the most recent tag.
#
# Any of these left empty makes its row SKIP rather than PASS. Skips are counted
# and named in the result line: a gate that ran no tests must not be able to
# report READY without saying so.
# ---------------------------------------------------------------------------

set -uo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Error: run from inside a git repo" >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1

PROFILE=""
VERSION_CMD=""
VERSION_FILES=""
DEPS_CMD=""
BUILD_CMD=""
TEST_CMD=""
AUDIT_CMD=""
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
  VERSION_FILES="package.json:jq:.version manifest.json:jq:.version versions.json:jqhas"
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

PROFILE="${PROFILE:-generic}"

# Repo-local overrides win over everything detected above.
if [ -f .release-gate ]; then
  # shellcheck disable=SC1091  # repo-local, not resolvable at lint time
  . ./.release-gate
  PROFILE="$PROFILE (.release-gate)"
  [ -n "${TAG_PREFIX:-}" ] && TAG_PREFIX_SET=1
fi

# --- Version under test -----------------------------------------------------
VERSION="${1:-}"
VERSION="${VERSION#v}"
if [ -z "$VERSION" ]; then
  if [ -z "$VERSION_CMD" ]; then
    echo "Error: cannot determine the version — no version source for this repo." >&2
    echo "Pass one as an argument, or set VERSION_CMD in a .release-gate file at" >&2
    echo "the repo root (see the header of $0)." >&2
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

LOG_DIR="$(mktemp -d)"
ROWS=()
FAIL_COUNT=0
WARN_COUNT=0
SKIP_COUNT=0
SKIP_NAMES=()
NOT_STARTED=0

# shellcheck disable=SC2329  # invoked via trap below
cleanup_logs() {
  if [ "$FAIL_COUNT" -eq 0 ] && [ "$WARN_COUNT" -eq 0 ]; then
    rm -rf "$LOG_DIR"
  else
    echo "Release check logs preserved at: $LOG_DIR" >&2
  fi
}
trap cleanup_logs EXIT

add_row() {
  local num="$1" name="$2" status="$3" details="${4:-}"
  ROWS+=("$(printf '| %-2s | %-22s | %-6s | %s' "$num" "$name" "$status" "$details")")
  case "$status" in
    FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
    WARN) WARN_COUNT=$((WARN_COUNT + 1)) ;;
    SKIP)
      SKIP_COUNT=$((SKIP_COUNT + 1))
      SKIP_NAMES+=("$name")
      ;;
  esac
}

# 1. Deps current. Read-only by contract: the command reports, it does not
#    update. (`bun outdated` and `go list -u` both honour that; `bun update`
#    would not, which is why neither profile uses it.)
if [ -z "$DEPS_CMD" ]; then
  add_row 1 "Deps current" "SKIP" "no dependency manifest"
elif DEPS_OUT="$(bash -c "$DEPS_CMD" 2>"$LOG_DIR/outdated.log")"; then
  printf '%s\n' "$DEPS_OUT" >>"$LOG_DIR/outdated.log"
  OUTDATED_COUNT="$(printf '%s' "$DEPS_OUT" | grep -c .)"
  if [ "$OUTDATED_COUNT" = "0" ]; then
    add_row 1 "Deps current" "PASS"
  else
    add_row 1 "Deps current" "WARN" "$OUTDATED_COUNT outdated (see $LOG_DIR/outdated.log)"
  fi
else
  add_row 1 "Deps current" "WARN" "dependency check failed (see $LOG_DIR/outdated.log)"
fi

# 2. Clean working tree
if [ -z "$(git status --porcelain)" ]; then
  add_row 2 "Clean working tree" "PASS"
else
  count="$(git status --porcelain | wc -l | tr -d ' ')"
  add_row 2 "Clean working tree" "FAIL" "$count modified files"
fi

# 3. On default branch
DEFAULT_BRANCH="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')"
if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH="main"
fi
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
  add_row 3 "On default branch" "PASS" "$DEFAULT_BRANCH"
else
  add_row 3 "On default branch" "FAIL" "on $CURRENT_BRANCH, not $DEFAULT_BRANCH"
fi

# 4. Up to date with remote
if git fetch --quiet origin "$DEFAULT_BRANCH" 2>/dev/null; then
  BEHIND="$(git rev-list --count "HEAD..origin/$DEFAULT_BRANCH")"
  if [ "$BEHIND" = "0" ]; then
    add_row 4 "Up to date with remote" "PASS"
  else
    add_row 4 "Up to date with remote" "WARN" "behind by $BEHIND"
  fi
else
  add_row 4 "Up to date with remote" "WARN" "fetch failed"
fi

# 5. No open PRs targeting default branch
if OPEN_PRS="$(gh pr list --base "$DEFAULT_BRANCH" --state open --json number -q '. | length' 2>/dev/null)"; then
  if [ "$OPEN_PRS" = "0" ]; then
    add_row 5 "No open PRs" "PASS"
  else
    NUMS="$(gh pr list --base "$DEFAULT_BRANCH" --state open --json number -q 'map(.number | tostring) | join(", #")' 2>/dev/null)"
    add_row 5 "No open PRs" "WARN" "$OPEN_PRS open (#$NUMS)"
  fi
else
  add_row 5 "No open PRs" "WARN" "gh query failed"
fi

# 6. Build
if [ -z "$BUILD_CMD" ]; then
  add_row 6 "Build" "SKIP" "no build step"
elif bash -c "$BUILD_CMD" >"$LOG_DIR/build.log" 2>&1; then
  add_row 6 "Build" "PASS" "$BUILD_CMD"
else
  add_row 6 "Build" "FAIL" "see $LOG_DIR/build.log"
fi

# 7. Tests
if [ -z "$TEST_CMD" ]; then
  add_row 7 "Tests pass" "SKIP" "no test command"
elif bash -c "$TEST_CMD" >"$LOG_DIR/test.log" 2>&1; then
  # Best-effort count, for the details column only. Anchored on a runner's own
  # summary line rather than an unanchored "pass", which matches test names and
  # file paths elsewhere in the log. Unrecognised runners report no count; the
  # row's verdict comes from the exit status either way.
  TEST_COUNT="$(grep -oE '^[[:space:]]*[0-9]+ pass$' "$LOG_DIR/test.log" | grep -oE '[0-9]+' | tail -1)"
  if [ -z "$TEST_COUNT" ]; then
    TEST_COUNT="$(grep -cE '^--- PASS' "$LOG_DIR/test.log")"
    [ "$TEST_COUNT" = "0" ] && TEST_COUNT=""
  fi
  add_row 7 "Tests pass" "PASS" "${TEST_COUNT:+$TEST_COUNT passed}"
else
  add_row 7 "Tests pass" "FAIL" "see $LOG_DIR/test.log"
fi

# 8. Walkthrough current
if [ -f WALKTHROUGH.md ]; then
  if uvx showboat verify WALKTHROUGH.md >"$LOG_DIR/walkthrough.log" 2>&1; then
    add_row 8 "Walkthrough current" "PASS" "showboat verified"
  else
    add_row 8 "Walkthrough current" "FAIL" "see $LOG_DIR/walkthrough.log"
  fi
else
  add_row 8 "Walkthrough current" "SKIP" "no WALKTHROUGH.md"
fi

# 9. Dependency audit (critical only blocks)
if [ -z "$AUDIT_CMD" ]; then
  add_row 9 "Dependency audit" "SKIP" "no audit command"
elif bash -c "$AUDIT_CMD" >"$LOG_DIR/audit.log" 2>&1; then
  add_row 9 "Dependency audit" "PASS"
else
  add_row 9 "Dependency audit" "FAIL" "critical findings (see $LOG_DIR/audit.log)"
fi

# 10. Version consistency. Every declared file must agree with the version under
#     test. This is the row that catches a tag racing ahead of the source.
VERSION_RE=$(printf '%s' "$VERSION" | sed 's/[][\.*^$()+?{|]/\\&/g')
if [ -z "$VERSION_FILES" ]; then
  add_row 10 "Version consistency" "SKIP" "no version files declared"
else
  VC_BAD=""
  for entry in $VERSION_FILES; do
    vpath="${entry%%:*}"
    if [ "$entry" = "$vpath" ]; then
      case "$vpath" in
        *.json) vspec="jq"; varg=".version" ;;
        *) vspec="grep"; varg="" ;;
      esac
    else
      vrest="${entry#*:}"
      vspec="${vrest%%:*}"
      varg="${vrest#*:}"
      [ "$varg" = "$vspec" ] && varg=""
    fi
    if [ ! -f "$vpath" ]; then
      VC_BAD="$VC_BAD $vpath=missing"
      continue
    fi
    case "$vspec" in
      jq)
        got="$(jq -r "${varg:-.version}" "$vpath" 2>/dev/null)"
        [ "$got" = "$VERSION" ] || VC_BAD="$VC_BAD $vpath=${got:-?}"
        ;;
      jqhas)
        got="$(jq -r --arg v "$VERSION" 'has($v)' "$vpath" 2>/dev/null)"
        [ "$got" = "true" ] || VC_BAD="$VC_BAD $vpath=no-entry"
        ;;
      grep)
        grep -qE "(^|[^0-9.])${VERSION_RE}([^0-9.]|$)" "$vpath" 2>/dev/null ||
          VC_BAD="$VC_BAD $vpath=absent"
        ;;
      *)
        VC_BAD="$VC_BAD $vpath=bad-spec:$vspec"
        ;;
    esac
  done
  if [ -z "$VC_BAD" ]; then
    add_row 10 "Version consistency" "PASS" "$VERSION across all files"
  else
    add_row 10 "Version consistency" "FAIL" "${VC_BAD# }"
  fi
fi

# 11. CHANGELOG entry (escape regex metachars — unescaped dots would match any char)
if [ ! -f CHANGELOG.md ]; then
  add_row 11 "CHANGELOG entry" "SKIP" "no CHANGELOG.md"
elif grep -qE "^## v?${VERSION_RE}( |$)" CHANGELOG.md 2>/dev/null; then
  add_row 11 "CHANGELOG entry" "PASS" "## $VERSION found"
else
  add_row 11 "CHANGELOG entry" "FAIL" "no ## $VERSION section"
fi

# 12. CI passing for the exact commit being released.
#
# Deliberately keyed on HEAD's sha rather than "the most recent run on the
# default branch". A bare --limit 1 answers a different question: it returns
# whichever workflow ran last, which in practice is often an unrelated one
# (a bot workflow, pages-build-deployment), and it will happily report a green
# run from several commits ago. Neither tells you whether the commit you are
# about to tag is green.
#
# Runs that are neither success nor failure (skipped by a path filter or an
# `if:` guard, cancelled, neutral) are ignored rather than warned about: a
# skipped bot workflow says nothing about code validity. The verdict comes from
# whether any real run failed, is still going, or succeeded.
#
# Both filters are load-bearing. claude.yml fires on issue_comment/issues and
# those runs are attributed to the branch head, so an unfiltered page of 30 can
# be entirely skipped bot runs with the real CI run sitting well past the window
# (measured: index 61). --commit alone does not save it — 62 runs shared that one
# sha. --event bounds the result set no matter how loud the bots get, but it takes
# a single value, so the two events that can legitimately turn a commit green are
# queried separately and merged: a normal push, and a manual re-run after a flake.
HEAD_SHA="$(git rev-parse HEAD)"
SHORT_SHA="${HEAD_SHA:0:8}"
ci_runs_for() {
  gh run list --branch "$DEFAULT_BRANCH" --event "$1" --commit "$HEAD_SHA" \
    --limit 30 --json name,headSha,status,conclusion 2>/dev/null || echo "[]"
}
if ! compgen -G ".github/workflows/*.y*ml" >/dev/null 2>&1; then
  add_row 12 "CI passing" "SKIP" "no workflows"
else
  CI_RUNS="$({ ci_runs_for push; ci_runs_for workflow_dispatch; } | jq -s 'add')"
  CI_MATCHED="$(echo "$CI_RUNS" | jq --arg s "$HEAD_SHA" '[.[] | select(.headSha == $s)]' 2>/dev/null || echo "[]")"
  if [ "$(echo "$CI_MATCHED" | jq 'length')" = "0" ]; then
    add_row 12 "CI passing" "WARN" "no run for $SHORT_SHA yet"
  else
    CI_FAILED="$(echo "$CI_MATCHED" | jq -r '[.[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "startup_failure")][0].name // empty')"
    CI_RUNNING="$(echo "$CI_MATCHED" | jq -r '[.[] | select(.status != "completed")][0].name // empty')"
    CI_GREEN="$(echo "$CI_MATCHED" | jq '[.[] | select(.conclusion == "success")] | length')"
    if [ -n "$CI_FAILED" ]; then
      add_row 12 "CI passing" "FAIL" "$CI_FAILED failed on $SHORT_SHA"
    elif [ -n "$CI_RUNNING" ]; then
      add_row 12 "CI passing" "WARN" "$CI_RUNNING still running on $SHORT_SHA"
    elif [ "$CI_GREEN" -gt 0 ]; then
      add_row 12 "CI passing" "PASS" "$CI_GREEN green on $SHORT_SHA"
    else
      add_row 12 "CI passing" "WARN" "no conclusive run on $SHORT_SHA"
    fi
  fi
fi

# LAST_TAG is needed by checks 13-15, so resolve it before them. Its prefix also
# settles TAG_PREFIX when .release-gate did not: tags are the only place the
# convention is recorded, and this repo's own most recent tag is the authority.
LAST_TAG=""
LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null)" || LAST_TAG=""
if [ "$TAG_PREFIX_SET" = "0" ] && [[ "$LAST_TAG" =~ ^v[0-9] ]]; then
  TAG_PREFIX="v"
fi
TARGET_TAG="${TAG_PREFIX}${VERSION}"

# 13. Tag available.
#
# The version being already tagged has two very different meanings, and
# collapsing them into one FAIL was actively misleading:
#
#   a) VERSION is the most recent tag  -> the release was never prepared. The
#      version has not been bumped since the last ship, so checks 10, 11 and 14
#      are all describing the *previous* release and pass vacuously. This is not
#      a failure to fix here; it is the cue to prepare the next version.
#   b) VERSION is some older tag       -> a genuine conflict worth blocking on.
if [ -z "$(git tag -l "$TARGET_TAG")" ]; then
  add_row 13 "Tag available" "PASS" "$TARGET_TAG not yet tagged"
elif [ "$TARGET_TAG" = "$LAST_TAG" ]; then
  NOT_STARTED=1
  add_row 13 "Tag available" "INFO" "$TARGET_TAG is the current release - not bumped yet"
else
  add_row 13 "Tag available" "FAIL" "$TARGET_TAG already tagged (and is not the latest)"
fi

# 14. Prior release tag exists
if [ -n "$LAST_TAG" ]; then
  add_row 14 "Prior release exists" "PASS" "$LAST_TAG"
else
  add_row 14 "Prior release exists" "INFO" "no prior tags"
fi

# 15. Changes since last tag
if [ -n "$LAST_TAG" ]; then
  COMMIT_COUNT="$(git rev-list --count "$LAST_TAG..HEAD")"
  add_row 15 "Changes since last tag" "INFO" "$COMMIT_COUNT commits since $LAST_TAG"
else
  COMMIT_COUNT="$(git rev-list --count HEAD)"
  add_row 15 "Changes since last tag" "INFO" "$COMMIT_COUNT total commits"
fi

# 16. Working tree still clean after the build.
#
# Check 2 runs before check 6, and check 6 runs the build, which may write a
# committed artifact. So this dirties the very tree check 2 just certified, and
# nothing would notice until the next run. Two different causes, both real:
# usually the committed bundle is stale (a dep bump merged without a rebuild),
# occasionally the build itself is nondeterministic. Building twice tells them
# apart. With no build step there is nothing to have dirtied the tree, so this
# says SKIP rather than restating check 2's verdict as a second PASS.
if [ -z "$BUILD_CMD" ]; then
  add_row 16 "Clean after build" "SKIP" "no build step"
elif [ -z "$(git status --porcelain)" ]; then
  add_row 16 "Clean after build" "PASS"
else
  # cut -c4- rather than awk '{print $2}': porcelain v1 is exactly two status
  # characters plus a space, so column 4 onward is the path verbatim. awk split on
  # whitespace, which truncated paths containing a space and reported only the old
  # name of a rename ("R  old -> new" -> "old").
  #
  # Untracked output is a different diagnosis from a rewritten tracked file, and the
  # remedy differs too -- gitignore it, or add it to the prep branch's staged list --
  # so the row says which happened instead of calling everything tracked.
  CHANGED="$(git status --porcelain | grep -v '^??' | cut -c4- | tr '\n' ' ')"
  ADDED="$(git status --porcelain | grep '^??' | cut -c4- | tr '\n' ' ')"
  if [ -n "$CHANGED" ] && [ -n "$ADDED" ]; then
    add_row 16 "Clean after build" "FAIL" "tracked changed: ${CHANGED}/ untracked added: $ADDED"
  elif [ -n "$ADDED" ]; then
    add_row 16 "Clean after build" "FAIL" "build added untracked files: $ADDED"
  else
    add_row 16 "Clean after build" "FAIL" "tracked files changed by build: $CHANGED"
  fi
fi

# Output
HEADER="Pre-Release Gate: $VERSION ($PROFILE)"
echo "$HEADER"
printf '%*s\n' "${#HEADER}" '' | tr ' ' '='
echo
echo "| #  | Check                  | Status | Details"
echo "|----|------------------------|--------|--------"
for row in "${ROWS[@]}"; do
  echo "$row"
done
echo

if [ -n "$LAST_TAG" ] && [ "$COMMIT_COUNT" != "0" ]; then
  echo "Commits since $LAST_TAG:"
  git log --oneline "$LAST_TAG..HEAD"
  echo
fi

# A skip is not a pass, and the two that matter most are the two most likely to
# be missing on a repo nobody has profiled yet. Name them on the result line so
# READY can never be read as "everything was checked".
SKIP_NOTE=""
if [ "$SKIP_COUNT" -gt 0 ]; then
  SKIP_NOTE=", $SKIP_COUNT skipped"
fi

if [ "$NOT_STARTED" = "1" ]; then
  echo "Result: NOT STARTED ($FAIL_COUNT failures, $WARN_COUNT warnings$SKIP_NOTE)"
  echo
  echo "$TARGET_TAG is already released. Nothing has been prepared for a new version,"
  echo "so checks 10, 11 and 14 above describe the *shipped* release, not a pending one."
  echo "Agree the next version with the user, then prepare it on a branch — bump the"
  echo "version, add the CHANGELOG section, bring the walkthrough current — merge that,"
  echo "and re-run this gate. Do not tag from here."
  if [ "$FAIL_COUNT" -gt 0 ]; then
    echo
    echo "The $FAIL_COUNT failure(s) above still need resolving. The prep branch covers"
    echo "version, CHANGELOG, walkthrough and a stale build artifact; anything else is"
    echo "yours to fix."
  fi
  RESULT=3
elif [ "$FAIL_COUNT" -gt 0 ]; then
  echo "Result: BLOCKED ($FAIL_COUNT failures, $WARN_COUNT warnings$SKIP_NOTE)"
  RESULT=1
elif [ "$WARN_COUNT" -gt 0 ]; then
  echo "Result: WARNINGS ($FAIL_COUNT failures, $WARN_COUNT warnings$SKIP_NOTE) - not ready, clear these and re-run"
  RESULT=2
else
  echo "Result: READY (0 failures, 0 warnings$SKIP_NOTE)"
  RESULT=0
fi

if [ "$SKIP_COUNT" -gt 0 ]; then
  echo
  printf 'Skipped: %s\n' "$(printf '%s, ' "${SKIP_NAMES[@]}" | sed 's/, $//')"
  for name in "${SKIP_NAMES[@]}"; do
    if [ "$name" = "Tests pass" ] || [ "$name" = "Version consistency" ]; then
      echo "A skipped '$name' is a gap in the profile, not a property of the repo."
      echo "Set TEST_CMD / VERSION_FILES in .release-gate if this repo has them."
      break
    fi
  done
fi

exit "$RESULT"
