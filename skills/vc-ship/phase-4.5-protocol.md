# Phase 4.5: Pre-Push Quality Review Protocol

This document details the protocol for Phase 4.5, a **mandatory quality gate** that runs before pushing commits to remote. It prevents premature pushes by analyzing commit quality, offering test execution, and ensuring code is ready for publication.

**Note**: Phase 4.5 runs between Phase 4 (Cleanup) and Phase 5 (Push). It is ALWAYS executed before any push operation.

## Overview

**Philosophy**: "Measure twice, cut once" for git pushes.

Once commits are pushed to remote, they become part of shared history. Taking 30 seconds to review can save 30 minutes of cleanup later—or prevent embarrassment from pushing "WIP" or broken code to the team.

Phase 4.5 catches quality issues early by:

1. **Preventing generic commit messages** - No more "WIP", "fix", "update" in shared history
2. **Suggesting history cleanup** - Detecting squash opportunities before push
3. **Enforcing format standards** - Ensuring messages meet 72-char and imperative mood rules
4. **Enabling pre-push testing** - Running tests before code reaches remote
5. **Educating developers** - Teaching commit best practices through feedback

## Requirements

**Shell Requirements:**

- Bash 4.0+ (for array syntax and string manipulation)
- Standard git 2.23+ (for `git log` and `git diff` commands)
- jq (optional, for package.json parsing - graceful degradation if missing)

**Portability Note:** This protocol uses bash-specific features. For POSIX sh compatibility, alternative implementations would be needed.

## When Phase 4.5 Runs

**Entry Conditions** (ALL must be true):

- User has completed Phase 3 (commits created) or Phase 4 (history cleaned)
- Local commits exist that are not on remote
- Working directory is clean (no uncommitted changes)
- NOT in detached HEAD state
- NOT during a merge/rebase in progress

**Skip Conditions** (Phase 4.5 does not run if):

- No commits to push (repository up-to-date with remote)
- User is in emergency override mode from protected branch protocol

**Timing**: Phase 4.5 runs BEFORE Phase 5 protected branch detection and push confirmation.

## Detection Logic: Quality Checks

Phase 4.5 performs three types of quality analysis:

### 1. Generic Message Detection

**Purpose**: Identify vague, non-descriptive commit messages that provide no value in history.

**Patterns to Detect** (case-insensitive, matching at start or as whole word):

```bash
GENERIC_PATTERNS=(
  "^wip"              # Work in progress
  "^fix$|^fix "       # Generic "fix" without context
  "^fixes$|^fixes "   # Generic "fixes"
  "^update$|^update " # Generic "update"
  "^temp"             # Temporary commit
  "^tmp"              # Temporary (abbreviated)
  "^oops"             # Mistake indicator
  "^minor"            # Generic "minor changes"
  "^changes$|^changes " # Generic "changes"
  "^stuff"            # Vague
  "^things"           # Vague
  "^misc"             # Miscellaneous
  "^test$|^test "     # Generic "test" without context
  "^testing"          # Generic testing
  "^debug"            # Debug commits
  "^todo"             # TODO markers
  "^asdf"             # Keyboard mashing
  "^refactor$"        # "refactor" without saying what
  "^tweaks"           # Vague adjustments
  "^cleanup$"         # Generic cleanup
)
```

**Detection Algorithm**:

```bash
is_generic_message() {
  local summary="$1"
  local summary_lower
  summary_lower=$(echo "$summary" | tr '[:upper:]' '[:lower:]')

  # Check each pattern
  for pattern in "${GENERIC_PATTERNS[@]}"; do
    if echo "$summary_lower" | grep -qE "$pattern"; then
      return 0  # Is generic
    fi
  done

  return 1  # Not generic
}

# Usage example
check_all_commits_for_generic() {
  local branch="$1"
  local issues=()

  # Get commits to be pushed
  while IFS= read -r commit; do
    local hash summary
    hash=$(echo "$commit" | awk '{print $1}')
    summary=$(git log -1 --format="%s" "$hash")

    if is_generic_message "$summary"; then
      issues+=("BLOCKER: Commit $hash has generic message: \"$summary\"")
    fi
  done < <(git log origin/"$branch"..HEAD --format="%h" 2>/dev/null || git log -n 1 --format="%h")

  if [ ${#issues[@]} -gt 0 ]; then
    printf '%s\n' "${issues[@]}"
    return 1  # Has issues
  fi

  return 0  # No issues
}
```

**Issue Severity**: **BLOCKER** - Requires fix or explicit override

**Why It Matters**: Generic messages provide zero context for future developers (including future you). "WIP" in shared history is unprofessional and unhelpful. Descriptive messages like "Add retry logic for failed API requests" tell a story.

### 2. Squash Opportunity Detection

**Purpose**: Identify commits that should be combined before pushing to keep history clean and logical.

**Detection Indicators**:

1. **Same files modified** - Commits touching identical files
2. **Fix relationship** - One commit fixes the previous ("Add X" → "Fix typo in X")
3. **Same component** - Commits mentioning same module/feature
4. **Small related changes** - Total lines < 200, clearly related

**Detection Algorithm**:

```bash
detect_squash_opportunities() {
  local branch="$1"
  local opportunities=()

  # Get commits in chronological order
  local commits
  commits=$(git log --reverse --format="%H" origin/"$branch"..HEAD 2>/dev/null || git log --reverse -n 5 --format="%H")

  local prev_commit=""
  local prev_files=""
  local prev_summary=""

  while IFS= read -r commit; do
    if [ -z "$prev_commit" ]; then
      # First commit, store and continue
      prev_commit="$commit"
      prev_files=$(git diff-tree --no-commit-id --name-only -r "$commit" | sort)
      prev_summary=$(git log -1 --format="%s" "$commit")
      continue
    fi

    local curr_files curr_summary
    curr_files=$(git diff-tree --no-commit-id --name-only -r "$commit" | sort)
    curr_summary=$(git log -1 --format="%s" "$commit")

    # Check for file overlap
    local overlap
    overlap=$(comm -12 <(echo "$prev_files") <(echo "$curr_files") | wc -l | tr -d ' ')

    if [ "$overlap" -gt 0 ]; then
      # Check for fix relationship
      if echo "$curr_summary" | grep -qiE "^(fix|correct|adjust|tweak|update)"; then
        opportunities+=("WARNING: Commits ${prev_commit:0:7} and ${commit:0:7} might be related (fix pattern)")
        opportunities+=("  - Previous: $prev_summary")
        opportunities+=("  - Current:  $curr_summary")
        opportunities+=("  - Shared files: $overlap")
      fi

      # Check for same component/module
      local prev_component curr_component
      prev_component=$(echo "$prev_summary" | sed -E 's/^(Add|Fix|Update|Remove|Refactor) ([a-zA-Z_-]+).*/\2/' | tr '[:upper:]' '[:lower:]')
      curr_component=$(echo "$curr_summary" | sed -E 's/^(Add|Fix|Update|Remove|Refactor) ([a-zA-Z_-]+).*/\2/' | tr '[:upper:]' '[:lower:]')

      if [ "$prev_component" = "$curr_component" ] && [ -n "$prev_component" ] && [ "$prev_component" != "$prev_summary" ]; then
        opportunities+=("WARNING: Commits ${prev_commit:0:7} and ${commit:0:7} mention same component ($prev_component)")
      fi
    fi

    prev_commit="$commit"
    prev_files="$curr_files"
    prev_summary="$curr_summary"
  done <<< "$commits"

  if [ ${#opportunities[@]} -gt 0 ]; then
    printf '%s\n' "${opportunities[@]}"
    return 1  # Has opportunities
  fi

  return 0  # No opportunities
}
```

**Issue Severity**: **WARNING** - Suggests cleanup, doesn't block push

**Why It Matters**: Squashing related commits makes history easier to review and understand. "Add feature" → "Fix typo" → "Actually fix typo" should be one commit: "Add feature".

### 3. Format Compliance Verification

**Purpose**: Ensure all commits follow standard formatting rules for professional history.

**Checks Performed**:

1. **Summary length** - ≤72 characters (50 ideal, 72 max)
2. **Imperative mood** - "Add" not "Added" or "Adds"
3. **Capitalization** - First word capitalized
4. **No period** - Summary should not end with period
5. **Blank line** - Between summary and body (if body exists)
6. **Body wrapping** - Lines wrapped at 72 characters

**Detection Algorithm**:

```bash
check_commit_format() {
  local commit="$1"
  local issues=()

  # Get commit message components
  local summary body
  summary=$(git log -1 --format="%s" "$commit")
  body=$(git log -1 --format="%b" "$commit")
  local summary_len=${#summary}

  # Check 1: Length (CRITICAL if > 80, WARNING if 73-80)
  if [ "$summary_len" -gt 80 ]; then
    issues+=("BLOCKER: Summary too long ($summary_len chars, max 80)")
    issues+=("  Current: $summary")
    issues+=("  Fix: Shorten to essential information")
  elif [ "$summary_len" -gt 72 ]; then
    issues+=("WARNING: Summary longer than ideal ($summary_len chars, ideal ≤72)")
    issues+=("  Current: $summary")
  fi

  # Check 2: Capitalization
  if ! echo "$summary" | grep -qE '^[A-Z]'; then
    issues+=("MEDIUM: Summary should start with capital letter")
    issues+=("  Current: $summary")
    issues+=("  Fix: Capitalize first word")
  fi

  # Check 3: Period at end
  if echo "$summary" | grep -qE '\.$'; then
    issues+=("LOW: Summary should not end with period")
    issues+=("  Current: $summary")
  fi

  # Check 4: Imperative mood (heuristic check)
  local first_word
  first_word=$(echo "$summary" | awk '{print $1}')

  # Past tense patterns
  if echo "$first_word" | grep -qE "^(Added|Fixed|Updated|Removed|Changed|Modified|Created|Deleted|Implemented|Refactored)$"; then
    issues+=("MEDIUM: Use imperative mood: '${first_word%ed}' not '$first_word'")
    issues+=("  Current: $summary")
  fi

  # Present tense patterns
  if echo "$first_word" | grep -qE "^(Adds|Fixes|Updates|Removes|Changes|Modifies|Creates|Deletes|Implements|Refactors)$"; then
    issues+=("MEDIUM: Use imperative mood: '${first_word%s}' not '$first_word'")
    issues+=("  Current: $summary")
  fi

  # Check 5: Body wrapping (if body exists)
  if [ -n "$body" ]; then
    local line_num=0
    while IFS= read -r line; do
      line_num=$((line_num + 1))
      local line_len=${#line}

      # Skip empty lines and lines that are URLs or paths
      if [ "$line_len" -eq 0 ] || echo "$line" | grep -qE '^https?://|^/|^  '; then
        continue
      fi

      if [ "$line_len" -gt 72 ]; then
        issues+=("LOW: Body line $line_num too long ($line_len chars, max 72)")
        issues+=("  Line: ${line:0:60}...")
        break  # Only report first violation
      fi
    done <<< "$body"
  fi

  # Return results
  if [ ${#issues[@]} -gt 0 ]; then
    printf '%s\n' "${issues[@]}"
    return 1  # Has issues
  fi

  return 0  # No issues
}
```

**Issue Severity Mapping**:

- Summary > 80 chars: **BLOCKER**
- Summary 73-80 chars: **WARNING**
- Past/present tense: **MEDIUM**
- No capitalization: **MEDIUM**
- Period at end: **LOW**
- Body not wrapped: **LOW**

**Why It Matters**: Format rules exist for readability. 72-character lines fit in all contexts (terminals, diff views, email). Imperative mood reads naturally: "This commit will Add feature" not "This commit will Added feature".

## Test Detection and Integration

Phase 4.5 can detect and offer to run tests before pushing code to remote.

### Test Detection Patterns

**Files/Patterns Checked** (in priority order):

1. **Node.js** - `package.json` with test scripts
2. **Make** - `Makefile` with test targets
3. **Python** - `pytest.ini`, `pyproject.toml`, or `tests/` directory
4. **Go** - `go.mod` file
5. **Rust** - `Cargo.toml` file

**Detection Algorithm**:

```bash
detect_test_commands() {
  local test_commands=()

  # 1. Node.js - package.json
  if [ -f "package.json" ]; then
    if command -v jq &>/dev/null; then
      # Use jq if available
      local test_script
      test_script=$(jq -r '.scripts.test // empty' package.json 2>/dev/null)
      if [ -n "$test_script" ]; then
        test_commands+=("npm test")
      fi

      # Check for other test scripts
      local other_tests
      other_tests=$(jq -r '.scripts | keys[] | select(test("^test:"))' package.json 2>/dev/null)
      while IFS= read -r script; do
        if [ -n "$script" ]; then
          test_commands+=("npm run $script")
        fi
      done <<< "$other_tests"
    else
      # Fallback: grep for test script
      if grep -q '"test"' package.json 2>/dev/null; then
        test_commands+=("npm test")
      fi
    fi
  fi

  # 2. Make - Makefile
  if [ -f "Makefile" ]; then
    local make_targets
    make_targets=$(grep -E '^test[^:]*:' Makefile 2>/dev/null | sed 's/:.*//')
    while IFS= read -r target; do
      if [ -n "$target" ]; then
        test_commands+=("make $target")
      fi
    done <<< "$make_targets"
  fi

  # 3. Python - pytest
  if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] || [ -d "tests" ]; then
    if command -v pytest &>/dev/null; then
      test_commands+=("pytest")
    elif python3 -c "import pytest" 2>/dev/null; then
      test_commands+=("python3 -m pytest")
    fi
  fi

  # 4. Go - go test
  if [ -f "go.mod" ]; then
    if command -v go &>/dev/null; then
      test_commands+=("go test ./...")
    fi
  fi

  # 5. Rust - cargo test
  if [ -f "Cargo.toml" ]; then
    if command -v cargo &>/dev/null; then
      test_commands+=("cargo test")
    fi
  fi

  # Output found commands (one per line)
  if [ ${#test_commands[@]} -gt 0 ]; then
    printf '%s\n' "${test_commands[@]}"
    return 0  # Tests available
  fi

  return 1  # No tests found
}
```

### Test Execution Protocol

**Execution with Safety Measures**:

```bash
run_tests() {
  local test_command="$1"
  local timeout_seconds="${2:-300}"  # Default 5 minutes

  echo "Running: $test_command"
  echo "Timeout: ${timeout_seconds}s"
  echo "----------------------------------------"

  # Create temp file for output
  local output_file
  output_file=$(mktemp)

  # Run with timeout, capture output
  if timeout "$timeout_seconds" bash -c "$test_command" > "$output_file" 2>&1; then
    local exit_code=$?

    # Show output
    cat "$output_file"
    rm -f "$output_file"

    if [ $exit_code -eq 0 ]; then
      echo "----------------------------------------"
      echo "✓ Tests PASSED"
      return 0
    else
      echo "----------------------------------------"
      echo "✗ Tests FAILED (exit code: $exit_code)"
      return 1
    fi
  else
    local timeout_exit=$?

    # Show partial output
    cat "$output_file"
    rm -f "$output_file"

    if [ $timeout_exit -eq 124 ]; then
      echo "----------------------------------------"
      echo "⚠ Tests TIMED OUT after ${timeout_seconds}s"
      return 2
    else
      echo "----------------------------------------"
      echo "✗ Tests FAILED"
      return 1
    fi
  fi
}
```

**Test Result Handling**:

- **PASS (exit 0)**: Continue to next step or Phase 5
- **FAIL (exit 1)**: Show output, offer Fix/Override/Cancel
- **TIMEOUT (exit 2)**: Offer to retry with longer timeout, skip, or cancel
- **COMMAND ERROR**: Test command not found or syntax error, offer skip or cancel

## User Interaction Flows

Phase 4.5 presents different options based on what it detects.

### Flow Scenario A: No Issues + Tests Available

**Situation**: Commits are clean, tests detected

**Flow**:

```text
✓ Quality Check PASSED
  - No generic messages
  - No format violations
  - No squash opportunities

✓ Test Detection
  Found: npm test

Run tests before pushing?
```

**Options via AskUserQuestion**:

1. **Yes, run tests** - Execute test command, show results
2. **No, skip tests** - Proceed to Phase 5
3. **Cancel** - Exit workflow

**If user chooses "Yes"**:

- Run tests with timeout
- If PASS → Proceed to Phase 5
- If FAIL → Enter Flow Scenario D

### Flow Scenario B: Issues Detected + No Tests

**Situation**: Quality issues found, no tests available

**Flow**:

```text
⚠ Quality Issues Detected (2 blockers, 1 warning)

BLOCKER (2):
  • Commit abc123: Generic message "WIP"
    Suggestion: Describe what was accomplished

  • Commit def456: Summary too long (85 chars)
    Current: "Add comprehensive authentication system with JWT and OAuth integration support"
    Suggestion: "Add authentication with JWT and OAuth support"

WARNING (1):
  • Commits abc123 and ghi789 modify same files
    Suggestion: Consider squashing related commits

What would you like to do?
```

**Options via AskUserQuestion**:

1. **Fix quality issues** - Return to Phase 3 or 4 to fix
2. **Override and push anyway** - Require justification if blockers
3. **Cancel** - Exit workflow

**If user chooses "Fix"**:

- Determine issue type (message vs. history)
- If message issues → Return to Phase 3 for reword
- If squash issues → Return to Phase 4 for cleanup
- User makes changes, workflow re-runs from that phase

**If user chooses "Override"**:

- If BLOCKER severity → Require justification (freeform text, min 10 chars)
- If WARNING/INFO only → Optional justification
- Log override reason in summary
- Proceed to Phase 5

### Flow Scenario C: Issues Detected + Tests Available

**Situation**: Quality issues and tests both present

**Flow**:

```text
⚠ Quality Issues Detected (1 blocker)

BLOCKER:
  • Commit abc123: Generic message "fix"

✓ Test Detection
  Found: npm test

What would you like to do?
```

**Options via AskUserQuestion**:

1. **Fix quality issues** - Return to Phase 3/4
2. **Run tests anyway** - Execute tests despite quality issues
3. **Override and push** - Require justification
4. **Cancel** - Exit workflow

**If user chooses "Run tests"**:

- Execute tests
- If PASS → Still show quality issues, ask Fix/Override/Cancel
- If FAIL → Show both problems, stronger suggestion to fix

**Combinations to Handle**:

- Tests PASS + Issues remain → "Tests passed, but quality issues remain. Fix or override?"
- Tests FAIL + Issues remain → "Tests failed AND quality issues found. Strongly recommend fixing both."

### Flow Scenario D: Tests Fail

**Situation**: Tests were run and failed

**Flow**:

```text
✗ Tests FAILED

Test Suites: 2 failed, 1 passed, 3 total
Tests:       3 failed, 21 passed, 24 total

Failures:
  ● Login validation › should reject invalid email
    Expected: 400
    Received: 500

  [... output truncated ...]

What would you like to do?
```

**Options via AskUserQuestion**:

1. **Fix code and add commit** - Exit workflow, user fixes, re-run
2. **Push anyway with reason** - Require strong justification
3. **Cancel and investigate** - Exit workflow

**If user chooses "Fix code"**:

- Exit workflow gracefully
- User fixes failures locally
- User re-runs workflow from Phase 1

**If user chooses "Push anyway"**:

- Require justification (freeform, min 20 chars for test failures)
- Example reasons: "Tests are flaky, fixing in next PR", "Urgent hotfix, tests will be fixed separately"
- Log justification in summary
- Proceed to Phase 5

## Quality Report Format

**Visual Structure**:

```text
╔════════════════════════════════════════════════════════════════════╗
║           PHASE 4.5: PRE-PUSH QUALITY REVIEW                       ║
╚════════════════════════════════════════════════════════════════════╝

┌─ Push Preview ─────────────────────────────────────────────────────┐
│                                                                     │
│ Branch:          feature/user-authentication                       │
│ Commits to push: 3                                                 │
│ Files changed:   8 files (+245, -67)                               │
│                                                                     │
│ Commits:                                                            │
│   1. a1b2c3d Add JWT authentication to API endpoints               │
│   2. d4e5f6g Fix typo in error message                             │
│   3. g7h8i9j Add tests for authentication                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─ Quality Analysis ─────────────────────────────────────────────────┐
│                                                                     │
│ ✓ No issues detected                                               │
│                                                                     │
│ Analysis completed:                                                 │
│   • Generic message check: PASSED                                  │
│   • Format compliance: PASSED                                      │
│   • Squash detection: PASSED                                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─ Test Detection ───────────────────────────────────────────────────┐
│                                                                     │
│ ✓ Found test commands:                                             │
│   • npm test                                                        │
│   • npm run test:integration                                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**With Issues**:

```text
┌─ Quality Analysis ─────────────────────────────────────────────────┐
│                                                                     │
│ ⚠ ISSUES DETECTED (2 blockers, 1 warning)                          │
│                                                                     │
│ BLOCKER (2):                                                        │
│   • Commit d4e5f6g: Generic commit message "WIP"                   │
│     Suggestion: Reword to describe what was accomplished           │
│                                                                     │
│   • Commit a1b2c3d: Summary too long (78 chars, max 72)            │
│     Current: "Add comprehensive JWT authentication system..."      │
│     Suggestion: "Add JWT authentication to API endpoints"          │
│                                                                     │
│ WARNING (1):                                                        │
│   • Commits d4e5f6g and a1b2c3d modify same files                  │
│     Suggestion: Consider squashing into single commit              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Override Handling

When users choose to push despite quality issues or test failures, handle appropriately.

### Override Requirements by Severity

**BLOCKER Issues**:

- **Require justification**: Freeform text input, minimum 10 characters
- **Examples**: "Quick WIP to share with team, will clean up before merge", "Hotfix for production, proper commit message to follow"
- **Validation**: Must provide reason, cannot be empty

**WARNING Issues**:

- **Optional justification**: Suggested but not required
- **Can proceed** without extensive explanation

**INFO Issues**:

- **No justification**: Informational only, can proceed freely

### Test Failure Overrides

**Requirements**:

- **Always require justification**: Minimum 20 characters
- **Strong warning**: "Pushing failing tests can break CI/CD and block team"
- **Examples**: "Tests are flaky on this machine, pass in CI", "Urgent hotfix, tests being fixed in parallel"

### Override Logging

**Not persisted**, but shown in Phase 4.5 summary:

```text
╔════════════════════════════════════════════════════════════════════╗
║                    QUALITY REVIEW SUMMARY                          ║
╚════════════════════════════════════════════════════════════════════╝

Status: OVERRIDDEN

Issues detected: 2 blockers
Override reason: "Quick WIP push to share with team for feedback, will clean up before final merge"

User: John Doe <john@example.com>
Date: 2026-01-02 15:45:00 UTC

⚠ NOTE: These commits have known quality issues. Clean up before merging to main.

Proceeding to Phase 5...
```

## Edge Cases and Solutions

### Edge Case 1: No Commits to Push

**Detection**:

```bash
COMMITS=$(git log origin/"$branch"..HEAD --format="%h" 2>/dev/null)
if [ -z "$COMMITS" ]; then
  # No commits to push
fi
```

**Handling**:

- Skip Phase 4.5 entirely
- Show message: "Working directory is up-to-date with remote"
- Exit workflow gracefully

### Edge Case 2: Only One Commit

**Impact**: Squash detection doesn't apply

**Handling**:

- Run generic message and format checks
- Skip squash opportunity detection
- Don't mention squashing in report

### Edge Case 3: All Commits Already Pushed

**Detection**:

```bash
git diff origin/"$branch" HEAD --quiet
if [ $? -eq 0 ]; then
  # No differences, already pushed
fi
```

**Handling**:

- Show: "All commits already pushed to origin/$branch"
- Skip Phase 4.5
- Exit workflow

### Edge Case 4: Test Command Exists But Fails to Execute

**Scenario**: `npm test` in package.json but npm not installed

**Detection**: Command exit code indicates command not found

**Handling**:

```text
⚠ Test Execution Error

Command: npm test
Error: npm: command not found

This might be because:
  • npm is not installed
  • npm is not in PATH
  • Wrong test command for this environment

Options:
1. Skip tests and proceed to push
2. Cancel and fix environment
3. Enter custom test command
```

### Edge Case 5: Tests Pass But Quality Issues Remain

**Handling**:

```text
Results:
  ✓ Tests PASSED (24/24)
  ⚠ Quality issues detected (1 blocker)

Tests passing is good! However, commit quality issues remain.

Recommendation: Fix quality issues for better history, then push.

Options:
1. Fix quality issues (recommended)
2. Override and push (tests passed, quality can be overridden)
3. Cancel
```

### Edge Case 6: Tests Fail But Quality is Good

**Handling**:

```text
Results:
  ✓ Commit quality GOOD
  ✗ Tests FAILED (2/24)

Your commits are well-formatted, but tests are failing.

⚠ Pushing failing tests can break CI/CD and block team members.

Recommendation: Fix tests before pushing.

Options:
1. Fix code and add commits (recommended)
2. Push anyway with strong justification (NOT recommended)
3. Cancel and investigate
```

### Edge Case 7: Multiple Test Commands Available

**Handling**:

```text
✓ Found multiple test commands:
  1. npm test (unit tests)
  2. npm run test:integration (integration tests)
  3. npm run test:e2e (end-to-end tests)

Which would you like to run?
1. Run all tests sequentially
2. Choose specific test suite
3. Skip tests
```

**If user chooses "Run all"**:

- Execute sequentially: unit → integration → e2e
- Stop on first failure
- Show cumulative results

### Edge Case 8: User Repeatedly Chooses Fix

**Detection**: Track Phase 4.5 execution count in session (3+ returns)

**Handling**:

```text
⚠ NOTICE: This is your 3rd time in quality review

The same issues keep appearing. You might want to:
  • Review commit message guidelines: commit-format.md
  • Use a commit message template
  • Ask for help if unsure about standards

Options:
1. See commit message examples
2. Continue fixing issues
3. Override and push anyway
4. Cancel
```

**If user chooses "See examples"**:

- Show 3-4 good examples from commit-format.md
- Return to fix options

### Edge Case 9: New Branch (No Upstream)

**Detection**:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
if [ $? -ne 0 ]; then
  # No upstream configured
fi
```

**Handling**:

- Can't use `git log origin/$branch..HEAD`
- Instead: Count all commits on current branch
- Show in preview: "New branch (will create upstream on push)"
- Proceed normally with local commit analysis

### Edge Case 10: Quality Analysis Takes Too Long

**Scenario**: Repository with 1000+ commits to push

**Handling**:

- Set 2-second timeout for analysis
- If exceeded, show progress: "Analyzing commit 500/1234..."
- Limit detailed checks to last 50 commits
- Show summary for older commits: "Analyzed last 50 commits, 950 older commits present"

### Edge Case 11: Test Run Modifies Working Directory

**Scenario**: Tests generate coverage reports, temp files

**Detection**:

```bash
git status --short
# After test run, check if files modified
```

**Handling**:

```text
⚠ Tests modified working directory

Files changed during test run:
  M coverage/lcov.info
  ?? .nyc_output/

These are NOT included in commits to push.

Recommendation:
  • Add these to .gitignore if they're test artifacts
  • Commit them if they should be tracked

Continue to push? [Yes/No]
```

### Edge Case 12: Detached HEAD State

**Detection**:

```bash
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
  # Detached HEAD
fi
```

**Handling**:

- Phase 4.5 should NOT run in detached HEAD
- Earlier phase (Phase 1) should catch and handle
- If somehow reached: Show error, exit workflow

## Performance Optimization

**Target Performance**:

- Quality analysis: < 2 seconds for 50 commits
- Test detection: < 0.5 seconds
- Total Phase 4.5 overhead: < 3 seconds (excluding test execution)

**Optimization Techniques**:

1. **Limit commit analysis** - Default to last 50 commits
2. **Use git plumbing commands** - Faster than porcelain
3. **Minimize external calls** - Use bash built-ins where possible
4. **Parallel checks** - Run independent checks concurrently
5. **Early exit** - Stop analysis on first BLOCKER found (optional)

**Example Parallel Execution**:

```bash
# Run all three checks in parallel
{
  check_generic_messages "$branch" > /tmp/generic.txt
} &
{
  detect_squash_opportunities "$branch" > /tmp/squash.txt
} &
{
  check_format_compliance "$branch" > /tmp/format.txt
} &

# Wait for all to complete
wait

# Collect results
cat /tmp/generic.txt /tmp/squash.txt /tmp/format.txt
rm -f /tmp/generic.txt /tmp/squash.txt /tmp/format.txt
```

## Error Handling and Graceful Degradation

**Philosophy**: Never block workflow due to Phase 4.5 internal errors - only due to actual quality issues.

**Error Scenarios**:

### Git Command Failure

```bash
if ! git log origin/"$branch"..HEAD 2>/dev/null; then
  echo "⚠ Warning: Quality analysis failed (git error)"
  echo "You may want to manually review commits before pushing"
  echo ""
  echo "Proceeding to Phase 5..."
  return 0  # Continue anyway
fi
```

### Test Detection Failure

```bash
if ! detect_test_commands 2>/dev/null; then
  echo "⚠ Warning: Test detection failed"
  echo "No tests will be offered"
  # Continue without test option
fi
```

### Test Execution Crash

```bash
if ! run_tests "$command" 2>&1; then
  local exit_code=$?
  if [ $exit_code -gt 2 ]; then
    echo "⚠ Test execution crashed (exit code: $exit_code)"
    echo "This is likely a test runner error, not a test failure"
    echo ""
    echo "Options:"
    echo "1. Skip tests and proceed"
    echo "2. Cancel and investigate"
  fi
fi
```

## Integration with Other Phases

**Phase 4 → Phase 4.5 Handoff**:

- Working directory is clean
- Commits are created (and optionally cleaned up)
- Ready for quality review

**Phase 4.5 → Phase 5 Handoff**:

- Quality checked (passed or overridden)
- Tests run (passed, skipped, or overridden)
- Push preview generated
- Ready for push confirmation

**Returning to Earlier Phases**:

- **Return to Phase 3**: For commit message rewording, adding new commits
- **Return to Phase 4**: For squashing, reordering, history cleanup
- After fixes, workflow re-runs from that phase and eventually returns to Phase 4.5

**Phase 5 Integration**:

- Phase 5 receives clean commits (or override acknowledgment)
- Phase 5 still performs protected branch check
- Phase 5 shows final push confirmation

## Summary

Phase 4.5 is the quality gate before pushing to remote. It:

✅ **Prevents embarrassment** - Catches "WIP" and vague messages
✅ **Maintains standards** - Enforces format and best practices
✅ **Enables testing** - Runs tests before code reaches remote
✅ **Educates developers** - Teaches commit quality through feedback
✅ **Allows flexibility** - Permits override with justification

**Key Principles**:

- **Always run** - Mandatory before every push
- **Be helpful** - Suggest specific fixes, not just complaints
- **Be flexible** - Allow override when justified
- **Be fast** - Complete in < 3 seconds
- **Be educational** - Explain why quality matters

For practical examples of Phase 4.5 in action, see [examples.md](examples.md#example-11-phase-45-catches-generic-messages).
