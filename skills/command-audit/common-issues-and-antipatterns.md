# Common Issues and Anti-patterns

Catalog of frequent problems found in command configurations, with examples,
severity levels, and fixes.

## Issue Classification

**CRITICAL** (official requirements) - Must fix for command to work

**IMPORTANT** (best practices) - Should fix for optimal performance

**NICE-TO-HAVE** - Polish for excellent quality

## Issue 0: Missing description Frontmatter

**Problem**: No description field in frontmatter

**Severity**: CRITICAL (official requirement)

**Impact**:

- Command won't appear in `/help`
- SlashCommand tool cannot invoke command
- Users cannot discover command functionality

**Example**:

```yaml
# ❌ WRONG
---
argument-hint: [file]
---
```

**Fix**:

```yaml
# ✅ CORRECT
---
description: Analyze file security vulnerabilities
argument-hint: [file]
---
```

**Detection**: Check frontmatter for `description:` field

## Issue 0.5: Description Too Verbose

**Problem**: Description exceeds 80 characters or contains unnecessary details

**Severity**: IMPORTANT (best practice for /help readability)

**Impact**:

- Clutters `/help` output
- Harder for users to scan available commands
- Description doesn't fit well in UI displays
- Violates 5-8 word (40-60 char) guideline

**Example**:

```yaml
# ❌ WRONG (13 words, 95 chars)
---
description: Validates an agent configuration for correctness, clarity, and effectiveness
---
```

**Fix**:

```yaml
# ✅ CORRECT (4 words, 39 chars)
---
description: Validate agent configuration quality
---
```

**Better examples**:

```yaml
# Before: 10 words, 85 chars
description: Audit shell scripts for best practices, security, and portability
# After: 4 words, 35 chars
description: Audit shell script quality
```

```yaml
# Before: 12 words, 100 chars
description: Guide for authoring output-styles that transform Claude's behavior and personality
# After: 5 words, 40 chars
description: Guide for authoring output-styles
```

**Detection**: Count words and characters in description field. Flag if >80 chars or >8 words.

**Target**: 5-8 words (40-60 chars ideal, 30-80 acceptable)

## Issue 1: Excessive Complexity (Consider Skill)

**Problem**: >80 lines or complex implementation logic

**Severity**: IMPORTANT (best practice recommendation)

**Example**: Command with 120 lines of if/else logic

**Impact**:

- Hard to understand and maintain
- Violates single responsibility principle
- Better suited as skill with auto-triggering

**Fix**: Convert to skill (recommended, not required)

**Note**: Some commands legitimately exceed 80 lines due to comprehensive
documentation. Evaluate based on complexity, not just line count.

**Detection criteria**:

- Line count > 80
- Contains if/else logic
- Contains loop constructs
- Multiple tool calls in sequence
- Extensive data processing

**When to override**: Well-documented delegator with clear single purpose may
exceed 80 lines

## Issue 2: Unclear Delegation

**Problem**: No explicit target

**Severity**: IMPORTANT (best practice for delegation pattern)

**Example**:

```markdown
Do some validation on the agent.
```

**Why it's problematic**:

- User doesn't know what happens
- Maintainer can't identify delegation target
- Unclear if it delegates or does work directly

**Fix** (use descriptive delegation):

```markdown
**Delegation:** Invokes the **audit-agent** skill for comprehensive
validation.
```

**Detection**: Look for vague phrases like "do some", "perform", "handle"
without naming target

## Issue 3: Arguments Ignored

**Problem**: User provides arguments but command doesn't use them

**Severity**: IMPORTANT (best practice)

**Example**:

```markdown
**Delegation:** Invokes the **audit-agent** skill.

# User types: /audit-agent code-generator
# But "code-generator" is ignored - not passed to skill
```

**Impact**:

- User expects argument to be used
- Command doesn't behave as expected
- Confusing user experience

**Fix** (ensure arguments are passed):

```markdown
Validate agent configuration(s) using the audit-agent skill.

**Target**: ${ARGUMENTS:-all agents}
```

Or simply rely on automatic argument passing with descriptive delegation -
Claude automatically passes $ARGUMENTS to invoked skills.

**Detection**: Check if command mentions $ARGUMENTS or uses argument-hint
without using arguments in body

## Issue 4: Over-Documented Simple Command

**Problem**: 6-line delegator with 50 lines of documentation

**Severity**: NICE-TO-HAVE (proportionality best practice)

**Example**:

```markdown
---
name: simple-task
description: Does a simple task
---

# simple-task

## Overview

This command performs a simple delegation to the task-handler skill...

## Background

The task-handler skill was created to...

## Usage

    /simple-task [arguments]

## Arguments

- arguments: Optional task description (default: "default task")

## Examples

    /simple-task "my task"
    /simple-task

## Notes

Remember to check the output...

## See Also

- Related command A
- Related command B

**Delegation:** Invoke task-handler skill.
```

**Why it's problematic**:

- Documentation overwhelms simple functionality
- Maintenance burden disproportionate to value
- User has to read excessive content

**Fix**: Remove excessive docs or justify complexity

**Simplified version**:

```markdown
---
name: simple-task
description: Does a simple task
argument-hint: [task]
---

**Delegation:** Invoke task-handler skill with ${ARGUMENTS:-default task}.
```

**Detection**: Compare documentation line count to functional line count.
If docs > 5x functional content, investigate.

## Issue 5: Underdocumented Complex Command

**Problem**: 60-line command with no usage docs

**Severity**: IMPORTANT (proportionality best practice)

**Example**:

```markdown
---
name: complex-processor
description: Process files
---

Process the input by reading files, validating contents, running analysis,
generating reports, and outputting results.

Read file: $1
Validate: Check schema
Analyze: Run 10 different checks
Report: Generate summary
Output: Write to $2
```

**Why it's problematic**:

- User doesn't know how to invoke
- Arguments not documented
- Expected behavior unclear
- Error scenarios not explained

**Fix**: Add full documentation (usage, examples)

**Improved version**:

```markdown
---
name: complex-processor
description: Process files with validation and analysis
argument-hint: <input-file> <output-file>
---

# complex-processor

Process files through validation, analysis, and reporting pipeline.

## Usage

    /complex-processor <input-file> <output-file>

## What It Does

1. Reads and validates input file against schema
2. Runs 10 comprehensive analysis checks
3. Generates detailed report
4. Writes results to output file

## Examples

    /complex-processor data.json report.txt
    /complex-processor input.csv output.md

## Notes

- Input file must be JSON or CSV format
- Output format determined by file extension

[Implementation details...]
```

**Detection**: Commands > 40 lines without Usage or Examples sections

## Issue 6: Multiple Delegation Targets

**Problem**: Command delegates to multiple skills/agents

**Severity**: IMPORTANT (single responsibility)

**Example**:

```markdown
First, invoke skill-a to analyze the code.

Then, invoke skill-b to generate tests.

Finally, invoke skill-c to create documentation.
```

**Why it's problematic**:

- Violates single responsibility
- Better as workflow skill
- Hard to maintain
- Unclear primary purpose

**Fix**: Create workflow skill or choose single delegation target

**Better approach**:

Option 1 - Single skill that orchestrates:

```markdown
**Delegation:** Invoke code-workflow skill to analyze, test, and document.
```

Option 2 - Separate commands:

```markdown
# commands/analyze-code.md
**Delegation:** Invoke skill-a for code analysis.

# commands/test-code.md
**Delegation:** Invoke skill-b for test generation.

# commands/document-code.md
**Delegation:** Invoke skill-c for documentation.
```

**Detection**: Multiple Skill/Task tool calls in command body

## Issue 7: Hardcoded Values (No Argument Support)

**Problem**: Command uses hardcoded paths/values instead of arguments

**Severity**: IMPORTANT (flexibility)

**Example**:

```markdown
---
name: audit-config
description: Audit configuration
---

Read ~/.claude/settings.json and validate.
```

**Why it's problematic**:

- Can't audit other configs
- Not reusable
- Limits usefulness

**Fix**: Accept arguments with sensible defaults

```markdown
---
name: audit-config
description: Audit configuration file
argument-hint: [config-file]
---

Read ${ARGUMENTS:-~/.claude/settings.json} and validate against schema.
```

**Detection**: Check for hardcoded paths when arguments would be appropriate

## Issue 8: Incomplete Frontmatter

**Problem**: Missing optional but useful frontmatter fields

**Severity**: NICE-TO-HAVE (usability)

**Example**:

```yaml
---
name: process-files
description: Process multiple files
---
```

**Missing useful fields**:

- `argument-hint` - Users don't know what arguments to provide
- `allowed-tools` - Command might fail if it needs restricted tools

**Improved**:

```yaml
---
name: process-files
description: Process multiple files with validation
argument-hint: <file1> [file2] [file3...]
allowed-tools: [Read, Grep, Bash]
---
```

**Detection**: Commands that clearly expect arguments but lack argument-hint

## Anti-patterns Summary

**Top 6 anti-patterns to avoid**:

1. **Missing description** - Command won't work properly (CRITICAL)
2. **Verbose description** - Exceeds 80 chars or 8 words (IMPORTANT)
3. **Vague delegation** - "Do something" without naming target (IMPORTANT)
4. **Ignored arguments** - User input not used (IMPORTANT)
5. **Excessive complexity** - Should be skill instead (IMPORTANT)
6. **Documentation mismatch** - Too much for simple, too little for complex
   (NICE-TO-HAVE)

## Quick Fixes

**For each issue type**:

- **Missing description**: Add description field to frontmatter
- **Verbose description**: Shorten to 5-8 words (40-60 chars), remove filler words
- **Unclear delegation**: Use "Delegation: Invoke **skill-name**" format
- **Ignored arguments**: Add $ARGUMENTS to delegation or prompt
- **Too complex**: Migrate to skill with auto-triggering
- **Wrong docs level**: Match documentation to command complexity
- **Multiple targets**: Split into separate commands or create workflow skill
- **Hardcoded values**: Use ${ARGUMENTS:-default} pattern
- **Missing frontmatter**: Add argument-hint and consider allowed-tools

## See Also

- [audit-checklist.md](audit-checklist.md) - Quick validation checklist
- [audit-workflow-steps.md](audit-workflow-steps.md) - Detailed audit process
- [simplicity-enforcement.md](simplicity-enforcement.md) - Complexity
  thresholds
- [examples.md](examples.md) - Good vs poor command comparisons
