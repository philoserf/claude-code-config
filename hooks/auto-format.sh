#!/bin/bash
# Auto-format hook - runs after Edit|Write operations
# Formats Go, JS/TS, JSON, YAML files using gofmt and prettier
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

# Use environment variable provided by Claude Code (preferred)
# Falls back to parsing JSON stdin if env var not set
file_path="${TOOL_FILE_PATH:-}"

if [ -z "$file_path" ]; then
	# Fallback: read from stdin JSON (PostToolUse payload structure)
	if command -v jq &>/dev/null; then
		if ! file_path=$(jq -r '.tool_input.file_path // empty' 2>/dev/null); then
			exit 0 # Graceful exit if JSON parsing fails
		fi
	else
		exit 0 # No jq available, can't parse stdin
	fi
fi

if [ -z "$file_path" ]; then
	exit 0
fi

# Run a formatter if available, log failures
try_format() {
	local tool="$1" file="$2"
	shift 2
	if command -v "$tool" &>/dev/null; then
		if ! "$tool" "$@" "$file" 2>/dev/null; then
			echo "[auto-format] $tool failed on $file" >&2
		fi
	fi
}

# Walk up from the file's directory looking for a Biome config.
# Biome is the source of truth for formatting/linting in projects that use it,
# so Prettier should not fight with it on Biome-supported file types.
has_biome_config() {
	local dir
	dir=$(dirname "$1")
	while [ -n "$dir" ] && [ "$dir" != "/" ]; do
		if [ -f "$dir/biome.json" ] || [ -f "$dir/biome.jsonc" ]; then
			return 0
		fi
		dir=$(dirname "$dir")
	done
	return 1
}

# Format based on file extension
case "$file_path" in
*.go)
	try_format gofmt "$file_path" -w
	;;
*.ts | *.tsx | *.js | *.jsx | *.json | *.jsonc)
	# Defer to Biome when present; otherwise Prettier handles it.
	if has_biome_config "$file_path"; then
		exit 0
	fi
	try_format bunx "$file_path" prettier --write
	;;
*.yaml | *.yml)
	try_format bunx "$file_path" prettier --write
	;;
*.md)
	basename=$(basename "$file_path")
	if [ "$basename" = "walkthrough.md" ]; then
		exit 0 # Managed by showboat — prettier would break verified output blocks
	fi
	try_format bunx "$file_path" prettier --write
	;;
esac

exit 0
