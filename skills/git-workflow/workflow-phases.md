# Workflow Phase Details

This document provides detailed instructions for each phase of the git-workflow skill.

## Phase 0: Branch Management

**Goal**: Prevent accidental work on protected branches and ensure proper isolation.

**CRITICAL**: This phase is MANDATORY when on protected branch with uncommitted changes.

**Steps**:

1. Check current branch: `git branch --show-current`

2. Check if on protected branch (main/master/develop/production/staging)

3. Check for uncommitted changes: `git diff-index --quiet HEAD --`

4. **If on protected branch WITH uncommitted changes:**
   - **BLOCK** the workflow
   - Show blocking message explaining risks
   - Present 3 options via AskUserQuestion:
     1. Create feature branch with auto-suggested name (RECOMMENDED)
     2. Create feature branch with custom name
     3. Override and continue on protected branch (requires confirmation)
   - Execute chosen option
   - See **[phase-0-protocol.md](phase-0-protocol.md)** for detailed protocol

5. **If on protected branch with CLEAN working directory:**
   - Show friendly proactive suggestion
   - Offer to create feature branch now
   - Allow user to skip (will check again if changes appear)

**Skip this phase if**:

- User is already on a feature branch
- User is on hotfix/_or release/_ branch (special handling)
- User is in detached HEAD state (separate edge case handling)

**Key differences from Phase 5**:

- Phase 0: Deals with UNCOMMITTED changes (uses `git stash`)
- Phase 5: Deals with COMMITTED changes (uses `git cherry-pick`)

## Phase 1: Repository Analysis

**Goal**: Thoroughly understand the current repository state and changes.

**Steps**:

1. Run these commands in parallel:
   - `git status --short` - See changed files compactly
   - `git diff` - See unstaged changes
   - `git diff --staged` - See staged changes (if any)
   - `git log --oneline -n 10` - See recent commit history

2. Analyze the changes to identify:
   - Types of changes (feature, fix, refactor, docs, config, tests)
   - Affected files and their relationships
   - Logical groupings for atomic commits
   - Any untracked files that might need attention

**Safety Checks**:

- Check for merge conflict markers in diff output
- Check for rebase in progress (look for `.git/rebase-merge` or `.git/rebase-apply`)
- Alert user and stop if conflicts or rebase in progress

## Phase 2: Organize into Atomic Commits

**Goal**: Group changes into logical, atomic commits that each represent a single coherent change.

**Atomic Commit Principles**:

- Each commit should represent ONE logical change
- Commits should be self-contained and compilable
- Related changes stay together (e.g., code + its tests)
- Unrelated changes should be in separate commits

**Grouping Strategy** (in priority order):

1. **Bug fixes** - Fixes to existing functionality
2. **Tests** - New or updated tests
3. **Refactoring** - Code improvements without behavior change
4. **Features** - New functionality
5. **Documentation** - README, comments, docs
6. **Configuration** - Build configs, dependencies, settings

**Steps**:

1. Analyze all changed files
2. Group files by the categories above
3. Within each category, identify sub-groups if changes are independent
4. Create a commit plan showing:
   - Each proposed commit
   - Files included
   - Brief description of what the commit will represent
5. Present plan to user for approval/adjustment

**Use TodoWrite** to track commits to be created if there are 3+ commits.

## Phase 3: Create Commits

**Goal**: Create each commit with a properly formatted commit message.

**For each commit in the plan**:

1. Stage the files: `git add <file1> <file2> ...`

2. Generate commit message following these rules:
   - **Summary line**: ≤72 characters, imperative mood, capitalize, no period
   - **Body**: Wrap at 72 characters, explain WHY not WHAT
   - Use bullet points for multiple aspects
   - Provide context that code can't convey

3. Execute commit using heredoc:

   ```bash
   git commit -m "$(cat <<'EOF'
   Summary line here

   Detailed body here if needed.

   - Bullet points if needed
   - Additional context
   EOF
   )"
   ```

4. Verify commit succeeded: `git log -1 --oneline`

**Commit Message Format**:

For detailed formatting rules, examples, and templates, see [commit-format.md](commit-format.md). Key rules:

- **Imperative mood**: "Add feature" not "Added feature"
- **Be specific**: "Fix null pointer in login" not "Fix bug"
- **Explain WHY**: Body should explain motivation and context
- **72 characters**: Summary ≤72 chars, body wrapped at 72

Good examples:

- "Add retry logic for failed API requests"
- "Fix race condition in payment processing"
- "Refactor database connection pooling for efficiency"

Bad examples:

- "fixed bug" (not imperative, not descriptive)
- "WIP" (never commit work-in-progress messages)
- "Added new feature for users." (past tense, has period)

## Phase 4: Commit History Cleanup (Optional)

**Goal**: Optionally reorganize recent commits for a cleaner history before pushing.

**When to offer cleanup**:

- Multiple commits exist that could be squashed
- Recent commit messages could be improved
- Commits would make more sense in different order
- Found "WIP" or "fix" commits that should be squashed

**When NOT to cleanup**:

- Commits have already been pushed to remote (unless user explicitly wants to force push)
- User is on shared branch with other developers
- Only one commit to push

**Safety First**:

1. Check if commits have been pushed: `git log origin/<branch>..HEAD`
2. If commits are pushed, warn about force push requirement
3. Ask user for explicit confirmation before proceeding

**Important**: NEVER use `git rebase -i` - it requires interactive input. Instead, explain to the user what commands they need to run manually, or use non-interactive git commands to achieve the same result (like `git reset --soft` followed by recommitting).

**For detailed rebase safety guidelines, commands, and examples, see [rebase-guide.md](rebase-guide.md).**

## Phase 4.5: Pre-Push Quality Review (Mandatory)

**Goal**: Ensure commit quality and verify tests before pushing to remote.

**This phase is MANDATORY** - always runs before Phase 5 to catch quality issues early.

**When Phase 4.5 Runs**:

- After Phase 3 (commits created) or Phase 4 (optional cleanup completed)
- Before Phase 5 (push to remote)
- ONLY if there are commits to push
- ONLY if working directory is clean

**Steps**:

1. **Generate Push Preview**:

   ```bash
   # Get commits to be pushed
   COMMITS=$(git log origin/"$CURRENT_BRANCH"..HEAD --format="%h %s" 2>/dev/null || \
             git log -n 5 --format="%h %s")  # Fallback for new branch

   # Get statistics
   STATS=$(git diff --stat origin/"$CURRENT_BRANCH"..HEAD 2>/dev/null || \
           git diff --stat HEAD~5..HEAD)  # Fallback for new branch

   # Count commits and files
   COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')
   FILES_CHANGED=$(echo "$STATS" | tail -1)  # Last line has summary

   ```

1. **Run Quality Analysis**:

   Run three quality checks on all commits to be pushed:

   **a. Generic Message Detection**
   - Check for patterns: WIP, fix, update, temp, oops, minor, changes, etc.
   - Case-insensitive matching at start or as whole word
   - Severity: **BLOCKER** - requires fix or explicit override

   **b. Squash Opportunity Detection**
   - Compare adjacent commits for same files modified
   - Detect fix relationships ("Add X" → "Fix typo in X")
   - Check for same component/module mentions
   - Severity: **WARNING** - suggests cleanup, doesn't block

   **c. Format Compliance Verification**
   - Summary ≤72 characters (BLOCKER if >80, WARNING if 73-80)
   - Imperative mood ("Add" not "Added" or "Adds")
   - First word capitalized
   - No period at end of summary
   - Body wrapped at 72 characters
   - Severity: Mixed (BLOCKER for >80 chars, MEDIUM for mood, LOW for others)

   **Classify issues by severity**: BLOCKER, WARNING, INFO

1. **Detect Test Commands**:

   Check for test commands in priority order:

   ```bash
   # 1. Node.js - package.json
   if [ -f "package.json" ]; then
     # Extract test script with jq or grep
     npm test, npm run test:*, etc.
   fi

   # 2. Make - Makefile
   if [ -f "Makefile" ]; then
     # Find test targets
     grep -E '^test[^:]*:' Makefile
   fi

   # 3. Python - pytest
   if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] || [ -d "tests" ]; then
     pytest or python3 -m pytest
   fi

   # 4. Go - go.mod
   if [ -f "go.mod" ]; then
     go test ./...
   fi

   # 5. Rust - Cargo.toml
   if [ -f "Cargo.toml" ]; then
     cargo test
   fi
   ```

1. **Present Quality Report**:

   Show formatted report with:
   - Push preview (branch, commit count, files changed, commit list)
   - Quality analysis results (issues categorized by severity)
   - Available test commands (if any detected)

   Example format:

   ```text
   ╔══════════════════════════════════════════════╗
   ║   PHASE 4.5: PRE-PUSH QUALITY REVIEW         ║
   ╚══════════════════════════════════════════════╝

   ┌─ Push Preview ──────────────────────────────┐
   │ Branch: feature/user-auth                   │
   │ Commits: 3                                  │
   │ Files: 8 files (+245, -67)                  │
   │ Commits:                                    │
   │   1. a1b2c3d Add authentication             │
   │   2. d4e5f6g Fix typo                       │
   │   3. g7h8i9j Add tests                      │
   └─────────────────────────────────────────────┘

   ┌─ Quality Analysis ──────────────────────────┐
   │ ✓ No issues detected                        │
   └─────────────────────────────────────────────┘

   ┌─ Test Detection ────────────────────────────┐
   │ ✓ Found: npm test                           │
   └─────────────────────────────────────────────┘

   ```

1. **User Decision**:

   Present different options based on findings:

   **If NO issues and NO tests**:
   - Proceed directly to Phase 5

   **If NO issues and tests available**:
   - Ask: "Run tests before pushing?"
   - Options: Yes/No/Cancel

   **If issues detected (no tests)**:
   - Show quality report
   - Options: Fix/Override/Cancel

   **If issues detected AND tests available**:
   - Show quality report
   - Options: Fix/Run tests/Override/Cancel

1. **Handle User Choice**:

   **Choice: Fix Issues**
   - Determine issue type:
     - Message issues (generic, format) → Return to Phase 3 for reword
     - History issues (squash opportunities) → Return to Phase 4 for cleanup
   - User makes changes
   - Workflow re-runs from that phase and returns to Phase 4.5

   **Choice: Run Tests**
   - Execute test command with 5-minute timeout
   - Show live output
   - Handle results:
     - **PASS**: Continue (or back to quality decision if issues remain)
     - **FAIL**: Offer Fix code/Override/Cancel
     - **TIMEOUT**: Offer Retry/Skip/Cancel
     - **ERROR**: Offer Skip/Cancel

   **Choice: Override**
   - If BLOCKER severity: Require justification (min 10 chars)
   - If WARNING/INFO only: Optional justification
   - If test failure: Require strong justification (min 20 chars)
   - Log override reason (shown in summary, not persisted)
   - Proceed to Phase 5

   **Choice: Cancel**
   - Exit workflow
   - User can investigate and re-run later

1. **Proceed to Phase 5**:

   Once quality is verified (passed or overridden) and tests complete (passed, skipped, or overridden):
   - Quality review complete
   - Continue to Phase 5 for protected branch check and push confirmation

**Quality Check Algorithms**:

For complete bash implementation of all quality checks, test detection patterns, and user interaction flows, see **[phase-4.5-protocol.md](phase-4.5-protocol.md)**.

**Key Principles**:

- **Always run** - This phase is not optional
- **Educate users** - Explain why issues matter
- **Allow override** - Permit push with justification
- **Fast analysis** - Complete in < 2 seconds (excluding test runs)
- **Be helpful** - Suggest specific fixes, not just complaints

**Edge Cases**:

- **No commits to push**: Skip Phase 4.5, exit workflow
- **Only one commit**: Skip squash detection
- **All commits already pushed**: Skip Phase 4.5
- **Test command not found**: Offer skip/cancel
- **Tests pass + issues remain**: Show both, ask Fix/Override
- **Tests fail + quality good**: Strong recommendation to fix
- **Multiple test commands**: Let user choose which to run
- **User returns 3+ times**: Offer examples and help

**Performance Targets**:

- Quality analysis: < 2 seconds for 50 commits
- Test detection: < 0.5 seconds
- Total overhead: < 3 seconds (excluding test execution)

**Error Handling**:

Never block workflow due to Phase 4.5 internal errors - only due to actual quality issues:

```bash
# If analysis fails
if ! analyze_commits 2>/dev/null; then
  echo "⚠ Quality analysis failed, proceeding anyway"
  echo "Manually review commits before pushing"
  # Continue to Phase 5
fi
```

## Phase 5: Push with Confirmation

**Goal**: Push commits to remote safely after user approval.

**Steps**:

1. **CRITICAL: Protected Branch Detection** (MUST BE FIRST):

   ```bash
   # 1a. Check for detached HEAD state first
   CURRENT_BRANCH=$(git branch --show-current)

   if [ -z "$CURRENT_BRANCH" ]; then
     # Detached HEAD state - handle before protected branch check
     echo "⚠️ You are in detached HEAD state"
     # Offer to create branch, then exit
     exit 1
   fi

   # 1b. Fetch latest remote state to avoid race conditions
   git fetch origin "$CURRENT_BRANCH" 2>/dev/null || true

   # 1c. Check for uncommitted changes (will interfere with migration)
   if ! git diff-index --quiet HEAD --; then
     echo "⚠️ You have uncommitted changes"
     echo "Please commit or stash changes before pushing"
     exit 1
   fi

   # 1d. Check if current branch is protected
   PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")

   if [[ " ${PROTECTED_BRANCHES[@]} " =~ " ${CURRENT_BRANCH} " ]]; then
     # STOP - Do NOT proceed with normal push flow
     # Enter Protected Branch Push Protocol
     # See protected-branch-protocol.md
   fi
   ```

   **If protected branch detected:**
   - **BLOCK the push** - do not show confirmation dialog
   - Display blocking message explaining why
   - Present 3 options using AskUserQuestion:
     1. Create feature branch and migrate commits (recommended)
     2. Rename current branch to feature branch
     3. Emergency override with reason (logged via audit commit)
   - Execute chosen option from protocol
   - See **[protected-branch-protocol.md](protected-branch-protocol.md)** for complete details

2. **Check for force push requirement:**

   ```bash
   # Detect if force push would be required
   # Check if remote branch has commits we don't have (non-fast-forward)
   if git fetch origin "$CURRENT_BRANCH" 2>/dev/null; then
     # Count commits on remote that we don't have
     REMOTE_AHEAD=$(git rev-list --count HEAD..origin/"$CURRENT_BRANCH" 2>/dev/null || echo "0")

     if [ "$REMOTE_AHEAD" -gt 0 ]; then
       # Remote has commits we don't have - would need force push

       # If current branch is protected - ABSOLUTELY BLOCK
       if [[ " ${PROTECTED_BRANCHES[@]} " =~ " ${CURRENT_BRANCH} " ]]; then
         echo "🛑 ABSOLUTELY BLOCKED: Force push to protected branch"
         # See protected-branch-protocol.md for blocking message
         # Exit - do not allow
       fi
     fi
   fi

   ```

3. Show summary of commits to be pushed:

   `git log origin/<branch>..HEAD --oneline`

(or just `git log --oneline -n <count>` if new branch)

1. Present summary to user:
   - Number of commits
   - Branch name
   - First line of each commit message
   - Whether this is a new branch or existing branch

2. Ask user for confirmation to push using AskUserQuestion

3. If user confirms:
   - For new branch: `git push -u origin <branch-name>`
   - For existing branch: `git push`

4. Verify push succeeded and show result

**Safety Checks** (in order):

1. **Protected branch check** - MUST be first, blocks if protected
2. **Force push to protected branch** - Absolutely blocked, no override
3. Verify remote exists: `git remote -v`
4. If no remote, help user set one up before pushing
5. Handle push failures gracefully (show error, suggest fixes)

**Key Principle**: Always check for protected branch BEFORE showing push confirmation. The user should never get to confirmation if on a protected branch.

## Phase 6: Pull Request Creation (Optional)

**Goal**: Optionally create a pull request after successful push.

**Steps**:

1. After successful push, ask if user wants to create a PR

2. If yes:
   - Verify `gh` CLI is available: `gh --version`
   - If not available, provide GitHub web URL for PR creation

3. Get base branch (default: main/master)
   - Detect default branch: `git remote show origin | grep "HEAD branch"`
   - Ask user if different base is needed

4. Generate PR title and description:
   - Title: Use first commit message summary (if single commit) or create from all commits
   - Description:

     ```markdown
     ## Summary

     [Brief overview of changes]

     ## Changes

     - [Bullet points from commits]

     ## Testing

     [Mention any test additions]
     ```

5. Show generated PR content to user for review

6. Create PR:

   ```bash
   gh pr create --title "<title>" --body "$(cat <<'EOF'
   <description>
   EOF
   )"
   ```

7. Show PR URL to user

**Alternative if gh not available**:

- Provide direct GitHub URL: `https://github.com/<owner>/<repo>/compare/<branch>`
