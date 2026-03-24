# Branch Protection

Prevents accidental work on protected branches (main/master/develop/production/staging) at two points: start-of-work (Phase 0) and push-time (Phase 6).

**Philosophy**: Catch mistakes early and block them late — defense in depth.

## Phase 0: Working Directory Protection

Detects uncommitted changes on protected branches before work begins.

### Detection Order

1. Get current branch
2. Detached HEAD → offer to create branch from current commit
3. Already on feature/fix/refactor/docs/test/chore/hotfix/release branch → skip Phase 0
4. Not on protected branch → skip Phase 0
5. Check for uncommitted changes (staged + unstaged):
   - **Dirty** → BLOCKING (Scenario 1)
   - **Clean** → suggestion only (Scenario 2)

### Scenario 1: Uncommitted Changes — BLOCKING

Present 3 options via AskUserQuestion:

**Option 1: Auto-suggest feature branch (Recommended)**

1. Determine branch type from changed files (priority: test → docs → fix → chore → feature)
2. Generate description from most-changed file (basename, kebab-case, lowercase)
3. Combine: `{prefix}/{description}` (e.g., `fix/auth-controller`)
4. Execute: `git stash push -u` → `git checkout -b {name}` → `git stash pop`
5. On failure: rollback — return to protected branch, delete new branch, restore stash

> If Phase 1 later excludes files (symlinks, secrets), consider renaming: `git branch -m <old> <new>`.

**Option 2: Custom branch name**

Ask user for name. Validate it starts with a standard prefix. If not, offer to prepend `feature/`. Same stash/checkout/pop migration.

**Option 3: Override — continue on protected branch**

- Strong warning (only for tiny config changes or critical hotfixes)
- Require explicit confirmation
- Create audit commit documenting the override

### Scenario 2: Clean Working Directory — Suggestion

Friendly tip suggesting a feature branch. Options:

1. Create branch now (placeholder name with date)
2. Skip — re-check if uncommitted changes appear later

## Phase 6: Push-Time Protection

Detects committed changes about to be pushed to protected branches.

### Detection Order

1. Check for detached HEAD → handle separately
2. Fetch latest: `git fetch origin $BRANCH`
3. Check for uncommitted changes → require commit or stash first
4. Check if current branch is protected → if yes, BLOCK

**Integration**: Phase 5 quality review runs BEFORE this check.

### When Protected Branch Detected

BLOCK the push. Present 3 options:

**Option 1: Create feature branch (Recommended)**

1. Suggest branch name from commit analysis
2. Show migration plan
3. Execute: `git checkout -b {feature} origin/{protected}` → cherry-pick commits → `git checkout {protected}` → `git reset --hard origin/{protected}` → `git checkout {feature}`
4. On cherry-pick failure: abort, return to protected branch, delete feature branch
5. Push feature branch with `-u`, offer Phase 7

**Option 2: Rename current branch**

1. Suggest name based on commits
2. Execute: `git branch -m {protected} {feature}` → `git checkout -b {protected} origin/{protected}` → `git checkout {feature}`
3. Push renamed branch, offer Phase 7

**Option 3: Emergency override (hotfix only)**

Valid reasons: security vulnerability, production down, critical data loss.

1. Require justification (freeform text) and explicit confirmation
2. Create audit commit documenting the override
3. Push with final warning
4. Recommend creating a documentation PR afterward

### Force Push to Protected Branch — ABSOLUTELY BLOCKED

No override. If `git rev-list --count HEAD..origin/$BRANCH` shows remote has commits we don't:

- Show absolute block message
- Explain: rewrites shared history, breaks others, can lose commits
- Direct user to handle manually
- Exit workflow

## Edge Cases

| Situation                   | Action                                                   |
| --------------------------- | -------------------------------------------------------- |
| Already on feature branch   | Skip Phase 0 entirely                                    |
| Detached HEAD               | Offer: create branch or return to main                   |
| Hotfix/release branch       | Allow push with warning; require PR to main              |
| Stash pop conflicts         | Rollback, show manual recovery steps                     |
| No remote                   | Proceed with local branch creation; skip Phase 6         |
| Cherry-pick fails           | Abort, return to protected branch, delete feature branch |
| Rename fails                | Check `git branch` to find commits, keep that branch     |
| Some commits already pushed | Warn, migrate only new commits                           |

## Rollback

Recovery tools: `git status`, `git log --oneline -10`, `git branch -a`, `git reflog`.

- **Cherry-pick fails**: abort, return to protected branch — commits unchanged
- **Reset fails after cherry-pick**: commits on both branches safely — push feature, reset protected manually
- **Override push fails**: audit commit local — retry push, or `git reset --soft HEAD~1`
