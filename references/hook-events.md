# Hook Events Reference

Comprehensive guide to Claude Code hook events and configuration.

## Hook Types

| Event               | Trigger                 | Tool Context | Use Cases                          |
| ------------------- | ----------------------- | ------------ | ---------------------------------- |
| `PreToolUse`        | Before tool execution   | Yes          | Validation, blocking, logging      |
| `PostToolUse`       | After tool execution    | Yes          | Formatting, notifications, cleanup |
| `UserPromptSubmit`  | User submits prompt     | No           | Prompt validation, enrichment      |
| `PermissionRequest` | Permission dialog shown | Yes          | Auto-allow/deny patterns           |
| `SessionStart`      | Session begins          | No           | Environment setup, initialization  |
| `Stop`              | Agent stops             | No           | Cleanup, notifications             |
| `SubagentStart`     | Subagent begins         | No           | Pre-processing, logging            |
| `SubagentStop`      | Subagent completes      | No           | Result processing, logging         |

## Agent-Level Hooks

Hooks can be defined in agent YAML frontmatter, scoping them to that specific agent only.

### Supported Events (Agent-Level)

| Event         | Trigger                | Use Case                                |
| ------------- | ---------------------- | --------------------------------------- |
| `PreToolUse`  | Before agent uses tool | Validation, blocking, logging           |
| `PostToolUse` | After tool completes   | Formatting, notifications               |
| `Stop`        | Agent finishes         | Cleanup (auto-converts to SubagentStop) |

### Agent vs Settings Hooks

| Aspect | Agent-Level (frontmatter)       | Settings-Level (settings.json)          |
| ------ | ------------------------------- | --------------------------------------- |
| Scope  | Single agent only               | All sessions/agents                     |
| Events | PreToolUse, PostToolUse, Stop   | All events including SubagentStart/Stop |
| Use    | Agent needs specific validation | Global behavior needed                  |

### When to Use Which

**Use agent-level hooks when:**

- Validation/behavior is specific to one agent's purpose
- You want hooks bundled with the agent for portability
- Different agents need different hook behavior

**Use settings-level hooks when:**

- Behavior should apply globally (formatting, logging)
- You need SubagentStart/SubagentStop events
- Multiple agents share the same validation needs

### Agent Hook Example

```yaml
---
name: code-reviewer
description: Review code changes with automatic linting
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
---
```

### Key Characteristics

- **Component-scoped**: Only run when that specific agent is active
- **Automatic cleanup**: Cleaned up when agent finishes
- **Same format**: Follows settings.json hook configuration format
- **Matchers**: Filter which tools trigger the hooks

## Configuration Pattern

### Basic Hook

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npm install",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Tool-Specific Hook (with matcher)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/format.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Multiple Hooks

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write \"$TOOL_FILE_PATH\"",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "git add \"$TOOL_FILE_PATH\"",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Environment Variables

Hooks receive contextual information via environment variables:

| Variable              | Available In                 | Description                             |
| --------------------- | ---------------------------- | --------------------------------------- |
| `$TOOL_NAME`          | PreToolUse, PostToolUse      | Tool being executed (Read, Write, etc.) |
| `$TOOL_FILE_PATH`     | Tool hooks (when applicable) | File path for file-based tools          |
| `$CLAUDE_PROJECT_DIR` | All hooks                    | Current project directory               |
| `$TOOL_RESULT`        | PostToolUse                  | Result from tool execution              |

## Matchers

### Syntax

- **Single tool**: `"Write"`
- **Multiple tools**: `"Write|Edit"`
- **All tools**: `"*"` or omit matcher
- **Regex pattern**: `"Write.*"` (matches Write, WriteFile, etc.)

### Tool Names

Common tool names for matchers:

- `Read`, `Write`, `Edit`
- `Bash`, `Glob`, `Grep`
- `Task`, `Skill`
- `WebFetch`, `WebSearch`

## Hook Script Requirements

### Input Format

Hooks receive JSON on stdin:

```json
{
  "tool": "Write",
  "file_path": "/path/to/file.js",
  "content": "file contents..."
}
```

### Exit Codes

- **0**: Allow (success)
- **2**: Block with error message
- **Other**: Treated as errors (allow but log warning)

### Error Handling

Always exit 0 on errors to avoid blocking workflow:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Parse input
input=$(cat)

# Do work, but don't fail on errors
if ! validate "$input"; then
    echo "Warning: validation failed" >&2
    exit 0  # Allow anyway
fi

exit 0
```

### Blocking Example

```python
#!/usr/bin/env python3
import json
import sys

data = json.load(sys.stdin)

if should_block(data):
    print("Blocked: reason here", file=sys.stderr)
    sys.exit(2)  # Block

sys.exit(0)  # Allow
```

## Performance Considerations

- Set appropriate `timeout` values (default: 30 seconds)
- Keep hook scripts fast (<1 second preferred)
- Use async processing for slow operations
- Log to files, not stderr (unless blocking)

## Common Patterns

### Auto-format on Write

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write \"$TOOL_FILE_PATH\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### Validate Before Commit

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-commit.sh",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

### Environment Setup on Start

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npm install && npm run build",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```
