# Command Creation Process

See [command-design-patterns.md](command-design-patterns.md) for pattern details.

## Step 1: Define Purpose

**Questions to ask**:

- What specific task does this command perform?
- Is this a shortcut for something users do frequently?
- Does a similar command already exist?
- Should this be a skill instead (auto-trigger)?

**Check existing commands**:

`ls -la ~/.claude/commands/`

## Step 2: Choose Command Pattern

**Standalone prompt**:

- Focused instructions for Claude
- Clear and specific task
- Keep it simple and actionable

**Bash execution** (using !):

- Running specific commands
- Executing scripts or tools
- Sequential operations

**File reference** (using @):

- Loading templates or checklists
- Reusable content patterns

## Step 3: Design Arguments

**Argument handling**:

- Access full arguments: `$ARGUMENTS`
- Access individual args: `$1`, `$2`, etc.
- Arguments are optional vs required

**Examples**:

```markdown
/validate-claude-agent [agent-name]

# agent-name is optional - validates all if omitted

/audit-skill skill-name

# skill-name is required
```

**Best practices**:

- Make arguments optional when sensible
- Provide sensible defaults
- Document in Usage section

## Step 4: Write Description (Required!)

**Description goes in frontmatter** and is used by:

- `/help` command listing
- Model when invoking the command

**Requirements**:

- Ultra-concise action phrase or sentence
- **5-8 words ideal** (40-60 chars), 30-80 acceptable
- Action verb + target/capability
- Eliminate filler words ("for", "with", unnecessary "and")

**Good examples** (5-8 words, 40-60 chars):

```yaml
description: Validate agent configuration quality  # 4 words, 39 chars
description: Audit shell script quality  # 4 words, 35 chars
description: Validate skill discoverability and triggering  # 6 words, 55 chars
```

**Bad examples**:

```yaml
description: Helps with stuff  # Too vague
description: A command  # Not descriptive
description: Validates a sub-agent configuration for correctness, clarity, and effectiveness  # Too verbose (11 words, 95 chars)
description: Audit shell scripts for best practices, security, and portability  # Too long (10 words, 85 chars)
```

**Before/After transformations**:

```yaml
# Before: 13 words, 106 chars
description: Guide for authoring specialized AI agents with focused expertise and tool restrictions
# After: 6 words, 47 chars
description: Guide for authoring specialized agents

# Before: 10 words, 85 chars
description: Audit shell scripts for best practices, security, and portability
# After: 4 words, 35 chars
description: Audit shell script quality
```

## Step 5: Choose Documentation Level

**Simple (6-10 lines)**:

- Obvious purpose
- No complex arguments
- Delegation target is clear

**Documented (30-80 lines)**:

- Arguments need explanation
- Multiple agents orchestrated
- Users will reference frequently
- Complex underlying capability

## Step 6: Create the File

**File location**: `~/.claude/commands/command-name.md`

**Filename conventions**:

- Use kebab-case: `command-name.md`
- Match command invocation: `/command-name`
- Descriptive, clear purpose

**Basic template**:

```markdown
---
description: [What the command does - REQUIRED]
---

# command-name

[Brief explanation or full documentation depending on pattern]

[Optional: Usage, Examples, Delegation sections]
```

## Step 7: Test the Command

**Test invocation**:

```text
/command-name
/command-name arg1
/command-name arg1 arg2
```

**Verify**:

1. Command appears in `/help` output
2. Description is clear and accurate
3. Delegation works correctly
4. Arguments are handled properly
5. Purpose is immediately obvious
