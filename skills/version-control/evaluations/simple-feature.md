# Evaluation: Simple Feature Addition

## Scenario Description

User has implemented a simple feature adding a new API endpoint with its test file. All changes are related to a single logical feature.

## Initial Repository State

**Branch**: `main`

**Git Status**:

```text
M src/api/routes.js
A src/api/handlers/profile.js
A tests/api/profile.test.js
```

**Changes Summary**:

- Modified routes.js to add new route registration
- New handler file for profile endpoint
- New test file with integration tests

## User Request

"Help me commit these changes"

## Expected Skill Behavior

### Phase 0: Branch Management

1. Detect user is on `main` branch
2. Analyze changes to identify feature work
3. Suggest branch name: `feature/profile-endpoint`
4. Ask user for confirmation
5. Create and checkout branch: `git checkout -b feature/profile-endpoint`

### Phase 1: Repository Analysis

1. Run `git status --short`, `git diff`, `git log --oneline -n 10` in parallel
2. Identify 3 files changed
3. Recognize all changes relate to single feature
4. No safety issues detected

### Phase 2: Organize into Atomic Commits

1. Analyze that all files are related to same feature
2. Propose single atomic commit containing all three files
3. Present plan to user: "1 commit: Add profile endpoint with tests"
4. Get user approval (no TodoWrite needed - only 1 commit)

### Phase 3: Create Commits

1. Stage all files: `git add src/api/routes.js src/api/handlers/profile.js tests/api/profile.test.js`
2. Generate commit message:
   - Summary: "Add user profile API endpoint"
   - Body: Explain why endpoint needed, what it returns, testing info
   - Format: ≤72 chars, imperative mood, explains WHY
3. Execute commit with heredoc
4. Verify: `git log -1 --oneline`

### Phase 4: Cleanup

1. Skip - only one commit, nothing to clean up

### Phase 5: Push

1. Show commit summary
2. Ask for push confirmation
3. Execute: `git push -u origin feature/profile-endpoint`
4. Verify success

### Phase 6: PR Creation

1. Ask if user wants to create PR
2. If yes:
   - Check for `gh` CLI
   - Generate PR title from commit
   - Generate PR description from commit body
   - Show for review
   - Create PR
   - Show URL

## Success Criteria

✅ **Branch created appropriately** - Feature branch created from main
✅ **Single atomic commit** - All related changes in one commit
✅ **Well-formatted message** - Follows 72-char, imperative mood rules
✅ **Message explains WHY** - Body provides context beyond code
✅ **Safety checks passed** - No conflicts, clean working directory
✅ **User confirmation** - Asked before branch creation and push
✅ **Successful push** - New branch pushed to remote
✅ **PR created** (optional) - If user requested, PR created successfully

## Common Pitfalls to Avoid

❌ Don't split into multiple commits - all changes are related
❌ Don't commit to main - should create feature branch
❌ Don't use past tense in commit message
❌ Don't skip body if feature warrants explanation
❌ Don't push without confirmation

## Model Variants

**Haiku**: May need more explicit reminders about imperative mood and 72-char limit
**Sonnet**: Should handle perfectly with standard instructions
**Opus**: May add extra detail to commit message - ensure stays under 72 chars for summary
