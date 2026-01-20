# Documentation Proportionality

Guide for assessing whether command documentation is appropriate for complexity level.

## Core Principle

**Documentation should match command complexity - no more, no less.**

Simple command (6-15 lines typical) = minimal docs
Documented command (25-80 lines typical) = full docs
Over-documented = wastes space, under-documented = confuses users

## Documentation Levels

### Level 1: Minimal (6-15 lines typical)

**When appropriate**: Simple delegators with obvious usage

**Required**:

- name field (frontmatter)
- description field (frontmatter)

**Optional**:

- 1-2 line explanation before delegation

**Not needed**:

- Usage section
- "What It Does" section
- Examples section
- Tips or notes

**Example**:

```yaml
---
name: audit-hook
description: Audit shell scripts for security and quality
---
{ Skill skill="hook-audit" args="$ARGUMENTS" }
```

**Line count**: 6 lines (frontmatter + delegation)

**Justification**: Command name and description are self-explanatory

### Level 2: Full (25-80 lines typical)

**When appropriate**: Documented delegators with complex arguments or multi-step processes

**Required**:

- name field (frontmatter)
- description field (frontmatter)
- Usage section (syntax)
- "What It Does" section (steps)
- Examples section (2-3 examples)

**Optional**:

- Tips or notes section
- Argument details
- Related commands

**Example**:

```yaml
---
name: audit-agent
description: Comprehensive agent configuration validation
---

# audit-agent

Validates agent configurations using specialized auditors.

## Usage

    /audit-agent [agent-name]

## What It Does

1. Invokes agent-audit for agent-specific validation
2. Checks model selection, tool restrictions, focus areas
3. Generates comprehensive audit report

## Examples

    /audit-agent evaluator
    /audit-agent evaluator

{Skill skill="agent-audit" args="$ARGUMENTS"}
```

**Line count**: 40 lines (frontmatter + full docs + delegation)

**Justification**: Multi-step process benefits from explanation

## Proportionality Assessment

### Criterion 1: Complexity Match

**Appropriate**:

- Simple command (6-15 lines typical) → Minimal docs
- Documented command (25-80 lines typical) → Full docs

**Inappropriate**:

- Simple command → 60 lines of docs (over-documented)
- Complex command → No usage docs (under-documented)

**Test**: Does documentation level match command complexity?

### Criterion 2: Information Density

**Good** (dense, useful):

```markdown
## Usage

    /audit-agent [agent-name]

Validates the specified agent. Defaults to evaluator if no argument.
```

**Bad** (verbose, repetitive):

```markdown
## Usage

This command is called audit-agent. You can use it by typing /audit-agent
followed by an agent name. If you don't provide an agent name, it will use a
default value. The default value is evaluator. You can override this by
providing your own agent name when you call the command.
```

**Test**: Is information concise and useful, or verbose and repetitive?

### Criterion 3: /help Readability

**Good** (concise in /help - 4 words, 35 chars):

```yaml
---
name: audit-hook
description: Audit shell script quality
---
```

**Bad** (clutters /help - 33 words, 285 chars):

```yaml
---
name: audit-hook
description: This command audits bash scripts for security vulnerabilities, quality issues, defensive programming compliance, POSIX portability, error handling, and best practices using the hook-audit skill which performs comprehensive static analysis with shellcheck integration.
---
```

**Target**: 5-8 words (40-60 chars ideal, 30-80 acceptable)

**Test**: Will /help output be readable and concise?

## When to Use Minimal Docs

### Justification Checklist

Use minimal docs (6-10 lines) when:

- [ ] Command name is self-explanatory
- [ ] Description in frontmatter is sufficient
- [ ] Usage is obvious (one argument, straightforward)
- [ ] Single delegation with no complexity
- [ ] No special argument handling

**Examples**:

```yaml
# audit-hook - obvious usage (4 words, 35 chars)
---
name: audit-hook
description: Audit shell script quality
---
{ Skill skill="hook-audit" args="$ARGUMENTS" }
```

```yaml
# test-skill - clear from name (6 words, 55 chars)
---
name: test-skill
description: Validate skill discoverability and triggering
---
{ Skill skill="test-runner" args="$ARGUMENTS" }
```

### Red Flags for Minimal Docs

**Don't use minimal docs if**:

- Argument syntax is complex
- Multiple steps involved
- Default behavior unclear
- Usage not obvious from name

**Example** (needs full docs):

```yaml
---
name: batch-validate
description: Validate multiple components with options
---
{ Skill skill="batch-auditor" args="$ARGUMENTS" }
```

**Problem**: "multiple components with options" suggests complex usage → Needs full docs

## When to Use Full Docs

### Justification Checklist

Use full docs (30-80 lines) when:

- [ ] Argument syntax is not obvious
- [ ] Multi-step process users should understand
- [ ] Default behavior needs explanation
- [ ] Multiple usage patterns exist
- [ ] Benefits from examples

**Examples**:

```yaml
# audit-agent - multi-step process
---
name: audit-agent
description: Comprehensive agent configuration validation
---

# audit-agent

[Full usage, what it does, examples]

{Skill skill="agent-audit" args="$ARGUMENTS"}
```

```yaml
# batch-audit - complex arguments
---
name: batch-audit
description: Batch validation with filtering options
---
# batch-audit

## Usage

/batch-audit [pattern] [--type=agent|skill|command]

[Examples, explanation]

{Skill skill="audit-coordinator" args="$ARGUMENTS"}
```

### Required Sections for Full Docs

**Minimum for full docs**:

1. **Usage section**: Syntax with [optional] / required
2. **"What It Does" section**: 3-5 step explanation
3. **Examples section**: 2-3 practical examples

**Optional sections**:

1. Tips or notes
2. Related commands
3. Argument details

## Common Anti-Patterns

### Anti-Pattern 1: Over-Documented Simple Command

**Problem**:

```yaml
---
name: audit-hook
description: Audit shell scripts
---

# audit-hook

## Overview

This command audits bash scripts for quality and security.

## Background

Bash scripts are commonly used in software development...
[30 lines of background]

## Usage

    /audit-hook [script-file]

## Detailed Explanation

When you run this command, it invokes the hook-audit skill...
[20 lines of explanation]

## Examples

    /audit-hook script.sh
    /audit-hook deploy.sh
    /audit-hook /path/to/script.sh

## Advanced Usage

You can combine this with other commands...
[10 lines of advanced usage]

## Related Commands

- /audit-agent
- /test-skill

{Skill skill="hook-audit" args="$ARGUMENTS"}
```

**Line count**: 95 lines

**Why bad**: Simple delegation buried in excessive documentation

**Fix**: Reduce to minimal docs:

```yaml
---
name: audit-hook
description: Audit shell scripts for security and quality
---
{ Skill skill="hook-audit" args="$ARGUMENTS" }
```

### Anti-Pattern 2: Under-Documented Complex Command

**Problem**:

```yaml
---
name: batch-validate
description: Batch validation with options
---
{ Skill skill="batch-auditor" args="$ARGUMENTS" }
```

**Why bad**: "with options" suggests complex usage, but no docs

**Fix**: Add full documentation:

```yaml
---
name: batch-validate
description: Batch validation with filtering and options
---

# batch-validate

## Usage

    /batch-validate [pattern] [--type=TYPE] [--parallel]

## Options

- `pattern`: Glob pattern (e.g., "agents/*", "*.md")
- `--type`: Filter by type (agent, skill, command, hook)
- `--parallel`: Run validations in parallel

## Examples

    /batch-validate agents/*
    /batch-validate --type=agent
    /batch-validate skills/* --parallel

{Skill skill="batch-auditor" args="$ARGUMENTS"}
```

### Anti-Pattern 3: Verbose, Repetitive Docs

**Problem**:

```markdown
## Usage

The audit-agent command is used to validate agents. To use it, type
/audit-agent followed by the name of the agent you want to validate.
If you don't provide an agent name, the command will use a default agent
name, which is evaluator. You can override this default by providing
your own agent name when you type the command.
```

**Why bad**: Repetitive, verbose, low information density

**Fix**: Concise version:

```markdown
## Usage

    /audit-agent [agent-name]

Validates the specified agent. Defaults to evaluator if omitted.
```

### Anti-Pattern 4: Missing Usage Syntax

**Problem**:

```markdown
# audit-agent

This command validates agents. You provide an agent name and it checks
the configuration.

## Examples

    /audit-agent evaluator

{Skill skill="agent-audit" args="$ARGUMENTS"}
```

**Why bad**: No clear usage syntax (what's optional? required?)

**Fix**: Add usage section:

```markdown
# audit-agent

## Usage

    /audit-agent [agent-name]

Validates agent configuration. Defaults to evaluator if no argument.

## Examples

    /audit-agent evaluator
    /audit-agent evaluator

{Skill skill="agent-audit" args="$ARGUMENTS"}
```

## Documentation Templates

### Template 1: Minimal Docs (6-10 lines)

```yaml
---
name: command-name
description: Brief description of what this command does
---
{ Skill skill="skill-name" args="$ARGUMENTS" }
```

### Template 2: Full Docs (30-80 lines)

```yaml
---
name: command-name
description: Comprehensive description with key features
---

# command-name

Brief overview of command purpose.

## Usage

    /command-name [required-arg] [optional-arg]

## What It Does

1. First step
2. Second step
3. Third step

## Examples

    /command-name example1
    /command-name example2 optional

{Skill skill="skill-name" args="$ARGUMENTS"}
```

## Validation Checklist

When auditing documentation proportionality:

- [ ] **Level matches complexity**: Minimal for simple, full for complex
- [ ] **Information density**: Concise and useful, not verbose
- [ ] **Required sections present** (for full docs): Usage, What It Does, Examples
- [ ] **No excessive docs** (for simple commands): <10 lines if minimal
- [ ] **Usage syntax clear** (for full docs): [optional] required notation
- [ ] **Description concise** (frontmatter): Works well in /help output

## Examples by Appropriateness

### Excellent Minimal Docs

**Command**: audit-hook (8 lines)

```yaml
---
name: audit-hook
description: Audit shell script quality
---
{ Skill skill="hook-audit" args="$ARGUMENTS" }
```

**Verdict**: ✓ Perfect - Self-explanatory (4 words, 35 chars), no docs needed

### Excellent Full Docs

**Command**: audit-agent (40 lines)

```yaml
---
name: audit-agent
description: Comprehensive agent configuration validation
---

# audit-agent

## Usage

    /audit-agent [agent-name]

## What It Does

1. Model selection validation
2. Tool restrictions check
3. Focus area assessment
4. Approach methodology review

## Examples

    /audit-agent evaluator
    /audit-agent evaluator

{Skill skill="agent-audit" args="$ARGUMENTS"}
```

**Verdict**: ✓ Appropriate - Complex enough to justify docs

### Over-Documented

**Command**: audit-hook-verbose (95 lines)

```yaml
---
name: audit-hook
description: Audit shell scripts
---

[70 lines of excessive documentation]

{Skill skill="hook-audit" args="$ARGUMENTS"}
```

**Verdict**: ✗ Over-documented - Too much for simple delegator

### Under-Documented

**Command**: batch-validate (8 lines)

```yaml
---
name: batch-validate
description: Batch validation with complex options
---
{ Skill skill="batch-auditor" args="$ARGUMENTS" }
```

**Verdict**: ✗ Under-documented - Complex options need explanation

## Summary

**Documentation levels**:

- **Minimal** (6-10 lines): Frontmatter only, obvious usage
- **Full** (30-80 lines): Frontmatter + Usage + What It Does + Examples

**Key principles**:

1. **Match complexity**: Simple → minimal, complex → full
2. **Be concise**: High information density, no verbosity
3. **Required sections** (full docs): Usage, What It Does, Examples
4. **Self-explanatory** (minimal docs): Name and description sufficient

**Decision rule**:

- If usage is obvious from name → Minimal docs
- If multi-step or complex arguments → Full docs

**When in doubt**: Start minimal, add docs only if truly needed.
