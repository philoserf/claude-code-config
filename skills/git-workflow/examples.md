# Git Workflow Examples

This document provides real-world examples of the git-workflow skill in action, showing how to handle various scenarios from simple commits to complex workflows.

## Example 1: Simple Feature Development

### Scenario

User has added a new API endpoint for fetching user profiles. Changes include route handler, service logic, and tests.

### Repository State

```bash
$ git status --short
 M src/routes/users.js
 M src/services/userService.js
 M tests/users.test.js
```

### Analysis

All changes are related to the same feature and should be in one atomic commit.

### Workflow

**Phase 0**: User is on `main` branch

- Suggest creating `feature/user-profile-endpoint`
- User confirms, create branch

**Phase 1**: Analyze changes

- 3 modified files, all related
- New functionality (feature)
- Tests included

**Phase 2**: Organize commits

- Single atomic commit (all changes related)

**Phase 3**: Create commit

```bash
git add src/routes/users.js src/services/userService.js tests/users.test.js
git commit -m "$(cat <<'EOF'
Add user profile endpoint to API

Clients need to fetch full user profile data including preferences
and activity history. This adds a new GET /api/users/:id/profile
endpoint with comprehensive profile information.

- Add /profile route handler with authentication check
- Implement getFullProfile method in userService
- Include user preferences and recent activity in response
- Add integration tests for profile endpoint

Tested with 100 sample users, average response time 45ms.
EOF
)"
```

**Phase 4**: Skip (only one commit, nothing to clean up)

**Phase 5**: Push

- Show commit summary
- Ask for confirmation
- `git push -u origin feature/user-profile-endpoint`

**Phase 6**: Create PR

- Generate title: "Add user profile endpoint to API"
- Generate description from commit message
- User reviews and confirms
- Create PR with `gh pr create`

### Result

Clean feature branch with one well-documented commit, ready for review.

---

## Example 2: Bug Fix with Mixed Changes

### Scenario

User fixed a login bug but also updated some documentation and added debug logging.

### Repository State

```bash
$ git status --short
 M src/auth/login.js
 M src/auth/session.js
 M README.md
 M docs/authentication.md
?? debug.log
```

### Git Diff Summary

- `login.js`: Fix null check + add debug logging
- `session.js`: Fix session timeout bug
- `README.md`: Update installation instructions
- `authentication.md`: Document the bug fix
- `debug.log`: Untracked file

### Analysis

Unrelated changes that should be separated:

1. Bug fix (login.js null check + session.js timeout)
2. Debug logging (login.js logging statements)
3. Documentation updates (README.md + authentication.md)

### Workflow

**Phase 0**: Already on `fix/login-session-bug` branch

**Phase 1**: Analyze changes

- Multiple unrelated changes
- Untracked debug.log file (should be .gitignored)

**Phase 2**: Organize commits
Alert user to untracked debug.log, suggest adding to .gitignore

Propose 3 commits:

1. Bug fix (null check + timeout fix + auth docs)
2. Add debug logging for troubleshooting
3. Update README installation instructions

User approves

**Phase 3**: Create commits

Commit 1:

```bash
git add src/auth/login.js  # Only null check portion
git add src/auth/session.js
git add docs/authentication.md
git commit -m "$(cat <<'EOF'
Fix null reference error in login and session timeout

Login attempts with empty email field caused server crash due to
missing null check. Session timeout calculation was also incorrect,
causing sessions to expire immediately.

- Add null check for email field before validation
- Return 400 error for missing required fields
- Fix session timeout calculation (was using seconds not milliseconds)
- Document the issue and fix in authentication docs

Bug was introduced in v2.3.0 and affected approximately 50 users.
EOF
)"
```

Commit 2:

```bash
git add src/auth/login.js  # Only logging portions
git commit -m "$(cat <<'EOF'
Add debug logging to login flow

To help diagnose authentication issues in production, add detailed
logging at each step of the login process.

- Log authentication attempts with timestamp and IP
- Log validation failures with specific field information
- Log session creation and token generation events

Log level is DEBUG so it won't appear in production unless enabled.
EOF
)"
```

Commit 3:

```bash
git add README.md
git commit -m "$(cat <<'EOF'
Update README with new environment variable

Installation instructions were missing the SESSION_TIMEOUT
environment variable added in v2.3.0.
EOF
)"
```

**Phase 4**: Commit history cleanup

- Show 3 commits
- Commits are logical and separate
- No cleanup needed

**Phase 5**: Push

- Show 3 commits
- User confirms
- `git push`

**Phase 6**: Skip (user doesn't want PR right now)

### Result

Three atomic commits, each addressing one specific concern. Easy to review and cherry-pick if needed.

---

## Example 3: Large Refactoring

### Scenario

User refactored the entire authentication system to use a new library.

### Repository State

```bash
$ git status --short
 M src/auth/authenticator.js
 M src/auth/tokenHandler.js
 M src/auth/validator.js
 M src/middleware/authMiddleware.js
 D src/auth/oldAuth.js
 A src/auth/config.js
 M package.json
 M tests/auth/authenticator.test.js
 M tests/auth/validator.test.js
 M tests/integration/login.test.js
```

### Analysis

Large changeset affecting multiple files. Need to organize into logical commits:

1. Add new dependency
2. Add configuration module
3. Refactor auth components
4. Update middleware
5. Remove old code
6. Update tests

### Workflow

**Phase 0**: Already on `refactor/auth-library-upgrade`

**Phase 2**: Organize commits

Propose 5 commits:

1. Add passport.js library and configuration
2. Refactor authenticator and tokenHandler to use passport
3. Refactor validator and update middleware
4. Remove deprecated oldAuth module
5. Update all tests for new auth system

**Phase 3**: Create commits

Commit 1:

```bash
git add package.json src/auth/config.js
git commit -m "$(cat <<'EOF'
Add passport.js for authentication

Replace custom auth implementation with battle-tested passport.js
library to improve security and reduce maintenance burden.

- Add passport and passport-jwt dependencies
- Create config module with passport strategies
- Configure JWT strategy with existing secret

No behavior changes yet, just adding the infrastructure.
EOF
)"
```

Commit 2:

```bash
git add src/auth/authenticator.js src/auth/tokenHandler.js
git commit -m "$(cat <<'EOF'
Refactor authenticator to use passport.js

Migrate token generation and validation from custom implementation
to passport.js JWT strategy.

- Replace custom JWT logic with passport-jwt
- Simplify token creation using passport's built-in methods
- Reduce code complexity from 200 to 80 lines
- Maintain exact same token format for backwards compatibility

All existing tokens remain valid during transition.
EOF
)"
```

Commit 3:

```bash
git add src/auth/validator.js src/middleware/authMiddleware.js
git commit -m "$(cat <<'EOF'
Update validator and middleware for passport integration

Connect passport strategies to existing middleware and validation
layer.

- Integrate passport.authenticate in auth middleware
- Update validator to use passport's user serialization
- Preserve existing error handling and status codes

Middleware API remains unchanged for other routes.
EOF
)"
```

Commit 4:

```bash
git add src/auth/oldAuth.js
git commit -m "$(cat <<'EOF'
Remove deprecated custom auth implementation

Now that passport.js is fully integrated, remove the old custom
authentication code that is no longer used.

This removes 350 lines of custom crypto and JWT code that is now
handled by passport.
EOF
)"
```

Commit 5:

```bash
git add tests/auth/authenticator.test.js tests/auth/validator.test.js tests/integration/login.test.js
git commit -m "$(cat <<'EOF'
Update tests for passport.js integration

Adapt all authentication tests to work with new passport-based
implementation.

- Update unit tests to mock passport strategies
- Adjust integration tests for passport middleware
- Add tests for new configuration module
- All 47 tests passing

Test coverage remains at 95%.
EOF
)"
```

**Phase 4**: Commit history cleanup

- 5 commits in logical order
- Each builds on previous
- Good separation of concerns
- No cleanup needed

**Phase 5**: Push and Phase 6\*\*: Create PR with detailed description

### Result

Well-organized refactoring that's easy to review commit-by-commit. Each commit builds on the previous, telling a clear story.

---

## Example 4: Starting from Main Branch

### Scenario

User is on main branch with uncommitted changes for a new feature.

### Repository State

```bash
$ git branch --show-current
main

$ git status --short
 M src/components/Dashboard.js
 A src/components/Chart.js
 M src/styles/dashboard.css
```

### Workflow

**Phase 0**: Branch Management

- Detect user is on main branch
- Analyze changes: new dashboard charting feature
- Suggest branch name: `feature/dashboard-charts`
- Ask user if they want to create branch
- User confirms
- Create and switch: `git checkout -b feature/dashboard-charts`

**Phase 1-3**: Proceed with normal commit workflow

**Result**
Changes safely isolated on feature branch, main stays clean.

---

## Example 4.5: Protected Branch with Uncommitted Changes

### Scenario

User accidentally started working on main branch and made several changes without realizing they should be on a feature branch.

### Repository State

```bash
$ git branch --show-current
main

$ git status --short
 M src/auth/LoginForm.js
 M src/auth/api.js
 A src/auth/validators.js
?? src/auth/tests/validators.test.js
```

### Workflow

**Phase 0**: Protected Branch Detection

The new proactive Phase 0 protocol catches this immediately:

1. **Detection**:
   - Current branch: `main` (protected)
   - Uncommitted changes: Yes
   - **BLOCKS** workflow with protection message

2. **Blocking Message**:

   ```text
   🛑 STOP: You're working on protected branch `main` with uncommitted changes

   Working directly on protected branches is risky:
   • Bypasses code review process
   • Changes can accidentally get pushed to main
   • Makes it harder to organize work into logical commits

   I detected changes in:
   src/auth/LoginForm.js
   src/auth/api.js
   src/auth/validators.js
   src/auth/tests/validators.test.js

   Let me help you create a feature branch to safely isolate this work.
   ```

3. **Analysis and Auto-Suggestion**:
   - Changed files: Authentication-related modifications
   - Detected type: New files + test files → `feature` prefix
   - Main file: `validators.js`
   - **Suggested branch name**: `feature/login-validators`

4. **Present 3 Options**:
   - **Option 1 (Recommended)**: Create `feature/login-validators`
   - **Option 2**: Create feature branch with custom name
   - **Option 3**: Override and continue on main (requires confirmation)

5. **User selects Option 1**

6. **Migration Execution**:

   ```bash
   # Stash uncommitted changes (including untracked)
   git stash push -u -m "Phase 0: Migrating to feature/login-validators"

   # Create and checkout new branch
   git checkout -b feature/login-validators

   # Apply stashed changes
   git stash pop

   ```

7. **Success**:

   ```text
   ✓ Stashed changes
   ✓ Created branch feature/login-validators
   ✓ Applied changes to feature/login-validators

   ✓ SUCCESS: main is now clean
   ✓ Your changes are on feature/login-validators
   ```

**Phase 1-6**: Proceed with normal workflow on feature branch

- Repository analysis on `feature/login-validators`
- Organize changes into atomic commits
- Create commits with proper messages
- Push to remote
- Create pull request

### Result

- User is **educated** about protected branch best practices
- Work is **properly isolated** on feature branch
- Main branch remains **clean** and production-ready
- **Proactive prevention** caught the issue before any commits were made
- User can now follow proper PR workflow

### Alternative: User Selects Override (Option 3)

If user had selected Option 3 instead:

1. **Strong Warning**:

   ```text
   ⚠️ OVERRIDE REQUIRED

   Continuing on main is strongly discouraged.

   This should ONLY be done if:
   ✓ You're making a tiny configuration change
   ✓ You're fixing a critical production bug
   ✓ You absolutely cannot use a feature branch

   This override will be logged in your git history.

   To proceed, type exactly: CONTINUE ON PROTECTED

   ```

1. **User types confirmation**

1. **Audit Commit Created**:

   ```bash
   git commit --allow-empty -m "Phase 0 Override: Continuing work on main

   Override-Date: 2026-01-02 15:30:00 UTC
   Override-User: John Doe <john@example.com>

   The user chose to continue working on main despite
   Phase 0 recommending a feature branch.

   Changes in progress:
   M src/auth/LoginForm.js
   M src/auth/api.js
   A src/auth/validators.js
   ?? src/auth/tests/validators.test.js"
   ```

1. **Workflow continues on main** (not recommended)
1. **Phase 5 will catch** the push attempt later and require migration

---

## Example 5: Cleaning Up Messy History

### Scenario

User made several quick commits while developing and now wants to clean up before pushing.

### Current History

````bash
$ git log --oneline -n 7
a1b2c3d WIP
d4e5f6g fix typo
g7h8i9j add chart component
j0k1l2m fix chart
m3n4o5p oops forgot to add file
p6q7r8s add dashboard
s9t0u1v update styles

### Analysis

Messy history with "WIP", "fix typo", "oops" commits that should be cleaned up:

- Commits about dashboard should be squashed
- Commits about charts should be squashed
- Result: 2 clean commits

### Workflow

**Phase 0-3**: Already committed, skip to Phase 4

**Phase 4**: Commit History Cleanup

Show current history to user, explain it's messy

Propose cleanup:

1. Squash p6q7r8s + s9t0u1v into "Add dashboard with updated styles"
2. Squash g7h8i9j + j0k1l2m + m3n4o5p into "Add chart component to dashboard"
3. Fixup d4e5f6g (typo fix) into previous commit
4. Reword a1b2c3d from "WIP" to proper message

User confirms cleanup

**Important**: Cannot use `git rebase -i` in non-interactive context. Instead, explain to user:

"To clean up this history, I recommend running this command manually:

`git rebase -i HEAD~7`

Then in the editor, change the rebase plan to:

```text
pick p6q7r8s add dashboard
squash s9t0u1v update styles
pick g7h8i9j add chart component
fixup j0k1l2m fix chart
fixup m3n4o5p oops forgot to add file
fixup d4e5f6g fix typo
reword a1b2c3d WIP
```

This will:

- Combine dashboard commits
- Combine chart commits
- Absorb the fixes into the main commits
- Let you reword the WIP commit to something meaningful

After rebasing, your history will be much cleaner with just 2-3 well-described commits."

Alternatively, can help user do this with individual commands:

```bash
# Reset to before messy commits
git reset --soft HEAD~7

# Recommit in clean groups
git add src/components/Dashboard.js src/styles/dashboard.css
git commit -m "Add dashboard component with styling"

git add src/components/Chart.js
git commit -m "Add chart component to dashboard"
```

**Phase 5**: After cleanup, push clean history

### Result

Clean, professional commit history that's easy to review.

---

## Example 6: Edge Case - No Changes

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

## Example 7: Edge Case - Merge Conflict in Progress

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
  2. Look for <<<<<<< and >>>>>>>markers
  3. Edit to resolve conflicts
  4. git add src/api/endpoints.js
  5. git commit

  ```

- Exit workflow

### Result

User gets helpful guidance instead of confusing git errors.

---

## Example 8: PR Creation with Multiple Commits

### Scenario

User has 3 clean commits ready to push and wants a PR.

### Commits

```text
commit 3: Add integration tests for new API
commit 2: Add validation for API parameters
commit 1: Add new customer search API endpoint
```

### Workflow

**Phase 5**: Push commits
**Phase 6**: Create PR

Generate PR content:

**Title**: "Add customer search API endpoint"
(from first/primary commit)

**Description**:

```markdown
## Summary

This PR adds a new API endpoint for searching customers by various
criteria including name, email, and account status.

## Changes

- Add new customer search API endpoint with multiple filter options
- Add validation for API parameters to ensure data integrity
- Add comprehensive integration tests for search functionality

## Testing

- All existing tests pass
- New integration tests cover happy path and error cases
- Manually tested with 1000+ customer records

## API Usage

GET /api/customers/search?name=John&status=active
```

User reviews, confirms, PR created.

### Result

PR with clear title and comprehensive description generated from commits.

---

## Example 9: Dependency Update

### Scenario

User updated a critical dependency for security fix.

### Repository State

```bash
$ git status --short
 M package.json
 M package-lock.json
```

### Workflow

**Phase 2**: Organize commits

- Single commit for dependency update

**Phase 3**: Create commit

```bash
git add package.json package-lock.json
git commit -m "$(cat <<'EOF'
Bump axios from 0.21.1 to 0.21.4

Security update to address CVE-2021-3749 (server-side request
forgery vulnerability).

- Update axios dependency to 0.21.4
- Update transitive dependencies via package-lock.json

All tests passing. No breaking changes in this patch release.
EOF
)"
```

### Result

Clear security fix commit with CVE reference for audit trail.

---

## Example 10: Working with Untracked Files

### Scenario

User has changes plus several untracked files.

### Repository State

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

### Workflow

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

User confirms both

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

### Result

Clean repository with proper gitignore, no secrets committed.

---

## Example 11: Phase 4.5 Catches Generic Messages

### Scenario

User has created commits locally and wants to push, but some commit messages are generic and need improvement.

### Repository State

```bash
$ git log --oneline -3
a1b2c3d WIP
d4e5f6g fix login
g7h8i9j Add user authentication module
```

User is on `feature/user-auth` branch, ready to push.

### Workflow Execution

**Phases 1-3**: Commits already created

**Phase 4**: User skipped optional cleanup

**Phase 4.5**: Quality Review (MANDATORY)

Skill enters Phase 4.5 before allowing push:

```text
╔════════════════════════════════════════════════════════════╗
║        PHASE 4.5: PRE-PUSH QUALITY REVIEW                  ║
╚════════════════════════════════════════════════════════════╝

┌─ Push Preview ─────────────────────────────────────────────┐
│                                                             │
│ Branch:          feature/user-auth                         │
│ Commits to push: 3                                         │
│ Files changed:   5 files (+187, -23)                       │
│                                                             │
│ Commits:                                                    │
│   1. g7h8i9j Add user authentication module                │
│   2. d4e5f6g fix login                                     │
│   3. a1b2c3d WIP                                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─ Quality Analysis ─────────────────────────────────────────┐
│                                                             │
│ ⚠ ISSUES DETECTED (2 blockers)                             │
│                                                             │
│ BLOCKER (2):                                                │
│   • Commit a1b2c3d: Generic message "WIP"                  │
│     Suggestion: Describe what was accomplished             │
│                                                             │
│   • Commit d4e5f6g: Generic message "fix login"            │
│     Suggestion: Be specific about what was fixed           │
│     Example: "Fix null pointer in login validation"        │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─ Test Detection ───────────────────────────────────────────┐
│                                                             │
│ ✓ Found test commands:                                     │
│   • npm test                                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘

What would you like to do?
1. Fix quality issues (recommended)
2. Run tests before pushing
3. Override and push anyway
4. Cancel
```

### User Choice: Fix Issues

User selects option 1 to fix quality issues.

Skill determines issue type:

- Both issues are commit **messages** (not history structure)
- Return to Phase 4 for squash + reword

**Suggestion shown**:

```text
These commits could be improved:

Option A: Squash all three into one commit
  - They all relate to the same feature (user authentication)
  - Would create cleaner history for PR review

Option B: Reword individual messages
  - Keep separate commits but improve descriptions
  - Maintain granular history

Which would you prefer? [A/B]
```

User chooses A (squash).

### Phase 4: Interactive Cleanup

Reset to before the three commits:

`git reset --soft HEAD~3`

All changes now staged. Create single well-formed commit:

```bash
$ git commit -m "$(cat <<'EOF'
Add user authentication module

Implement JWT-based authentication for API endpoints with login
validation and session management.

- Add authentication middleware
- Implement login endpoint with email validation
- Add session token generation and verification
- Include input sanitization for login form

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### Return to Phase 4.5

Workflow re-runs Phase 4.5 with new commit:

```text
╔════════════════════════════════════════════════════════════╗
║        PHASE 4.5: PRE-PUSH QUALITY REVIEW                  ║
╚════════════════════════════════════════════════════════════╝

┌─ Push Preview ─────────────────────────────────────────────┐
│                                                             │
│ Branch:          feature/user-auth                         │
│ Commits to push: 1                                         │
│ Files changed:   5 files (+187, -23)                       │
│                                                             │
│ Commits:                                                    │
│   1. h9i0j1k Add user authentication module                │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─ Quality Analysis ─────────────────────────────────────────┐
│                                                             │
│ ✓ No issues detected                                       │
│                                                             │
│ Analysis completed:                                         │
│   • Generic message check: PASSED                          │
│   • Format compliance: PASSED                              │
│   • Squash detection: N/A (single commit)                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─ Test Detection ───────────────────────────────────────────┐
│                                                             │
│ ✓ Found: npm test                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Quality looks good! Run tests before pushing?
1. Yes, run tests
2. No, skip tests
```

User selects 2 (skip tests this time).

### Phase 5: Push

Proceed to Phase 5 with clean commit:

`git push -u origin feature/user-auth`

Success!

### Result

Clean, professional commit with descriptive message ready for PR review. No "WIP" or vague "fix" in shared history.

### Alternative: User Overrides

If user had chosen option 3 (Override) in Phase 4.5:

```text
You're choosing to push despite quality issues.

⚠ This means generic messages like "WIP" and "fix login" will
be in shared history, visible to team and in PR reviews.

Why are you pushing with quality issues?
(minimum 10 characters)

> _
```

User provides justification:

```text
Quick WIP push to share progress with team for early feedback. Will squash and clean up messages before final merge to main.
```

Skill logs override and proceeds:

```text
╔════════════════════════════════════════════════════════════╗
║              QUALITY REVIEW SUMMARY                        ║
╚════════════════════════════════════════════════════════════╝

Status: OVERRIDDEN

Issues detected: 2 blockers (generic messages)
Override reason: "Quick WIP push to share progress with team for early feedback. Will squash and clean up messages before final merge to main."

User: John Doe <john@example.com>
Date: 2026-01-02 16:30:00 UTC

⚠ NOTE: These commits have known quality issues.
Remember to clean up before merging to main.

Proceeding to Phase 5...
```

---

## Example 12: Test Runner Integration

### Scenario

User has clean commits and wants to run tests before pushing to ensure code quality.

### Repository State

```bash
$ git log --oneline -2
f3e4d5c Add retry logic for failed API requests
a9b8c7d Add tests for retry logic
```

User is on `feature/api-retry` branch. Commits are well-formatted, tests available.

### Workflow Execution

**Phases 1-4**: Commits created and cleaned up

**Phase 4.5**: Quality Review

```text
╔════════════════════════════════════════════════════════════╗
║        PHASE 4.5: PRE-PUSH QUALITY REVIEW                  ║
╚════════════════════════════════════════════════════════════╝

┌─ Push Preview ─────────────────────────────────────────────┐
│                                                             │
│ Branch:          feature/api-retry                         │
│ Commits to push: 2                                         │
│ Files changed:   4 files (+156, -12)                       │
│                                                             │
│ Commits:                                                    │
│   1. f3e4d5c Add retry logic for failed API requests       │
│   2. a9b8c7d Add tests for retry logic                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─ Quality Analysis ─────────────────────────────────────────┐
│                                                             │
│ ✓ No issues detected                                       │
│                                                             │
│ Analysis completed:                                         │
│   • Generic message check: PASSED                          │
│   • Format compliance: PASSED                              │
│   • Squash detection: PASSED (commits are independent)     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─ Test Detection ───────────────────────────────────────────┐
│                                                             │
│ ✓ Found test commands:                                     │
│   • npm test                                                │
│   • npm run test:integration                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Quality looks good! Run tests before pushing?
1. Yes, run tests
2. No, skip tests
```

### User Choice: Run Tests

User selects option 1.

**Follow-up question**:

```text
Which tests would you like to run?
1. npm test (recommended - runs all tests)
2. npm run test:integration
3. Skip tests
```

User selects 1 (npm test).

### Test Execution

```text
Running: npm test
Timeout: 300s
────────────────────────────────────────────────────────────

> api-service@2.1.0 test
> jest

PASS  src/api/__tests__/retry.test.js
  Retry Logic
    ✓ should retry failed requests up to 3 times (45 ms)
    ✓ should return success on first retry (12 ms)
    ✓ should fail after max retries exceeded (38 ms)
    ✓ should use exponential backoff (52 ms)

PASS  src/api/__tests__/endpoints.test.js
  API Endpoints
    ✓ GET /users should return user list (23 ms)
    ✓ POST /users should create user (18 ms)
    [... 18 more tests ...]

Test Suites: 2 passed, 2 total
Tests:       24 passed, 24 total
Snapshots:   0 total
Time:        4.235s

────────────────────────────────────────────────────────────
✓ Tests PASSED
```

### Phase 5: Push

Tests passed, proceed to push:

```text
Tests passed successfully!

Proceeding to Phase 5...
```

Protected branch check (none - on feature branch), then:

`git push -u origin feature/api-retry`

Success!

### Result

Code pushed to remote with confidence that tests pass. Team members can review PR knowing the code is tested.

### Alternative: Tests Fail

If tests had failed:

```text
Running: npm test
Timeout: 300s
────────────────────────────────────────────────────────────

> api-service@2.1.0 test
> jest

FAIL  src/api/__tests__/retry.test.js
  Retry Logic
    ✓ should retry failed requests up to 3 times (45 ms)
    ✗ should return success on first retry (12 ms)
    ✓ should fail after max retries exceeded (38 ms)
    ✓ should use exponential backoff (52 ms)

  ● Retry Logic › should return success on first retry

    expect(received).toBe(expected)

    Expected: 200
    Received: 500

      at Object.<anonymous> (src/api/__tests__/retry.test.js:45:28)

PASS  src/api/__tests__/endpoints.test.js
  [... other tests pass ...]

Test Suites: 1 failed, 1 passed, 2 total
Tests:       1 failed, 23 passed, 24 total

────────────────────────────────────────────────────────────
✗ Tests FAILED (exit code: 1)
```

**Skill presents options**:

```text
Tests failed. What would you like to do?

1. Fix code and add commit (recommended)
   - Fix the failing test
   - Add a new commit with the fix
   - Re-run workflow

2. Push anyway with reason (NOT recommended)
   - Requires justification
   - Will push failing tests to remote
   - May break CI/CD pipeline

3. Cancel and investigate
   - Exit workflow
   - Investigate failure locally
   - Re-run when ready
```

User chooses option 1 (Fix code).

**Skill exits workflow**:

```text
Exiting workflow to allow code fixes.

Failing test: "should return success on first retry"
Error: Expected 200, received 500

After fixing:
1. Test your changes locally: npm test
2. Add new commit with fix: git add . && git commit -m "..."
3. Re-run workflow to push
```

User fixes the bug in retry logic, tests locally:

```bash
$ npm test
# All tests pass now

$ git add src/api/retry.js
$ git commit -m "Fix status code handling in retry logic"
```

User re-runs workflow:

- Phase 4.5 runs again
- Quality check passes (3 commits now)
- Tests run again
- All tests PASS
- Proceeds to Phase 5
- Push succeeds

### Result

Bug caught before pushing to remote. Tests ensure code quality. Team doesn't see broken code in PR.

---

## Key Patterns

### Pattern 1: One Logical Change = One Commit

Don't mix unrelated changes. If you fixed a bug and updated docs, that's two commits.

### Pattern 2: Commits Should Build on Each Other

In refactoring, order commits so each one is a working state: add new → migrate → remove old.

### Pattern 3: Clean Up Before Pushing

Messy local history is fine while developing, but clean it up before sharing.

### Pattern 4: Tests With Code

Include test changes with the code they test, not as separate commits (unless it's a large test suite addition).

### Pattern 5: Config Separate from Code

Configuration changes (package.json, environment) can be separate commits unless tightly coupled to code changes.

### Pattern 6: Branch Per Feature

Always create a branch for features/fixes. Never commit directly to main.

### Pattern 7: Descriptive Commit Messages

Future you (and your teammates) will thank you for explaining WHY, not just WHAT.

## Summary

The git-workflow skill handles diverse scenarios from simple single-file changes to complex multi-commit refactorings. The key is:

1. **Analyze first** - Understand all changes before organizing
2. **Group logically** - Related changes together, unrelated apart
3. **Format well** - Professional commit messages matter
4. **Clean up** - Messy history before pushing gets cleaned
5. **Communicate** - Clear PRs help reviewers

Good Git workflow is about telling a clear story of how the code evolved.
````
