# Example: Protected Branch with Uncommitted Changes

## Scenario

User accidentally started working on main branch and made several changes without realizing they should be on a feature branch.

## Repository State

```bash
$ git branch --show-current
main

$ git status --short
 M src/auth/LoginForm.js
 M src/auth/api.js
 A src/auth/validators.js
?? src/auth/tests/validators.test.js
```

## Phase 0: Protected Branch Detection

The proactive Phase 0 protocol catches this immediately:

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

   Let me help you create a feature branch to safely isolate this work.
   ```

3. **Analysis and Auto-Suggestion**:
   - Changed files: Authentication-related modifications
   - Detected type: New files + test files → `feature` prefix
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

## Result

- User is **educated** about protected branch best practices
- Work is **properly isolated** on feature branch
- Main branch remains **clean** and production-ready
- **Proactive prevention** caught the issue before any commits were made

## Alternative: User Selects Override (Option 3)

If user selects override:

1. **Strong Warning** with confirmation required
2. User must type exactly: `CONTINUE ON PROTECTED`
3. **Audit Commit Created** documenting the override
4. Workflow continues on main (not recommended)
5. **Phase 5 will catch** the push attempt later and require migration
