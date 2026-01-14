# Interactive Rebase Safety Guide

This guide covers when and how to safely use interactive rebase to clean up Git commit history.

## What is Interactive Rebase?

Interactive rebase (`git rebase -i`) allows you to modify commit history by:

- Reordering commits
- Combining (squashing) multiple commits into one
- Editing commit messages
- Removing commits
- Splitting commits

It's a powerful tool for creating clean, professional commit history before sharing your work.

## The Golden Rule

**Never rebase commits that have been pushed to a shared branch.**

Once commits are on a shared branch (like main or a branch others are working on), rewriting history creates problems for everyone else.

## When to Use Rebase

### Safe Scenarios (DO rebase)

1. **Local commits not yet pushed**
   - You made several "WIP" commits while developing
   - You want to clean them up before pushing
   - Example: Squash 5 messy commits into 2 clean ones

2. **Feature branch you own**
   - You're the only one working on this branch
   - Commits haven't been pushed yet (or you're willing to force push)
   - Example: Reorder commits for better logical flow

3. **After code review feedback**
   - Reviewer asks you to split a commit
   - You want to fixup a small change into earlier commit
   - You control the branch and team expects rebasing

### Unsafe Scenarios (DON'T rebase)

1. **Commits on main/master**
   - Never rebase shared branches
   - Use revert instead if you need to undo

2. **Commits others have based work on**
   - Someone else branched from your commits
   - Rebasing will break their branch

3. **Public commits in open source**
   - Once pushed to public repo, history should be stable
   - Others may have pulled your commits

4. **Uncertain about impact**
   - If you're not sure, don't rebase
   - You can always make a new commit instead

## Interactive Rebase Commands

When you run `git rebase -i HEAD~N`, Git opens an editor with a list of commits and commands.

### Available Commands

**pick** (or `p`)

- Keep this commit as-is
- Default command
- Use when commit is fine and shouldn't change

**reword** (or `r`)

- Keep the changes, but edit the commit message
- Git will open editor for you to rewrite the message
- Use to improve unclear commit messages

**edit** (or `e`)

- Pause rebase to manually edit this commit
- You can modify files, split commit, etc.
- Use when you need to make changes to the commit content

**squash** (or `s`)

- Combine this commit with the previous one
- Keeps both commit messages
- Git will let you edit the combined message
- Use to merge related commits while preserving context

**fixup** (or `f`)

- Combine this commit with the previous one
- Discard this commit's message
- Use for "fix typo" or "forgot to add file" commits

**drop** (or `d`)

- Remove this commit entirely
- Use for commits you don't want at all
- Be careful - this deletes work!

**exec** (or `x`)

- Run a shell command
- Rebase stops if command fails
- Use to run tests after each commit

### Command Order Matters

Commits are applied from top to bottom. The topmost commit is applied first.

Example:

```text
pick abc123 Add feature
pick def456 Add tests
pick ghi789 Fix typo
```

This means:

1. First, apply "Add feature"
2. Then, apply "Add tests" on top
3. Finally, apply "Fix typo" on top

## Common Rebase Scenarios

### Scenario 1: Squash "Fix" Commits

You have:

```text
pick abc123 Add login feature
pick def456 Add login tests
pick ghi789 Fix typo in login
pick jkl012 Oops forgot to commit CSS
```

You want: Two clean commits (feature + tests)

Change to:

```text
pick abc123 Add login feature
fixup jkl012 Oops forgot to commit CSS
squash ghi789 Fix typo in login
pick def456 Add login tests
```

Result:

- First commit: "Add login feature" with CSS and typo fix included
- Second commit: "Add login tests"

### Scenario 2: Improve Commit Messages

You have:

```text
pick abc123 stuff
pick def456 more stuff
pick ghi789 final changes
```

Change to:

```text
reword abc123 stuff
reword def456 more stuff
reword ghi789 final changes
```

Git will prompt you to rewrite each message.

### Scenario 3: Reorder Commits

You have:

```text
pick abc123 Add tests
pick def456 Add feature
pick ghi789 Add documentation
```

Better order (feature → tests → docs):

```text
pick def456 Add feature
pick abc123 Add tests
pick ghi789 Add documentation
```

### Scenario 4: Remove Unwanted Commit

You have:

```text
pick abc123 Add feature
pick def456 Debug logging (not needed)
pick ghi789 Add tests
```

Change to:

```text
pick abc123 Add feature
drop def456 Debug logging
pick ghi789 Add tests
```

Or just delete the line entirely:

```text
pick abc123 Add feature
pick ghi789 Add tests
```

## Safety Checks Before Rebasing

Always verify these conditions before rebasing:

### 1. Check if commits are pushed

```bash
# See unpushed commits
git log origin/your-branch..HEAD

# If this shows commits, they're safe to rebase
# If empty, all commits are pushed (be careful!)
```

### 2. Check branch status

```bash
# Make sure you're on the right branch
git branch --show-current

# Make sure it's not a protected branch
# (not main, master, develop, etc.)
```

### 3. Ensure clean working directory

```bash
git status

# Should show "nothing to commit, working tree clean"
# If not, commit or stash changes first
```

### 4. Create backup branch (optional but recommended)

```bash
# Create backup before rebasing
git branch backup-before-rebase

# If rebase goes wrong, you can recover:
# git reset --hard backup-before-rebase
```

## Step-by-Step Rebase Process

### 1. Identify commits to rebase

```bash
# See last 5 commits
git log --oneline -n 5

# Result:
# a1b2c3d (HEAD) Fix typo
# d4e5f6g Add tests
# g7h8i9j Add feature
# j0k1l2m Previous work
# m3n4o5p Older work
```

Want to rebase last 3 commits (Fix typo, Add tests, Add feature).

### 2. Start interactive rebase

```bash
# Rebase last 3 commits
git rebase -i HEAD~3

# Or rebase since a specific commit
git rebase -i j0k1l2m
```

### 3. Edit the rebase plan

Editor opens with:

```text
pick g7h8i9j Add feature
pick d4e5f6g Add tests
pick a1b2c3d Fix typo

# Rebase j0k1l2m..a1b2c3d onto j0k1l2m (3 commands)
```

Modify to:

```text
pick g7h8i9j Add feature
fixup a1b2c3d Fix typo
pick d4e5f6g Add tests
```

Save and close editor.

### 4. Git applies the changes

Git will:

- Apply "Add feature"
- Apply "Fix typo" and merge into "Add feature"
- Apply "Add tests"

### 5. Verify the result

```bash
# Check new history
git log --oneline -n 3

# Should show:
# x9y8z7w Add tests
# w6v5u4t Add feature (now includes the typo fix)
# j0k1l2m Previous work
```

### 6. Push (with force if needed)

If commits were already pushed:

```bash
# Force push (overwrites remote history)
git push --force-with-lease origin your-branch

# --force-with-lease is safer than --force
# It fails if remote has commits you don't have
```

## Handling Rebase Conflicts

Sometimes rebasing causes conflicts. Don't panic!

### When conflicts occur

```bash
# Git stops and shows:
# Auto-merging file.js
# CONFLICT (content): Merge conflict in file.js
# error: could not apply abc123... commit message
```

### Resolve conflicts

1. **Open conflicted files**
   - Look for `<<<<<<<`, `=======`, `>>>>>>>` markers
   - Edit to resolve conflicts

2. **Stage resolved files**

   `git add file.js`

3. **Continue rebase**

   `git rebase --continue`

4. **Or abort if needed**

   ```bash
   git rebase --abort
   # Returns to state before rebase started
   ```

## Common Mistakes and How to Fix

### Mistake 1: Rebased pushed commits

**Problem**: You rebased and force pushed, now teammate's branch is broken.

**Fix**:

```bash
# Recover old commits from reflog
git reflog

# Find the commit before rebase (look for "checkout" or "rebase")
# Reset to that commit
git reset --hard abc123

# Push to restore
git push --force origin your-branch
```

Lesson: Always check if commits are pushed before rebasing.

### Mistake 2: Lost commits during rebase

**Problem**: You dropped commits by accident.

**Fix**:

```bash
# Find lost commit in reflog
git reflog

# Cherry-pick it back
git cherry-pick abc123
```

Lesson: Create backup branch before rebasing.

### Mistake 3: Rebase created duplicate commits

**Problem**: After rebase, commits appear twice.

**Fix**:

```bash
# Abort if rebase is in progress
git rebase --abort

# Check remote status
git fetch origin

# Reset to remote if needed
git reset --hard origin/your-branch
```

Lesson: Make sure you're rebasing the right branch.

## Alternative: Avoid Rebase

Sometimes it's better to NOT rebase. Alternatives:

### Create a new clean commit

Instead of rebasing to fix a typo:

```bash
# Just make a new commit
git commit -m "Fix typo in login function"
```

### Use git commit --amend for latest commit

Only works for the most recent commit:

```bash
# Modify last commit
git add file.js
git commit --amend
```

### Use git revert to undo

Instead of rebasing to remove a commit:

```bash
# Create new commit that undoes changes
git revert abc123
```

## Best Practices

1. **Rebase locally before pushing**
   - Clean up messy development commits
   - Create logical story before sharing

2. **Use backup branches**
   - `git branch backup` before rebasing
   - Easy recovery if something goes wrong

3. **Communicate with team**
   - Tell teammates before force pushing
   - Establish team conventions around rebasing

4. **Prefer squash merges for PRs**
   - Many teams squash on merge
   - Makes rebasing local history less critical

5. **Know when to stop**
   - If rebase is getting complicated, stop
   - Consider if new commits would be clearer

6. **Test after rebasing**
   - Make sure code still works
   - Run test suite before pushing

## Quick Reference

```bash
# Start interactive rebase
git rebase -i HEAD~N              # Rebase last N commits
git rebase -i <commit-hash>       # Rebase since commit

# During rebase
git rebase --continue             # After resolving conflicts
git rebase --abort                # Cancel rebase
git rebase --skip                 # Skip current commit

# Force push after rebase
git push --force-with-lease       # Safer force push

# Create backup
git branch backup-$(date +%s)     # Timestamped backup

# View reflog (find lost commits)
git reflog                        # See all recent HEAD positions

# Recover from rebase gone wrong
git reset --hard ORIG_HEAD        # Reset to before rebase
```

## Summary

Interactive rebase is powerful for creating clean commit history, but use it carefully:

- **DO** rebase local commits before pushing
- **DON'T** rebase commits on shared branches
- **ALWAYS** check if commits are pushed first
- **BACKUP** your branch before rebasing
- **COMMUNICATE** with team about force pushes
- **ABORT** if rebase gets too complicated

Remember: A messy but accurate history is better than a clean but broken one. When in doubt, make a new commit instead of rebasing.

## Additional Resources

- [Git Rebase Documentation](https://git-scm.com/docs/git-rebase)
- [Atlassian Git Rebase Tutorial](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase)
- [Git Rebase Best Practices](https://www.freecodecamp.org/news/git-rebase-handbook/)
