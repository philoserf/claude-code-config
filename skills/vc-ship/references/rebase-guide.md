# History Cleanup Guide

## The Golden Rule

**Never rebase commits that have been pushed to a shared branch.**

## When to Clean Up

### Safe

- Local commits not yet pushed — clean up WIP before sharing
- Feature branch you own — commits not pushed, or you accept force push
- After review feedback — reorganize commits on your own branch

### Unsafe

- Commits on main/master — use `git revert` instead
- Commits others based work on — rebasing breaks their branch
- Public commits in open source — history should be stable once pushed
- Uncertain about impact — make a new commit instead

## How to Clean Up (Non-Interactive)

**Never use `git rebase -i`** — it requires interactive terminal input.

Use `git reset --soft` instead:

```bash
# Safety check first
git log origin/$BRANCH..HEAD   # verify commits aren't pushed
git status                      # verify clean working directory

# Reset to before the messy commits (N = number of commits to redo)
git reset --soft HEAD~N

# Recommit in clean groups
git add <group-1-files>
git commit -m "Clean message for group 1"

git add <group-2-files>
git commit -m "Clean message for group 2"
```

## Safety Checklist

Before cleaning up:

1. `git log origin/$BRANCH..HEAD` — are commits pushed? If empty output, commits may already be on remote
2. `git branch --show-current` — not on a protected branch?
3. `git status` — working directory clean?
4. Optional: `git branch backup-before-cleanup` — safety net

## Conflict Resolution

If something goes wrong during cleanup:

- `git reflog` — find the commit before the reset
- `git reset --hard <reflog-hash>` — restore to that point
- Or use the backup branch if you created one

## Alternatives

- **`git commit --amend`** — modify only the latest commit
- **`git revert`** — undo a commit with a new commit (safe for shared branches)
- **New commit** — sometimes cleaner than rewriting history
