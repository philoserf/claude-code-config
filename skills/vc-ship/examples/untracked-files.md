# Example: Working with Untracked Files

## Scenario

User has changes plus several untracked files.

## Repository State

```bash
$ git status
Changes not staged for commit:
  modified:   src/app.js

Untracked files:
  node_modules/
  .env
  debug.log
  src/newFeature.js
```

## Workflow

**Phase 1**: Analyze

- Find untracked files
- Identify which should likely be ignored (.env, debug.log, node_modules)
- Identify which should likely be added (src/newFeature.js)

Ask user about untracked files:

```text
I found these untracked files:

Should add to commit:
- src/newFeature.js

Should probably ignore:
- .env (contains secrets)
- debug.log (temporary file)
- node_modules/ (dependencies)

Would you like me to:
1. Add newFeature.js to this commit
2. Add .env, debug.log, node_modules/ to .gitignore
```

User confirms both.

Update .gitignore:

```bash
echo ".env" >> .gitignore
echo "debug.log" >> .gitignore
echo "node_modules/" >> .gitignore
git add .gitignore
```

Then proceed with commits:

- Commit 1: Add newFeature.js + app.js changes
- Commit 2: Update .gitignore

## Result

Clean repository with proper gitignore, no secrets committed.
