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

# Format based on file extension
case "$file_path" in
  *.go)
    try_format gofmt "$file_path" -w
    ;;
  *.ts | *.tsx | *.js | *.jsx | *.json | *.yaml | *.yml)
    try_format prettier "$file_path" --write
    ;;
  *.md)
    basename=$(basename "$file_path")
    if [ "$basename" = "walkthrough.md" ]; then
      exit 0 # Managed by showboat — prettier would break verified output blocks
    fi
    try_format prettier "$file_path" --write
    ;;
esac

exit 0
