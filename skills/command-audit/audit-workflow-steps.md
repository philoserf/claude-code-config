# Command Audit Workflow Steps

Complete step-by-step guide for auditing commands. Follow these steps for
thorough validation of command configurations.

## Overview

The audit workflow consists of 7 steps:

1. Read command file
2. Validate frontmatter features (official requirements)
3. Identify command pattern
4. Assess simplicity guidelines
5. Validate argument handling
6. Check documentation proportionality
7. Decide: Command or Skill?
8. Generate audit report

Each step builds on the previous, creating a comprehensive evaluation.

## Step 1: Read Command File

Identify the command file to audit:

```bash
# Single command
Read commands/audit-agent.md

# Find all commands
Glob commands/*.md
```

## Step 1.5: Validate Frontmatter Features

**Check official frontmatter fields** (OFFICIAL REQUIREMENTS):

```bash
# Read frontmatter (first few lines)
Read commands/command-name.md | head -15
```

**Required validation**:

- [ ] **description present** - CRITICAL: Required for /help visibility and
      model invocation
- [ ] **argument-hint format** - If present, uses `[optional]` or `<required>`
      notation
- [ ] **allowed-tools valid** - If present, are valid tool names (Read, Write,
      Edit, Bash, Grep, Glob, Task, Skill, etc.)
- [ ] **model valid** - If present, is valid model identifier (sonnet, opus,
      haiku, or full string)
- [ ] **disable-model-invocation** - If present, is boolean (true/false)

**Common issues**:

- Missing description → Command won't appear in /help (CRITICAL)
- Invalid model name → Command might fail (CRITICAL)
- Argument-hint doesn't match usage → Confuses users (IMPORTANT)
- Restrictive allowed-tools → Command might fail if it needs unlisted tools
  (IMPORTANT)

See [frontmatter-validation.md](frontmatter-validation.md) for complete
frontmatter guidance.

## Step 2: Identify Command Pattern

**Commands can use multiple valid patterns** (per official Anthropic
guidance):

### Pattern 1: Descriptive Delegation

Most common in this codebase:

```markdown
**Delegation:** Invokes the **agent-audit** skill for comprehensive
validation.
```

Or:

```markdown
Execute the git-workflow skill to handle complete git workflow automation.
```

Or:

```markdown
Validate agent configuration(s) using the agent-audit skill.

**Target**: ${ARGUMENTS:-all agents in ~/.claude/agents/}
```

### Pattern 2: Standalone Prompt

Also valid:

```markdown
Analyze the provided file and generate a comprehensive quality report
including:

- **Code Style**: Adherence to language conventions and best practices
- **Security**: Potential vulnerabilities and security concerns
- **Performance**: Optimization opportunities and bottlenecks
- **Maintainability**: Code clarity, documentation, and structure
```

### Pattern 3: Bash Execution

Using ! syntax:

```markdown
!git log --oneline -10
!npm test

Summarize the output above.
```

### Pattern 4: File Reference

Using @ syntax:

```markdown
@.claude/templates/code-review-checklist.md

Apply this checklist to $ARGUMENTS
```

### Validation Criteria

For **delegation pattern**:

- **Target named**: Clearly identifies skill or agent
- **Purpose described**: Explains what skill/agent does
- **Single target**: Delegates to one component
- **Descriptive**: Uses natural language, not tool call syntax

For **standalone prompt**:

- **Clear instructions**: Tells Claude what to do
- **Structured**: Well-organized, actionable
- **Single purpose**: Focused on one task

For **bash/file patterns**:

- **Valid syntax**: Proper ! or @ usage
- **Appropriate use**: Bash for commands, @ for templates

**Note**: All patterns are valid per official Anthropic documentation.
Evaluate based on:

- Is the pattern clear and understandable?
- Does it accomplish a single purpose?
- Is it appropriate for the task?

See [delegation-patterns.md](../../references/customization/delegation-patterns.md) for
delegation examples.

## Step 3: Assess Simplicity Guidelines

**Check file size and complexity** (BEST PRACTICE GUIDELINES):

```bash
wc -l commands/audit-agent.md
```

**Guidelines** (not hard limits):

- **6-15 lines**: Typical simple command (minimal documentation)
- **25-80 lines**: Typical documented command (full documentation)
- **>80 lines**: Consider skill migration (evaluate complexity)

**Focus on principles**:

- Single clear purpose
- Easy to understand
- Not implementing complex logic
- Appropriate for manual invocation

**Red flags** (suggest skill migration):

- Complex logic (if/else, loops) - belongs in skill
- Multiple tool calls - orchestration belongs in skill
- Extensive processing - implementation belongs in skill
- \> 80 lines - usually indicates skill-worthy complexity

**Note**: Line counts are guidelines. A well-documented command with clear
purpose might exceed guidelines and still be appropriate.

See [simplicity-enforcement.md](simplicity-enforcement.md) for decision
criteria.

## Step 4: Validate Argument Handling

**Check argument usage**:

**Good** (proper handling):

```markdown
{Task description="Validate $ARGUMENTS" prompt="Validate the following:
$ARGUMENTS"}
```

**With defaults**:

```markdown
{Task description="Validate ${ARGUMENTS:-all agents}" prompt="..."}
```

**Poor** (no handling):

```markdown
{Task description="Validate something" prompt="..."}

# User provides argument but command ignores it
```

**Validation criteria**:

- **Passes arguments**: Uses $ARGUMENTS or $1, $2, etc.
- **Sensible defaults**: Provides fallback if no argument
- **Documented usage**: Explains expected arguments (for documented commands)

See [argument-handling.md](argument-handling.md) for patterns.

## Step 5: Check Documentation Proportionality

**Documentation levels**:

### Simple Delegator (6-10 lines)

```yaml
---
name: audit-bash
description: Audit shell scripts for security and quality
---

Launch hook-auditor skill to validate Bash scripts:

{Skill skill="hook-auditor" args="$ARGUMENTS"}
```

### Documented Delegator (30-80 lines)

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

1. Invokes agent-auditor for agent-specific validation
2. Checks model selection, tool restrictions, focus areas
3. Generates comprehensive audit report

## Examples

    /audit-agent bash-scripting
    /audit-agent claude-code-evaluator

Launch agent-auditor:

{Skill skill="agent-auditor" args="$ARGUMENTS"}
```

**Validation**: Documentation level matches complexity

See [documentation-proportionality.md](documentation-proportionality.md) for
guidelines.

## Step 6: Decide: Command or Skill?

**Should this be a command?**

**Yes (keep as command) if**:

- User-invoked shortcut
- Simple delegation (6-80 lines)
- Convenience wrapper
- Slash command usage pattern

**No (convert to skill) if**:

- Auto-triggers on queries
- Complex logic (>80 lines)
- Multiple tool calls
- Extensive processing

**Test**: "Would a user type /this-name in chat?" → Yes = Command, No = Skill

See [simplicity-enforcement.md](simplicity-enforcement.md) for decision
framework.

## Step 7: Generate Audit Report

Compile findings into standardized report format.

See [report-format.md](report-format.md) for detailed structure and template.

## Quick Reference

**Checklist**: Use [audit-checklist.md](audit-checklist.md) for rapid
validation

**Common issues**: See
[common-issues-and-antipatterns.md](common-issues-and-antipatterns.md) for
specific patterns

**Report format**: Follow [report-format.md](report-format.md) structure

## Tips for Effective Audits

1. **Start with checklist**: Quick scan for obvious issues
2. **Read the command**: Understand intent before critiquing
3. **Distinguish official vs custom**: Critical vs Important vs Nice-to-Have
4. **Consider context**: Some deviations are justified
5. **Provide actionable feedback**: Specific fixes, not vague suggestions
6. **Check cross-references**: Validate links to skills/agents exist
