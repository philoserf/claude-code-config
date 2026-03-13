# Improvement Examples

This document shows before/after examples demonstrating improvements in action.

## Contents

- Example 1: Effectiveness — Vague Purpose
- Example 2: Effectiveness — Missing Error Handling
- Example 3: Verification — Task Skill Missing Verification
- Example 4: Verification — Analysis Skill Missing Output Format
- Example 5: Best Practices — Side-Effect Skill Unguarded
- Example 6: Best Practices — Token Economy
- Example 7: Trigger Coverage Enhancement
- Example 8: Adding Edge Case Examples (Documentation)
- Example 9: Fixing Inconsistent Terminology (Clarity)
- Example 10: Comprehensive Improvement Report
- Pattern Recognition

## Example 1: Effectiveness — Vague Purpose

### Before

```markdown
## Overview

This skill processes data files and generates reports.
```

**Problem**: Purpose is vague — what kind of data? What kind of reports? A user can't tell if this skill fits their need.

### After

```markdown
## Purpose

Analyzes CSV and JSON data files to produce summary statistics and comparison reports. Handles single-file analysis and multi-file diff comparisons.

## When to Use

- Analyze CSV or JSON data files for summary statistics
- Compare two datasets for differences
- Extract counts, averages, and distributions from structured data

**Don't use for**: unstructured text (use text-analyzer), real-time streams, or database queries.
```

**Improvement**: Clear purpose with specific data types, output types, and scope boundaries.

**Priority**: P1 (High impact, Low effort — 10 minutes)

---

## Example 2: Effectiveness — Missing Error Handling

### Before

```markdown
## Steps

1. Read the input file
2. Parse the contents
3. Generate the output
4. Write to destination
```

**Problem**: No mention of what happens when the file doesn't exist, parsing fails, or the destination is read-only.

### After

```markdown
## Steps

1. Read the input file
2. Parse the contents
3. Generate the output
4. Write to destination

## Error Handling

- **File not found**: Report the missing path and suggest checking the location
- **Parse failure**: Show the first malformed line with context; suggest format validation
- **Write permission denied**: Report the permission issue; suggest an alternative path
- **Empty input**: Warn and exit rather than producing an empty report
```

**Improvement**: Covers the four most common failure modes with specific recovery guidance.

**Priority**: P2 (High impact, High effort — 30-60 minutes to identify and document all failure modes)

---

## Example 3: Verification — Task Skill Missing Verification

### Before

```markdown
## Steps

1. Create feature branch
2. Make changes
3. Commit with message
4. Push to remote
5. Create PR
```

**Problem**: No verification after any step. User can't confirm the skill worked correctly.

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

All steps complete when:
- Feature branch exists on remote
- Commit history is clean (no WIP commits)
- PR is created with correct base branch
- CI checks are passing
```

**Improvement**: Each phase has a verification command. Explicit success criteria define what "done right" looks like.

**Priority**: P1 (High impact, Low effort — 15 minutes to add verification commands)

---

## Example 4: Verification — Analysis Skill Missing Output Format

### Before

```markdown
## Output

The skill produces a quality report with scores and recommendations.
```

**Problem**: No defined structure. User can't tell if the output is correct or complete.

### After

```markdown
## Output

Reports follow this structure:

| Section | Contents |
|---------|----------|
| Summary | Overall score, quality tier |
| Dimension Scores | Per-dimension scores with evidence |
| Analysis | Strengths and issues per dimension |
| Recommendations | Prioritized improvement list |

See [report-template.md](assets/report-template.md) for the complete format.
```

**Improvement**: Defined output structure serves as implicit verification — if the report matches the template, the skill ran correctly.

**Priority**: P1 (High impact, Low effort — 10 minutes)

---

## Example 5: Best Practices — Side-Effect Skill Unguarded

### Before

```yaml
---
name: auto-deploy
description: Deploys the current branch to staging or production.
---
```

**Problem**: This skill deploys code — a side effect that could cause outages if auto-invoked. No invocation guard.

### After

```yaml
---
name: auto-deploy
description: Deploys the current branch to staging or production. Use when deploying, pushing to staging, releasing to prod, or shipping a build.
disable-model-invocation: true
---
```

**Improvement**: `disable-model-invocation: true` ensures the skill only runs when the user explicitly invokes it, preventing accidental deployments.

**Priority**: P1 (High impact, Low effort — 1 minute)

---

## Example 6: Best Practices — Token Economy

### Before (Single 700-line SKILL.md)

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

## Authentication
...120 lines of auth patterns...

## Examples
...200 lines of examples...

## Troubleshooting
...90 lines of troubleshooting...
```

**Problem**: 700 lines loads ~10k tokens into context on every invocation — double the recommended 5k budget.

### After (Restructured)

**SKILL.md** (~120 lines):

```markdown
---
name: api-client
description: Makes API calls with error handling and retry logic.
---

## Reference Files

- [configuration.md](references/configuration.md) - Setup and configuration options
- [error-handling.md](references/error-handling.md) - Error types and handling strategies
- [retry-logic.md](references/retry-logic.md) - Retry configuration and backoff
- [auth-patterns.md](references/auth-patterns.md) - Authentication methods
- [examples.md](references/examples.md) - Common usage scenarios

---

## Overview
...50 lines of overview with key concepts...

## Quick Start
...20 lines of basic usage...

## Tools Used
...10 lines...
```

**Improvement**: SKILL.md drops from ~10k to ~2k tokens. Details load on demand via references.

**Priority**: P2 (High impact, High effort — 1-2 hours to restructure)

---

## Example 7: Trigger Coverage Enhancement

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

**Priority**: P1 (High impact, Low effort — 5 minutes)

---

## Example 8: Adding Edge Case Examples (Documentation)

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
```

### Permission Errors

When lacking write permissions:

```text
User: Organize /system/protected
Response: Cannot modify /system/protected (permission denied).
Try running with elevated permissions or choose a different directory.
```
````

**Improvement**: Concrete examples showing actual behavior in edge cases.

**Priority**: P2 (High impact, High effort — 1 hour)

---

## Example 9: Fixing Inconsistent Terminology (Clarity)

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

**Priority**: P3 (Medium impact, Low effort — 10 minutes)

---

## Example 10: Comprehensive Improvement Report

This example shows a full improvement assessment for a hypothetical skill.

### Skill: template-generator

**Current State**:

- Short description (45 chars)
- 350-line SKILL.md with no references
- 2 basic examples, no expected output
- Inconsistent heading levels
- No success criteria or verification steps
- Includes Write tool (appropriate for this skill)
- No `disable-model-invocation` despite writing files

### Improvement Recommendations

| #   | Recommendation                          | Category         | Priority |
| --- | --------------------------------------- | ---------------- | -------- |
| 1   | Expand description with trigger phrases | Trigger Coverage | P1       |
| 2   | Add success criteria                    | Verification     | P1       |
| 3   | Add `disable-model-invocation: true`    | Best Practices   | P1       |
| 4   | Add "when to use" section               | Effectiveness    | P1       |
| 5   | Extract detailed options to options.md  | Documentation    | P2       |
| 6   | Add edge case handling examples         | Documentation    | P2       |
| 7   | Fix heading hierarchy (h2→h3→h4)        | Clarity          | P3       |
| 8   | Add 3 more example scenarios            | Documentation    | P3       |
| 9   | Create troubleshooting.md               | Documentation    | P4       |

### Prioritized Action Plan

**Do First (P1)**:

1. Expand description: "Generates project templates and boilerplate code. Use when starting new projects, scaffolding components, creating file structures, or generating boilerplate."
2. Add success criteria: "Template generated successfully when target directory contains all expected files matching the template structure"
3. Add `disable-model-invocation: true` — skill writes files, should require explicit invocation
4. Add "When to Use" section explaining skill vs manual creation

**Plan Carefully (P2)**:

1. Extract options documentation to reference file (reduce SKILL.md token load)
2. Add edge case examples (empty directories, existing files, permission errors)

**Quick Wins (P3)**:

1. Fix heading hierarchy
2. Add example scenarios for common template types

**Consider (P4)**:

1. Create troubleshooting guide (assess if users actually need this)

---

## Pattern Recognition

Common improvement patterns to look for:

| Pattern         | Signal                                 | Typical Fix                    | Category         |
| --------------- | -------------------------------------- | ------------------------------ | ---------------- |
| Undiscoverable  | Description <50 chars                  | Expand with trigger phrases    | Trigger Coverage |
| Bloated         | SKILL.md >500 lines or >5k tokens      | Progressive disclosure         | Best Practices   |
| Unclear         | Multiple terminology variants          | Standardize terms              | Clarity          |
| Incomplete      | "Handle appropriately"                 | Add specific examples          | Effectiveness    |
| Unverifiable    | No success criteria                    | Add verification steps         | Verification     |
| Unguarded       | Side-effect skill, no invocation guard | Add `disable-model-invocation` | Best Practices   |
| Missing context | No "when to use"                       | Add guidance section           | Effectiveness    |
