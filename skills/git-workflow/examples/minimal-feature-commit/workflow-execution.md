# Workflow Execution: Minimal Feature

## Phase 0: Verify Branch

```bash
git status
# On branch feature/add-logging
```

Good - already on feature branch, not on main.

## Phase 1: Review Changes

```bash
git diff
# Shows changes to src/logger.py

git status
# Shows untracked tests/test_logger.py
```

## Phase 2: Stage Files

```bash
git add src/logger.py tests/test_logger.py
git status
# Changes to be committed:
#   modified: src/logger.py
#   new file: tests/test_logger.py
```

## Phase 3: Create Commit

```bash
git commit -m "Add structured logging with tests

Implement structured logger supporting JSON and text formats.
Add comprehensive test coverage for logger functionality.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Phase 4: Review (Optional for Small Changes)

```bash
git log -1 --stat
# Verify commit looks good
```

## Phase 5: Push

`git push -u origin feature/add-logging`

## Done

Workflow complete. Create PR from GitHub/GitLab UI.

**Time**: ~2 minutes for straightforward changes.
