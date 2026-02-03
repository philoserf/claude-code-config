#!/bin/bash
# Hook event logging - logs hook events with timestamps
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

event_name="$1"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
mkdir -p ~/.claude/logs

input=$(cat)
tool=""
tool_input=""

if [ -n "$input" ]; then
	tool=$(echo "$input" | jq -r '.tool // .tool_name // empty' 2>/dev/null)
	tool_input=$(echo "$input" | jq -c '.tool_input // empty' 2>/dev/null)
fi

line="[$timestamp] $event_name"
if [ -n "$tool" ] && [ "$tool" != "null" ]; then
	line="$line tool=$tool"
fi
if [ -n "$tool_input" ] && [ "$tool_input" != "null" ]; then
	line="$line input=$tool_input"
fi

echo "$line" >>~/.claude/logs/hook-events.log

exit 0
