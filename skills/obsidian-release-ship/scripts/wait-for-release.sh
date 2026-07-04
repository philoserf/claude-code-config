#!/usr/bin/env bash
# Waits for the latest GitHub Actions run on main to finish, then prints its
# conclusion. Used by the obsidian-release-ship skill after pushing a tag, since
# macOS BSD userland has no timeout(1) to bound the poll.
#
# Usage: ~/.claude/skills/obsidian-release-ship/scripts/wait-for-release.sh [MAX_SECONDS] [INTERVAL_SECONDS]
#   MAX_SECONDS      total time to wait before giving up (default 600)
#   INTERVAL_SECONDS delay between polls (default 15)
#
# Prints the run's conclusion (e.g. "success", "failure") to stdout on completion.
# Exit 0: run completed (check the printed conclusion — "success" means shipped).
# Exit 1: timed out or no run found; the caller should stop and investigate.

set -uo pipefail

MAX="${1:-600}"
INTERVAL="${2:-15}"

RUN_ID="$(gh run list --branch main --limit 1 --json databaseId --jq '.[0].databaseId')"
if [ -z "$RUN_ID" ]; then
  echo "No workflow run found on main — was the tag pushed?" >&2
  exit 1
fi

ELAPSED=0
STATUS=""
while [ "$ELAPSED" -lt "$MAX" ]; do
  STATUS="$(gh run view "$RUN_ID" --json status --jq '.status')"
  [ "$STATUS" = "completed" ] && break
  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))
done

if [ "$STATUS" != "completed" ]; then
  echo "CI still running after ${MAX}s — check 'gh run view $RUN_ID' or wait longer before retrying this phase." >&2
  exit 1
fi

gh run view "$RUN_ID" --json conclusion --jq '.conclusion'
