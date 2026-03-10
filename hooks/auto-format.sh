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

# Format based on file extension
case "$file_path" in
*.go)
	if command -v gofmt &>/dev/null; then
		if ! gofmt -w "$file_path" 2>/dev/null; then
			echo "[auto-format] gofmt failed on $file_path" >&2
		fi
	fi
	;;
*.ts | *.tsx | *.js | *.jsx | *.json | *.yaml | *.yml)
	if command -v prettier &>/dev/null; then
		if ! prettier --write "$file_path" 2>/dev/null; then
			echo "[auto-format] prettier failed on $file_path" >&2
		fi
	fi
	;;
*.md)
	basename=$(basename "$file_path")
	if [ "$basename" = "walkthrough.md" ]; then
		exit 0 # Managed by showboat — prettier would break verified output blocks
	fi
	if command -v prettier &>/dev/null; then
		if ! prettier --write "$file_path" 2>/dev/null; then
			echo "[auto-format] prettier failed on $file_path" >&2
		fi
	fi
	;;
esac

exit 0
