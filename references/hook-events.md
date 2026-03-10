# Hook Events Reference

Comprehensive guide to Claude Code hook events and configuration.

## Contents

- All Hook Events
- Hook Execution Types
- Agent-Level Hooks
- Configuration Pattern
- Common Input Fields
- Event-Specific Input Fields
- Matchers
- Hook Script Requirements
- Decision Control
- Performance Considerations
- Common Patterns

## All Hook Events

### Session Lifecycle

| Event                | Trigger                                      | Decision Control              |
| -------------------- | -------------------------------------------- | ----------------------------- |
| `SessionStart`       | New session, resume, `/clear`, or compaction | Add context; persist env vars |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded               | Observability only            |
| `SessionEnd`         | Session terminates                           | Cleanup only                  |
| `PreCompact`         | Compaction triggered (manual or auto)        | Add context                   |

### User Input

| Event              | Trigger               | Decision Control          |
| ------------------ | --------------------- | ------------------------- |
| `UserPromptSubmit` | User submits a prompt | Allow, block, add context |

### Tool Execution

| Event                | Trigger                         | Decision Control                            |
| -------------------- | ------------------------------- | ------------------------------------------- |
| `PreToolUse`         | Before tool execution           | Allow, deny, ask; modify input; add context |
| `PermissionRequest`  | Permission dialog about to show | Allow, deny; modify input                   |
| `PostToolUse`        | After successful tool execution | Block; add context; replace MCP output      |
| `PostToolUseFailure` | Tool execution fails            | Add context                                 |

### Agent and Team

| Event           | Trigger                           | Decision Control                  |
| --------------- | --------------------------------- | --------------------------------- |
| `SubagentStart` | Subagent spawned via Agent tool   | Add context to subagent           |
| `SubagentStop`  | Subagent finishes responding      | Block, continue with feedback     |
| `Stop`          | Main agent finishes responding    | Block to keep Claude working      |
| `TeammateIdle`  | Agent team teammate about to idle | Continue with feedback or stop    |
| `TaskCompleted` | Task marked complete or turn ends | Block completion or stop teammate |

### Configuration

| Event          | Trigger                        | Decision Control               |
| -------------- | ------------------------------ | ------------------------------ |
| `ConfigChange` | Settings or skill files change | Block (except policy_settings) |

### Notification

| Event          | Trigger                          | Decision Control   |
| -------------- | -------------------------------- | ------------------ |
| `Notification` | Claude Code sends a notification | Informational only |

### Version Control

| Event            | Trigger                | Decision Control                   |
| ---------------- | ---------------------- | ---------------------------------- |
| `WorktreeCreate` | Git worktree created   | Must print absolute path to stdout |
| `WorktreeRemove` | Worktree being removed | Cleanup only                       |

## Hook Execution Types

Claude Code supports four hook types. Not all events support all types.

| Type      | Description                           | Blocking | Async Support |
| --------- | ------------------------------------- | -------- | ------------- |
| `command` | Run a shell command                   | Yes      | Yes           |
| `http`    | Send HTTP request                     | Yes      | No            |
| `prompt`  | Inject a prompt into the conversation | Yes      | No            |
| `agent`   | Spawn an agent to handle the event    | Yes      | No            |

### Type Support by Event

**All four types** (command, http, prompt, agent):

- `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`
- `UserPromptSubmit`, `Stop`, `SubagentStop`, `TaskCompleted`

**Command only**:

- `SessionStart`, `SessionEnd`, `InstructionsLoaded`, `SubagentStart`
- `TeammateIdle`, `Notification`, `ConfigChange`, `PreCompact`
- `WorktreeCreate`, `WorktreeRemove`

## Agent-Level Hooks

Hooks can be defined in agent YAML frontmatter, scoping them to that specific agent only.

### Supported Events (Agent-Level)

| Event         | Trigger                | Use Case                                |
| ------------- | ---------------------- | --------------------------------------- |
| `PreToolUse`  | Before agent uses tool | Validation, blocking, logging           |
| `PostToolUse` | After tool completes   | Formatting, notifications               |
| `Stop`        | Agent finishes         | Cleanup (auto-converts to SubagentStop) |

### Agent vs Settings Hooks

| Aspect | Agent-Level (frontmatter)       | Settings-Level (settings.json) |
| ------ | ------------------------------- | ------------------------------ |
| Scope  | Single agent only               | All sessions/agents            |
| Events | PreToolUse, PostToolUse, Stop   | All 18 events                  |
| Use    | Agent needs specific validation | Global behavior needed         |

### When to Use Which

**Use agent-level hooks when:**

- Validation/behavior is specific to one agent's purpose
- You want hooks bundled with the agent for portability
- Different agents need different hook behavior

**Use settings-level hooks when:**

- Behavior should apply globally (formatting, logging)
- You need events beyond PreToolUse/PostToolUse/Stop
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

### Async Hook

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/log-changes.sh",
            "timeout": 5,
            "async": true
          }
        ]
      }
    ]
  }
}
```

## Common Input Fields

All hooks receive JSON on stdin with these fields present on every event:

| Field             | Description                             |
| ----------------- | --------------------------------------- |
| `session_id`      | Unique session identifier               |
| `transcript_path` | Path to session transcript              |
| `cwd`             | Current working directory               |
| `permission_mode` | Permission mode (default/bypass/custom) |
| `hook_event_name` | Name of the firing event                |

## Event-Specific Input Fields

### SessionStart

```json
{
  "source": "startup|resume|clear|compact",
  "model": "claude-opus-4-6",
  "agent_type": "optional"
}
```

### SessionEnd

```json
{
  "reason": "clear|logout|prompt_input_exit|bypass_permissions_disabled|other"
}
```

### InstructionsLoaded

```json
{
  "file_path": "/path/to/CLAUDE.md",
  "memory_type": "User|Project|Local|Managed",
  "load_reason": "session_start|nested_traversal|path_glob_match|include",
  "globs": "optional",
  "trigger_file_path": "optional",
  "parent_file_path": "optional"
}
```

### UserPromptSubmit

```json
{
  "prompt": "user's prompt text"
}
```

### PreToolUse / PermissionRequest

```json
{
  "tool_name": "Write",
  "tool_input": { "file_path": "/path", "content": "..." },
  "tool_use_id": "unique-id"
}
```

### PostToolUse

```json
{
  "tool_name": "Write",
  "tool_input": { "file_path": "/path", "content": "..." },
  "tool_response": "result text",
  "tool_use_id": "unique-id"
}
```

### PostToolUseFailure

```json
{
  "tool_name": "Bash",
  "tool_input": { "command": "..." },
  "tool_use_id": "unique-id",
  "error": "error message",
  "is_interrupt": false
}
```

### SubagentStart

```json
{
  "agent_id": "unique-id",
  "agent_type": "Bash|Explore|Plan|custom-agent-name"
}
```

### SubagentStop / Stop

```json
{
  "stop_hook_active": true,
  "agent_id": "unique-id (SubagentStop only)",
  "agent_type": "agent type (SubagentStop only)",
  "agent_transcript_path": "path (SubagentStop only)",
  "last_assistant_message": "final response text"
}
```

### TeammateIdle

```json
{
  "teammate_name": "name",
  "team_name": "name"
}
```

### TaskCompleted

```json
{
  "task_id": "unique-id",
  "task_subject": "subject",
  "task_description": "optional",
  "teammate_name": "name",
  "team_name": "name"
}
```

### PreCompact

```json
{
  "trigger": "manual|auto",
  "custom_instructions": "user text or empty"
}
```

### ConfigChange

```json
{
  "source": "user_settings|project_settings|local_settings|policy_settings|skills",
  "file_path": "optional"
}
```

### Notification

```json
{
  "message": "notification text",
  "title": "optional",
  "notification_type": "permission_prompt|idle_prompt|auth_success|elicitation_dialog"
}
```

### WorktreeCreate

```json
{
  "name": "worktree-slug-identifier"
}
```

### WorktreeRemove

```json
{
  "worktree_path": "/absolute/path/to/worktree"
}
```

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
- `Agent`, `Skill`
- `WebFetch`, `WebSearch`

## Hook Script Requirements

### Exit Codes

- **0**: Allow (success)
- **2**: Block with error message
- **Other**: Treated as errors (allow but log warning)

### Error Handling

Always exit 0 on errors to avoid blocking workflow:

```bash
#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

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

## Decision Control

### JSON Output Format

Hooks can output JSON to control behavior beyond simple exit codes:

```json
{
  "decision": "allow|deny|block",
  "reason": "explanation text",
  "additionalContext": "text injected into conversation"
}
```

### PreToolUse Special Case

PreToolUse uses a nested field instead of top-level `decision`:

```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow|deny|ask"
  }
}
```

### Adding Context

Any hook can inject text into the conversation via `additionalContext`:

```json
{
  "additionalContext": "Note: this file was auto-formatted after writing."
}
```

### Persisting Environment Variables

SessionStart hooks can persist env vars via `CLAUDE_ENV_FILE`:

```bash
#!/usr/bin/env bash
echo "MY_VAR=value" >> "$CLAUDE_ENV_FILE"
```

## Performance Considerations

- Set appropriate `timeout` values (default: 30 seconds)
- Keep hook scripts fast (<1 second preferred)
- Use `async: true` on command hooks for slow, non-blocking operations
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

### Keep Claude Working on Stop

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-completion.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### Log Failed Tool Executions

```json
{
  "hooks": {
    "PostToolUseFailure": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/log-failures.sh",
            "timeout": 5,
            "async": true
          }
        ]
      }
    ]
  }
}
```
