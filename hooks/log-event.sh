#!/usr/bin/env bash
set -uo pipefail

logdir="$HOME/.claude/logs"
mkdir -p "$logdir"
logfile="$logdir/hook-events.log"
input=$(cat) || true
event=$(echo "$input" | jq -r '.hook_event_name // "unknown"' 2>/dev/null) || event="unknown"
session=$(echo "$input" | jq -r '.session_id // "unknown"' 2>/dev/null) || session="unknown"

# Rotate if log exceeds 5MB
if [[ -f $logfile ]] && [[ $(stat -f%z "$logfile" 2>/dev/null || echo 0) -gt 5242880 ]]; then
	mv "$logfile" "${logfile}.$(date +%Y%m%d)"
fi

# Extract a short detail field per event type (keep each under ~120 chars)
detail=""
case "$event" in
SessionStart)
	detail=$(echo "$input" | jq -r '.source // empty' 2>/dev/null) || true
	;;
SessionEnd)
	detail=$(echo "$input" | jq -r '.reason // empty' 2>/dev/null) || true
	;;
Stop | SubagentStop)
	type=$(echo "$input" | jq -r '.agent_type // empty' 2>/dev/null) || true
	msg=$(echo "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null | head -1 | cut -c1-120) || true
	if [[ -n "$type" && -n "$msg" ]]; then
		detail="$type | $msg"
	elif [[ -n "$msg" ]]; then
		detail="$msg"
	elif [[ -n "$type" ]]; then
		detail="$type"
	fi
	;;
SubagentStart)
	detail=$(echo "$input" | jq -r '.agent_type // empty' 2>/dev/null) || true
	;;
PostToolUseFailure)
	tool=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null) || true
	err=$(echo "$input" | jq -r '.error // empty' 2>/dev/null | head -1 | cut -c1-100) || true
	[[ -n "$tool" ]] && detail="$tool: $err" || detail="$err"
	;;
PreCompact | PostCompact)
	detail=$(echo "$input" | jq -r '.trigger // empty' 2>/dev/null) || true
	;;
ConfigChange)
	detail=$(echo "$input" | jq -r '.source // empty' 2>/dev/null) || true
	;;
TaskCompleted)
	detail=$(echo "$input" | jq -r '.task_subject // empty' 2>/dev/null | cut -c1-120) || true
	;;
WorktreeCreate)
	detail=$(echo "$input" | jq -r '.name // empty' 2>/dev/null) || true
	;;
WorktreeRemove)
	detail=$(echo "$input" | jq -r '.worktree_path // empty' 2>/dev/null) || true
	;;
esac

if [[ -n "$detail" ]]; then
	echo "$(date -Iseconds) $event $session | $detail" >>"$logfile"
else
	echo "$(date -Iseconds) $event $session" >>"$logfile"
fi

exit 0
