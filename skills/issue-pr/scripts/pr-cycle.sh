#!/usr/bin/env bash
# Opens a pull request, waits for CI to REGISTER and then pass, and merges it.
# The mechanical half of the issue-pr skill; the judgment half stays in SKILL.md.
#
# Exit codes:
#   0  the requested subcommand succeeded
#   2  no check ever registered within the timeout — CI may not be wired to this
#      branch. Nothing was merged.
#   3  checks registered and FAILED. Nothing was merged.
#   4  checks are still pending at the deadline. Nothing was merged.
#   1  anything else (bad usage, git/gh failure, dirty tree, refusal)
#
# Usage:
#   pr-cycle.sh start  <branch>
#   pr-cycle.sh open   <branch> <title> <body-file>
#   pr-cycle.sh wait   <pr-number>
#   pr-cycle.sh merge  <pr-number>
#   pr-cycle.sh ship   <branch> <title> <body-file>      # open + wait + merge
#
# Environment:
#   PR_WAIT_REGISTER  seconds to wait for the first check row (default 300)
#   PR_WAIT_CHECKS    seconds to wait for checks to conclude  (default 1800)
#   PR_POLL           seconds between polls                   (default 10)
#   PR_BASE           base branch (default: the repo's default branch)
#
# Why a bespoke wait instead of `gh pr checks --watch` alone:
#
#   `gh pr checks` exits 1 both for "no checks reported" and for a real failure,
#   so the exit code cannot tell "CI has not started" from "CI said no". A PR
#   created seconds ago normally has zero check rows, so watching immediately
#   reports a green PR that CI never looked at. This script therefore blocks
#   until the row COUNT is a positive integer before it watches anything.
#
#   The count is tested numerically. `grep -qvx 0` is the tempting spelling and
#   is not safe, because which `grep` answers depends on where the line runs:
#
#     /usr/bin/grep (BSD 2.6.0-FreeBSD)  empty input, -qvx 0  -> exit 1
#     ugrep 7.8.4                        empty input, -qvx 0  -> exit 0
#
#   A script gets the first; an interactive shell, or anything typed at a shell
#   where ugrep shadows grep, gets the second — and there a transient API error
#   returning nothing reads as "checks registered" and falls straight through to
#   a merge. The numeric test is correct under both, which is the point: this
#   guard is the last thing standing between an API hiccup and an unchecked
#   merge, so it must not depend on which grep is on PATH.

set -uo pipefail

PR_WAIT_REGISTER="${PR_WAIT_REGISTER:-300}"
PR_WAIT_CHECKS="${PR_WAIT_CHECKS:-1800}"
PR_POLL="${PR_POLL:-10}"

die() { echo "pr-cycle: $*" >&2; exit 1; }

default_branch() {
  if [ -n "${PR_BASE:-}" ]; then echo "$PR_BASE"; return; fi
  gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null || echo main
}

# The repo decides how PRs land. Hard-coding --squash silently fails on a repo
# that disallows it, and picking merge-commit where squash is the convention
# rewrites the history style the CHANGELOG is drafted from.
merge_flag() {
  local m
  m="$(gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed \
        --jq '[(if .squashMergeAllowed then "squash" else empty end),
               (if .mergeCommitAllowed then "merge" else empty end),
               (if .rebaseMergeAllowed then "rebase" else empty end)] | .[0] // ""' 2>/dev/null)"
  case "$m" in
    squash) echo "--squash" ;;
    merge)  echo "--merge" ;;
    rebase) echo "--rebase" ;;
    *)      echo "--squash" ;;
  esac
}

cmd_start() {
  local branch="${1:?branch required}" base
  base="$(default_branch)"
  [ -z "$(git status --porcelain)" ] || die "working tree is dirty; commit or stash first"
  git checkout "$base" >/dev/null 2>&1 || die "cannot checkout $base"
  git pull --ff-only origin "$base" >/dev/null 2>&1 || die "cannot fast-forward $base"
  git checkout -b "$branch" >/dev/null 2>&1 || die "cannot create branch $branch"
  echo "on $branch from $(git rev-parse --short HEAD) (base $base)"
}

cmd_open() {
  local branch="${1:?branch required}" title="${2:?title required}" body="${3:?body-file required}" base url
  [ -f "$body" ] || die "body file not found: $body"
  base="$(default_branch)"
  git push -u origin "$branch" >/dev/null 2>&1 || die "cannot push $branch"
  url="$(gh pr create --base "$base" --head "$branch" --title "$title" --body-file "$body")" \
    || die "gh pr create failed"
  echo "$url"
}

# Blocks until at least one check row exists, then until every row concludes.
cmd_wait() {
  local pr="${1:?pr number required}" waited=0 n

  while :; do
    n="$(gh pr checks "$pr" --json name --jq 'length' 2>/dev/null)"
    case "${n:-}" in
      ''|*[!0-9]*) n=0 ;;
    esac
    [ "$n" -gt 0 ] && break
    if [ "$waited" -ge "$PR_WAIT_REGISTER" ]; then
      echo "no check registered on #$pr after ${PR_WAIT_REGISTER}s" >&2
      return 2
    fi
    sleep "$PR_POLL"; waited=$((waited + PR_POLL))
  done
  echo "checks registered on #$pr: $n row(s) after ${waited}s"

  local deadline=$((SECONDS + PR_WAIT_CHECKS)) pending failed
  while :; do
    pending="$(gh pr checks "$pr" --json bucket --jq '[.[] | select(.bucket=="pending")] | length' 2>/dev/null)"
    failed="$(gh pr checks "$pr" --json bucket --jq '[.[] | select(.bucket=="fail")] | length' 2>/dev/null)"
    case "${pending:-}" in ''|*[!0-9]*) pending=1 ;; esac
    case "${failed:-}"  in ''|*[!0-9]*) failed=0  ;; esac

    if [ "$failed" -gt 0 ]; then
      gh pr checks "$pr" >&2 || true
      echo "checks FAILED on #$pr" >&2
      return 3
    fi
    [ "$pending" -eq 0 ] && break
    if [ "$SECONDS" -ge "$deadline" ]; then
      echo "checks still pending on #$pr after ${PR_WAIT_CHECKS}s" >&2
      return 4
    fi
    sleep "$PR_POLL"
  done

  gh pr checks "$pr" || true
  echo "checks green on #$pr"
}

cmd_merge() {
  local pr="${1:?pr number required}" base flag n
  base="$(default_branch)"

  # Refuse to merge a PR that has no checks. Reaching merge with an empty list
  # means the wait was skipped, and a green-looking merge is the worst outcome.
  n="$(gh pr checks "$pr" --json name --jq 'length' 2>/dev/null)"
  case "${n:-}" in ''|*[!0-9]*) n=0 ;; esac
  [ "$n" -gt 0 ] || die "#$pr has no checks registered; refusing to merge"

  flag="$(merge_flag)"
  gh pr merge "$pr" "$flag" --delete-branch || die "gh pr merge failed"
  git checkout "$base" >/dev/null 2>&1 || die "cannot checkout $base"
  git pull --ff-only origin "$base" >/dev/null 2>&1 || die "cannot fast-forward $base"
  echo "merged #$pr ($flag); $base now $(git rev-parse --short HEAD)"
}

cmd_ship() {
  local branch="${1:?}" title="${2:?}" body="${3:?}" url pr rc
  url="$(cmd_open "$branch" "$title" "$body")" || exit 1
  echo "$url"
  pr="${url##*/}"
  cmd_wait "$pr"; rc=$?
  [ "$rc" -eq 0 ] || exit "$rc"
  cmd_merge "$pr"
}

case "${1:-}" in
  start) shift; cmd_start "$@" ;;
  open)  shift; cmd_open  "$@" ;;
  wait)  shift; cmd_wait  "$@" ;;
  merge) shift; cmd_merge "$@" ;;
  ship)  shift; cmd_ship  "$@" ;;
  *) sed -n '2,30p' "$0" >&2; exit 1 ;;
esac
