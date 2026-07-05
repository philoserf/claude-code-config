#!/usr/bin/env sh
# PostToolUse hook: append one JSONL record per skill invocation to a usage log.
# Feeds skill-cleaner's ground-truth "unused" detection. Fail-open — never blocks
# a tool call and always exits 0, even when jq is missing or the input is unexpected.

input=$(cat)

# jq is the only dependency; degrade to a no-op if it is absent.
command -v jq >/dev/null 2>&1 || exit 0

skill=$(printf '%s' "$input" | jq -r '.tool_input.skill // empty' 2>/dev/null)
[ -n "$skill" ] || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // ""' 2>/dev/null)
ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

log="$HOME/.claude/state/skill-usage.jsonl"
mkdir -p "$(dirname "$log")" 2>/dev/null || exit 0

# Build the record with jq so skill names / cwd with quotes stay valid JSON.
printf '%s' "$input" \
  | jq -c --arg ts "$ts" '{ts: $ts, skill: .tool_input.skill, cwd: (.cwd // "")}' 2>/dev/null \
  >> "$log" 2>/dev/null

exit 0
