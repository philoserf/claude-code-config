#!/bin/bash
# Desktop notification hook - alerts when Claude needs input
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0
# Note: macOS-specific (uses osascript) - fails gracefully on other platforms

# Use macOS native notification system
osascript -e 'display notification "Claude is waiting for your input" with title "Claude Code" sound name "Glass"' 2>/dev/null || true

exit 0
