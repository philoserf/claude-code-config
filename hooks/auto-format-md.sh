#!/usr/bin/env bash
# PostToolUse hook: auto-format markdown files with bun fmt.
# Silent on success and on any failure — never block the user's flow.
# Set AUTO_FORMAT_DEBUG=/path/to/log to capture formatter output for diagnosis.

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

# bun fmt honors .gitignore and .prettierignore from its cwd, as prettier v3 did,
# and the hook inherits the session's cwd, which may be a subdirectory. Run from
# the nearest ancestor holding bunfig.toml, .prettierignore or .git so the ignore
# files apply. bunfig.toml marks the vault on almanac, which has no .git there.
root=$(dirname "$file")
dir=$root
while [ "$dir" != / ]; do
	if [ -e "$dir/bunfig.toml" ] || [ -e "$dir/.prettierignore" ] || [ -e "$dir/.git" ]; then
		root=$dir
		break
	fi
	dir=$(dirname "$dir")
done

# --no-script: without it, a project's own `fmt` script runs instead of formatting this file.
#
# macOS BSD userland has no timeout(1); bound the run with job control instead.
(cd "$root" && exec bun fmt --no-script "$file") >>"$log" 2>&1 &
pid=$!
(
	sleep 10
	kill "$pid" 2>/dev/null
) &
watcher=$!
wait "$pid" 2>/dev/null
kill "$watcher" 2>/dev/null

exit 0
