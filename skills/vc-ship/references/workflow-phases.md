# Workflow Phase Details

## Phase 0: Branch Management

**Goal**: Prevent accidental work on protected branches and ensure proper isolation.

Detects protected branches (main/master/develop/production/staging), blocks the workflow if uncommitted changes exist on them, and offers to create a feature branch. Skips if already on a feature branch.

See **[branch-protection.md](branch-protection.md)** for the full detection and migration protocol.

## Phase 1: Repository Analysis

**Goal**: Thoroughly understand the current repository state and changes.

**Clean tree shortcut**: If the working tree is clean but unpushed commits exist, skip Phases 2-4 and proceed directly to Phase 5. The existing commits are the work to ship.

**Steps**:

1. Run these commands in parallel:
   - `git status --short`
   - `git diff` and `git diff --staged`
   - `git log --oneline -n 10`

2. Analyze changes to identify:
   - Types (feature, fix, refactor, docs, config, tests)
   - Affected files and relationships
   - Logical groupings for atomic commits
   - Untracked files needing attention

**Safety checks**:

- Merge conflict markers in diff output → STOP
- Rebase in progress (`.git/rebase-merge` or `.git/rebase-apply`) → STOP
- No remotes (`git remote`) → continue through Phase 5, skip Phases 6-7
- Symlinks in changed files → exclude from commit plan, inform user
- Bare git repo → not supported, exit with message about using the repo's wrapper command

**Branch freshness check** (required when a remote exists):

Repos using rebase-merge rewrite commit SHAs on merge. If the branch base diverged from `origin/main`, false merge conflicts result.

1. `git fetch origin`
2. Detect default branch: `git remote show origin | grep "HEAD branch" | awk '{print $NF}'`
3. Find merge-base: `git merge-base HEAD origin/<default-branch>`
4. If merge-base is not an ancestor of `origin/<default-branch>` (`git merge-base --is-ancestor` exits non-zero), the base is stale
5. Stash if needed, rebase onto `origin/<default-branch>`, restore stash
6. If rebase has conflicts → STOP

## Phase 2: Organize into Atomic Commits

**Goal**: Group changes into logical, atomic commits — one logical change per commit.

**Principles**: Each commit should be self-contained and compilable. Related changes stay together (code + its tests). Unrelated changes go in separate commits.

**Grouping priority**: bug fixes → tests → refactoring → features → docs → config

**Steps**:

1. Analyze all changed files
2. Re-inspect individual diffs (`git diff <file>`) when grouping is ambiguous
3. Group by category, identify sub-groups within categories
4. Create commit plan (files per commit, brief descriptions)
5. Present plan to user for approval

**Cross-cutting docs**: When a single file (e.g., README) references changes from multiple commits, prefer a trailing docs commit over splitting with `git add -p`.

Use **TaskCreate** to track each commit if 3+ commits planned.

## Phase 3: Create Commits

**Goal**: Create each commit with a properly formatted message.

For each commit: stage files → generate message → commit via heredoc → verify with `git log -1 --oneline`.

```bash
git add <files>
git commit -m "$(cat <<'EOF'
Summary line here

Body explaining WHY, not WHAT.
EOF
)"
```

If files are in a gitignored directory but should be tracked, use `git add -f`.

See **[commit-format.md](commit-format.md)** for message formatting rules and templates.

## Phase 4: History Cleanup (Optional)

**Goal**: Optionally reorganize recent commits for a cleaner history before pushing.

**Offer when**: multiple squashable commits, poor messages, WIP/fix commits.
**Skip when**: commits already pushed, shared branch, only one commit.

**Never use `git rebase -i`** — use `git reset --soft HEAD~N` and recommit.

See **[rebase-guide.md](rebase-guide.md)** for the approach and safety checklist.

## Phase 5: Pre-Push Quality Review (Mandatory)

**Goal**: Ensure commit quality and verify tests before pushing.

This mandatory gate runs after Phase 3/4. It checks for generic messages, squash opportunities, and format compliance, then offers to run tests.

See **[phase-5-protocol.md](phase-5-protocol.md)** for the complete protocol.

## Phase 6: Push with Confirmation

**Goal**: Push commits to remote safely after user approval.

**Skip entirely if no remote was detected in Phase 1.**

Checks for detached HEAD, fetches latest, detects protected branches and blocks pushes to them. For non-protected branches: show commit summary, ask for confirmation, push with `-u` for new branches.

See **[branch-protection.md](branch-protection.md)** for push-time protection.

## Phase 7: Pull Request Creation (Optional)

**Goal**: Create a pull request after successful push.

**Skip entirely if no remote exists.**

1. Ask if user wants a PR
2. Verify `gh` CLI available (fallback: provide GitHub compare URL)
3. Detect base branch: `git remote show origin | grep "HEAD branch"`
4. Gather context in parallel:
   ```bash
   git diff --stat <base>...HEAD
   git diff --name-only <base>...HEAD
   git log --oneline <base>...HEAD
   ```
5. **Large PR check**: >20 files or >500 net lines → warn, suggest splitting. Don't block.
6. Generate title (≤72 chars) and description with sections: Summary, Changes, Breaking Changes, Dependencies, Testing, Related Issues. Omit empty sections entirely.
7. Show to user for review
8. Create via `gh pr create` with heredoc body
9. Show PR URL

## Workflow Complete

Print summary:

- **Branch**: `{name}`
- **Commits**: `{count}` (list of summary lines)
- **Pushed**: Yes/No
- **PR**: {URL or "not created"}
