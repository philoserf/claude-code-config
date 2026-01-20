# Skill Examples

Concrete examples of good and poor skills with before/after comparisons and discovery analysis.

## Good Examples

### hook-audit Skill (Excellent - 10/10)

**File**: `/Users/markayers/.claude/skills/hook-audit/SKILL.md`

**Frontmatter**:

```yaml
---
name: hook-audit
description: Comprehensive security and quality audit for shell scripts (bash, sh, zsh) using defensive programming principles and ShellCheck static analysis. Use when user asks to audit, review, check, lint, validate, or analyze shell scripts for security vulnerabilities, bugs, errors, defensive programming compliance, or best practices. Also triggers for improving script quality, finding script errors or issues, checking portability problems (macOS vs Linux), validating error handling, fixing shellcheck warnings, reviewing legacy automation scripts before release, setting up CI/CD linting infrastructure, configuring pre-commit hooks, understanding ShellCheck error codes, suppressing false positives, or ensuring script portability and quality.
allowed-tools: [Read, Bash, Grep, Edit, Write, Glob]
---
```

**Why It's Excellent**:

✓ **Capability** (What): "Comprehensive security and quality audit for shell scripts"
✓ **Tools** (How): "using defensive programming principles and ShellCheck static analysis"
✓ **Triggers** (When): 15+ distinct use cases listed
✓ **Keywords**: audit, review, check, lint, validate, analyze, improve, find, fixing, reviewing, setting up, configuring, understanding, suppressing, ensuring
✓ **Plain Language**: "find script errors", "check portability problems", "ensure quality"
✓ **Specificity**: Shell scripts (bash, sh, zsh), not generic

**Discovery Score**: 10/10

**Test Queries** (all trigger):

1. "audit my bash script" ✓
2. "check shell script for errors" ✓
3. "fix shellcheck warnings" ✓
4. "review script security" ✓
5. "validate bash code" ✓
6. "find bugs in my script" ✓
7. "check script portability" ✓
8. "improve script quality" ✓
9. "set up shellcheck in CI" ✓
10. "ensure script is safe" ✓

**Progressive Disclosure**:

- SKILL.md: 315 lines (under 500 ✓)
- References: 6 files, well-organized
- Clear reference list at top
- All references linked

**Structure**: EXCELLENT (9/10)

### git-workflow Skill (Excellent - 9/10)

**Frontmatter**:

```yaml
---
name: git-workflow
description: Automates complete git workflows including branch management, atomic commits with formatted messages, history cleanup, and PR creation. Use when the user wants to commit changes, push to remote, create a PR, clean up commits, mentions atomic commits, git workflow, or needs help organizing git changes. Also use when user is on main/master with uncommitted changes (suggest branching), has messy commit history to clean up before pushing, wants to squash or reorder commits, or needs help creating pull requests.
allowed-tools: [Read, Bash, Grep, Glob, Edit]
---
```

**Why It's Excellent**:

✓ **Capability**: "Automates complete git workflows"
✓ **Features**: branch management, atomic commits, history cleanup, PR creation
✓ **Triggers**: 10+ use cases
✓ **Keywords**: commit, push, PR, clean up, squash, reorder, organizing, creating
✓ **Plain Language**: "commit changes", "push to remote", "create a PR"

**Discovery Score**: 9/10

**Minor Gap**: Could add "merge" as a trigger

**Structure**: GOOD (8/10)

- Clear workflow
- Good use cases
- Well-organized

### author-skill Skill (Excellent - 10/10)

**Frontmatter**:

```yaml
---
name: author-skill
description: Guide for authoring effective skills. Use when creating, building, updating, designing, packaging, reviewing, evaluating, or improving skills that extend Claude's capabilities with specialized knowledge, workflows, or tool integrations. Helps with skill structure, SKILL.md frontmatter, progressive disclosure, resource organization (scripts/assets/reference files), initialization templates, validation, and packaging. Also use when asking how to create a skill, what makes a good skill, learning about skill development, or troubleshooting skill issues. Includes proven design patterns for workflows and output quality.
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---
```

**Why It's Excellent**:

✓ **Capability**: "Guide for authoring effective skills"
✓ **Action Verbs**: creating, building, updating, designing, packaging, reviewing, evaluating, improving
✓ **Specifics**: structure, frontmatter, progressive disclosure, resource organization
✓ **Plain Language**: "how to create", "what makes a good skill", "troubleshooting"
✓ **Length**: 553 chars (comprehensive)

**Discovery Score**: 10/10

## Poor Examples (Before/After)

### Example 1: Too Short

**Before** (✗ Poor - 2/10):

```yaml
---
name: git-helper
description: Helps with git operations
---
```

**Problems**:

- Only 27 chars (way too short)
- "Helps with" is vague
- No specific operations listed
- No use cases
- Generic name
- Would rarely be discovered

**After** (✓ Good - 8/10):

```yaml
---
name: git-workflow
description: Automates git workflows including commits, branches, and PRs. Use when committing changes, creating pull requests, cleaning up history, pushing code, or organizing branches.
---
```

**Improvements**:

- 187 chars (much better)
- Specific: commits, branches, PRs
- Clear use cases
- Action verbs: committing, creating, cleaning, pushing, organizing
- Specific name

### Example 2: Missing "Use When"

**Before** (✗ Poor - 4/10):

```yaml
---
name: hook-audit
description: Comprehensive security and quality audit for shell scripts using ShellCheck static analysis and defensive programming principles.
---
```

**Problems**:

- No use cases listed
- Technical jargon only
- Users don't know when to use it
- Missing action verbs

**After** (✓ Excellent - 10/10):

```yaml
---
name: hook-audit
description: Comprehensive security and quality audit for shell scripts using ShellCheck. Use when auditing scripts, reviewing code quality, finding security issues, fixing shellcheck warnings, checking portability, or validating error handling.
---
```

**Improvements**:

- Added "Use when" with 6 scenarios
- Action verbs: auditing, reviewing, finding, fixing, checking, validating
- Plain language alongside technical terms

### Example 3: Only Technical Terms

**Before** (✗ Poor - 3/10):

```yaml
---
name: static-analyzer
description: Performs static code analysis using AST parsing and linting tools to identify code smells and anti-patterns.
---
```

**Problems**:

- Technical jargon: "AST parsing", "code smells", "anti-patterns"
- No plain language
- Users don't ask for "static analysis"
- No use cases

**After** (✓ Good - 8/10):

```yaml
---
name: code-reviewer
description: Reviews code for bugs, security issues, and best practices using automated analysis. Use when checking code quality, finding errors, reviewing pull requests, ensuring code safety, or improving code standards.
---
```

**Improvements**:

- Plain language: bugs, security issues, best practices
- Clear use cases
- Action verbs: checking, finding, reviewing, ensuring, improving
- Relatable name

### Example 4: Too Generic

**Before** (✗ Poor - 1/10):

```yaml
---
name: helper
description: General purpose assistant for various tasks
---
```

**Problems**:

- Extremely vague
- "helper" and "assistant" say nothing
- "various tasks" is meaningless
- Would trigger on everything or nothing
- Unusable

**After** (✓ Good - 9/10):

```yaml
---
name: document-organizer
description: Organizes document collections by source, type, and naming conventions. Use when organizing PDFs, managing document folders, creating folder structures, renaming files consistently, detecting duplicates, or auditing file organization.
---
```

**Improvements**:

- Specific capability
- Clear domain (documents)
- Specific use cases
- Actionable triggers

### Example 5: Body Content in Description

**Before** (✗ Poor - 5/10):

```yaml
---
name: git-workflow
description: Git workflow automation
---
## When to Use

- Committing changes
- Creating pull requests
- Cleaning up history
- Managing branches
```

**Problems**:

- Short description (24 chars)
- All use cases in body (doesn't help triggering!)
- Body content loaded AFTER trigger
- Wastes opportunity

**After** (✓ Excellent - 10/10):

```yaml
---
name: git-workflow
description: Git workflow automation for commits, PRs, and history cleanup. Use when committing changes, creating pull requests, cleaning up history, or managing branches.
---
# Git Workflow

Automates complete git workflows...
```

**Improvements**:

- All use cases in description
- Body has workflow details, not triggers
- 166 chars in description
- Would trigger on expected queries

## Progressive Disclosure Examples

### Good Example: hook-audit

**SKILL.md** (315 lines):

```markdown
## Reference Files

- [configurations.md](configurations.md) - Config examples
- [error-codes.md](error-codes.md) - Error reference
  ...

# Bash Script Audit

Quick workflow, common patterns, integration
```

**workflows.md** (250 lines):

```markdown
# Complete Audit Workflows

Step-by-step processes for different scenarios...
```

**Analysis**:

- ✓ Main file <500 lines
- ✓ Details in references
- ✓ Clear linking
- ✓ One level deep
- ✓ Well-organized (6 topic-based files)

**Score**: 9/10 (Excellent)

### Poor Example: Flat Monolith

**SKILL.md** (1200 lines):

```markdown
---
name: comprehensive-guide
description: Complete guide to everything
---

# Everything You Need to Know

[1200 lines of content with no references]
```

**Analysis**:

- ✗ Way over 500 line target
- ✗ No progressive disclosure
- ✗ Hard to navigate
- ✗ Slow to load

**Score**: 2/10 (Poor)

**Fix**: Split into SKILL.md (<500 lines) + 8-10 reference files

## Discovery Score Examples

### Example 1: Excellent Discovery (hook-audit)

**Test Results**:

- Positive Tests: 10/10 triggered
- Negative Tests: 5/5 correctly ignored
- Edge Cases: 2/3 reasonably handled

**Discovery Score**: 10/10

**Description Quality**: 10/10

- 540 chars (comprehensive)
- 15+ use cases
- Both technical and plain language
- Clear triggers

### Example 2: Good Discovery (git-workflow)

**Test Results**:

- Positive Tests: 9/10 triggered
- Negative Tests: 5/5 correctly ignored
- Edge Cases: 3/3 reasonably handled

**Discovery Score**: 9/10

**Gap**: Missing "merge" as trigger

**Recommendation**: Add "merging branches" to description

### Example 3: Poor Discovery (helper)

**Test Results**:

- Positive Tests: 2/10 triggered
- Negative Tests: 3/5 incorrectly triggered
- Edge Cases: All confused

**Discovery Score**: 2/10

**Problems**:

- Too vague
- No specific triggers
- Would match everything/nothing

**Recommendation**: Complete rewrite with specific domain

## Summary Checklist

**Good Skill Characteristics**:

✓ **Description**:

- 150-500 chars
- What + When clearly stated
- 5-10 use cases listed
- Both technical and plain language
- Action verbs (audit, review, check, fix, etc.)

✓ **Structure**:

- SKILL.md <500 lines
- References for details (if needed)
- Clear navigation
- One level deep
- All references linked

✓ **Discovery**:

- Score ≥8/10
- Triggers on expected queries
- Doesn't trigger on unrelated queries
- No critical keyword gaps

✓ **Metadata**:

- allowed-tools present and accurate
- Name matches filename
- Description length >50 chars

**Poor Skill Characteristics**:

✗ **Description**:

- <50 chars (too short)
- "Helps with" or vague phrases
- Missing use cases
- Only technical jargon
- No action verbs

✗ **Structure**:

- SKILL.md >800 lines (no progressive disclosure)
- Nested reference directories
- Orphaned files
- No linking

✗ **Discovery**:

- Score <5/10
- Rarely triggers
- Major keyword gaps
- Too broad or too narrow

✗ **Metadata**:

- Missing allowed-tools
- Name/filename mismatch
- Description <50 chars

Use these examples as templates when creating or improving skills!
