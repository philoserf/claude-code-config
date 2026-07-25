#!/usr/bin/env sh
# DirectoryAdded hook: append one JSONL record per new working directory to a log.
# Fires after /add-dir (source: slash_command) or SDK register_repo_root (source:
# register_repo_root). Fail-open — never blocks and always exits 0.

input=$(cat)

# jq is the only dependency; degrade to a no-op if it is absent.
command -v jq >/dev/null 2>&1 || exit 0

directory=$(printf '%s' "$input" | jq -r '.directory // empty' 2>/dev/null)
[ -n "$directory" ] || exit 0

ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

log="$HOME/.claude/state/directory-added.jsonl"
mkdir -p "$(dirname "$log")" 2>/dev/null || exit 0

# Build the record with jq so paths with quotes stay valid JSON.
printf '%s' "$input" \
  | jq -c --arg ts "$ts" '{ts: $ts, directory: .directory, source: (.source // ""), cwd: (.cwd // "")}' \
  >> "$log" 2>/dev/null

exit 0
