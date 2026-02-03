# Protected Branch Push Protocol

This document details the protocol for preventing direct **pushes** to protected branches (main/master/develop/production/staging).

**Note**: This is Phase 5 protection (push-time). For Phase 0 protection (when starting work on protected branch), see [phase-0-protocol.md](phase-0-protocol.md).

## Overview

**Philosophy**: It's easier to override when you know what you're doing than to undo a bad push to main.

Direct pushes to protected branches are dangerous because they:

1. **Bypass code review** - No PR means no review process
2. **Break CI/CD** - Many projects protect main in GitHub but not locally
3. **Risk production** - Main often auto-deploys to production
4. **Lose history** - Can't easily revert without force push
5. **Team disruption** - Unexpected changes appear in main

## Requirements

**Shell Requirements:**

- Bash 4.0+ (for array syntax)
- Standard git 2.23+ (for `git branch --show-current`)

**Portability Note:** This protocol uses bash-specific features. For POSIX sh compatibility, alternative implementations would be needed.

## Detection Logic

**Before pushing, perform these checks in order:**

```bash
# 1. Check for detached HEAD state first
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
  # Detached HEAD state - handle before protected branch check
  echo "⚠️ You are in detached HEAD state"
  # Offer to create branch (see Detached HEAD edge case)
  exit 1
fi

# 2. Fetch latest remote state to avoid race conditions
git fetch origin "$CURRENT_BRANCH" 2>/dev/null || true

# 3. Check for uncommitted changes (will interfere with migration)
if ! git diff-index --quiet HEAD --; then
  echo "⚠️ You have uncommitted changes"
  echo "Please commit or stash changes before pushing"
  exit 1
fi

# 4. Check if current branch is protected
PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")

if [[ " ${PROTECTED_BRANCHES[@]} " =~ " ${CURRENT_BRANCH} " ]]; then
  # STOP - Enter protected branch push protocol
  # Do NOT push - block the operation
fi
```

**When to check**:

- In Phase 5, BEFORE showing the push confirmation dialog
- After user has created commits, before actually pushing
- After verifying working directory is clean

## Integration with Phase 4.5

Note: Phase 4.5 (Quality Review) runs BEFORE the protected branch check in Phase 5.

**Workflow Sequence**:

1. Phase 4: Commit history cleanup (optional)
2. **Phase 4.5: Quality review and tests** (MANDATORY)
3. Phase 5: Protected branch detection → push confirmation → push

Quality issues (generic messages, format violations) are caught in Phase 4.5 even before we check if the branch is protected. This ensures commits are clean regardless of which branch the user is on.

**Why This Order Matters**:

- Quality review is universal (applies to all branches)
- Protected branch check is specific (only applies to main/master/etc.)
- Better UX: Fix quality issues once, even if also need to migrate branch

For Phase 4.5 details, see [phase-4.5-protocol.md](phase-4.5-protocol.md).

## Protected Branch Push Protocol

When a push to a protected branch is detected, **BLOCK** the operation and present this message:

```text
🛑 BLOCKED: Cannot push directly to `{branch}` branch

Direct pushes to protected branches are not allowed.

Why this is blocked:
• Bypasses code review process
• Risk of breaking production
• No opportunity for team feedback
• Makes history harder to track

What you should do instead:

Option 1: Create a feature branch (Recommended)
  Move your commits to a new feature branch, then create a PR

Option 2: Rename current branch
  If you meant to be on a feature branch, rename it

Option 3: Emergency override (hotfix only)
  Only for critical hotfixes - requires explicit reason

Which option would you like? [1/2/3]
```

Use **AskUserQuestion** to present these options with descriptions.

## Option 1: Create Feature Branch (Recommended)

**Steps to automate**:

1. **Suggest branch name based on commits:**
   - Analyze recent commits not in origin/{branch}
   - Determine type of work (fix, feature, refactor, docs, test)
   - Generate descriptive name following convention
   - Example: `fix/login-validation`, `feature/user-dashboard`

2. **Show the migration plan:**

   ```text
   I'll help you move these commits to a feature branch:

   1. Create new branch: {suggested-name}
   2. Cherry-pick commits from {protected-branch}
   3. Reset {protected-branch} to origin/{protected-branch}
   4. Push {suggested-name} to remote
   5. Offer to create PR

   Commits to migrate:
   - {commit-hash} {commit-message}
   - {commit-hash} {commit-message}

   Proceed with this plan?
   ```

3. **Execute the migration:**

   ```bash
   # Get commits to migrate (not in origin) in chronological order
   # Use git's --reverse flag instead of tac for portability
   COMMITS=$(git log origin/{protected-branch}..HEAD --format="%H" --reverse)

   # Verify we have commits to migrate
   if [ -z "$COMMITS" ]; then
     echo "No commits to migrate"
     exit 1
   fi

   # Create feature branch from origin/{protected-branch}
   git checkout -b {feature-branch} origin/{protected-branch}

   # Cherry-pick commits to feature branch
   for commit in $COMMITS; do
     if ! git cherry-pick $commit; then
       echo "Cherry-pick failed. Rolling back..."
       git cherry-pick --abort
       git checkout {protected-branch}
       git branch -D {feature-branch}
       echo "Migration failed. Your commits remain on {protected-branch}"
       exit 1
     fi
   done

   # Switch back to protected branch and reset to origin
   git checkout {protected-branch}
   git reset --hard origin/{protected-branch}

   # Switch to feature branch for push
   git checkout {feature-branch}
   ```

4. **Push feature branch:**
   - Use `git push -u origin {feature-branch}`
   - Confirm success
   - Proceed to Phase 6 (PR creation)

**Edge case - origin doesn't exist:**

- If `origin/{protected-branch}` doesn't exist, branch from current HEAD instead
- Warn user that protected branch isn't tracking remote

## Option 2: Rename Current Branch

**Use when:** User forgot to create a feature branch and has been working on main by mistake.

**Steps to automate:**

1. **Ask for new branch name:**
   - Suggest name based on commits
   - Allow user to customize

2. **Show the plan:**

   ```text
   I'll rename your current branch and recreate {protected-branch}:

   1. Rename {protected-branch} → {feature-branch}
   2. Recreate {protected-branch} from origin/{protected-branch}
   3. Push {feature-branch} to remote
   4. Offer to create PR

   This preserves all your work on {feature-branch} and resets
   {protected-branch} to match the remote.

   Proceed?
   ```

3. **Execute the rename:**

   ```bash
   # Rename current protected branch to feature branch
   git branch -m {protected-branch} {feature-branch}

   # Recreate protected branch from origin
   git checkout -b {protected-branch} origin/{protected-branch}

   # Switch to feature branch for push
   git checkout {feature-branch}
   ```

4. **Push renamed branch:**
   - Use `git push -u origin {feature-branch}`
   - Confirm success
   - Proceed to Phase 6 (PR creation)

**Edge case - uncommitted changes:**

- If there are uncommitted changes, offer to stash them first
- After rename, offer to restore stashed changes

## Option 3: Emergency Override

**Use ONLY for:** Critical hotfixes that must go directly to protected branch.

**Valid reasons:**

- Security vulnerability fix needed immediately
- Production is down and this fixes it
- Critical data loss prevention

**Invalid reasons:**

- "I forgot to branch"
- "It's just a small change"
- "I don't want to make a PR"

**Steps:**

1. **Explain the severity:**

   ```text
   ⚠️ EMERGENCY OVERRIDE REQUIRED

   This should ONLY be used for critical hotfixes that must go
   directly to {protected-branch}.

   Examples of VALID reasons:
   ✓ Security vulnerability fix needed immediately
   ✓ Production is down and this fixes it
   ✓ Critical data loss prevention

   Examples of INVALID reasons:
   ✗ "I forgot to branch"
   ✗ "It's just a small change"
   ✗ "I don't want to make a PR"

   This override will be logged for audit purposes.
   ```

2. **Collect reason and confirmation:**

   Use **AskUserQuestion** to ask:
   - "What is the emergency that requires direct push to {protected-branch}?"
     (text input required)
   - "Type 'I UNDERSTAND THE RISKS' to confirm"
     (must match exactly)

3. **Log the override:**

   Create an audit commit that logs the override decision:

   ```bash
   # Create empty commit with audit information
   git commit --allow-empty -m "$(cat <<EOF
   EMERGENCY OVERRIDE: Direct push to {protected-branch}

   Override-Reason: {user-reason}
   Override-Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
   Override-User: $(git config user.name) <$(git config user.email)>
   Override-Approved-By: $(git config user.name)

   This commit documents an emergency override of the protected branch
   push prevention protocol. The changes were pushed directly to
   {protected-branch} without going through the normal PR process.

   Previous commit: $(git log -1 --format="%H" HEAD~1)
   EOF
   )"
   ```

   **Security Note:** User identity in git can be spoofed. For serious audit
   requirements, consider using GPG commit signing (`git commit -S`).

4. **Proceed with push:**
   - Show final warning
   - Execute `git push` (includes audit commit)
   - **Still recommend creating a PR for documentation:**

   ```text
   Push completed with audit trail.

   ⚠️ IMPORTANT: Even though you pushed directly, please create a
   PR for documentation and tracking purposes:

   This PR won't require approval (already merged), but provides:
   • Visible record of changes
   • Place for discussion
   • Better commit visibility

   Create documentation PR now?
   ```

## Force Push Protection

Force pushing to protected branches is **ABSOLUTELY BLOCKED** with no override:

```bash
# Detect if force push would be required
# Check if remote branch has commits we don't have (non-fast-forward)
if git fetch origin "$CURRENT_BRANCH" 2>/dev/null; then
  # Count commits on remote that we don't have
  REMOTE_AHEAD=$(git rev-list --count HEAD..origin/"$CURRENT_BRANCH" 2>/dev/null || echo "0")

  if [ "$REMOTE_AHEAD" -gt 0 ]; then
    # Remote has commits we don't have - would need force push
    NEEDS_FORCE_PUSH=true
  fi
fi
```

**Note:** This detection is more reliable than parsing git push error messages,
which can vary across git versions.

**If force push needed to protected branch:**

```text
🛑 ABSOLUTELY BLOCKED: Force push to {protected-branch}

Force pushing to protected branches is extremely dangerous:
• Rewrites shared history
• Breaks other developers' work
• Can lose commits permanently

This is blocked without exception.

If you absolutely need to do this:
1. Contact your team lead
2. Notify all team members
3. Use git directly (outside this skill)
4. Document what happened and why

For now, please use Option 1 or Option 2 above to safely
handle your changes.
```

**Do NOT proceed** - exit the workflow and require user to handle manually.

## Edge Cases

### Hotfix Branches

Some teams use `hotfix/*` branches that merge to main:

```bash
# Check if current branch is a hotfix branch
if [[ $CURRENT_BRANCH =~ ^hotfix/ ]]; then
  # Allow push to hotfix branch (not protected)
  # But warn that this will merge to main
  # Require PR creation to main
fi
```

**Message:**

```text
This is a hotfix branch that will merge to {protected-branch}.

Allowing push to {current-branch}, but you MUST:
1. Push this hotfix branch
2. Create PR to {protected-branch}
3. Get it reviewed before merging

Proceed with push to {current-branch}?
```

### Release Branches

Similar to hotfix:

```bash
# Check if current branch is a release branch
if [[ $CURRENT_BRANCH =~ ^release/ ]]; then
  # Allow push to release branch
  # Suggest PR to main for tracking
fi
```

### Already Pushed Commits

If some commits already exist on `origin/{protected-branch}`:

```bash
# Check if any commits already pushed
git log origin/{protected-branch}..HEAD
```

**If some commits are new, some already pushed:**

```text
⚠️ WARNING: Some commits already pushed to origin/{protected-branch}

This is unusual. You have {n} commits:
• {x} already on remote
• {y} new commits not pushed

Options:
1. Continue with Option 1/2 (migrate new commits only)
2. Stop and investigate why some commits are already remote
3. Contact team lead

What would you like to do?
```

### Detached HEAD

If in detached HEAD state:

```text
⚠️ You are in detached HEAD state

Before proceeding with protected branch protocol, let's
get you onto a proper branch.

Would you like to:
1. Create new branch from current commit
2. Return to {protected-branch}
3. Investigate current state
```

### No Remote Configured

If no remote exists:

```text
⚠️ No remote repository configured

Cannot determine if branch is behind remote.

Would you like to:
1. Add remote repository (recommended)
2. Proceed without remote verification (risky)
```

## Rollback Procedures

If an option fails midway during execution, follow these recovery procedures:

### Option 1 Failed (Feature Branch Migration)

**If cherry-pick fails:**

The script includes automatic rollback (see Option 1 Step 3). Manual recovery:

```bash
# Abort the cherry-pick
git cherry-pick --abort

# Return to original branch
git checkout {protected-branch}

# Delete the incomplete feature branch
git branch -D {feature-branch}
```

**Result:** Your commits remain on {protected-branch}, unchanged.

**If reset fails after cherry-pick:**

```bash
# Your commits are now on both {feature-branch} and {protected-branch}
# This is safe - just push the feature branch

git checkout {feature-branch}
git push -u origin {feature-branch}

# Then fix protected branch
git checkout {protected-branch}
git reset --hard origin/{protected-branch}
```

### Option 2 Failed (Branch Rename)

**If branch rename fails:**

```bash
# Check current state
git branch

# If rename partially completed, you may see both old and new branch
# Determine which has your commits
git log {old-branch} --oneline
git log {new-branch} --oneline

# Keep the one with your commits, delete the other
git branch -D {unwanted-branch}
```

**If recreating protected branch fails:**

```bash
# You renamed the branch but couldn't recreate protected
# Your work is safe on the renamed branch

git checkout {renamed-branch}
git push -u origin {renamed-branch}

# Recreate protected branch manually
git fetch origin
git checkout -b {protected-branch} origin/{protected-branch}
```

### Option 3 Failed (Emergency Override)

**If push fails after override approval:**

```bash
# The audit commit was created but push failed
# Check what went wrong
git status
git log -1

# If it's a network/auth issue, just retry
git push

# If you want to abort the override
git reset --soft HEAD~1  # Remove audit commit
# Your original commits remain
```

### General Recovery

**Check repository state:**

```bash
git status              # See current branch and uncommitted changes
git log --oneline -10   # See recent commits
git branch -a           # See all branches (local and remote)
git reflog              # See recent HEAD movements
```

**Restore to known good state:**

```bash
# Return to origin state (CAUTION: loses local commits)
git fetch origin
git reset --hard origin/{branch-name}

# Recover "lost" commits
git reflog  # Find the commit hash
git checkout -b recovery-branch {commit-hash}
```

**Get help:**

If you're unsure about the state or recovery:

1. Don't force anything
2. Run `git status` and `git log --oneline -10`
3. Ask for help - your commits are likely still in reflog
4. Git rarely loses data permanently

## Configuration

Protected branches can be configured in the skill. Default list:

`PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")`

**Future enhancement**: Could read from:

- Git config: `git config --get-regexp branch.*.protected`
- `.gitprotected` file in repo root
- GitHub branch protection API

## Summary

**Protection flow:**

1. **Phase 5 begins** → Check if current branch is protected
2. **If protected** → BLOCK push, show protocol message
3. **User chooses option:**
   - Option 1: Automate feature branch migration
   - Option 2: Automate branch rename
   - Option 3: Require emergency justification + confirmation
4. **Execute chosen option** → Resolve safely
5. **Continue workflow** → Push to feature branch or log override

**Key principles:**

- **Block first, explain second** - Don't let the push happen
- **Educate the user** - Explain why it's dangerous
- **Provide easy alternatives** - Make doing the right thing easy
- **Allow emergencies** - But make them explicit and logged
- **No force push** - Absolutely blocked, no exceptions
