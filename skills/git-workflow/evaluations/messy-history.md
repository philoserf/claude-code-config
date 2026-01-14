# Evaluation: Messy History Cleanup

## Scenario Description

User has been developing locally with quick "WIP" commits and now wants to clean up history before pushing to remote.

## Initial Repository State

**Branch**: `feature/authentication`

**Git Log**:

```text
abc1234 WIP
def5678 fix typo
ghi9012 add tests
jkl3456 oops forgot file
mno7890 add auth logic
pqr1234 add auth module
```

**Changes Summary**:

- 6 messy commits with unclear messages
- Should be organized into 2-3 clean commits
- None have been pushed yet (verified with `git log origin/feature/authentication..HEAD`)

## User Request

"I need to clean up my commits before pushing"

## Expected Skill Behavior

### Phase 0-2: Skip

Already on feature branch, commits already created

### Phase 3: Skip

Commits exist, no new commits to create

### Phase 4: Commit History Cleanup

1. **Check push status**:

   `git log origin/feature/authentication..HEAD`

Shows 6 unpushed commits - safe to rebase

1. **Analyze commit history**:
   - Review all 6 commits
   - Identify logical groupings:
     - Auth module creation (pqr1234, mno7890, jkl3456, def5678)
     - Tests (ghi9012)
     - WIP should be incorporated
   - Detect "WIP", "oops", "fix typo" - clear indicators of messy history

2. **Propose cleanup plan**:

   ```text
   Suggested cleanup:

   1. Squash pqr1234 + mno7890 + jkl3456 + def5678 into "Add JWT authentication module"
   2. Keep ghi9012 as separate commit, reword to "Add authentication tests"
   3. Determine what's in abc1234 (WIP) - fold into appropriate commit
   ```

3. **IMPORTANT: Don't use `git rebase -i`**

   Instead, provide manual instructions:

   ```text
   To clean up this history manually, run:

   git rebase -i HEAD~6

   Then change the rebase plan to:
   pick pqr1234 add auth module
   squash mno7890 add auth logic
   squash jkl3456 oops forgot file
   squash def5678 fix typo
   reword ghi9012 add tests
   fixup abc1234 WIP
   ```

   OR use non-interactive approach:

   ```bash
   # Reset to before messy commits
   git reset --soft HEAD~6

   # Re-commit in clean groups (we'll help you)
   ```

4. **Ask for confirmation** before any rebase/reset operation

5. **After user manually rebases** (or if using reset approach):
   - Verify new history: `git log --oneline -n 3`
   - Should show 2 clean commits with good messages

### Phase 5: Push

1. Show cleaned-up commits
2. Warn that this will be first push of this branch OR force push if already pushed
3. Ask for confirmation
4. Execute: `git push -u origin feature/authentication` or `git push --force-with-lease`
5. Verify success

### Phase 6: PR Creation

Proceed normally if requested

## Success Criteria

✅ **Identified messy history** - Detected WIP, typo, oops commits
✅ **Checked push status** - Verified commits not yet pushed (safe to rebase)
✅ **Proposed logical grouping** - Suggested meaningful commit organization
✅ **Avoided interactive rebase** - Did NOT use `git rebase -i` directly
✅ **Provided clear instructions** - Explained manual rebase OR used reset approach
✅ **Got user confirmation** - Asked before destructive operations
✅ **Verified result** - Checked cleaned history before push
✅ **Clean final history** - 2-3 commits with professional messages

## Common Pitfalls to Avoid

❌ Don't use `git rebase -i` in the tool (requires interactive terminal)
❌ Don't rebase if commits were already pushed without explicit approval
❌ Don't proceed with messy history if cleanup fails
❌ Don't force push without `--force-with-lease`
❌ Don't skip verification after cleanup

## Alternative Approach: Reset & Recommit

If rebase explanation is too complex, use this approach:

```bash
# 1. Reset to base (keeping changes)
git reset --soft HEAD~6

# 2. Review what's staged
git status

# 3. Recommit in clean groups
git commit -m "$(cat <<'EOF'
Add JWT authentication module

Implement token-based authentication using JWT for API security.

- Create auth module with token generation and validation
- Add middleware for protected routes
- Configure JWT secret and expiration
EOF
)"

git add tests/
git commit -m "Add authentication integration tests"
```

This is easier to execute programmatically than explaining interactive rebase.

## Model Variants

**Haiku**: May need more guidance on grouping strategy
**Sonnet**: Should handle well, prefer reset approach over rebase instructions
**Opus**: May provide excellent analysis but ensure doesn't use `git rebase -i`
