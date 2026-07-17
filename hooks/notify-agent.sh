#!/bin/sh
# Desktop notification when a background Claude Code agent needs input or completes.
# Wired via settings.json hooks.Notification (matchers: agent_needs_input, agent_completed).
# $1 is the event context ("needs-input" | "completed").
# Intentionally fail-open and silent: a missing tool degrades to a no-op, never blocks.

kind="$1"
input=$(cat 2>/dev/null)

case "$kind" in
  needs-input) title="Claude Code — needs your input"; sound="Ping"  ;;
  completed)   title="Claude Code — agent done";        sound="Glass" ;;
  *)           title="Claude Code";                     sound="Glass" ;;
esac

msg=""
if command -v jq >/dev/null 2>&1; then
  msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
fi
[ -z "$msg" ] && msg="Background agent update"

# A literal newline inside the AppleScript string breaks the -e expression and
# the notification silently vanishes — flatten to spaces first.
msg=$(printf '%s' "$msg" | tr '\n\r' '  ')

esc_title=$(printf '%s' "$title" | sed 's/["\\]/\\&/g')
esc_msg=$(printf '%s' "$msg" | sed 's/["\\]/\\&/g')

osascript -e "display notification \"$esc_msg\" with title \"$esc_title\" sound name \"$sound\"" >/dev/null 2>&1 || true
exit 0
