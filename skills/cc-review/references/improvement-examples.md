# Improvement Examples

Before/after examples demonstrating concrete improvements by dimension and priority.

## Contents

- [Example 1: Effectiveness — Vague Purpose (P1)](#example-1-effectiveness--vague-purpose-p1)
- [Example 2: Verification — Missing Verification Commands (P1)](#example-2-verification--missing-verification-commands-p1)
- [Example 3: Best Practices — Side-Effect Skill Unguarded (P1)](#example-3-best-practices--side-effect-skill-unguarded-p1)
- [Example 4: Best Practices — Token Economy (P2)](#example-4-best-practices--token-economy-p2)
- [Example 5: Trigger Coverage — Short Description (P1)](#example-5-trigger-coverage--short-description-p1)
- [Example 6: Clarity — Inconsistent Terminology (P3)](#example-6-clarity--inconsistent-terminology-p3)
- [Example 7: Hooks — Good vs Poor Implementation](#example-7-hooks--good-vs-poor-implementation)
- [Pattern Recognition](#pattern-recognition)

## Example 1: Effectiveness — Vague Purpose (P1)

### Before

```markdown
## Overview

This skill processes data files and generates reports.
```

**Problem**: Vague — what data? what reports? Users can't tell if this skill fits their need.

### After

```markdown
## Purpose

Analyzes CSV and JSON data files to produce summary statistics and comparison reports.
Handles single-file analysis and multi-file diff comparisons.

## When to Use

- Analyze CSV or JSON data files for summary statistics
- Compare two datasets for differences
- Extract counts, averages, and distributions from structured data

**Don't use for**: unstructured text, real-time streams, or database queries.
```

**Why**: Specific data types, output types, and scope boundaries let users self-select in or out immediately.

---

## Example 2: Verification — Missing Verification Commands (P1)

### Before

```markdown
## Steps

1. Create feature branch
2. Make changes
3. Commit with message
4. Push to remote
5. Create PR
```

**Problem**: No verification after any step — users can't confirm the skill worked correctly.

### After

```markdown
## Steps

1. Create feature branch
   - **Verify**: `git branch --show-current` shows the new branch name
2. Make changes
3. Commit with message
   - **Verify**: `git log --oneline -1` shows the expected commit message
4. Push to remote
   - **Verify**: `git status` shows "Your branch is up to date with origin"
5. Create PR
   - **Verify**: `gh pr view --web` opens the PR in browser

## Success Criteria

- Feature branch exists on remote
- Commit history is clean (no WIP commits)
- PR is created with correct base branch
- CI checks are passing
```

**Why**: Per-step verification commands and explicit success criteria define what "done right" looks like.

---

## Example 3: Best Practices — Side-Effect Skill Unguarded (P1)

### Before

```yaml
---
name: auto-deploy
description: Deploys the current branch to staging or production.
---
```

**Problem**: Deploys code — a side effect that could cause outages if auto-invoked. No invocation guard.

### After

```yaml
---
name: auto-deploy
description: Deploys the current branch to staging or production. Use when deploying, pushing to staging, releasing to prod, or shipping a build.
disable-model-invocation: true
---
```

**Why**: `disable-model-invocation: true` ensures the skill only runs on explicit user invocation, preventing accidental deployments.

---

## Example 4: Best Practices — Token Economy (P2)

### Before (single 700-line SKILL.md)

```markdown
---
name: api-client
description: Makes API calls with error handling and retry logic.
---

## Overview
...50 lines...

## Configuration
...80 lines...

## Error Handling
...100 lines...

## Authentication
...120 lines...

## Examples
...200 lines...

## Troubleshooting
...90 lines...
```

**Problem**: 700 lines loads ~10k tokens into context on every invocation — double the 5k budget.

### After (restructured with references)

**SKILL.md** (~120 lines):

```markdown
---
name: api-client
description: Makes API calls with error handling and retry logic.
---

## Reference Files

- [configuration.md](references/configuration.md) - Setup and configuration options
- [error-handling.md](references/error-handling.md) - Error types and handling strategies
- [auth-patterns.md](references/auth-patterns.md) - Authentication methods
- [examples.md](references/examples.md) - Common usage scenarios

## Overview
...50 lines of key concepts...

## Quick Start
...20 lines of basic usage...
```

**Why**: SKILL.md drops from ~10k to ~2k tokens. Details load on demand via references.

---

## Example 5: Trigger Coverage — Short Description (P1)

### Before

```yaml
---
name: file-organizer
description: Organizes files in directories.
---
```

**Problem**: 30-character description with no trigger phrases. Users asking "clean up this folder" won't find it.

### After

```yaml
---
name: file-organizer
description: Organizes files and folders into logical structures. Use when cleaning up directories, restructuring projects, sorting files by type, organizing messy folders, or planning file hierarchies.
---
```

**Why**: 200+ characters with multiple trigger phrases covering natural user queries.

---

## Example 6: Clarity — Inconsistent Terminology (P3)

### Before

```markdown
## Configuration

Set up the config file in your settings directory.
Configure the configuration options as needed.
Update your settings when the config changes.
```

**Problem**: Uses "config", "configuration", and "settings" interchangeably throughout.

### After

```markdown
## Configuration

Set up the configuration file in your configuration directory.
Configure the options as needed.
Update your configuration when requirements change.
```

**Why**: Consistent use of "configuration" removes ambiguity and reads as a single authoritative voice.

---

## Example 7: Hooks — Good vs Poor Implementation

### Good Hook

```python
#!/usr/bin/env python3
# Validates YAML frontmatter before Write/Edit operations
# Exit codes: 0=allow, 2=block

import json
import sys

try:
    import yaml
except ImportError:
    print("Warning: PyYAML not installed, skipping validation", file=sys.stderr)
    sys.exit(0)

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path.endswith(".md"):
        sys.exit(0)

    # Validation logic here...

    sys.exit(0)  # Allow operation

except Exception as e:
    print(f"Error in hook: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block user on hook errors
```

**Assessment**: PASS — correct shebang, safe `.get()` defaults, graceful fallback on missing deps, proper exit codes, never blocks user on hook errors.

### Poor Hook

```python
#!/usr/bin/python
# Validation hook

import json
import sys

data = json.loads(sys.stdin.read())
path = data["tool_input"]["file_path"]

if ".md" in path:
    result = validate(path)
    if not result:
        sys.exit(1)
```

**Assessment**: FAIL — wrong shebang, crashes on malformed JSON (no try/except), direct key access without `.get()` defaults, uses exit code `1` instead of `2` to block, no stderr messages.

---

## Pattern Recognition

| Signal                            | Common Fix                     | Category         |
| --------------------------------- | ------------------------------ | ---------------- |
| Description <50 chars             | Expand with trigger phrases    | Trigger Coverage |
| SKILL.md >500 lines or >5k tokens | Progressive disclosure         | Best Practices   |
| Multiple terminology variants     | Standardize terms              | Clarity          |
| "Handle appropriately" (vague)    | Add specific examples          | Effectiveness    |
| No success criteria               | Add verification steps         | Verification     |
| Side-effect skill, no guard       | Add `disable-model-invocation` | Best Practices   |
| No "when to use" section          | Add guidance section           | Effectiveness    |
