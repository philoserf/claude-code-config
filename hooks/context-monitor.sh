#!/usr/bin/env bash
# context-monitor.sh — PostToolUse hook
# Reads context metrics from bridge file (written by statusline) and injects
# advisory warnings when context window is low.
# Inspired by GSD's gsd-context-monitor.js.
#
# Thresholds:
#   WARNING  (remaining <= 35%): Wrap up current work
#   CRITICAL (remaining <= 25%): Stop and inform user
#
# Debounce: 8 tool calls between warnings. Severity escalation bypasses debounce.
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

WARNING_THRESHOLD=35
CRITICAL_THRESHOLD=25
DEBOUNCE_CALLS=8
STALE_SECONDS=120

# Read stdin JSON for session_id
input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)

if [ -z "$session_id" ]; then
  exit 0
fi

# Read bridge file written by statusline
bridge_file="/tmp/claude-ctx-${session_id}.json"
if [ ! -f "$bridge_file" ]; then
  exit 0
fi

bridge=$(cat "$bridge_file" 2>/dev/null)
remaining=$(echo "$bridge" | jq -r '.remaining_percentage // empty' 2>/dev/null)
used_pct=$(echo "$bridge" | jq -r '.used_pct // empty' 2>/dev/null)
timestamp=$(echo "$bridge" | jq -r '.timestamp // 0' 2>/dev/null)

if [ -z "$remaining" ]; then
  exit 0
fi

# Ignore stale data
now=$(date +%s)
age=$((now - timestamp))
if [ "$age" -gt "$STALE_SECONDS" ]; then
  exit 0
fi

# Convert to integer for comparison
remaining_int=${remaining%.*}

# No warning needed
if [ "$remaining_int" -gt "$WARNING_THRESHOLD" ] 2>/dev/null; then
  exit 0
fi

# Debounce state file (keyed by session_id)
state_file="/tmp/claude-ctx-warn-${session_id}"

# Read state: "calls_since_warn:last_level"
state=$(cat "$state_file" 2>/dev/null || echo "0:none")
calls_since=${state%%:*}
last_level=${state#*:}
calls_since=$((calls_since + 1))

# Determine current level
if [ "$remaining_int" -le "$CRITICAL_THRESHOLD" ] 2>/dev/null; then
  current_level="critical"
else
  current_level="warning"
fi

# Check debounce — skip if we warned recently (unless severity escalated)
severity_escalated="false"
if [ "$current_level" = "critical" ] && [ "$last_level" = "warning" ]; then
  severity_escalated="true"
fi

if [ "$calls_since" -lt "$DEBOUNCE_CALLS" ] && [ "$severity_escalated" = "false" ] && [ "$last_level" != "none" ]; then
  echo "${calls_since}:${last_level}" >"$state_file"
  exit 0
fi

# Reset debounce counter
echo "0:${current_level}" >"$state_file"

# Build warning message
if [ "$current_level" = "critical" ]; then
  message="CONTEXT CRITICAL: ${used_pct}% used, ${remaining_int}% remaining. Context is nearly exhausted. Inform the user that context is low and ask how they want to proceed. Do not start new complex work."
else
  message="CONTEXT WARNING: ${used_pct}% used, ${remaining_int}% remaining. Context is getting limited. Avoid starting new complex work or unnecessary exploration."
fi

# Output advisory (Claude Code reads this as additionalContext)
jq -n --arg msg "$message" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'

exit 0
