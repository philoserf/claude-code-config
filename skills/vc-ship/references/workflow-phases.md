# Workflow Phase Details

This document provides detailed instructions for each phase of the vc-ship skill.

## Phase 0: Branch Management

**Goal**: Prevent accidental work on protected branches and ensure proper isolation.

Detects protected branches (main/master/develop/production/staging), blocks the workflow if uncommitted changes exist on them, and offers to create a feature branch. Skips if already on a feature branch.

See **[phase-0-protocol.md](phase-0-protocol.md#detection-order)** for the full detection and migration protocol.

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
- Check for remotes: `git remote`. If none exist, note this and continue through Phase 5 but skip Phases 6-7 (push/PR) at the end. Inform the user that commits are local-only.

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

**Use TaskCreate** to track each commit as a task if there are 3+ commits. Update task status as you create each one.

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

For detailed formatting rules, examples, and templates, see [commit-format.md](commit-format.md#summary-line). Key rules:

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

**For detailed rebase safety guidelines, commands, and examples, see [rebase-guide.md](rebase-guide.md#safety-checklist).**

## Phase 5: Pre-Push Quality Review (Mandatory)

**Goal**: Ensure commit quality and verify tests before pushing to remote.

This mandatory phase runs after commits are created (Phase 3) or cleaned up (Phase 4). It generates a push preview, runs three quality checks (generic message detection, squash opportunity detection, format compliance), detects available test commands, and presents a quality report. Users can fix issues, run tests, override with justification, or cancel.

See **[phase-5-protocol.md](phase-5-protocol.md#three-quality-checks)** for complete quality check algorithms, test detection patterns, and user interaction flows.

## Phase 6: Push with Confirmation

**Goal**: Push commits to remote safely after user approval.

**Skip this phase entirely if no remote was detected in Phase 1.** Inform the user that commits are local-only and the workflow is complete.

Otherwise: checks for detached HEAD, fetches latest remote state, detects protected branches, and blocks pushes to them. For non-protected branches, shows a commit summary, asks for confirmation, and pushes (with `-u` for new branches). Force pushes to protected branches are absolutely blocked with no override.

See **[protected-branch-protocol.md](protected-branch-protocol.md#detection-order)** for the full protected branch push protocol.

## Phase 7: Pull Request Creation (Optional)

**Goal**: Optionally create a pull request after successful push.

**Skip this phase entirely if no remote exists.** The workflow ends after Phase 5 (or Phase 6 if push was skipped due to no remote).

**Steps**:

1. After successful push, ask if user wants to create a PR

2. If yes:
   - Verify `gh` CLI is available: `gh --version`
   - If not available, provide GitHub web URL for PR creation

3. Get base branch (default: main/master)
   - Detect default branch: `git remote show origin | grep "HEAD branch"`
   - Ask user if different base is needed

4. **Gather PR context** by running in parallel:

   ```bash
   git diff --stat <base>...HEAD        # files changed, insertions, deletions
   git diff --name-only <base>...HEAD   # file list for categorization
   git log --oneline <base>...HEAD      # commit list
   ```

5. **Large PR check**: If >20 files changed or >500 net lines, warn the user:
   - Show the stats
   - Suggest splitting if changes span unrelated areas
   - Ask: proceed with one PR, or split first?
   - Do not block — just inform

6. **Generate PR title and description**:
   - **Title**: First commit summary (single commit) or synthesized from all commits. Keep under 72 chars.
   - **Description** — build these sections from the diff and commits:

     ```markdown
     ## Summary

     [1-2 sentence overview] — [N files changed (+X, -Y)]

     ## Changes

     [Group by category: source, tests, config, docs. Bullet points from commits.]

     ## Breaking Changes

     [Only if API signatures, config schemas, or public interfaces changed. Omit section if none.]

     ## Dependencies

     [Only if lock files or manifest files were modified. Omit section if none.]

     ## Testing

     [Mention test additions/changes. Note if Phase 5 tests passed.]

     ## Related Issues

     [Extract #NNN, fixes #NNN, closes #NNN from commit messages. Omit if none.]
     ```

   - Omit empty optional sections entirely — don't include headings with "N/A" or "None"
   - Extract issue references (`#123`, `fixes #456`) from commit messages automatically

7. Show generated PR content to user for review

8. Create PR:

   ```bash
   gh pr create --title "<title>" --body "$(cat <<'EOF'
   <description>
   EOF
   )"
   ```

9. Show PR URL to user

**Alternative if gh not available**:

- Provide direct GitHub URL: `https://github.com/<owner>/<repo>/compare/<branch>`
