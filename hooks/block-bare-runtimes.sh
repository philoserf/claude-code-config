#!/usr/bin/env bash
# PreToolUse hook (Bash): block bare `python`, `python3`, `pip`, `pip3`, and `npx` in
# command position. This is a uv and bunx house (see ~/.claude/CLAUDE.md, Environment):
# `uv run`, `uv run --script`, `uvx`, and `bunx` are the runtimes. The rule is mechanical,
# so it lives here rather than as prose the model may skip. Exit 2 blocks the call and
# feeds stderr to the model. Fail-open: missing jq or an unparsable payload lets it through.

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

# Command position only: line start, after a separator, or inside $( ). `uv run python`
# and `command -v python3` are not in command position and pass.
hit=$(printf '%s\n' "$cmd" \
  | grep -oE '(^|[;&|(]|\$\()[[:space:]]*(python3?|pip3?|npx)([[:space:]]|$)' \
  | head -1 | tr -d ' ;&|($\n')
[ -z "$hit" ] && exit 0

case "$hit" in
  npx) echo "Blocked: bare npx. Run one-off JS tools with bunx." >&2 ;;
  *) echo "Blocked: bare $hit. Run scripts with uv run (PEP 723: uv run --script), tools with uvx, and an interpreter with uv run python." >&2 ;;
esac
exit 2
