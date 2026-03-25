#!/bin/bash
# Session context loading hook - injects recent git activity and issues
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

if [ ! -d .git ]; then
  exit 0
fi

if command -v gh &>/dev/null && git remote get-url origin 2>/dev/null | grep -q github.com; then
  echo "### Open GitHub Issues"
  gh issue list --state open --limit 25 2>/dev/null || echo "No open issues"
  echo ""
fi

exit 0
