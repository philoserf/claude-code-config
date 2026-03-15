#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
event=$(echo "$input" | jq -r '.hook_event_name // "unknown"')
session=$(echo "$input" | jq -r '.session_id // "unknown"')

echo "$(date -Iseconds) $event $session" >>"$HOME/.claude/logs/hook-events.log"

exit 0
