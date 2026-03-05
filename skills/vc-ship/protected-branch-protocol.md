# Protected Branch Push Protocol

Prevents direct **pushes** to protected branches (main/master/develop/production/staging).

**Philosophy**: Easier to override when you know what you're doing than to undo a bad push to main.

**Note**: This is Phase 6 protection (push-time). For Phase 0 protection (start-of-work), see [phase-0-protocol.md](phase-0-protocol.md#detection-order).

## Detection Order

1. Check for detached HEAD → handle separately
2. Fetch latest remote state: `git fetch origin $BRANCH`
3. Check for uncommitted changes → require commit or stash first
4. Check if current branch is protected → if yes, BLOCK and enter this protocol

**Integration with Phase 5**: Quality review runs BEFORE this check. Commits are validated regardless of branch.

## When Protected Branch Detected

BLOCK the push. Present 3 options via AskUserQuestion:

### Option 1: Create feature branch (Recommended)

1. Suggest branch name from commit analysis
2. Show migration plan (commits to move, target branch name)
3. Execute: `git checkout -b {feature} origin/{protected}` → cherry-pick commits → `git checkout {protected}` → `git reset --hard origin/{protected}` → `git checkout {feature}`
4. On cherry-pick failure: abort, return to protected branch, delete feature branch
5. Push feature branch with `-u`, offer Phase 7 (PR creation)

### Option 2: Rename current branch

1. Suggest name based on commits
2. Execute: `git branch -m {protected} {feature}` → `git checkout -b {protected} origin/{protected}` → `git checkout {feature}`
3. Push renamed branch, offer Phase 7

### Option 3: Emergency override (hotfix only)

Valid reasons: security vulnerability, production down, critical data loss.

1. Require justification (freeform text)
2. Require explicit confirmation
3. Create audit commit documenting the override
4. Push with final warning
5. Recommend creating a documentation PR afterward

## Force Push to Protected Branch — ABSOLUTELY BLOCKED

No override. Detect by checking if remote has commits we don't have (`git rev-list --count HEAD..origin/$BRANCH`). If force push would be needed on a protected branch:

- Show absolute block message
- Explain: rewrites shared history, breaks other developers, can lose commits
- Direct user to handle manually outside this skill
- Exit workflow

## Edge Cases

| Situation                    | Action                                             |
| ---------------------------- | -------------------------------------------------- |
| Hotfix branch (`hotfix/*`)   | Allow push, require PR to main                     |
| Release branch (`release/*`) | Allow push, suggest PR to main                     |
| Some commits already pushed  | Warn about unusual state, migrate only new commits |
| Detached HEAD                | Offer to create branch first                       |
| No remote                    | Skip Phase 6 entirely — commits stay local-only    |

## Rollback

If any option fails midway:

- **Cherry-pick fails**: abort cherry-pick, return to protected branch, delete feature branch — commits remain on protected branch unchanged
- **Reset fails after cherry-pick**: commits exist on both branches safely — push feature branch, then reset protected branch manually
- **Rename fails**: check `git branch` to identify which branch has commits, keep that one
- **Override push fails**: audit commit exists locally — retry push, or `git reset --soft HEAD~1` to remove audit commit

Recovery tools: `git status`, `git log --oneline -10`, `git branch -a`, `git reflog`.
