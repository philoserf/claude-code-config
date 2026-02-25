# Interactive Rebase Safety Guide

## The Golden Rule

**Never rebase commits that have been pushed to a shared branch.**

## When to Rebase

### Safe (DO rebase)

- **Local commits not yet pushed** — clean up WIP before sharing
- **Feature branch you own** — commits not pushed, or you accept force push
- **After review feedback** — split/fixup commits on your own branch

### Unsafe (DON'T rebase)

- **Commits on main/master** — use `git revert` instead
- **Commits others based work on** — rebasing breaks their branch
- **Public commits in open source** — history should be stable once pushed
- **Uncertain about impact** — make a new commit instead

## Rebase Commands

| Command  | Effect                                      |
| -------- | ------------------------------------------- |
| `pick`   | Keep commit as-is                           |
| `reword` | Keep changes, edit message                  |
| `edit`   | Pause to modify commit content              |
| `squash` | Combine with previous, keep both messages   |
| `fixup`  | Combine with previous, discard this message |
| `drop`   | Remove commit entirely                      |

Commits apply top-to-bottom. Topmost is applied first.

## Common Scenarios

### Squash fix commits

```text
pick abc123 Add login feature
fixup jkl012 Oops forgot CSS      ← merged into "Add login feature"
pick def456 Add login tests
```

### Improve messages

Change `pick` to `reword` — Git prompts for new message.

### Reorder commits

Rearrange lines for better logical flow (e.g., feature → tests → docs).

## Safety Checklist

Before rebasing:

1. `git log origin/$BRANCH..HEAD` — are commits pushed? If empty, be careful
2. `git branch --show-current` — not on a protected branch?
3. `git status` — working directory clean?
4. Optional: `git branch backup-before-rebase` — safety net

## Conflict Resolution

1. Edit conflicted files (look for `<<<<<<<` markers)
2. `git add <resolved-files>`
3. `git rebase --continue`
4. Or `git rebase --abort` to return to pre-rebase state

## Alternatives to Rebase

- **`git commit --amend`** — modify only the latest commit
- **`git revert`** — undo a commit with a new commit (safe for shared branches)
- **New commit** — sometimes cleaner than rewriting history

## Key Principle

**IMPORTANT**: Never use `git rebase -i` in this skill — it requires interactive terminal input. Instead, use `git reset --soft HEAD~N` followed by recommitting, or explain the manual steps to the user.
