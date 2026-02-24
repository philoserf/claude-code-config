#!/bin/bash
# Git command logging hook - logs all git/gh commands with timestamps
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
description=$(echo "$input" | jq -r '.tool_input.description // "No description"' 2>/dev/null || echo "No description")

# Only log git/gh/dot commands
if echo "$command" | grep -qE '^(git|gh|dot)\s'; then
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	# Extract session ID from stdin JSON (last 8 chars)
	session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
	session_id="${session_id: -8}"
	session_id="${session_id:-default}"
	log_dir=~/.claude/logs/"$session_id"
	mkdir -p "$log_dir"
	echo "[$timestamp] $command | $description" >>"$log_dir"/git-commands.log
fi

exit 0 # Never block, just log
