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
# Profile resolution — which commands to run, and where the version lives — is
# shared with the ship skill and documented in scripts/profile.sh, sourced below.
# ---------------------------------------------------------------------------

set -uo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Error: run from inside a git repo" >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1

VERSION_ARG="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=profile.sh
. "$SCRIPT_DIR/profile.sh"

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
#
# A staleness signal, not a correctness one: has code been committed since the
# walkthrough was last touched? Nothing re-reads the prose, so this is the only
# automated thing that will ever notice the document falling behind.
#
# The other narrative documents are excluded from the comparison because they
# move together in the release pass — counting them would make the walkthrough
# look stale for having been updated alongside THEORY.md.
if [ ! -f WALKTHROUGH.md ]; then
  add_row 8 "Walkthrough current" "SKIP" "no WALKTHROUGH.md"
else
  WT_COMMIT="$(git log -1 --format=%H -- WALKTHROUGH.md 2>/dev/null)"
  if [ -z "$WT_COMMIT" ]; then
    add_row 8 "Walkthrough current" "SKIP" "WALKTHROUGH.md not committed"
  else
    CODE_COMMITS="$(git rev-list --count "$WT_COMMIT"..HEAD -- . \
      ':!WALKTHROUGH.md' ':!THEORY.md' ':!README.md' ':!CHANGELOG.md' ':!CLAUDE.md' \
      2>/dev/null)"
    if [ "${CODE_COMMITS:-0}" -eq 0 ]; then
      add_row 8 "Walkthrough current" "PASS" "no code commits since last update"
    else
      [ "$CODE_COMMITS" -eq 1 ] && PLURAL="commit" || PLURAL="commits"
      add_row 8 "Walkthrough current" "FAIL" "$CODE_COMMITS code $PLURAL since last update"
    fi
  fi
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

# LAST_TAG, TAG_PREFIX and TARGET_TAG come from profile.sh.

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
