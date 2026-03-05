# Example: Simple Feature Development

## Scenario

User has added a new API endpoint for fetching user profiles. Changes include route handler, service logic, and tests.

## Repository State

```bash
$ git status --short
 M src/routes/users.js
 M src/services/userService.js
 M tests/users.test.js
```

## Analysis

All changes are related to the same feature → single atomic commit.

## Workflow

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

**Phase 4**: Skip (only one commit)

**Phase 6**: Push

```bash
git push -u origin feature/user-profile-endpoint
```

**Phase 7**: Create PR with generated description

## Result

Clean feature branch with one well-documented commit, ready for review.
