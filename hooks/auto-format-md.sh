#!/usr/bin/env sh
# PostToolUse hook: auto-format markdown files with prettier.
# Silent on success and on any failure — never block the user's flow.
# Set AUTO_FORMAT_DEBUG=/path/to/log to capture prettier output for diagnosis.

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[ -z "$file" ] && exit 0
case "$file" in
  *.md | *.mdx | *.markdown) ;;
  *) exit 0 ;;
esac
[ ! -f "$file" ] && exit 0

dir=$(dirname "$file")
log="${AUTO_FORMAT_DEBUG:-}"

if [ -f "$dir/.gitignore" ]; then
  if [ -n "$log" ]; then
    timeout 10s bunx prettier --write --ignore-path="$dir/.gitignore" "$file" >>"$log" 2>&1 || true
  else
    timeout 10s bunx prettier --write --ignore-path="$dir/.gitignore" "$file" >/dev/null 2>&1 || true
  fi
else
  if [ -n "$log" ]; then
    timeout 10s bunx prettier --write "$file" >>"$log" 2>&1 || true
  else
    timeout 10s bunx prettier --write "$file" >/dev/null 2>&1 || true
  fi
fi
