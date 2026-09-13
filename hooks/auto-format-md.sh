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

# Both spellings of the run differed only in where output went, and `>>` on
# /dev/null behaves the same as `>`, so the default expresses the whole fork.
log="${AUTO_FORMAT_DEBUG:-/dev/null}"

# prettier v3 honors .gitignore and .prettierignore from its cwd by default;
# an explicit --ignore-path REPLACES those defaults, so never pass one.
#
# macOS BSD userland has no timeout(1); bound the run with job control instead.
bunx prettier --write "$file" >>"$log" 2>&1 &
pid=$!
( sleep 10; kill "$pid" 2>/dev/null ) &
watcher=$!
wait "$pid" 2>/dev/null
kill "$watcher" 2>/dev/null

exit 0
