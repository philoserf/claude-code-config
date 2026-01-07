# ShellCheck Workflows

End-to-end examples showing complete analyze → fix → verify cycles for common ShellCheck scenarios.

## Basic Workflow: Analyze → Fix → Verify

### Step 1: Analyze

```bash
shellcheck script.sh
```

Output:

```text
In script.sh line 5:
  echo $filename
       ^------^ SC2086: Double quote to prevent globbing and word splitting.

In script.sh line 8:
  if [ $? -eq 0 ]; then
       ^-- SC2181: Check exit code directly with e.g. 'if mycmd;', not indirectly with $?.
```

### Step 2: Categorize Issues

- **Critical** (SC2086): Quoting issue - could cause bugs
- **Style** (SC2181): Better practice - improves readability

### Step 3: Fix Issues

Before:

```bash
#!/bin/bash
filename=myfile.txt

echo $filename

grep "pattern" file.txt
if [ $? -eq 0 ]; then
  echo "Found"
fi
```

After:

```bash
#!/bin/bash
filename=myfile.txt

echo "$filename"

if grep "pattern" file.txt; then
  echo "Found"
fi
```

### Step 4: Verify

```bash
shellcheck script.sh
# No output = success
echo $?
# 0 = all checks passed
```

## Workflow: New Script with Pre-commit Hook

### Step 1: Create Script

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
SERVER=$1
rsync -av build/ $SERVER:/var/www/
ssh $SERVER 'systemctl restart nginx'
EOF

chmod +x deploy.sh
```

### Step 2: Run ShellCheck

```bash
shellcheck deploy.sh
```

Output:

```text
In deploy.sh line 3:
rsync -av build/ $SERVER:/var/www/
                 ^-----^ SC2086: Double quote to prevent globbing and word splitting.

In deploy.sh line 4:
ssh $SERVER 'systemctl restart nginx'
    ^-----^ SC2086: Double quote to prevent globbing and word splitting.
```

### Step 3: Fix and Add Error Handling

```bash
#!/bin/bash
set -euo pipefail

SERVER=$1
if [ -z "$SERVER" ]; then
  echo "Usage: $0 <server>" >&2
  exit 1
fi

rsync -av build/ "$SERVER:/var/www/"
ssh "$SERVER" 'systemctl restart nginx'
```

### Step 4: Verify Clean

```bash
shellcheck deploy.sh
# No output

# Set up pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
shellcheck *.sh || exit 1
EOF

chmod +x .git/hooks/pre-commit
```

## Workflow: Batch Processing Multiple Scripts

### Step 1: Find All Shell Scripts

```bash
find . -name "*.sh" -type f > scripts.txt
```

### Step 2: Run ShellCheck on All

```bash
shellcheck --format=gcc $(cat scripts.txt) > shellcheck-report.txt
```

### Step 3: Analyze Report

```bash
# Count issues by error code
grep -oP 'SC\d+' shellcheck-report.txt | sort | uniq -c | sort -rn

# Example output:
# 15 SC2086
# 8 SC2181
# 5 SC2154
# 3 SC1091
```

### Step 4: Fix Most Common Issue First

Focus on SC2086 (quoting) across all files:

```bash
# Find all SC2086 violations
grep SC2086 shellcheck-report.txt

# Fix each file systematically
for script in $(grep SC2086 shellcheck-report.txt | cut -d: -f1 | sort -u); do
  echo "Fixing $script"
  # Edit file to add quotes
  # Re-run: shellcheck "$script"
done
```

### Step 5: Verify Progress

```bash
# Re-run on all scripts
shellcheck --format=gcc $(cat scripts.txt) > shellcheck-report-fixed.txt

# Compare before/after
wc -l shellcheck-report.txt shellcheck-report-fixed.txt
```

## Workflow: Legacy Script Migration

### Scenario: Old script with 50+ violations

Initial run:

```bash
shellcheck legacy-backup.sh | wc -l
# 53
```

### Step 1: Create Baseline

```bash
# Save current violations
shellcheck legacy-backup.sh > baseline.txt

# Count by severity
grep "error:" baseline.txt | wc -l    # 5
grep "warning:" baseline.txt | wc -l  # 45
grep "note:" baseline.txt | wc -l     # 3
```

### Step 2: Fix Critical Errors Only

Focus on "error:" level issues first:

```bash
grep "error:" baseline.txt
```

Fix these 5 critical issues, then verify:

```bash
shellcheck legacy-backup.sh > current.txt
grep "error:" current.txt | wc -l
# 0
```

### Step 3: Suppress Non-Critical for Now

Add to top of script:

```bash
#!/bin/bash
# shellcheck disable=SC2086,SC2181,SC2001
# TODO: Fix quoting issues (SC2086) - tracked in JIRA-123
# TODO: Refactor exit code checks (SC2181) - tracked in JIRA-124
```

### Step 4: Gradual Improvement

Create issues for remaining violations and fix over time:

```bash
# Month 1: Fix all SC2086 (quoting)
# Month 2: Fix all SC2181 (exit codes)
# Month 3: Fix remaining warnings
```

Track progress:

```bash
# Weekly check
shellcheck legacy-backup.sh | grep -c "SC2086"
# Week 1: 20
# Week 2: 15
# Week 3: 8
# Week 4: 0 ✓
```

## Workflow: CI/CD Integration with Baseline

### Problem: Existing codebase has violations, want to prevent NEW ones

### Step 1: Create Baseline File

```bash
# Generate baseline of current violations
shellcheck --format=json scripts/*.sh > .shellcheck-baseline.json
```

### Step 2: CI Script to Check Only New Issues

```bash
#!/bin/bash
# ci-shellcheck.sh

# Run shellcheck
shellcheck --format=json scripts/*.sh > current.json

# Compare with baseline (simplified)
NEW_ISSUES=$(comm -13 <(jq -S . .shellcheck-baseline.json) <(jq -S . current.json))

if [ -n "$NEW_ISSUES" ]; then
  echo "New ShellCheck violations found:"
  echo "$NEW_ISSUES" | jq .
  exit 1
fi

echo "No new violations. Existing baseline: $(jq length .shellcheck-baseline.json) issues"
```

### Step 3: Add to CI Pipeline

```yaml
# .github/workflows/shellcheck.yml
name: ShellCheck
on: [pull_request]
jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: sudo apt-get install -y shellcheck jq
      - run: bash ci-shellcheck.sh
```

### Step 4: Gradually Reduce Baseline

```bash
# Monthly: Fix violations and update baseline
shellcheck --format=json scripts/*.sh > .shellcheck-baseline.json
git add .shellcheck-baseline.json
git commit -m "ShellCheck: Reduced baseline from 50 to 35 violations"
```

## Workflow: Understanding and Fixing Unknown Error

### Scenario: Encounter unfamiliar error code

```bash
shellcheck script.sh
```

Output:

```text
In script.sh line 12:
  cd $OLDPWD
     ^----^ SC2164: Use 'cd ... || exit' in case cd fails.
```

### Step 1: Understand the Issue

```bash
# Look up explanation
shellcheck --wiki=SC2164

# Or visit: https://www.shellcheck.net/wiki/SC2164
```

### Step 2: Read Example

Wiki shows:

```bash
# Problematic:
cd "$target_dir"
rm ./*  # Could delete wrong directory if cd fails!

# Correct:
cd "$target_dir" || exit
rm ./*  # Safe now
```

### Step 3: Apply Fix to Your Code

Before:

```bash
cd $OLDPWD
make clean
```

After:

```bash
cd "$OLDPWD" || exit 1
make clean
```

### Step 4: Verify and Commit

```bash
shellcheck script.sh
# No SC2164

git add script.sh
git commit -m "Fix SC2164: Add error handling for cd command"
```

## Version Requirements

Some ShellCheck features require specific versions:

- **ShellCheck 0.7.0+**: JSON output format, directive support
- **ShellCheck 0.8.0+**: Improved POSIX compliance checks, better error messages
- **ShellCheck 0.9.0+**: Additional security checks, performance improvements

Check your version:

```bash
shellcheck --version
```

Upgrade if needed:

```bash
# macOS
brew upgrade shellcheck

# Linux (from source for latest)
wget https://github.com/koalaman/shellcheck/releases/latest/download/shellcheck-latest.linux.x86_64.tar.xz
tar -xf shellcheck-latest.linux.x86_64.tar.xz
sudo cp shellcheck-latest/shellcheck /usr/local/bin/
```
