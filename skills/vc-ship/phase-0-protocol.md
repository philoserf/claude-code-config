# Phase 0: Protected Branch Working Directory Protocol

Prevents direct work on protected branches by detecting uncommitted changes early.

**Philosophy**: Catch mistakes early — before you invest time in work that's hard to migrate.

**Note**: This is Phase 0 protection (start-of-work). For Phase 6 protection (push-time), see [protected-branch-protocol.md](protected-branch-protocol.md#when-protected-branch-detected).

## Detection Order

1. Get current branch
2. If detached HEAD → handle separately (offer to create branch)
3. If already on feature/fix/refactor/docs/test/chore/hotfix/release branch → skip Phase 0
4. If not on protected branch (main/master/develop/production/staging) → skip Phase 0
5. Check for uncommitted changes (staged + unstaged)
   - **Dirty** → Scenario 1 (BLOCKING)
   - **Clean** → Scenario 2 (suggestion)

## Scenario 1: Uncommitted Changes — BLOCKING

Show blocking message listing changed files and explaining risks (bypasses review, accidental push, messy history).

Present 3 options via AskUserQuestion:

### Option 1: Auto-suggest feature branch (Recommended)

1. **Determine branch type** from changed files (priority: test → docs → fix → chore → feature)
2. **Generate description** from most-changed file (basename, kebab-case, lowercase)
3. **Combine**: `{prefix}/{description}` (e.g., `fix/auth-controller`)
4. **Execute migration**: `git stash push -u` → `git checkout -b {name}` → `git stash pop`
5. **On failure**: rollback — return to protected branch, delete new branch, restore stash

### Option 2: Custom branch name

Ask user for name. Validate it starts with a standard prefix (feature/, fix/, etc.). If not, offer to prepend `feature/`. Execute same stash/checkout/pop migration.

### Option 3: Override — continue on protected branch

- Show strong warning (only for tiny config changes or critical hotfixes)
- Require explicit confirmation
- Create audit commit documenting the override
- Proceed to Phase 1

## Scenario 2: Clean Working Directory — Suggestion (non-blocking)

Friendly tip suggesting the user create a feature branch before starting work. Options:

1. **Create branch now** — placeholder name with date, can rename later
2. **Skip** — proceed to Phase 1; re-check if uncommitted changes appear later

## Edge Cases

| Situation                            | Action                                                                                             |
| ------------------------------------ | -------------------------------------------------------------------------------------------------- |
| Already on feature branch            | Skip Phase 0 entirely                                                                              |
| Detached HEAD                        | Offer: create branch from current commit, or return to main                                        |
| Hotfix/release branch                | Allow with warning; require PR before merging to main                                              |
| Stash pop conflicts                  | Rollback: return to protected branch, delete new branch, restore stash, show manual recovery steps |
| No remote configured                 | Proceed with local branch creation                                                                 |
| Both committed + uncommitted changes | Handle uncommitted (Phase 0), committed caught later (Phase 5)                                     |

## Phase 0 vs Phase 6

| Aspect        | Phase 0                       | Phase 6                  |
| ------------- | ----------------------------- | ------------------------ |
| **When**      | Start of workflow             | Before pushing           |
| **Detects**   | Uncommitted changes           | Committed changes        |
| **Migration** | `git stash` / `git stash pop` | `git cherry-pick`        |
| **Options**   | Auto/custom branch/override   | Migrate/rename/emergency |
