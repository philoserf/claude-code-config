# Example: Large Refactoring

## Scenario

User refactored the entire authentication system to use a new library.

## Repository State

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

## Analysis

Large changeset affecting multiple files. Organize into logical commits:

1. Add new dependency
2. Add configuration module
3. Refactor auth components
4. Update middleware
5. Remove old code
6. Update tests

## Workflow

**Phase 2**: Propose 5 commits

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
git add tests/
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

## Result

Well-organized refactoring that's easy to review commit-by-commit. Each commit builds on the previous, telling a clear story.
