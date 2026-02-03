#!/usr/bin/env bash
#
# Copy-pasteable commands for minimal feature commit workflow
#

# Phase 0: Verify branch
git status

# Phase 1: Review changes
git diff
git status

# Phase 2: Stage files
git add src/logger.py tests/test_logger.py

# Phase 3: Commit
git commit -m "Add structured logging with tests

Implement structured logger supporting JSON and text formats.
Add comprehensive test coverage for logger functionality.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Phase 4: Review (optional)
git log -1 --stat

# Phase 5: Push
git push -u origin feature/add-logging
