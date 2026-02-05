# Example: Phase 4.5 Catches Generic Messages

## Scenario

User has created commits locally and wants to push, but some commit messages are generic.

## Repository State

```bash
$ git log --oneline -3
a1b2c3d WIP
d4e5f6g fix login
g7h8i9j Add user authentication module
```

User is on `feature/user-auth` branch, ready to push.

## Phase 4.5: Quality Review (MANDATORY)

```text
╔════════════════════════════════════════════════════════════╗
║        PHASE 4.5: PRE-PUSH QUALITY REVIEW                  ║
╚════════════════════════════════════════════════════════════╝

┌─ Push Preview ─────────────────────────────────────────────┐
│ Branch:          feature/user-auth                         │
│ Commits to push: 3                                         │
│ Files changed:   5 files (+187, -23)                       │
└─────────────────────────────────────────────────────────────┘

┌─ Quality Analysis ─────────────────────────────────────────┐
│ ⚠ ISSUES DETECTED (2 blockers)                             │
│                                                             │
│ BLOCKER (2):                                                │
│   • Commit a1b2c3d: Generic message "WIP"                  │
│     Suggestion: Describe what was accomplished             │
│                                                             │
│   • Commit d4e5f6g: Generic message "fix login"            │
│     Suggestion: Be specific about what was fixed           │
│     Example: "Fix null pointer in login validation"        │
└─────────────────────────────────────────────────────────────┘

What would you like to do?
1. Fix quality issues (recommended)
2. Run tests before pushing
3. Override and push anyway
4. Cancel
```

## User Choice: Fix Issues

User selects option 1.

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

## Phase 4: Interactive Cleanup

```bash
git reset --soft HEAD~3
git commit -m "$(cat <<'EOF'
Add user authentication module

Implement JWT-based authentication for API endpoints with login
validation and session management.

- Add authentication middleware
- Implement login endpoint with email validation
- Add session token generation and verification
- Include input sanitization for login form
EOF
)"
```

## Return to Phase 4.5

Quality check now passes:

```text
┌─ Quality Analysis ─────────────────────────────────────────┐
│ ✓ No issues detected                                       │
│   • Generic message check: PASSED                          │
│   • Format compliance: PASSED                              │
│   • Squash detection: N/A (single commit)                  │
└─────────────────────────────────────────────────────────────┘

Quality looks good! Run tests before pushing?
1. Yes, run tests
2. No, skip tests
```

## Result

Clean, professional commit ready for PR review. No "WIP" or vague "fix" in shared history.
