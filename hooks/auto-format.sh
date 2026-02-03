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
	if ! file_path=$(jq -r '.tool_input.file_path // empty' 2>/dev/null); then
		exit 0 # Graceful exit if JSON parsing fails
	fi
fi

if [ -z "$file_path" ]; then
	exit 0
fi

# Format based on file extension
case "$file_path" in
*.go)
	command -v gofmt &>/dev/null && gofmt -w "$file_path" 2>/dev/null
	;;
*.ts | *.tsx | *.js | *.jsx | *.json | *.yaml | *.yml)
	command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
	;;
*.md)
	command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
	command -v markdownlint &>/dev/null && [ -n "$file_path" ] && markdownlint --fix "$file_path" >/dev/null 2>&1
	;;
esac

exit 0
