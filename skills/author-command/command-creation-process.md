# Command Creation Process

See [command-design-patterns.md](command-design-patterns.md) for pattern details.

## Step 1: Define Purpose

**Questions to ask**:

- What specific task does this command perform?
- Is this a shortcut for something users do frequently?
- Does a similar command already exist?
- Should this be a skill instead (auto-trigger)?

**Check existing commands**:

```bash
ls -la ~/.claude/commands/
```

## Step 2: Choose Delegation Target

**Single agent/skill**:

- Most commands delegate to one target
- Keep it simple and focused

**Multiple agents**:

- Only if workflow genuinely requires orchestration
- Document the sequence clearly

**No delegation** (rare):

- Only for very simple prompts
- Usually better as skill or agent

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

- Clear, concise explanation of what command does
- 50-150 characters ideal
- Action-oriented

**Good examples**:

```yaml
description: Validates a sub-agent configuration for correctness, clarity, and effectiveness
description: Audit shell scripts for best practices, security, and portability
description: Tests a skill's discoverability and effectiveness with sample queries
```

**Bad examples**:

```yaml
description: Helps with stuff  # Too vague
description: A command  # Not descriptive
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
