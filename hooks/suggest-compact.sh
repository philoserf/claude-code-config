#!/bin/bash
# Suggest-compact hook - nudges compaction every ~30 tool calls
# Runs as PostToolUse (counter) and SessionStart (reset)
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

# Use session ID from stdin JSON if available, fall back to PID
session_id=""
if raw=$(cat 2>/dev/null); then
	if command -v jq &>/dev/null && [ -n "$raw" ]; then
		session_id=$(echo "$raw" | jq -r '.session_id // empty' 2>/dev/null) || true
	fi
fi
session_id="${session_id:-$$}"
counter_file="/tmp/claude-compact-count-${session_id}"

# SessionStart resets the counter (hook_event env var from Claude Code)
if [ "${HOOK_EVENT:-}" = "SessionStart" ]; then
	# Clean up any stale counter files from previous sessions
	rm -f /tmp/claude-compact-count-* 2>/dev/null
	rm -f /tmp/claude-ctx-*.json /tmp/claude-ctx-warn-* 2>/dev/null
	echo "0" >"$counter_file"
	exit 0
fi

# Increment counter
count=$(cat "$counter_file" 2>/dev/null || echo "0")
count=$((count + 1))
echo "$count" >"$counter_file"

# Suggest compaction every 30 tool calls
if [ $((count % 30)) -eq 0 ]; then
	echo "You've made $count tool calls this session. Consider running /compact at a natural breakpoint." >&2
fi

exit 0
