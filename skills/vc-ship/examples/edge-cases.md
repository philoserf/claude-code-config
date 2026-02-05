# Example: Edge Cases

## Example 1: No Changes

### Scenario

User asks to commit but repository is clean.

### Repository State

```bash
$ git status
On branch main
nothing to commit, working tree clean
```

### Workflow

**Phase 1**: Detect no changes

- Alert user: "Your working directory is clean. There are no changes to commit."
- Exit gracefully

### Result

User informed, no unnecessary actions taken.

---

## Example 2: Merge Conflict in Progress

### Scenario

User asks to commit while merge conflict exists.

### Repository State

```bash
$ git status
On branch feature/new-api
You have unmerged paths.
  (fix conflicts and run "git commit")

Unmerged paths:
  (use "git add <file>..." to mark resolution)
 both modified:   src/api/endpoints.js
```

### Workflow

**Phase 1**: Detect merge conflict

- Check status output for "unmerged paths"
- Alert user: "You have unresolved merge conflicts. Please resolve conflicts before committing."
- Show conflicted files:

  ```text
  Conflicted files:
  - src/api/endpoints.js
  ```

- Suggest next steps:

  ```text
  To resolve:
  1. Open src/api/endpoints.js
  2. Look for <<<<<<< and >>>>>>> markers
  3. Edit to resolve conflicts
  4. git add src/api/endpoints.js
  5. git commit
  ```

- Exit workflow

### Result

User gets helpful guidance instead of confusing git errors.
