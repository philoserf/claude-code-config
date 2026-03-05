# Example: Cleaning Up Messy History

## Scenario

User made several quick commits while developing and now wants to clean up before pushing.

## Current History

```bash
$ git log --oneline -n 7
a1b2c3d WIP
d4e5f6g fix typo
g7h8i9j add chart component
j0k1l2m fix chart
m3n4o5p oops forgot to add file
p6q7r8s add dashboard
s9t0u1v update styles
```

## Analysis

Messy history with "WIP", "fix typo", "oops" commits that should be cleaned up:

- Commits about dashboard should be squashed
- Commits about charts should be squashed
- Result: 2 clean commits

## Workflow

**Phase 4**: Commit History Cleanup

Show current history to user, explain it's messy.

Propose cleanup:

1. Squash p6q7r8s + s9t0u1v into "Add dashboard with updated styles"
2. Squash g7h8i9j + j0k1l2m + m3n4o5p into "Add chart component to dashboard"
3. Fixup d4e5f6g (typo fix) into previous commit
4. Reword a1b2c3d from "WIP" to proper message

**Important**: Cannot use `git rebase -i` in non-interactive context.

Use the non-interactive `git reset --soft` approach:

```bash
# Reset to before messy commits
git reset --soft HEAD~7

# Recommit in clean groups
git add src/components/Dashboard.js src/styles/dashboard.css
git commit -m "Add dashboard component with styling"

git add src/components/Chart.js
git commit -m "Add chart component to dashboard"
```

## Result

Clean, professional commit history that's easy to review.
