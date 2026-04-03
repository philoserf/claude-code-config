#!/bin/bash
# Warn when the current branch hasn't been committed to in 3+ days
# or is significantly behind origin/main.
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

if [ ! -d .git ]; then
	exit 0
fi

branch=$(git branch --show-current 2>/dev/null) || exit 0

# Skip main/master — no staleness concept
case "$branch" in
main | master) exit 0 ;;
esac

# Skip detached HEAD
if [ -z "$branch" ]; then
	exit 0
fi

STALE_DAYS=3
warnings=""

# Check days since last commit on this branch
last_commit_epoch=$(git log -1 --format=%ct "$branch" 2>/dev/null) || exit 0
now_epoch=$(date +%s)
days_old=$(((now_epoch - last_commit_epoch) / 86400))

if [ "$days_old" -ge "$STALE_DAYS" ]; then
	warnings="Branch '$branch' last committed ${days_old} days ago"
fi

# Check how far behind origin/main
git fetch origin main --quiet 2>/dev/null
behind=$(git rev-list --count "$branch..origin/main" 2>/dev/null) || behind=0

if [ "$behind" -gt 0 ]; then
	behind_msg="${behind} commits behind origin/main"
	if [ -n "$warnings" ]; then
		warnings="${warnings}, ${behind_msg}"
	else
		warnings="Branch '$branch' is ${behind_msg}"
	fi
fi

if [ -n "$warnings" ]; then
	echo "STALE BRANCH WARNING: ${warnings} — consider syncing or starting fresh"
fi

exit 0
