#!/usr/bin/env bash
set -uo pipefail

logfile="$HOME/.claude/logs/hook-events.log"
input=$(cat) || true
event=$(echo "$input" | jq -r '.hook_event_name // "unknown"' 2>/dev/null) || event="unknown"
session=$(echo "$input" | jq -r '.session_id // "unknown"' 2>/dev/null) || session="unknown"

# Rotate if log exceeds 5MB
if [[ -f "$logfile" ]] && [[ $(stat -f%z "$logfile" 2>/dev/null || echo 0) -gt 5242880 ]]; then
  mv "$logfile" "${logfile}.$(date +%Y%m%d)"
fi

echo "$(date -Iseconds) $event $session" >>"$logfile"

exit 0
