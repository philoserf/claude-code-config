#!/usr/bin/env sh
# PreToolUse hook (Bash): block `gh pr create` with --fill / -f / --fill-first / --fill-verbose.
# --fill copies the commit body — including the Co-Authored-By trailer — into the PR body,
# which sidesteps attribution.pr = "". Exit 2 blocks the call and feeds stderr to the model.
# Fail-open: missing jq or an unparsable payload lets the command through.

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

# Only `gh pr create` in command position (line start or after a separator), up to the next
# separator — so `rm -f` elsewhere and the phrase quoted in a commit message are ignored.
printf '%s\n' "$cmd" \
  | grep -oE '(^|[;&|(])[[:space:]]*gh[[:space:]]+pr[[:space:]]+create[^;&|]*' \
  | grep -qE '(^|[[:space:]])(-f|--fill(-first|-verbose)?)([[:space:]=)]|$)' \
  || exit 0

echo "Blocked: gh pr create --fill copies the commit body (and its Co-Authored-By trailer) into the PR. Pass --title and --body (or --body-file) explicitly, with no attribution line." >&2
exit 2
