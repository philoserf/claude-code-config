#!/usr/bin/env bash
# Runs the repo's local gate, opens a pull request, and merges it.
# The mechanical half of the issue-pr skill; the judgment half stays in SKILL.md.
#
# The local gate is the check. GitHub is a git remote with PRs and issues; no
# status check is required or waited on.
#
# Exit codes:
#   0  the requested subcommand succeeded
#   3  the gate failed, or left the tree dirty. Nothing was pushed or merged.
#   1  anything else (bad usage, git/gh failure, dirty tree, refusal)
#
# Usage:
#   pr-cycle.sh start  <branch>
#   pr-cycle.sh gate   <gate-command>
#   pr-cycle.sh open   <branch> <title> <body-file>
#   pr-cycle.sh merge  <pr-number>
#   pr-cycle.sh ship   <branch> <title> <body-file> <gate-command>   # gate + open + merge
#
# Environment:
#   PR_BASE           base branch (default: origin's HEAD branch)
#   GH_REPO           repo for every gh call (default: origin's owner/name)
#
# The gate runs on a clean tree and must leave it clean. A dirty tree before it
# means the gate tests work that will not be pushed; a dirty tree after it means
# a formatter rewrote files the PR would ship without.

set -uo pipefail

die() { echo "pr-cycle: $*" >&2; exit 1; }

# gh picks its repo itself, and where GitHub still classifies a repo as a fork it can
# pick the parent: its default branch, its merge settings, the repo `pr create` opens
# on. Pin every gh call to origin, unless the caller already chose with GH_REPO.
origin_repo() {
  local url
  url="$(git remote get-url origin 2>/dev/null)" || return 1
  url="${url%.git}"
  case "$url" in
    *github.com[:/]*) echo "${url#*github.com[:/]}" ;;
    *) return 1 ;;
  esac
}
if [ -z "${GH_REPO:-}" ] && repo="$(origin_repo)"; then export GH_REPO="$repo"; fi

default_branch() {
  local head
  if [ -n "${PR_BASE:-}" ]; then echo "$PR_BASE"; return; fi
  if head="$(git symbolic-ref --short -q refs/remotes/origin/HEAD)"; then echo "${head#origin/}"; return; fi
  gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null || echo main
}

# The repo decides how PRs land. Hard-coding --squash silently fails on a repo
# that disallows it, and picking merge-commit where squash is the convention
# rewrites the history style the CHANGELOG is drafted from.
merge_flag() {
  gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed \
    --jq '[(if .squashMergeAllowed then "--squash" else empty end),
           (if .mergeCommitAllowed then "--merge" else empty end),
           (if .rebaseMergeAllowed then "--rebase" else empty end)] | .[0] // "--squash"' 2>/dev/null \
    || echo "--squash"
}

# A linked worktree cannot check out the base branch while the main checkout has it,
# so there the base is used as origin's ref and the local base branch is left alone.
in_linked_worktree() {
  [ "$(git rev-parse --path-format=absolute --git-dir)" != "$(git rev-parse --path-format=absolute --git-common-dir)" ]
}

cmd_start() {
  local branch="${1:?branch required}" base
  base="$(default_branch)"
  [ -z "$(git status --porcelain)" ] || die "working tree is dirty; commit or stash first"
  if in_linked_worktree; then
    git fetch -q origin "$base" || die "cannot fetch $base"
    git checkout --no-track -b "$branch" "origin/$base" >/dev/null 2>&1 || die "cannot create branch $branch"
    echo "on $branch from $(git rev-parse --short HEAD) (base origin/$base, worktree)"
    return
  fi
  git checkout "$base" >/dev/null 2>&1 || die "cannot checkout $base"
  git pull --ff-only origin "$base" >/dev/null 2>&1 || die "cannot fast-forward $base"
  git checkout -b "$branch" >/dev/null 2>&1 || die "cannot create branch $branch"
  echo "on $branch from $(git rev-parse --short HEAD) (base $base)"
}

cmd_gate() {
  local gate="${1:?gate command required}"
  [ -z "$(git status --porcelain)" ] || die "working tree is dirty; commit first, so the gate tests what ships"
  bash -c "$gate" || { echo "gate failed: $gate" >&2; return 3; }
  if [ -n "$(git status --porcelain)" ]; then
    git status --short >&2
    echo "gate left the tree dirty; commit and re-run" >&2
    return 3
  fi
  echo "gate passed: $gate"
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

cmd_merge() {
  local pr="${1:?pr number required}" base flag branch
  base="$(default_branch)"
  flag="$(merge_flag)"
  branch="$(gh pr view "$pr" --json headRefName --jq .headRefName)" || die "cannot read #$pr"
  # Branches are deleted here, not by `gh pr merge --delete-branch`: with GIT_DIR and
  # GIT_WORK_TREE set (the dotfiles' bare repo), gh deleted the checked-out branch
  # without switching away first, leaving HEAD on a ref that no longer existed.
  gh pr merge "$pr" "$flag" || die "gh pr merge failed"
  if in_linked_worktree; then
    # Detach at origin's base so the branch can be deleted; the worktree is the
    # caller's to remove, and the main checkout's base is the caller's to pull.
    git fetch -q origin "$base" || die "cannot fetch $base"
    git checkout -q --detach "origin/$base" || die "cannot detach at origin/$base"
  else
    git checkout "$base" >/dev/null 2>&1 || die "cannot checkout $base"
    git pull --ff-only origin "$base" >/dev/null 2>&1 || die "cannot fast-forward $base"
  fi
  # -D: a squash or rebase merge leaves the branch unmerged as far as git can tell.
  git branch -D "$branch" >/dev/null 2>&1 || echo "pr-cycle: local branch $branch not deleted" >&2
  # The remote branch may already be gone where the repo auto-deletes head branches.
  git push -q origin --delete "$branch" >/dev/null 2>&1 || :
  echo "merged #$pr ($flag); $base now $(git rev-parse --short HEAD)"
}

cmd_ship() {
  local branch="${1:?}" title="${2:?}" body="${3:?}" gate="${4:?gate command required}" url pr rc
  cmd_gate "$gate"; rc=$?
  [ "$rc" -eq 0 ] || exit "$rc"
  url="$(cmd_open "$branch" "$title" "$body")" || exit 1
  echo "$url"
  pr="${url##*/}"
  cmd_merge "$pr"
}

case "${1:-}" in
  start) shift; cmd_start "$@" ;;
  gate)  shift; cmd_gate  "$@" ;;
  open)  shift; cmd_open  "$@" ;;
  merge) shift; cmd_merge "$@" ;;
  ship)  shift; cmd_ship  "$@" ;;
  *) sed -n '2,25p' "$0" >&2; exit 1 ;;
esac
