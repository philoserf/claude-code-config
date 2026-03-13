---
name: vc-sync
description: Syncs local repository by switching to main, pulling latest from remote, and cleaning merged branches. Use when syncing repo, pulling latest, refreshing branches, updating from remote, cleaning up after merging PRs, fetching and merging, updating main, or pruning stale branches.
---

## Purpose

Sync the local repository to a clean, up-to-date state on the main branch.

## Prerequisites

- `gitup` ([git-repo-updater](https://github.com/earwig/git-repo-updater)) — batch fetch + merge
- `git sweep` — delete local branches whose remote tracking branches are merged

Both are installed via the user's `.Brewfile`.

## Process

1. **Guard** — Check for uncommitted changes; warn before switching branches
2. **Switch to main** — `git checkout main`
3. **Update from remote** — `gitup .` (fetch + merge)
4. **Clean merged branches** — `git sweep`

## Commands

```bash
git stash list && git status --short
```

If the working tree is dirty, warn the user and confirm before proceeding.

```bash
git checkout main && gitup . && git sweep
```

## Failure Modes

- **Dirty working tree** — Guard step warns before proceeding. Commit or stash changes first.
- **Merge conflict during `gitup`** — Resolve the conflict manually, then re-run.
- **`git sweep` skips branches** — Branches without merged remote tracking branches are retained. This is expected.

## Verification

After running, confirm the sync succeeded:

```bash
git status && git branch
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
* main
```

## Related

- `vc-ship` — The complement: ships changes from a feature branch via atomic commits and PR creation.
