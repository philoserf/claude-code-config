#!/bin/sh
# PostToolUse hook: auto-format markdown files with prettier.
# Silent on success and on any failure — never block the user's flow.

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[ -z "$file" ] && exit 0
case "$file" in
  *.md | *.mdx | *.markdown) ;;
  *) exit 0 ;;
esac
[ ! -f "$file" ] && exit 0

dir=$(dirname "$file")
if [ -f "$dir/.gitignore" ]; then
  bunx prettier --write --ignore-path="$dir/.gitignore" "$file" >/dev/null 2>&1 || true
else
  bunx prettier --write "$file" >/dev/null 2>&1 || true
fi
