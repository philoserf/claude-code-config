# Argument Handling

Guide for validating command argument handling patterns and defaults.

## Core Principle

**Commands should handle user arguments appropriately for their pattern.**

**For delegation commands**: Claude automatically passes arguments when using descriptive delegation
**For standalone prompts**: Arguments referenced in instructions via $ARGUMENTS variable
**For bash execution**: Arguments passed via $ARGUMENTS in bash commands

Claude's descriptive delegation pattern automatically passes arguments - no explicit syntax needed.

## What Are Arguments

Arguments are user-provided input passed to commands:

**Usage**:

````text
/command-name argument1 argument2
```text

**In command file**:

- `$ARGUMENTS`: All arguments as single string
- `$1`, `$2`, `$3`: Individual positional arguments
- `${ARGUMENTS:-default}`: Arguments with default fallback

**Example**:

```text
User types: /audit-agent bash-author

In command: $ARGUMENTS = "bash-author"
```text

## Argument Patterns

### Pattern 1: Descriptive Delegation (Arguments Auto-Passed)

**When to use**: Delegating to skill/agent

**Structure**:

```markdown
**Delegation:** Invokes the **skill-name** skill for [purpose].
```

Or:

```markdown
Validate [target] using the skill-name skill.
```

**Example**:

```markdown
**Usage:** `/audit-agent [agent-name]`

**Delegation:** Invokes the **agent-audit** skill for comprehensive validation.
```

**User types**:

```text
/audit-agent bash-author
```

**Result**: agent-audit skill automatically receives "bash-author" as $ARGUMENTS

**Characteristics**:

- Claude automatically passes $ARGUMENTS to invoked skill
- No explicit argument syntax needed
- Works with descriptive delegation pattern
- Most common pattern in this codebase

### Pattern 2: With Default Value

**When to use**: Provide sensible default if no argument

**Structure**:

```markdown
Validate [target] using the skill-name skill.

**Target**: ${ARGUMENTS:-default-value}
```

**Example**:

```markdown
Validate agent configuration(s) using the agent-audit skill.

**Target**: ${ARGUMENTS:-all agents in ~/.claude/agents/}
```

**User types** (with argument):

```text
/audit-agent claude-code-evaluator
```

**Result**: Validates "claude-code-evaluator" specifically

**User types** (no argument):

```text
/audit-agent
```

**Result**: Validates all agents (default)

**Characteristics**:

- Graceful fallback
- Sensible default
- User can override

### Pattern 3: Standalone Prompt with Argument Reference

**When to use**: Inline instructions that use arguments

**Structure**:

```markdown
Analyze $ARGUMENTS and provide detailed feedback on...
```

**Example**:

```markdown
**Usage:** `/analyze-file [file-path]`

Analyze the file at $ARGUMENTS and provide:
- Code quality assessment
- Security review
- Performance recommendations
```

**User types**:

```text
/analyze-file src/app.py
```

**Result**: $ARGUMENTS = "src/app.py", Claude analyzes specified file

**Characteristics**:

- Standalone prompt (no delegation)
- Explicit $ARGUMENTS reference
- Claude interprets instructions directly

### Pattern 4: Positional Arguments

**When to use**: Multiple distinct arguments

**Structure**:

```markdown
{Task prompt="Validate file $1 with rules $2"}
```text

**Example**:

```markdown
{Task subagent_type="validator" prompt="Validate $1 in $2 directory"}
```text

**User types**:

```text
/validate agent.md agents/
```text

**Result**:

- `$1` = "agent.md"
- `$2` = "agents/"

**Characteristics**:

- Multiple arguments
- Position-dependent
- Less common (usually use $ARGUMENTS)

### Pattern 4: Constructed Prompt

**When to use**: Build detailed prompt from arguments

**Structure**:

```markdown
{Task prompt="[template with $ARGUMENTS embedded]"}
```text

**Example**:

```markdown
{Task subagent_type="agent-auditor" description="Audit $ARGUMENTS" prompt="Audit the $ARGUMENTS agent for model selection appropriateness, tool restriction accuracy, focus area quality, and approach completeness."}
```text

**User types**:

```text
/audit-agent bash-author
```text

**Result**: Full prompt with "bash-author" embedded

**Characteristics**:

- Detailed prompt construction
- Context added around argument
- Common for Task tool

## Validation Criteria

### Criterion 1: Arguments Are Used

**Good** (arguments used):

```markdown
{Skill skill="agent-auditor" args="$ARGUMENTS"}
```text

**Bad** (arguments ignored):

```markdown
{Skill skill="agent-auditor"}
```text

**Test**: Does the delegation use $ARGUMENTS, $1, or similar?

### Criterion 2: Sensible Defaults (Optional)

**Good** (useful default):

```markdown
{Skill skill="agent-auditor" args="${ARGUMENTS:-bash-author}"}
```text

**Bad** (unhelpful default):

```markdown
{Skill skill="agent-auditor" args="${ARGUMENTS:-foo}"}
```text

**Test**: If default provided, is it sensible and helpful?

### Criterion 3: Usage Documented (For Documented Commands)

**Good** (usage explained):

```markdown
## Usage

    /audit-agent [agent-name]

Validates the specified agent. If no agent name provided, defaults to bash-author.
```text

**Bad** (no usage docs for complex command):

```markdown
# audit-agent

[40 lines of docs, no usage section]
```text

**Test**: If command is documented (30-80 lines), are arguments explained?

## Common Anti-Patterns

### Anti-Pattern 1: Arguments Ignored

**Problem**:

```markdown
{Skill skill="agent-auditor"}
```text

**User types**:

```text
/audit-agent bash-author
```text

**Result**: "bash-author" is lost, agent-auditor gets nothing

**Fix**:

```markdown
{Skill skill="agent-auditor" args="$ARGUMENTS"}
```text

### Anti-Pattern 2: Hardcoded Values

**Problem**:

```markdown
{Skill skill="agent-auditor" args="bash-author"}
```text

**User types**:

```text
/audit-agent claude-code-evaluator
```text

**Result**: User wants "claude-code-evaluator", but command always uses "bash-author"

**Fix**:

```markdown
{Skill skill="agent-auditor" args="$ARGUMENTS"}
```text

### Anti-Pattern 3: No Default When Needed

**Problem**:

```markdown
{Skill skill="agent-auditor" args="$ARGUMENTS"}
```text

**User types** (no argument):

```text
/audit-agent
```text

**Result**: agent-auditor gets empty string, may fail

**Fix** (if default makes sense):

```markdown
{Skill skill="agent-auditor" args="${ARGUMENTS:-bash-author}"}
```text

Or document that argument is required.

### Anti-Pattern 4: Unhelpful Default

**Problem**:

```markdown
{Skill skill="agent-auditor" args="${ARGUMENTS:-example}"}
```text

**Default**: "example" (not a real agent)

**Fix**: Use real, useful default:

```markdown
{Skill skill="agent-auditor" args="${ARGUMENTS:-bash-author}"}
```text

Or no default if one doesn't make sense.

### Anti-Pattern 5: Complex Argument Processing

**Problem**:

```markdown
Parse $ARGUMENTS.
Split by comma.
For each part:
Validate individually.
Combine results.
```text

**Why bad**: Complex processing in command

**Fix**: Move to skill, command passes arguments:

```markdown
{Skill skill="batch-auditor" args="$ARGUMENTS"}
```text

Skill handles parsing and processing.

## Argument Documentation

### For Simple Commands (6-10 lines)

**No usage docs needed** (obvious from name):

```yaml
---
name: audit-bash
description: Audit shell scripts for security and quality
---
{ Skill skill="hook-auditor" args="$ARGUMENTS" }
```text

**User understands**: `/audit-bash script.sh`

### For Documented Commands (30-80 lines)

**Usage section required**:

```markdown
## Usage

    /audit-agent [agent-name]

Validates the specified agent configuration.
If no agent name provided, defaults to bash-author.

### Examples

    /audit-agent bash-author
    /audit-agent claude-code-evaluator
```text

**Components**:

- Syntax with [optional] or <required>
- Explanation of what argument does
- Default behavior if omitted
- Examples showing usage

## Default Value Selection

### When to Provide Default

**Good candidates for defaults**:

- Most common use case
- Reasonable fallback
- Safe default (won't break anything)
- Example/demo value

**Examples**:

```markdown
# Default to most common agent

${ARGUMENTS:-bash-author}

# Default to current directory

${ARGUMENTS:-.}

# Default to all (comprehensive check)

${ARGUMENTS:-all}
```text

### When NOT to Provide Default

**Skip default when**:

- No sensible default exists
- Every use case is different
- Required argument (should fail if missing)
- Default would be misleading

**Example** (no default appropriate):

```markdown
{Skill skill="agent-auditor" args="$ARGUMENTS"}
```text

If no argument → agent-auditor decides behavior

## Skill Tool vs Task Tool Argument Passing

### Skill Tool

**Pattern**:

```markdown
{Skill skill="skill-name" args="$ARGUMENTS"}
```text

**Characteristics**:

- Uses `args` parameter
- Simple pass-through
- Skill receives argument string

### Task Tool

**Pattern**:

```markdown
{Task subagent_type="agent-name" description="Brief" prompt="Detailed prompt with $ARGUMENTS"}
```text

**Characteristics**:

- Arguments embedded in prompt
- More control over context
- Can construct detailed prompt

**Example**:

```markdown
{Task subagent_type="agent-auditor" description="Audit $ARGUMENTS" prompt="Audit the $ARGUMENTS agent for model selection, tool restrictions, focus areas, and approach methodology."}
```text

## Validation Checklist

When auditing argument handling:

- [ ] **Arguments used**: $ARGUMENTS or $1, $2, etc. present
- [ ] **Passed to target**: Arguments reach delegated skill/agent
- [ ] **Default sensible** (if provided): Useful fallback value
- [ ] **Usage documented** (if 30-80 line command): Syntax and examples
- [ ] **No hardcoded values**: User input not overridden
- [ ] **No complex processing**: Simple pass-through, not parsing/transforming

## Examples by Pattern

### Excellent Pass-Through

**Command**: audit-bash

```yaml
---
name: audit-bash
description: Audit shell scripts for security and quality
---
{ Skill skill="hook-auditor" args="$ARGUMENTS" }
```text

**Analysis**:

- ✓ Arguments passed: $ARGUMENTS → hook-auditor
- ✓ Simple pass-through
- ✓ No complexity

**User types**: `/audit-bash script.sh`

**Result**: hook-auditor receives "script.sh"

### Good Default Handling

**Command**: audit-agent

```yaml
---
name: audit-agent
description: Validate agent configurations
---

{Skill skill="agent-auditor" args="${ARGUMENTS:-bash-author}"}
```text

**Analysis**:

- ✓ Arguments passed with default
- ✓ Sensible default (bash-author)
- ✓ User can override

**User types**: `/audit-agent` (no argument)

**Result**: agent-auditor receives "bash-author" (default)

### Poor: Arguments Ignored

**Command**: bad-command

```yaml
---
name: bad-command
description: Does validation
---
{ Skill skill="agent-auditor" }
```text

**Analysis**:

- ✗ No arguments passed
- ✗ User input lost

**User types**: `/bad-command bash-author`

**Result**: "bash-author" ignored, agent-auditor gets nothing

**Fix**: Add `args="$ARGUMENTS"`

## Summary

**Key principles**:

1. **Pass arguments**: Use $ARGUMENTS in delegation
2. **Sensible defaults** (optional): Provide helpful fallback
3. **Document usage** (if documented command): Explain argument syntax
4. **No complex processing**: Simple pass-through only
5. **Don't hardcode**: User input should reach target

**Common patterns**:

```markdown
# Simple pass-through (most common)

{Skill skill="skill-name" args="$ARGUMENTS"}

# With default

{Skill skill="skill-name" args="${ARGUMENTS:-default}"}

# Task tool with embedded arguments

{Task prompt="Do something with $ARGUMENTS"}
```text

**When in doubt**: Use `$ARGUMENTS` to pass user input unchanged.
````
