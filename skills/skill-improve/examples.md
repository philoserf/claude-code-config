# Improvement Examples

This document shows before/after examples demonstrating improvements in action.

## Contents

- Example 1: Trigger Phrase Enhancement
- Example 2: Progressive Disclosure
- Example 3: Adding Missing Examples
- Example 4: Fixing Inconsistent Terminology
- Example 5: Portability Improvement
- Example 6: Adding "When to Use" Guidance
- Example 7: Comprehensive Improvement Report
- Pattern Recognition

## Example 1: Trigger Phrase Enhancement

### Before

```yaml
---
name: file-organizer
description: Organizes files in directories.
---
```

**Problem**: Description is only 30 characters with no trigger phrases. Users asking "help me organize my project files" or "clean up this folder" won't find it.

### After

```yaml
---
name: file-organizer
description: Organizes files and folders into logical structures. Use when cleaning up directories, restructuring projects, sorting files by type, organizing messy folders, or planning file hierarchies.
---
```

**Improvement**: Description now 200+ characters with multiple trigger phrases covering natural user queries.

**Priority**: P1 (High impact, Low effort - 5 minutes)

---

## Example 2: Progressive Disclosure

### Before (Single 400-line SKILL.md)

```markdown
---
name: api-client
description: Makes API calls with error handling and retry logic.
---

## Overview
...50 lines of overview...

## Configuration
...80 lines of configuration details...

## Error Handling
...100 lines of error handling...

## Retry Logic
...60 lines of retry logic...

## Examples
...110 lines of examples...
```

### After (Restructured)

**SKILL.md** (~100 lines):

```markdown
---
name: api-client
description: Makes API calls with error handling and retry logic.
---

## Reference Files

- [configuration.md](configuration.md) - Setup and configuration options
- [error-handling.md](error-handling.md) - Error types and handling strategies
- [retry-logic.md](retry-logic.md) - Retry configuration and backoff
- [examples.md](examples.md) - Common usage scenarios

---

## Overview
...50 lines of overview with key concepts...

## Quick Start
...20 lines of basic usage...

## Tools Used
...10 lines...
```

Plus four reference files with detailed content.

**Improvement**: Reduced context size by moving details to reference files. SKILL.md stays focused on overview and quick start.

**Priority**: P2 (High impact, High effort - 1-2 hours)

---

## Example 3: Adding Missing Examples

### Before

```markdown
## Edge Cases

The skill handles various edge cases appropriately.
```

**Problem**: No actual examples of edge cases or how they're handled.

### After

````markdown
## Edge Cases

### Empty Directories

When encountering empty directories:

```text
User: Organize /project/empty-folder
Response: Directory is empty. Options:
1. Delete the empty directory
2. Keep it for future use
3. Add a .gitkeep placeholder
````

### Permission Errors

When lacking write permissions:

```text
User: Organize /system/protected
Response: Cannot modify /system/protected (permission denied).
Try running with elevated permissions or choose a different directory.
```

### Mixed Content

When directory has both files and subdirectories:

```text
User: Organize /project/mixed
Response: Found 15 files and 3 subdirectories.
Recommend organizing files first, then reviewing subdirectories.
```

**Improvement**: Concrete examples showing actual behavior in edge cases.

**Priority**: P2 (High impact, High effort - 1 hour)

---

## Example 4: Fixing Inconsistent Terminology

### Before

```markdown
## Configuration

Set up the config file in your settings directory.
Configure the configuration options as needed.
Update your settings when the config changes.
```

**Problem**: Uses "config", "configuration", and "settings" interchangeably.

### After

```markdown
## Configuration

Set up the configuration file in your configuration directory.
Configure the options as needed.
Update your configuration when requirements change.
```

**Improvement**: Consistent use of "configuration" throughout.

**Priority**: P3 (Medium impact, Low effort - 10 minutes)

---

## Example 5: Portability Improvement

### Before

```yaml
---
name: code-analyzer
description: Analyzes code quality and patterns.
allowed-tools: Read Write Edit Bash Glob Grep WebFetch
model: sonnet
context: project
---
```

**Problem**: Frontmatter includes multiple non-standard, agent-specific fields (`allowed-tools`, `model`, `context`). Skill is structurally coupled to one agent implementation.

### After

```yaml
---
name: code-analyzer
description: Analyzes code quality and patterns. Use when reviewing code structure, finding anti-patterns, or auditing code quality.
---
```

**Improvement**: Removed non-standard frontmatter fields. Only spec-standard `name` and `description` remain. Skill is now portable across agent implementations.

**Priority**: P1 (High impact for portability, Low effort - 2 minutes)

---

## Example 6: Adding "When to Use" Guidance

### Before

```markdown
## Overview

This skill processes data files and generates reports.
```

**Problem**: No guidance on when to invoke this skill vs alternatives.

### After

```markdown
## Overview

This skill processes data files and generates reports.

## When to Use

Use this skill when you need to:
- Analyze CSV or JSON data files
- Generate summary reports from raw data
- Compare datasets for differences
- Extract statistics from structured data

**Don't use this skill for**:
- Unstructured text analysis (use text-analyzer instead)
- Real-time data processing (use stream-processor instead)
- Database queries (use direct SQL)
```

**Improvement**: Clear guidance on appropriate use cases and alternatives.

**Priority**: P1 (High impact, Low effort - 10 minutes)

---

## Example 7: Comprehensive Improvement Report

This example shows a full improvement assessment for a hypothetical skill.

### Skill: template-generator

**Current State**:

- Short description (45 chars)
- 350-line SKILL.md with no references
- 2 basic examples
- Inconsistent heading levels
- Includes Write tool (appropriate for this skill)

### Improvement Recommendations

| #   | Recommendation                          | Category        | Priority |
| --- | --------------------------------------- | --------------- | -------- |
| 1   | Expand description with trigger phrases | Trigger Phrases | P1       |
| 2   | Add "when to use" section               | Documentation   | P1       |
| 3   | Fix heading hierarchy (h2→h3→h4)        | Clarity         | P3       |
| 4   | Extract detailed options to options.md  | Reference Files | P2       |
| 5   | Add 3 more example scenarios            | Examples        | P3       |
| 6   | Add edge case handling examples         | Examples        | P2       |
| 7   | Create troubleshooting.md               | Reference Files | P4       |

### Prioritized Action Plan

**Do First (P1)**:

1. Expand description: "Generates project templates and boilerplate code. Use when starting new projects, scaffolding components, creating file structures, or generating boilerplate."
2. Add "When to Use" section explaining skill vs manual creation

**Plan Carefully (P2)**:

1. Extract options documentation to reference file
2. Add edge case examples (empty directories, existing files, permission errors)

**Quick Wins (P3)**:

1. Fix heading hierarchy
2. Add example scenarios for common template types

**Consider (P4)**:

1. Create troubleshooting guide (assess if users actually need this)

---

## Pattern Recognition

Common improvement patterns to look for:

| Pattern         | Signal                           | Typical Fix                         |
| --------------- | -------------------------------- | ----------------------------------- |
| Undiscoverable  | Description <50 chars            | Expand with trigger phrases         |
| Bloated         | SKILL.md >300 lines or >3k words | Progressive disclosure              |
| Unclear         | Multiple terminology variants    | Standardize terms                   |
| Incomplete      | "Handle appropriately"           | Add specific examples               |
| Agent-coupled   | Non-standard frontmatter fields  | Remove or document as impl-specific |
| Missing context | No "when to use"                 | Add guidance section                |
