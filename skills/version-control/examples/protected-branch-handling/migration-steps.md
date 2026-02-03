# Migration Steps

## Option 1: Stash and Branch

```bash
# Stash changes
git stash

# Create and switch to feature branch
git checkout -b feature/my-work

# Apply stashed changes
git stash pop
```

## Option 2: Direct Branch (if no conflicts)

```bash
# Create branch keeping changes
git checkout -b feature/my-work
```

## Verification

```bash
git status
# On branch feature/my-work
# Changes not staged for commit...
```

Now safe to commit on feature branch.
