#!/bin/bash
# SessionEnd cleanup - delete logs and session data older than 7 days
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

log_dir=~/.claude/logs

# Remove session log directories older than 7 days
find "$log_dir" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true

# Remove legacy flat log files from before session-scoped logging
rm -f "$log_dir/hook-events.log" "$log_dir/hook-events.log.1" "$log_dir/git-commands.log" "$log_dir/git-commands.log.1" 2>/dev/null || true

# Remove debug files older than 7 days
find ~/.claude/debug -name "*.txt" -mtime +7 -delete 2>/dev/null || true

# Remove stale shell snapshots older than 7 days
find ~/.claude/shell-snapshots -type f -mtime +7 -delete 2>/dev/null || true

exit 0
