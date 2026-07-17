#!/usr/bin/env bash
# Waits for the latest run of the release workflow to finish, then prints its
# conclusion. Used by the obsidian-release-ship skill after pushing a tag, since
# macOS BSD userland has no timeout(1) to bound the poll. Filters by workflow
# file (release.yml) rather than --branch main: tag-push runs report the tag as
# their head branch, so a branch filter would grab the merge commit's CI run.
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

RUN_ID="$(gh run list --workflow release.yml --limit 1 --json databaseId --jq '.[0].databaseId')"
if [ -z "$RUN_ID" ]; then
  echo "No release.yml workflow run found — was the tag pushed? (If this repo's release workflow has a different filename, poll it manually with 'gh run list'.)" >&2
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
