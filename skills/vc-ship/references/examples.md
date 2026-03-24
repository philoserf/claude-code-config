# Workflow Examples

## Simple Feature — Single Atomic Commit

**Scenario**: User added a new API endpoint. Route handler, service logic, and tests all relate to one feature.

```bash
$ git status --short
 M src/routes/users.js
 M src/services/userService.js
 M tests/users.test.js
```

**Workflow**: Phase 0 detects user is on `main` → suggest `feature/user-profile-endpoint` → Phase 1 finds 3 related files → Phase 2 proposes single commit → Phase 3 commits:

```bash
git add src/routes/users.js src/services/userService.js tests/users.test.js
git commit -m "$(cat <<'EOF'
Add user profile endpoint to API

Clients need to fetch full user profile data including preferences
and activity history. This adds a new GET /api/users/:id/profile
endpoint with comprehensive profile information.

- Add /profile route handler with authentication check
- Implement getFullProfile method in userService
- Add integration tests for profile endpoint
EOF
)"
```

Phase 4 skipped (one commit). Push, then optionally create PR.

---

## Bug Fix — Mixed Changes Separated

**Scenario**: User fixed a login bug but also updated docs and added debug logging.

```bash
$ git status --short
 M src/auth/login.js
 M src/auth/session.js
 M README.md
 M docs/authentication.md
?? debug.log
```

**Workflow**: Phase 1 identifies unrelated changes + untracked debug.log (suggest .gitignore). Phase 2 proposes 3 commits:

1. **Bug fix** — login.js + session.js + authentication.md (fix + its docs)
2. **Debug logging** — login.js logging portions only
3. **Documentation** — README.md

Each commit gets a focused message explaining WHY. Result: easy to review and cherry-pick.

---

## Large Refactor — Multi-Commit Sequence

**Scenario**: User refactored the auth system to use passport.js. 10 files changed.

**Workflow**: Phase 2 proposes 5 ordered commits that tell a story:

1. `Add passport.js for authentication` — package.json + config module
2. `Refactor authenticator to use passport.js` — core auth files
3. `Update validator and middleware for passport integration` — integration layer
4. `Remove deprecated custom auth implementation` — delete old code
5. `Update tests for passport.js integration` — all test files

Use TaskCreate to track each commit. Each builds on the previous — add new, migrate, remove old.

---

## Messy History — Cleanup Before Push

**Scenario**: User made WIP commits during development:

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

**Workflow**: Phase 4 proposes cleanup using `git reset --soft` (never `git rebase -i`):

```bash
git reset --soft HEAD~7
# Recommit in clean groups:
git add src/components/Dashboard.js src/styles/dashboard.css
git commit -m "Add dashboard component with styling"

git add src/components/Chart.js
git commit -m "Add chart component to dashboard"
```

Result: 7 messy commits → 2 clean ones.

---

## PR Creation — Rich Description

**Scenario**: 3 clean commits on `feature/customer-search`, referencing issue #42.

**Workflow**: Phase 7 gathers context:

```bash
git diff --stat main...HEAD     # 8 files, +245, -12
git diff --name-only main...HEAD
git log --oneline main...HEAD
```

Large PR check: 8 files, 245 lines — under thresholds. Generate PR:

```bash
gh pr create --title "Add customer search API endpoint" --body "$(cat <<'EOF'
## Summary

Add a new API endpoint for searching customers by name, email, and
account status — 8 files changed (+245, -12)

## Changes

### Source

- Add customer search endpoint with multiple filter options
- Add request validation for search parameters
- Add `CustomerSearchParams` type

### Tests

- Add integration tests covering happy path and error cases
- Add customer fixture data

### Docs

- Update API documentation with search endpoint usage

## Dependencies

- Add `zod` for runtime parameter validation

## Testing

- Integration tests pass (Phase 5 verified)

## Related Issues

Fixes #42
EOF
)"
```

Omit empty optional sections (Breaking Changes, Dependencies, etc.) — don't include headings with "N/A".
