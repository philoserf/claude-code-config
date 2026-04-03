---
name: Claude Code hook stdin payloads differ by hook type
description: Statusline gets context_window data; PreToolUse/PostToolUse hooks get session_id, tool_name, tool_input but NOT context_window
type: reference
---

Claude Code hook stdin JSON payloads are NOT uniform across hook types:

- **Statusline:** Gets `context_window.remaining_percentage`, `model`, `workspace`, `session_id`
- **PostToolUse/PreToolUse:** Gets `session_id`, `tool_name`, `tool_input`, `cwd`, `hook_event_name` — but NOT `context_window`

To share context data with hooks, use a bridge file pattern: statusline writes to `/tmp/claude-ctx-{session_id}.json`, other hooks read it.
