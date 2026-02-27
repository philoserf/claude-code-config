# Frontmatter Requirements

Complete YAML frontmatter specifications for all Claude Code component types.

**Decision Guides**:

- Not sure which component to create? See [When to Use What](when-to-use-what.md) for decision guide
- Quick comparison table? See [Decision Matrix](decision-matrix.md)
- Need naming patterns? See [Naming Conventions](naming-conventions.md)

## Subagents

```yaml
---
name: component-name # Required: matches filename without .md
description: When to invoke # Required: triggers and purpose
tools: Read, Edit, Bash # Optional: restricts available tools
model: sonnet # Optional: sonnet, haiku, opus, or inherit
permissionMode: default # Optional: default, acceptEdits, bypassPermissions, plan, ignore
skills: skill1, skill2 # Optional: auto-load skills when agent starts
hooks: # Optional: lifecycle hooks scoped to this agent
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/format.sh"
---
```

### Required Fields

- **name**: Must match filename (without `.md` extension)
- **description**: Explains when and why to invoke this agent

### Optional Fields

- **tools**: List of allowed tools (inherits all if omitted)
- **model**: Which Claude model to use
- **permissionMode**: How to handle permissions
- **skills**: Comma-separated list of skills to auto-load
- **hooks**: Lifecycle hooks scoped to this agent (PreToolUse, PostToolUse, Stop)

### Model Options

- **Aliases**: `sonnet`, `opus`, `haiku`
- **Full strings**: `haiku`, `sonnet`
- **inherit**: Use main conversation's model
- **Default**: Inherits if omitted

### Permission Modes

- **default**: Normal permission prompts (default)
- **acceptEdits**: Auto-accept Edit tool calls
- **bypassPermissions**: Skip all permission checks (use carefully)
- **plan**: Run in plan mode (read-only initially)
- **ignore**: Ignore permission settings

### Hook Path Resolution

When specifying hook commands in agent frontmatter:

- **Relative paths** are resolved from the project root (where `.claude/` lives)
- **Working directory** when hooks execute is the project root
- **Absolute paths** are supported but reduce portability
- Use `./` prefix for clarity when referencing project-relative scripts

### Example

```yaml
---
name: bash-scripting
description: Master of defensive Bash scripting for production automation, CI/CD pipelines, and system utilities. Expert in safe, portable, and testable shell scripts.
model: sonnet
allowed_tools:
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Bash
  - Bash(git:*)
---
```

## Skills

```yaml
---
name: skill-name # Required: lowercase, hyphens, max 64 chars
description: What and when to use # Required: max 1024 chars
---
```

### Required Fields

- **name**: Skill identifier (must match directory name)
- **description**: What the skill does AND when to use it

### Experimental Fields

- **allowed-tools**: Restricts tool access (experimental, varying agent support)

### Naming Rules

- Lowercase letters, numbers, and hyphens only
- Maximum 64 characters
- Must match directory name
- No uppercase, underscores, or special characters

### Description Best Practices

- **Use third-person voice** — descriptions must start with a third-person verb ("Analyzes...", "Generates...", "Runs..."), not imperative ("Analyze...", "Generate...", "Run...")
- Include **what** the skill provides
- Include **when** to use it (trigger scenarios)
- Use trigger phrases that match user queries
- Target 200-500 characters for good discoverability
- Front-load important keywords

**Examples**:

```yaml
# ✅ Third-person voice
description: Analyzes a codebase and recommends Claude Code automations...

# ❌ Imperative voice
description: Analyze a codebase and recommend Claude Code automations...
```

### Example

```yaml
---
name: audit-skill
description: Comprehensive evaluation and validation of Claude Code customizations. Auto-triggers when reviewing, evaluating, or improving agents, commands, skills, hooks, or output-styles. Provides naming conventions, structural guidance, and best practices for all .claude/ components.
---
```

## Hooks (No Frontmatter)

Hooks are configured in `settings.json`, not in frontmatter. They don't have YAML frontmatter in their script files.

### Hook Configuration in settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/validate-config.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Hook Events

| Event               | Trigger                  | Use Case                      |
| ------------------- | ------------------------ | ----------------------------- |
| `PreToolUse`        | Before tool execution    | Validation, blocking, logging |
| `PostToolUse`       | After tool execution     | Formatting, notifications     |
| `UserPromptSubmit`  | When user submits prompt | Prompt validation             |
| `PermissionRequest` | On permission dialog     | Auto-allow/deny patterns      |
| `SessionStart`      | Session begins           | Environment setup             |
| `Stop`              | Agent stops              | Cleanup, notifications        |
| `SubagentStop`      | Subagent completes       | Result processing             |

See [hook-events.md](hook-events.md) for detailed event documentation.

## Output Styles (Deprecated)

Output styles are deprecated. Migrate to:

- **Subagents** for specialized task delegation with custom personas
- **SessionStart hooks** for environment initialization

### Legacy Format (Not Recommended)

```yaml
---
name: style-name
description: When to use this style
---
```

## Validation Checklist

### For Agents

- [ ] `name` matches filename (without `.md`)
- [ ] `description` is clear and specific
- [ ] `model` is valid (if specified)
- [ ] `tools` list matches actual usage (if specified)

### For Skills

- [ ] `name` is kebab-case, lowercase only
- [ ] `name` matches directory name
- [ ] `description` includes "what" AND "when"
- [ ] `description` length is 200-500 chars (recommended)
- [ ] Only spec-standard frontmatter fields used (`name`, `description`)

## Common Frontmatter Errors

### Missing Required Fields

```yaml
# ❌ WRONG - missing description
---
name: my-agent
---
```

```yaml
# ✓ CORRECT
---
name: my-agent
description: Expert in debugging Python applications with focus on performance issues
---
```

### Name Mismatch

```yaml
# ❌ WRONG - filename is bash-scripting.md but name is bash
---
name: bash
description: Bash expert
---
```

```yaml
# ✓ CORRECT
---
name: bash-scripting
description: Bash expert
---
```

### Invalid Skill Name

```yaml
# ❌ WRONG - uppercase and underscores
---
name: My_Skill
description: Does things
---
```

```yaml
# ✓ CORRECT
---
name: my-skill
description: Does things
---
```

### Poor Skill Description

```yaml
# ❌ WRONG - too short, no "when" info
---
name: helper
description: Helps with tasks
---
```

```yaml
# ✓ CORRECT
---
name: task-automation
description: Automates repetitive development tasks including file generation, code scaffolding, and batch processing. Use when you need to create multiple similar files, generate boilerplate code, or process files in bulk.
---
```

### Command Without Description

```yaml
# ❌ WRONG - won't appear in /help
---
argument-hint: [file]
---
```

```yaml
# ✓ CORRECT
---
description: Validates the specified file for syntax errors
argument-hint: [file]
---
```

## Tools for Validation

The `validate-config.py` hook automatically validates frontmatter when you edit agent, skill, or command files. It checks:

- YAML syntax correctness
- Required fields presence
- Field value validity
- Name/filename matching

If validation fails, the hook will block the write operation and display the error.
