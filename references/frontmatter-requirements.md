# Frontmatter Requirements

Complete YAML frontmatter specifications for all Claude Code component types.

**Decision Guides**:

- Not sure which component to create? See [Decision Matrix](decision-matrix.md) for comparison table, scenarios, and migration paths
- Need naming patterns? See [Naming Conventions](naming-conventions.md)

## Contents

- Skills
  - Description Best Practices
  - String Substitutions
- Subagents
- Commands (Legacy)
- Output Styles
- Rules
- Hooks (No Frontmatter)
- Validation Checklist
- Common Frontmatter Errors
- Tools for Validation

## Skills

```yaml
---
name: skill-name # Optional: defaults to directory name
description: What and when to use # Recommended: max 1024 chars
---
```

### Fields

All fields are optional. Only `description` is recommended so Claude knows when to use the skill.

| Field                      | Type    | Default   | Description                                                                                                     |
| -------------------------- | ------- | --------- | --------------------------------------------------------------------------------------------------------------- |
| `name`                     | string  | dir name  | Display name. If omitted, uses the directory name. Lowercase letters, numbers, and hyphens only (max 64 chars). |
| `description`              | string  | —         | What the skill does and when to use it. If omitted, uses the first paragraph of markdown content.               |
| `argument-hint`            | string  | —         | Hint shown during autocomplete (e.g., `[issue-number]`)                                                         |
| `disable-model-invocation` | boolean | `false`   | Prevent Claude from auto-loading this skill                                                                     |
| `user-invocable`           | boolean | `true`    | Show in `/` menu; set `false` for background knowledge                                                          |
| `allowed-tools`            | string  | —         | Comma-separated pre-approved tool list (e.g., `Read, Grep, Glob`)                                               |
| `model`                    | string  | `inherit` | Model override: `sonnet`, `opus`, `haiku`, or `inherit`                                                         |
| `context`                  | string  | —         | Set to `fork` to run in a forked subagent context                                                               |
| `agent`                    | string  | —         | Subagent type when `context: fork` (default: `general-purpose`)                                                 |
| `hooks`                    | object  | —         | Lifecycle hooks scoped to this skill (same format as settings.json)                                             |

### Naming Rules

Per the [Claude Code skills docs](https://docs.anthropic.com/en/docs/claude-code/skills):

- Optional — defaults to directory name if omitted
- Lowercase letters, numbers, and hyphens only (max 64 characters)
- Must match the parent directory name if specified

### Description Best Practices

- **Use third-person voice** — descriptions must start with a third-person verb ("Analyzes...", "Generates...", "Runs..."), not imperative ("Analyze...", "Generate...", "Run...")
- Include **what** the skill provides
- Include **when** to use it (trigger scenarios)
- Use trigger phrases that match user queries
- Target 200-500 characters for good discoverability
- Front-load important keywords

**Examples**:

```yaml
# Good: third-person voice
description: Analyzes a codebase and recommends Claude Code automations...

# Bad: imperative voice
description: Analyze a codebase and recommend Claude Code automations...
```

### String Substitutions

Available in skill markdown body:

| Variable               | Description                                  |
| ---------------------- | -------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index           |
| `${CLAUDE_SESSION_ID}` | Current session ID                           |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's SKILL.md    |

### Example

```yaml
---
name: task-automation
description: Automates repetitive development tasks including file generation, code scaffolding, and batch processing. Use when you need to create multiple similar files, generate boilerplate code, or process files in bulk.
---
```

## Subagents

```yaml
---
name: component-name # Required: matches filename without .md
description: When to invoke # Required: triggers and purpose
---
```

### Required Fields

- **name**: Must match filename (without `.md` extension)
- **description**: Explains when and why to invoke this agent

### Optional Fields

| Field             | Type    | Default   | Description                                                              |
| ----------------- | ------- | --------- | ------------------------------------------------------------------------ |
| `tools`           | string  | inherited | Comma/space-separated list of allowed tools                              |
| `disallowedTools` | string  | —         | Tools to explicitly deny (removed from inherited or allowed list)        |
| `model`           | string  | `inherit` | Model: `sonnet`, `opus`, `haiku`, or `inherit`                           |
| `permissionMode`  | string  | `default` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`         |
| `maxTurns`        | integer | —         | Maximum agentic turns before the subagent stops                          |
| `skills`          | array   | —         | Skills to preload into the subagent's context at startup                 |
| `mcpServers`      | object  | —         | MCP servers available to this subagent (name reference or inline config) |
| `hooks`           | object  | —         | Lifecycle hooks scoped to this agent (PreToolUse, PostToolUse, Stop)     |
| `memory`          | string  | —         | Persistent memory scope: `user`, `project`, or `local`                   |
| `background`      | boolean | `false`   | Always run this subagent as a background task                            |
| `isolation`       | string  | —         | Set to `worktree` to run in a temporary git worktree                     |

### Permission Modes

- **default**: Normal permission prompts
- **acceptEdits**: Auto-accept Edit tool calls
- **dontAsk**: Skip permission prompts (subagent-scoped)
- **bypassPermissions**: Skip all permission checks (use carefully)
- **plan**: Run in plan mode (read-only initially)

### Memory Scopes

- **user**: `~/.claude/agent-memory/<name>/` — shared across all projects
- **project**: `.claude/agent-memory/<name>/` — project-specific, version-controlled
- **local**: `.claude/agent-memory-local/<name>/` — project-specific, gitignored

### Hook Path Resolution

When specifying hook commands in agent frontmatter:

- **Relative paths** are resolved from the project root (where `.claude/` lives)
- **Working directory** when hooks execute is the project root
- **Absolute paths** are supported but reduce portability
- Use `./` prefix for clarity when referencing project-relative scripts

### Example

```yaml
---
name: code-reviewer
description: Reviews code changes for quality, security, and style issues. Use before committing or when asked to review code.
tools: Read, Grep, Glob, Bash
model: sonnet
maxTurns: 10
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/format.sh"
---
```

## Commands (Legacy)

Commands (`.claude/commands/*.md`) are a legacy path — all commands in this repo have been migrated to skills. Skills support `$ARGUMENTS` parameter substitution, auto-triggering, and richer configuration.

- Skills take precedence if same name exists in both locations

### Example

```yaml
---
description: Validates the specified file for syntax errors
argument-hint: [file]
---
```

## Output Styles

Output styles modify Claude Code's system prompt for non-coding use cases.

**Location**: `.claude/output-styles/<name>.md` or `~/.claude/output-styles/<name>.md`

```yaml
---
name: style-name # Optional: defaults to filename
description: When to use this style # Optional: shown in /output-style menu
keep-coding-instructions: false # Optional: default false
---
```

### Fields

| Field                      | Type    | Default | Description                                      |
| -------------------------- | ------- | ------- | ------------------------------------------------ |
| `name`                     | string  | —       | Name of the output style (defaults to filename)  |
| `description`              | string  | —       | Description shown in the `/output-style` UI menu |
| `keep-coding-instructions` | boolean | `false` | Keep Claude Code's built-in coding instructions  |

### Behavior

- Directly modifies Claude Code's system prompt
- Excludes efficiency instructions (concise responses) by default
- Excludes coding instructions unless `keep-coding-instructions: true`
- Built-in styles: Default, Explanatory, Learning

## Rules

Rules are markdown files with optional `paths` frontmatter for conditional loading.

**Location**: `.claude/rules/<name>.md` or `~/.claude/rules/<name>.md`

```yaml
---
paths: # Optional: glob patterns for conditional loading
  - "**/*.sh"
  - "bin/**"
---
```

### Fields

| Field   | Type  | Default | Description                                                 |
| ------- | ----- | ------- | ----------------------------------------------------------- |
| `paths` | array | —       | Glob patterns; rule loads only when matching files are read |

### How Rules Load

- **Without `paths` frontmatter**: Loaded unconditionally at session start
- **With `paths` frontmatter**: Loaded only when Claude reads files matching the globs

### Example

```text
.claude/
├── rules/
│   ├── markdown.md     # No paths → always loaded
│   ├── git.md          # No paths → always loaded
│   ├── bash.md         # paths: ["**/*.sh", "bin/**"] → conditional
│   ├── go.md           # paths: ["**/*.go", "go.mod"] → conditional
│   └── typescript.md   # paths: ["**/*.ts", "**/*.tsx"] → conditional
```

## Hooks (No Frontmatter)

Hooks are configured in `settings.json`, not in frontmatter. Hook script files (`.sh`, `.py`, `.js`) have no YAML frontmatter.

Hooks can also be defined inline in **skill or agent frontmatter** via the `hooks` field.

See [hook-events.md](hook-events.md) for the complete list of 18 hookable events, input schemas, and decision control patterns.

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

### Hook Types

| Type      | Description                           | Blocking | Async Support |
| --------- | ------------------------------------- | -------- | ------------- |
| `command` | Run a shell command                   | Yes      | Yes           |
| `http`    | Send HTTP request                     | Yes      | No            |
| `prompt`  | Inject a prompt into the conversation | Yes      | No            |
| `agent`   | Spawn an agent to handle the event    | Yes      | No            |

## Validation Checklist

### For Skills

- [ ] `name` matches directory name (if specified)
- [ ] `name` is lowercase letters, numbers, and hyphens only (if specified)
- [ ] `description` includes "what" AND "when" (recommended)
- [ ] `description` length is 200-500 chars (recommended)
- [ ] `description` is under 1024 characters (if specified)
- [ ] Only documented frontmatter fields used

### For Agents

- [ ] `name` matches filename (without `.md`)
- [ ] `description` is clear and specific
- [ ] `model` is valid (if specified)
- [ ] `tools` list matches actual usage (if specified)
- [ ] `permissionMode` is a valid value (if specified)

### For Rules

- [ ] `paths` globs are valid patterns (if specified)
- [ ] Language/tool-specific rules use `paths` to avoid loading globally

### For Output Styles

- [ ] `description` is set (for `/output-style` menu display)
- [ ] `keep-coding-instructions` is intentionally set if non-default

## Common Frontmatter Errors

### Missing Required Fields

```yaml
# Bad: missing description
---
name: my-agent
---
```

```yaml
# Good
---
name: my-agent
description: Expert in debugging Python applications with focus on performance issues
---
```

### Name Mismatch

```yaml
# Bad: filename is bash-scripting.md but name is bash
---
name: bash
description: Bash expert
---
```

```yaml
# Good
---
name: bash-scripting
description: Bash expert
---
```

### Invalid Skill Name

```yaml
# Bad: uppercase and underscores
---
name: My_Skill
description: Does things
---
```

```yaml
# Good
---
name: my-skill
description: Does things
---
```

### Poor Skill Description

```yaml
# Bad: too short, no "when" info
---
name: helper
description: Helps with tasks
---
```

```yaml
# Good
---
name: task-automation
description: Automates repetitive development tasks including file generation, code scaffolding, and batch processing. Use when you need to create multiple similar files, generate boilerplate code, or process files in bulk.
---
```

## Tools for Validation

The `validate-config.py` hook automatically validates frontmatter when you edit agent, skill, or command files. It checks:

- YAML syntax correctness
- Required fields presence
- Field value validity
- Name/filename matching

If validation fails, the hook will block the write operation and display the error.
