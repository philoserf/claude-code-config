#!/usr/bin/env bash
# Waits for the release-workflow run belonging to a specific tag to finish, then
# prints its conclusion. Used by the obsidian-ship skill after pushing a
# tag, since macOS BSD userland has no timeout(1) to bound the poll.
#
# Usage: wait-for-release.sh <TAG> [MAX_SECONDS] [INTERVAL_SECONDS]
#   TAG              the tag just pushed (e.g. 2.4.0) — required
#   MAX_SECONDS      total time to wait before giving up (default 600)
#   INTERVAL_SECONDS delay between polls (default 15)
#
# Prints the run's conclusion (e.g. "success", "failure") to stdout on completion.
# Exit 0: run completed (check the printed conclusion — "success" means shipped).
# Exit 1: timed out, or no run for this tag appeared; stop and investigate.
#
# Why the tag is required rather than "the latest release.yml run":
#
#   There is a gap of several seconds between `git push origin <tag>` and the
#   run appearing in the API. Land in that gap while polling for the *latest*
#   run and you get the PREVIOUS release's run — already completed/success — so
#   the script reports success for a release that never started. Tag-push runs
#   report the tag as their headBranch, so filtering on it is exact.

set -uo pipefail

TAG="${1:-}"
if [ -z "$TAG" ]; then
  echo "Usage: wait-for-release.sh <TAG> [MAX_SECONDS] [INTERVAL_SECONDS]" >&2
  echo "The tag is required — without it this cannot tell a new run from the previous release's." >&2
  exit 1
fi
MAX="${2:-600}"
INTERVAL="${3:-15}"

# Note: gh's own --jq does not accept --arg, so the tag is passed to a real jq
# on the other side of a pipe. Using gh --jq here silently matches nothing.
find_run() {
  gh run list --workflow release.yml --limit 20 --json databaseId,headBranch 2>/dev/null \
    | jq -r --arg t "$TAG" '[.[] | select(.headBranch == $t)][0].databaseId // empty'
}

# Phase 1: wait for the run to exist.
ELAPSED=0
RUN_ID="$(find_run)"
while [ -z "$RUN_ID" ] && [ "$ELAPSED" -lt "$MAX" ]; do
  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))
  RUN_ID="$(find_run)"
done

if [ -z "$RUN_ID" ]; then
  echo "No release.yml run for tag '$TAG' after ${MAX}s." >&2
  echo "Was the tag pushed? Does release.yml trigger on tag push? If this repo's" >&2
  echo "release workflow has a different filename, poll it manually with 'gh run list'." >&2
  exit 1
fi

# Phase 2: wait for that specific run to finish.
STATUS=""
while [ "$ELAPSED" -lt "$MAX" ]; do
  STATUS="$(gh run view "$RUN_ID" --json status --jq '.status')"
  [ "$STATUS" = "completed" ] && break
  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))
done

if [ "$STATUS" != "completed" ]; then
  echo "Release run $RUN_ID for '$TAG' still going after ${MAX}s — check 'gh run view $RUN_ID'." >&2
  exit 1
fi

gh run view "$RUN_ID" --json conclusion --jq '.conclusion'
