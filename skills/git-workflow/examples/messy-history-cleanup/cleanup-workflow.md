# Cleanup Workflow

## Step 1: Identify Base Commit

```bash
git log --oneline
# Find where feature branch diverged from main
```

## Step 2: Interactive Rebase

```bash
git rebase -i main
# Opens editor with commits
```

## Step 3: Squash and Reword

In editor, mark commits:

```text
pick abc1234 add feature
squash def5678 fix typo
squash ghi9012 WIP
squash jkl3456 fix again
pick mno7890 add UI
```

## Step 4: Write Clean Messages

First commit message:

```text
Implement user authentication

Add JWT-based authentication with session management.
Includes password hashing and token validation.
```

Second commit message:

```text
Add login UI components

Create login form and authentication flow.
Add error handling and validation.
```

## Result

Clean, professional history ready to push.
