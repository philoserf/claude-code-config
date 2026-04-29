#!/usr/bin/env bash
# Pre-release gate for Obsidian plugins. Runs 15 mechanical checks and prints
# a summary table. Exits 0 on pass, 1 on failures, 2 on warnings-only.
#
# Usage: ~/.claude/skills/obsidian-release-check/scripts/release-check.sh [VERSION]
#   VERSION defaults to the current package.json version.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT" || exit 1

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  VERSION="$(jq -r '.version' package.json)"
fi

LOG_DIR="$(mktemp -d)"
trap 'rm -rf "$LOG_DIR"' EXIT

ROWS=()
FAIL_COUNT=0
WARN_COUNT=0

add_row() {
  local num="$1" name="$2" status="$3" details="${4:-}"
  ROWS+=("$(printf '| %-2s | %-22s | %-6s | %s' "$num" "$name" "$status" "$details")")
  case "$status" in
    FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
    WARN) WARN_COUNT=$((WARN_COUNT + 1)) ;;
  esac
}

# 1. Deps current (runs bun update --latest)
TREE_CLEAN_AT_START=0
if [ -z "$(git status --porcelain)" ]; then
  TREE_CLEAN_AT_START=1
fi
if [ "$TREE_CLEAN_AT_START" = "1" ]; then
  if bun update --latest >"$LOG_DIR/update.log" 2>&1; then
    DEPS_CHANGED="$(git status --porcelain -- package.json bun.lock bun.lockb 2>/dev/null | wc -l | tr -d ' ')"
    if [ "$DEPS_CHANGED" = "0" ]; then
      add_row 1 "Deps current" "PASS"
    else
      add_row 1 "Deps current" "FAIL" "bun update bumped deps — commit and retry"
    fi
  else
    add_row 1 "Deps current" "FAIL" "bun update failed (see $LOG_DIR/update.log)"
  fi
else
  add_row 1 "Deps current" "SKIP" "tree dirty, run after clean"
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

# 6. Validate (or fallback build). Track whether tests already ran.
VALIDATE_RAN_TESTS=0
if jq -e '.scripts.validate' package.json >/dev/null 2>&1; then
  if bun run validate >"$LOG_DIR/validate.log" 2>&1; then
    add_row 6 "Validate" "PASS" "validate script"
    VALIDATE_RAN_TESTS=1
  else
    add_row 6 "Validate" "FAIL" "see $LOG_DIR/validate.log"
  fi
else
  if bun run build >"$LOG_DIR/build.log" 2>&1; then
    add_row 6 "Build" "PASS" "check + build"
  else
    add_row 6 "Build" "FAIL" "see $LOG_DIR/build.log"
  fi
fi

# 7. Tests
if [ "$VALIDATE_RAN_TESTS" = "1" ]; then
  add_row 7 "Tests pass" "SKIP" "run by validate"
else
  if bun test >"$LOG_DIR/test.log" 2>&1; then
    TEST_COUNT="$(grep -cE '^\(pass\)|^✓|pass' "$LOG_DIR/test.log")"
    add_row 7 "Tests pass" "PASS" "$TEST_COUNT ok lines"
  else
    add_row 7 "Tests pass" "FAIL" "see $LOG_DIR/test.log"
  fi
fi

# 8. Walkthrough current
if [ -f walkthrough.md ]; then
  if uvx showboat verify walkthrough.md >"$LOG_DIR/walkthrough.log" 2>&1; then
    add_row 8 "Walkthrough current" "PASS" "showboat verified"
  else
    add_row 8 "Walkthrough current" "FAIL" "see $LOG_DIR/walkthrough.log"
  fi
else
  add_row 8 "Walkthrough current" "SKIP" "no walkthrough.md"
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

# 11. CHANGELOG entry
if grep -qE "^## ${VERSION}( |$)" CHANGELOG.md 2>/dev/null; then
  add_row 11 "CHANGELOG entry" "PASS" "## $VERSION found"
else
  add_row 11 "CHANGELOG entry" "FAIL" "no ## $VERSION section"
fi

# 12. CI passing on default branch
CI_JSON="$(gh run list --branch "$DEFAULT_BRANCH" --limit 1 --json conclusion,name,status 2>/dev/null || echo "[]")"
CI_CONCLUSION="$(echo "$CI_JSON" | jq -r '.[0].conclusion // "none"')"
CI_NAME="$(echo "$CI_JSON" | jq -r '.[0].name // ""')"
case "$CI_CONCLUSION" in
  success) add_row 12 "CI passing" "PASS" ;;
  none | "" | null) add_row 12 "CI passing" "WARN" "no recent runs" ;;
  *) add_row 12 "CI passing" "FAIL" "$CI_NAME: $CI_CONCLUSION" ;;
esac

# 13. Tag available
if [ -z "$(git tag -l "$VERSION")" ]; then
  add_row 13 "Tag available" "PASS" "$VERSION not yet tagged"
else
  add_row 13 "Tag available" "FAIL" "$VERSION already tagged"
fi

# 14. Prior release tag exists
LAST_TAG=""
if LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null)"; then
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

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "Result: BLOCKED ($FAIL_COUNT failures, $WARN_COUNT warnings)"
  exit 1
elif [ "$WARN_COUNT" -gt 0 ]; then
  echo "Result: READY ($FAIL_COUNT failures, $WARN_COUNT warnings)"
  exit 2
else
  echo "Result: READY (0 failures, 0 warnings)"
  exit 0
fi
