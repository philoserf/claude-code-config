#!/usr/bin/env bash
# Pre-release gate for Obsidian plugins. Runs 16 mechanical checks and prints
# a summary table.
#
# Exit codes:
#   0  READY       — all checks pass, safe to tag
#   1  BLOCKED     — one or more FAIL rows
#   2  READY       — warnings only, caller may acknowledge and proceed
#   3  NOT STARTED — the target version is already released; the release has
#                    not been prepared yet. The user runs /obsidian-ship
#                    phases 1-5 (bump, CHANGELOG, walkthrough, prep PR), merges,
#                    then this gate runs again against the new version.
#
# Usage: ~/.claude/skills/obsidian-gate/scripts/release-check.sh [VERSION]
#   VERSION defaults to the current package.json version.

set -uo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Error: run from inside a git repo" >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1

# Every plugin in the fleet has the same shape. Assert it up front: on anything
# else most of the 16 checks below are meaningless, and a table of misleading
# rows is worse than a refusal.
if ! jq -e '.minAppVersion' manifest.json >/dev/null 2>&1; then
  echo "Error: no manifest.json with minAppVersion — not an Obsidian plugin repo" >&2
  exit 1
fi
if [ ! -f .github/workflows/release.yml ]; then
  echo "Error: no .github/workflows/release.yml — not an Obsidian plugin repo" >&2
  exit 1
fi

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  VERSION="$(jq -r '.version' package.json)"
fi

LOG_DIR="$(mktemp -d)"
ROWS=()
FAIL_COUNT=0
WARN_COUNT=0
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
  esac
}

# 1. Deps current (read-only probe: `bun outdated` reports without writing
#    to package.json/bun.lock, unlike `bun update`)
if OUTDATED_OUTPUT="$(bun outdated 2>&1)"; then
  echo "$OUTDATED_OUTPUT" >"$LOG_DIR/outdated.log"
  OUTDATED_COUNT="$(echo "$OUTDATED_OUTPUT" | grep -E '^\| ' | grep -v '| Package' | grep -cE '^\| [^-]')"
  if [ "$OUTDATED_COUNT" = "0" ]; then
    add_row 1 "Deps current" "PASS"
  else
    add_row 1 "Deps current" "WARN" "$OUTDATED_COUNT outdated (see $LOG_DIR/outdated.log)"
  fi
else
  echo "$OUTDATED_OUTPUT" >"$LOG_DIR/outdated.log"
  add_row 1 "Deps current" "WARN" "bun outdated failed (see $LOG_DIR/outdated.log)"
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

# 6. Build. `bun run build` is check + bundle in every plugin in the fleet.
if bun run build >"$LOG_DIR/build.log" 2>&1; then
  add_row 6 "Build" "PASS" "check + build"
else
  add_row 6 "Build" "FAIL" "see $LOG_DIR/build.log"
fi

# 7. Tests
if bun test >"$LOG_DIR/test.log" 2>&1; then
  # Anchor on bun's own summary line (e.g. " 12 pass") rather than an
  # unanchored "pass" substring, which can match unrelated text (test
  # names, file paths, error output) elsewhere in the log.
  TEST_COUNT="$(grep -oE '^[[:space:]]*[0-9]+ pass$' "$LOG_DIR/test.log" | grep -oE '[0-9]+' | tail -1)"
  add_row 7 "Tests pass" "PASS" "${TEST_COUNT:-0} passed"
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
if bun audit --audit-level=critical >"$LOG_DIR/audit.log" 2>&1; then
  add_row 9 "Dependency audit" "PASS"
else
  add_row 9 "Dependency audit" "FAIL" "critical findings (see $LOG_DIR/audit.log)"
fi

# 10. Version consistency across three files
PKG_V="$(jq -r '.version' package.json)"
MANIFEST_V="$(jq -r '.version' manifest.json 2>/dev/null || echo "missing")"
HAS_VERSIONS_ENTRY="$(jq -r --arg v "$VERSION" 'has($v)' versions.json 2>/dev/null || echo "false")"
if [ "$PKG_V" = "$VERSION" ] && [ "$MANIFEST_V" = "$VERSION" ] && [ "$HAS_VERSIONS_ENTRY" = "true" ]; then
  add_row 10 "Version consistency" "PASS" "$VERSION across all files"
else
  add_row 10 "Version consistency" "FAIL" "pkg=$PKG_V mf=$MANIFEST_V vj=$HAS_VERSIONS_ENTRY"
fi

# 11. CHANGELOG entry (escape regex metachars — unescaped dots would match any char)
VERSION_RE=$(printf '%s' "$VERSION" | sed 's/[][\.*^$()+?{|]/\\&/g')
if grep -qE "^## ${VERSION_RE}( |$)" CHANGELOG.md 2>/dev/null; then
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

# LAST_TAG is needed by checks 13-15, so resolve it before them.
LAST_TAG=""
LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null)" || LAST_TAG=""

# 13. Tag available.
#
# The version being already tagged has two very different meanings, and
# collapsing them into one FAIL was actively misleading:
#
#   a) VERSION is the most recent tag  -> the release was never prepared. The
#      version has not been bumped since the last ship, so checks 10, 11 and 14
#      are all describing the *previous* release and pass vacuously. This is not
#      a failure to fix here; it is the cue to run ship phases 1-5.
#   b) VERSION is some older tag       -> a genuine conflict worth blocking on.
if [ -z "$(git tag -l "$VERSION")" ]; then
  add_row 13 "Tag available" "PASS" "$VERSION not yet tagged"
elif [ "$VERSION" = "$LAST_TAG" ]; then
  NOT_STARTED=1
  add_row 13 "Tag available" "INFO" "$VERSION is the current release - not bumped yet"
else
  add_row 13 "Tag available" "FAIL" "$VERSION already tagged (and is not the latest)"
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
# Check 2 runs before check 6, and check 6 runs `bun run build`, which writes
# main.js. So this dirties the very tree check 2 just certified, and nothing
# would notice until the next run. Two different causes, both real: usually the
# committed bundle is stale (a dep bump merged without a rebuild), occasionally
# the build itself is nondeterministic. Building twice tells them apart.
if [ -z "$(git status --porcelain)" ]; then
  add_row 16 "Clean after build" "PASS"
else
  DIRTY="$(git status --porcelain | awk '{print $2}' | tr '\n' ' ')"
  add_row 16 "Clean after build" "FAIL" "tracked files changed by build: $DIRTY"
fi

# Output
echo "Pre-Release Gate: $VERSION (Obsidian plugin)"
echo "============================================="
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

if [ "$NOT_STARTED" = "1" ]; then
  echo "Result: NOT STARTED ($FAIL_COUNT failures, $WARN_COUNT warnings)"
  echo
  echo "$VERSION is already released. Nothing has been prepared for a new version,"
  echo "so checks 10, 11 and 14 above describe the *shipped* release, not a pending one."
  echo "Agree the next version with the user, then ask them to run"
  echo "/obsidian-ship (phases 1-5: bump, CHANGELOG, walkthrough, prep PR)."
  echo "Do not run those phases by hand. Re-run this gate after the prep PR merges."
  if [ "$FAIL_COUNT" -gt 0 ]; then
    echo
    echo "The $FAIL_COUNT failure(s) above still need resolving; prep phases 2-5 cover"
    echo "version, CHANGELOG, walkthrough and a stale main.js. Anything else is yours to fix."
  fi
  exit 3
elif [ "$FAIL_COUNT" -gt 0 ]; then
  echo "Result: BLOCKED ($FAIL_COUNT failures, $WARN_COUNT warnings)"
  exit 1
elif [ "$WARN_COUNT" -gt 0 ]; then
  echo "Result: READY ($FAIL_COUNT failures, $WARN_COUNT warnings)"
  exit 2
else
  echo "Result: READY (0 failures, 0 warnings)"
  exit 0
fi
