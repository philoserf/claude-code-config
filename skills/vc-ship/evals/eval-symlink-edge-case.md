# Evaluation: Symlinked Files Edge Case

## Scenario Description

User has a mix of regular files and symlinked directories in their changes. The symlinked files cannot be staged with `git add` and must be detected and excluded during Phase 1.

## Initial Repository State

**Branch**: `main`

**Git Status**:

```text
M settings.json
?? skills/new-skill
?? rules/new-rule.md
```

**Key Detail**: `skills/new-skill` is a symlink to `../../.agents/skills/new-skill` (installed via `npx skills add -g`).

## User Request

"Ship these changes"

## Expected Skill Behavior

### Phase 0: Branch Management

1. Detect user is on `main` branch
2. Suggest branch name from changed files
3. Create feature branch

### Phase 1: Repository Analysis

1. Run `git status --short`, `git diff`, `git log --oneline -n 10` in parallel
2. Identify 3 items: 1 modified file, 2 untracked
3. **Check for symlinks**: `find skills/new-skill -type l`
4. **Detect** `skills/new-skill` is a symlink
5. **Flag**: inform user that symlinked files will be excluded from the commit plan
6. Continue with remaining committable files only

### Phase 2: Organize into Atomic Commits

1. Exclude `skills/new-skill` from commit plan
2. Organize remaining files (`settings.json`, `rules/new-rule.md`)
3. Present plan showing only committable files
4. Note excluded symlinks in the plan summary

### Phase 3: Create Commits

1. Stage only non-symlinked files: `git add -f settings.json rules/new-rule.md`
2. Use `git add -f` since files may be in gitignored directories
3. Generate commit message covering the actual changes
4. Execute commit

### Phase 4-7: Normal Flow

Continue through remaining phases normally with the reduced file set.

## Success Criteria

- **Symlinks detected in Phase 1** — not discovered at `git add` time in Phase 3
- **User informed** — clear message about which files were excluded and why
- **Commit plan accurate** — only includes committable files
- **No `git add` failures** — symlinked files never reach staging
- **Branch name reasonable** — reflects actual shipped content, not excluded files
- **`git add -f` used** — for files in gitignored directories

## Common Pitfalls to Avoid

- Don't attempt to `git add` symlinked files (fails with "beyond a symbolic link")
- Don't silently skip files — always inform the user
- Don't include symlinked files in the commit plan
- Don't name the branch after excluded files
- Don't copy symlink targets to replace symlinks (unless user requests it)
