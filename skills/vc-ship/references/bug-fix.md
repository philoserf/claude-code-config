# Example: Bug Fix with Mixed Changes

## Scenario

User fixed a login bug but also updated some documentation and added debug logging.

## Repository State

```bash
$ git status --short
 M src/auth/login.js
 M src/auth/session.js
 M README.md
 M docs/authentication.md
?? debug.log
```

## Analysis

Unrelated changes that should be separated:

1. Bug fix (login.js null check + session.js timeout)
2. Debug logging (login.js logging statements)
3. Documentation updates (README.md + authentication.md)

## Workflow

**Phase 1**: Analyze changes

- Multiple unrelated changes
- Untracked debug.log file (should be .gitignored)

**Phase 2**: Organize into 3 commits

Alert user to untracked debug.log, suggest adding to .gitignore

**Phase 3**: Create commits

Commit 1 - Bug fix:

```bash
git add src/auth/login.js src/auth/session.js docs/authentication.md
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

Commit 2 - Debug logging:

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

Commit 3 - Documentation:

```bash
git add README.md
git commit -m "$(cat <<'EOF'
Update README with new environment variable

Installation instructions were missing the SESSION_TIMEOUT
environment variable added in v2.3.0.
EOF
)"
```

## Result

Three atomic commits, each addressing one specific concern. Easy to review and cherry-pick if needed.
