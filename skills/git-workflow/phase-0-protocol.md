# Phase 0: Protected Branch Working Directory Protocol

This document details the protocol for preventing direct work on protected branches (main/master/develop/production/staging) by detecting uncommitted changes early in the workflow.

## Overview

**Philosophy**: Catch mistakes early - before you invest time in work that will be hard to migrate.

Direct work on protected branches is risky because it:

1. **Bypasses code review** - No PR means no review process
2. **Risk accidental push** - Easy to accidentally push to main
3. **Makes history messy** - Work mixed with production code
4. **Harder to organize** - Difficult to group changes into atomic commits
5. **Team disruption** - Unexpected changes appear in shared branch

**Note**: This is Phase 0 protection (start-of-work). For Phase 5 protection (push-time), see [protected-branch-protocol.md](protected-branch-protocol.md).

## Requirements

**Shell Requirements:**

- Bash 4.0+ (for array syntax)
- Standard git 2.23+ (for `git branch --show-current`)

**Portability Note:** This protocol uses bash-specific features. For POSIX sh compatibility, alternative implementations would be needed.

## Detection Logic

**Before starting repository analysis, perform these checks in order:**

```bash
# 1. Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# 2. Check for detached HEAD state first
if [ -z "$CURRENT_BRANCH" ]; then
  # Detached HEAD state - handle before protected branch check
  echo "⚠️ You are in detached HEAD state"
  # Offer to create branch (see Detached HEAD edge case)
  exit 1
fi

# 3. Skip if already on feature/fix/refactor/docs/test/chore/hotfix/release branch
if [[ $CURRENT_BRANCH =~ ^(feature|fix|refactor|docs|test|chore|hotfix|release)/ ]]; then
  # Already on appropriate branch - skip Phase 0
  exit 0
fi

# 4. Check if current branch is protected
PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")

if [[ ! " ${PROTECTED_BRANCHES[@]} " =~ " ${CURRENT_BRANCH} " ]]; then
  # Not on protected branch - skip Phase 0
  exit 0
fi

# 5. Check for uncommitted changes (staged + unstaged)
if git diff-index --quiet HEAD --; then
  # Clean working directory - proactive suggestion (soft)
  SCENARIO="clean"
else
  # Uncommitted changes - BLOCK (mandatory)
  SCENARIO="dirty"
fi
```

**When to check**:

- In Phase 0, BEFORE starting repository analysis (Phase 1)
- As first action when git-workflow skill is invoked
- Before user has made any commits

## Scenario 1: Uncommitted Changes on Protected Branch (BLOCKING)

When uncommitted changes are detected on a protected branch, **BLOCK** the operation and present this message:

```text
🛑 STOP: You're working on protected branch `{branch}` with uncommitted changes

Working directly on protected branches is risky:
• Bypasses code review process
• Changes can accidentally get pushed to main
• Makes it harder to organize work into logical commits

I detected changes in:
{list first 5 changed files}

Let me help you create a feature branch to safely isolate this work.
```

Use **AskUserQuestion** to present these options with descriptions.

### Option 1: Create Feature Branch with Auto-Suggested Name (Recommended)

**Steps to automate**:

1. **Analyze changed files to suggest branch type:**

```bash
# Get list of changed files
CHANGED_FILES=$(git diff --name-only HEAD)

# Determine type (priority order)
if echo "$CHANGED_FILES" | grep -q "test\|spec"; then
  PREFIX="test"
elif echo "$CHANGED_FILES" | grep -q "README\|docs/\|\.md$"; then
  PREFIX="docs"
elif git diff HEAD | grep -i "fix\|bug\|patch" | head -5 | grep -q .; then
  PREFIX="fix"
elif echo "$CHANGED_FILES" | grep -q "package.json\|\.config\|\.yml$\|\.yaml$"; then
  PREFIX="chore"
else
  PREFIX="feature"
fi
```

1. **Generate description from most-changed file:**

```bash
# Find file with most changes
MAIN_FILE=$(git diff --stat HEAD | sort -rn -k2 | head -1 | awk '{print $1}')

# Extract description
if [ -n "$MAIN_FILE" ]; then
  # Get basename without extension
  DESCRIPTION=$(basename "$MAIN_FILE" | sed 's/\.[^.]*$//')

  # Convert CamelCase to kebab-case
  DESCRIPTION=$(echo "$DESCRIPTION" | sed 's/[A-Z]/-\L&/g' | sed 's/^-//')

  # Convert to lowercase
  DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]')

  # Remove common words
  DESCRIPTION=$(echo "$DESCRIPTION" | sed 's/index//g' | sed 's/main//g' | sed 's/utils//g')

  # Clean up multiple hyphens
  DESCRIPTION=$(echo "$DESCRIPTION" | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
else
  # Fallback description
  DESCRIPTION="update-$(date +%Y-%m-%d)"
fi

# Combine
SUGGESTED_NAME="${PREFIX}/${DESCRIPTION}"
```

1. **Show the plan to user:**

```text
I suggest creating: {SUGGESTED_NAME}

This will:
• Stash your uncommitted changes
• Create new branch from current {PROTECTED_BRANCH}
• Apply your changes to the new branch
• Leave {PROTECTED_BRANCH} clean

Proceed with this branch name?
```

1. **Execute migration:**

```bash
# Store current protected branch name
PROTECTED_BRANCH="$CURRENT_BRANCH"

# 1. Stash uncommitted changes (including untracked)
git stash push -u -m "Phase 0: Migrating to ${SUGGESTED_NAME}"
STASH_REF=$(git rev-parse refs/stash)

echo "✓ Stashed changes"

# 2. Create and checkout new branch
if ! git checkout -b "${SUGGESTED_NAME}"; then
  echo "⚠️ ROLLBACK: Failed to create branch"
  git stash apply "$STASH_REF"
  exit 1
fi

echo "✓ Created branch ${SUGGESTED_NAME}"

# 3. Apply stashed changes
if ! git stash pop; then
  # ROLLBACK: Stash apply failed (likely conflicts)
  echo "⚠️ ROLLBACK: Stash apply failed (likely conflicts)"

  # Return to protected branch
  git checkout "${PROTECTED_BRANCH}"

  # Delete the new branch
  git branch -D "${SUGGESTED_NAME}"

  # Restore stash (don't pop, keep it)
  git stash apply "$STASH_REF"

  echo ""
  echo "Your changes remain on ${PROTECTED_BRANCH}"
  echo "The stash has been preserved for manual recovery"
  echo ""
  echo "Manual resolution:"
  echo "1. Manually create branch: git checkout -b <branch-name>"
  echo "2. Apply stash with conflict resolution: git stash pop"
  echo "3. Resolve conflicts and commit"

  exit 1
fi

echo "✓ Applied changes to ${SUGGESTED_NAME}"
echo ""
echo "✓ SUCCESS: ${PROTECTED_BRANCH} is now clean"
echo "✓ Your changes are on ${SUGGESTED_NAME}"
```

### Option 2: Create Feature Branch with Custom Name

**Steps to automate**:

1. **Ask for custom branch name:**

Use **AskUserQuestion** (other option):

```text
What should the branch be named?

Examples:
• feature/user-authentication
• fix/login-validation
• refactor/auth-library
• docs/api-documentation
• test/auth-coverage
```

1. **Validate format:**

```bash
CUSTOM_NAME="<user input>"

# Validate format
if [[ ! $CUSTOM_NAME =~ ^(feature|fix|refactor|docs|test|chore)/ ]]; then
  echo "⚠️ Branch name should start with: feature/, fix/, refactor/, docs/, test/, or chore/"
  echo ""
  echo "Examples:"
  echo "  feature/user-authentication"
  echo "  fix/login-bug"
  echo ""

  # Offer to prepend feature/
  echo "Would you like me to prepend 'feature/' to '${CUSTOM_NAME}'?"
  # If yes: CUSTOM_NAME="feature/${CUSTOM_NAME}"
fi
```

1. **Execute migration:**

Same as Option 1, but use `CUSTOM_NAME` instead of `SUGGESTED_NAME`.

### Option 3: Continue on Protected Branch (Override)

**IMPORTANT**: This option should be used sparingly - only for tiny config changes or critical hotfixes.

**Steps to automate**:

1. **Show strong warning:**

```text
⚠️ OVERRIDE REQUIRED

Continuing on {PROTECTED_BRANCH} is strongly discouraged.

This should ONLY be done if:
✓ You're making a tiny configuration change
✓ You're fixing a critical production bug
✓ You absolutely cannot use a feature branch

This override will be logged in your git history.

To proceed, type exactly: CONTINUE ON PROTECTED
```

1. **Validate confirmation:**

```bash
# User must type exactly: "CONTINUE ON PROTECTED"
CONFIRMATION="<user input>"

if [ "$CONFIRMATION" != "CONTINUE ON PROTECTED" ]; then
  echo "Override cancelled - confirmation did not match"
  # Return to option selection
fi
```

1. **Create audit commit:**

```bash
# Get current changed files for documentation
CHANGED_FILES=$(git status --short)

# Create empty commit with metadata
git commit --allow-empty -m "$(cat <<EOF
Phase 0 Override: Continuing work on ${CURRENT_BRANCH}

Override-Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Override-User: $(git config user.name) <$(git config user.email)>

The user chose to continue working on ${CURRENT_BRANCH} despite
Phase 0 recommending a feature branch.

Changes in progress:
${CHANGED_FILES}

This commit can be removed later if needed:
  git rebase -i HEAD~2  # Remove this commit during cleanup
EOF
)"

echo ""
echo "✓ Override logged"
echo "⚠️ You can now continue on ${CURRENT_BRANCH}"
echo ""
echo "REMINDER: You should still create a PR before merging to ${CURRENT_BRANCH}"
```

1. **Proceed to Phase 1:**

Allow workflow to continue with repository analysis.

## Scenario 2: Clean Working Directory on Protected Branch (SUGGESTION)

When working directory is clean but user is on protected branch, show a **friendly proactive suggestion** (non-blocking):

```text
💡 TIP: You're on protected branch `{branch}` with a clean working directory

Before you start making changes, consider creating a feature branch to:
• Isolate your work from production code
• Make it easier to create a clean PR later
• Organize commits logically

Would you like me to create a feature branch now?
```

**2 Options via AskUserQuestion**:

### Option 1: Create Branch Now

Since there are no changes yet, create a placeholder branch:

```bash
# Create placeholder name with date
PLACEHOLDER_NAME="feature/work-in-progress-$(date +%Y-%m-%d)"

# Create and checkout
git checkout -b "$PLACEHOLDER_NAME"

echo "✓ Created ${PLACEHOLDER_NAME}"
echo ""
echo "You can rename this branch later if needed:"
echo "  git branch -m <new-name>"
```

### Option 2: Continue on Protected Branch

```text
Okay, I'll skip for now.

Note: If you make uncommitted changes, I'll check again and
strongly recommend creating a feature branch at that time.
```

Then proceed to Phase 1. If uncommitted changes appear during the workflow, re-enter **Scenario 1** (blocking protocol).

## Branch Name Suggestion Algorithm

**Full algorithm for intelligent branch naming:**

```bash
suggest_branch_name() {
  local protected_branch="$1"

  # 1. Get changed files
  local changed_files=$(git diff --name-only HEAD)

  # 2. Determine branch type (priority order)
  local prefix="feature"  # default

  if echo "$changed_files" | grep -q "test\|spec"; then
    prefix="test"
  elif echo "$changed_files" | grep -q "README\|docs/\|\.md$"; then
    prefix="docs"
  elif git diff HEAD | grep -i "fix\|bug\|patch" | head -5 | grep -q .; then
    prefix="fix"
  elif echo "$changed_files" | grep -q "package.json\|\.config\|\.yml$\|\.yaml$\|\.toml$"; then
    prefix="chore"
  fi

  # 3. Extract description from most-changed file
  local main_file=$(git diff --stat HEAD | sort -rn -k2 | head -1 | awk '{print $1}')
  local description=""

  if [ -n "$main_file" ]; then
    # Get basename without extension
    description=$(basename "$main_file" | sed 's/\.[^.]*$//')

    # Convert CamelCase to kebab-case
    description=$(echo "$description" | sed 's/[A-Z]/-\L&/g' | sed 's/^-//')

    # Convert to lowercase
    description=$(echo "$description" | tr '[:upper:]' '[:lower:]')

    # Remove common words
    description=$(echo "$description" | sed 's/index//g' | sed 's/main//g' | sed 's/utils//g' | sed 's/helper//g')

    # Clean up multiple hyphens
    description=$(echo "$description" | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

    # Limit to 3-4 words max
    description=$(echo "$description" | cut -d'-' -f1-4)
  fi

  # 4. Fallback if no good description
  if [ -z "$description" ] || [ "$description" = "-" ]; then
    description="update-$(date +%Y-%m-%d)"
  fi

  # 5. Combine
  echo "${prefix}/${description}"
}

# Usage:
SUGGESTED_NAME=$(suggest_branch_name "$CURRENT_BRANCH")
```

## Edge Cases

### Already on Feature Branch

**Detection:**

```bash
if [[ $CURRENT_BRANCH =~ ^(feature|fix|refactor|docs|test|chore)/ ]]; then
  # Skip Phase 0 entirely
  exit 0
fi
```

**Action:** Skip Phase 0 entirely and proceed to Phase 1.

### Detached HEAD State

**Detection:**

```bash
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
  # Detached HEAD
fi
```

**Action:**

```text
⚠️ You are in detached HEAD state

You're not on any branch. This happens when you checkout a specific commit.

Would you like to create a branch from the current commit?

1. Create branch from current commit
2. Return to main branch
```

**Option 1:**

```bash
# Ask for branch name
BRANCH_NAME="<user input>"

# Create branch from current commit
git checkout -b "$BRANCH_NAME"

echo "✓ Created branch ${BRANCH_NAME} from current commit"
```

**Option 2:**

```bash
# Determine main branch
if git show-ref --verify --quiet refs/heads/main; then
  git checkout main
elif git show-ref --verify --quiet refs/heads/master; then
  git checkout master
else
  git checkout develop
fi
```

### Hotfix or Release Branch

**Detection:**

```bash
if [[ $CURRENT_BRANCH =~ ^(hotfix|release)/ ]]; then
  # Special branch - allow but warn
fi
```

**Action:**

```text
✓ You're on ${CURRENT_BRANCH} (special branch type)

Hotfix and release branches are allowed, but:
⚠️ You should still create a PR before merging
⚠️ Changes should be reviewed before merging to main

Proceeding with workflow...
```

Then skip to Phase 1.

### Stash Pop Conflicts

**Detection:**

```bash
if ! git stash pop; then
  # Conflict occurred
fi
```

**Rollback procedure:**

```bash
echo "⚠️ ROLLBACK: Stash apply failed (likely conflicts)"

# 1. Return to protected branch
git checkout "${PROTECTED_BRANCH}"

# 2. Delete the new branch
git branch -D "${SUGGESTED_NAME}"

# 3. Restore stash (keep it, don't pop)
git stash apply "$STASH_REF"

echo ""
echo "Your changes remain on ${PROTECTED_BRANCH}"
echo "The stash has been preserved in: ${STASH_REF}"
echo ""
echo "To recover manually:"
echo "1. Create branch: git checkout -b <branch-name>"
echo "2. Apply stash: git stash pop"
echo "3. Resolve conflicts"
echo "4. Commit changes"
```

### No Remote Configured

**Detection:**

```bash
if ! git remote -v | grep -q "origin"; then
  # No remote
fi
```

**Action:**

```text
⚠️ No remote repository configured

Your repository doesn't have a remote 'origin'. This means:
• You can still create feature branches locally
• You won't be able to push until remote is configured

Proceeding with local branch creation...
```

Then continue with normal flow.

### Both Committed and Uncommitted Changes

**Detection:**

```bash
# Check for uncommitted changes
HAS_UNCOMMITTED=false
if ! git diff-index --quiet HEAD --; then
  HAS_UNCOMMITTED=true
fi

# Check for unpushed commits
HAS_COMMITS=false
if git log origin/${CURRENT_BRANCH}..HEAD --oneline 2>/dev/null | grep -q .; then
  HAS_COMMITS=true
fi
```

**Action:**

If both exist:

```text
⚠️ You have both uncommitted changes AND unpushed commits on ${CURRENT_BRANCH}

I'll handle this in two steps:
1. First: Migrate uncommitted changes (Phase 0)
2. Later: Migrate committed changes (Phase 5)

Proceeding with uncommitted changes...
```

Then proceed with Phase 0 protocol for uncommitted changes. Phase 5 will catch the committed changes later.

## Integration with Phase 5

**Clear separation of concerns:**

| Aspect        | Phase 0                       | Phase 5                      |
| ------------- | ----------------------------- | ---------------------------- |
| **When**      | Start of workflow             | Before pushing               |
| **Detects**   | Uncommitted changes           | Committed changes            |
| **Migration** | `git stash` / `git stash pop` | `git cherry-pick`            |
| **Scenario**  | User started work on main     | User committed to main       |
| **Severity**  | Warning + blocking            | Error + blocking             |
| **Options**   | 3 (auto/custom/override)      | 3 (migrate/rename/emergency) |

**Workflow example:**

```text
User state: On main with uncommitted changes

Phase 0: Detects uncommitted changes
         → Blocks and offers migration
         → User creates feature branch
         → Uncommitted changes migrated

Phase 1-4: Normal workflow
         → Repository analysis
         → Atomic commits
         → Create commits
         → (Optional) History cleanup

Phase 5: Check for push to protected branch
         → User is on feature branch
         → No protection needed
         → Push succeeds

Phase 6: Create PR
```

**Alternative scenario (if Phase 0 override used):**

```text
User state: On main with uncommitted changes

Phase 0: Detects uncommitted changes
         → User selects override
         → Creates audit commit
         → Continues on main

Phase 1-4: Normal workflow on main
         → Creates commits on main

Phase 5: Detects push to protected branch
         → BLOCKS push
         → User must migrate commits via Phase 5 protocol
```

This shows Phase 0 and Phase 5 work together as defense-in-depth.

## Rollback Procedures

### If Branch Creation Fails

```bash
if ! git checkout -b "${BRANCH_NAME}"; then
  echo "⚠️ Failed to create branch ${BRANCH_NAME}"
  echo "Possible causes:"
  echo "• Branch already exists"
  echo "• Invalid branch name"

  # Restore stash
  git stash apply "$STASH_REF"

  echo "Your changes have been restored on ${PROTECTED_BRANCH}"
  exit 1
fi
```

### If Stash Pop Fails

See "Stash Pop Conflicts" edge case above.

### If User Cancels Mid-Flow

```bash
# At any confirmation point, if user cancels:

echo "Operation cancelled by user"

# If stash exists, restore it
if git stash list | grep -q "Phase 0: Migrating"; then
  git stash apply "$STASH_REF"
  echo "Your changes have been restored"
fi

# If new branch was created, optionally delete it
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
  echo "Delete the created branch ${BRANCH_NAME}?"
  # If yes: git branch -D "${BRANCH_NAME}"
fi

exit 0
```

## Configuration Considerations

**Future enhancements** (not in current implementation):

1. **Custom protected branch list:**

```bash
# Read from git config
PROTECTED_BRANCHES=($(git config --get-all branch.protected))

# Or read from .gitprotected file
if [ -f .gitprotected ]; then
  PROTECTED_BRANCHES=($(cat .gitprotected))
fi
```

1. **Custom branch prefixes:**

```bash
# Read allowed prefixes from config
ALLOWED_PREFIXES=($(git config --get-all workflow.branch-prefixes))
```

1. **Disable Phase 0 protection:**

```bash
# Check if disabled
if git config --get-bool workflow.phase0-enabled | grep -q "false"; then
  exit 0
fi
```

## Summary

Phase 0 Protected Branch Working Directory Protocol provides:

1. **Early detection** - Catches work on protected branches before commits
2. **Intelligent suggestions** - Auto-suggests branch names from changed files
3. **Safe migration** - Stash/unstash pattern preserves all changes
4. **Override path** - Allows emergency work with audit trail
5. **Proactive guidance** - Suggests branching even before work starts
6. **Defense-in-depth** - Works with Phase 5 for complete protection

**Philosophy**: Make it easy to do the right thing, hard to do the wrong thing, and always provide an escape hatch for emergencies.

The goal is to help users develop good git workflow habits while never blocking legitimate work.
