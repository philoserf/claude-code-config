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

# macOS BSD userland has no timeout(1); bound the run with job control instead.
run_bounded() {
  "$@" &
  pid=$!
  ( sleep 10; kill "$pid" 2>/dev/null ) &
  watcher=$!
  wait "$pid" 2>/dev/null
  kill "$watcher" 2>/dev/null
}

if [ -f "$dir/.gitignore" ]; then
  if [ -n "$log" ]; then
    run_bounded bunx prettier --write --ignore-path="$dir/.gitignore" "$file" >>"$log" 2>&1
  else
    run_bounded bunx prettier --write --ignore-path="$dir/.gitignore" "$file" >/dev/null 2>&1
  fi
else
  if [ -n "$log" ]; then
    run_bounded bunx prettier --write "$file" >>"$log" 2>&1
  else
    run_bounded bunx prettier --write "$file" >/dev/null 2>&1
  fi
fi

exit 0
