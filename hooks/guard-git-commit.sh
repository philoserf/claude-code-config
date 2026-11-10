#!/usr/bin/env bash
# PreToolUse hook (Bash): refuse two `git commit` shapes that prose rules failed to stop.
#
#   1. A commit on the default branch of a repo under ~/source. Those repos ship through
#      `pr-cycle start` branches (~/source/CLAUDE.md). The vault, dotfiles and ~/.claude
#      commit to main by design, so a repo outside ~/source passes.
#   2. A commit chained after a check (`task`, `go test`) by `;` or a newline, which runs
#      the commit whether or not the check passed. `&&` makes the commit wait on it.
#
# Exit 2 blocks the call and feeds stderr to the model. Fail-open: missing jq, an
# unparsable payload, or a directory git cannot read lets the call through.

payload=$(cat)
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
cwd=$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# Everything before the first `git commit` is what decides both rules.
before=${cmd%%git commit*}

# Rule 2: a check before the commit, and a `;` or newline after the check.
check=$(printf '%s' "$before" | grep -oE '(^|[;&|(]|\$\()[[:space:]]*(task|go test)([[:space:];&|]|$).*' | tail -1)
if [ -n "$check" ]; then
  after_check=${before#*"$check"}
  # Look at what follows the last check up to the commit, `&&` removed.
  rest="${check}${after_check}"
  # Parameter expansion, not $( ): a command substitution would drop the
  # trailing newline that is the separator this rule looks for.
  stripped=${rest//&&/}
  case "$stripped" in
    *";"* | *$'\n'*)
      echo "Blocked: this commit runs whether or not the check before it passed (a ';' or a newline separates them). Run the gate, read its result, then commit, or join them with &&." >&2
      exit 2
      ;;
  esac
fi

# Rule 1: the directory the commit runs in, after any `cd` before it.
dir=$cwd
target=$(printf '%s' "$before" | grep -oE '(^|[;&|(])[[:space:]]*cd[[:space:]]+[^[:space:];&|)]+' | tail -1 | sed -E 's/.*cd[[:space:]]+//')
if [ -n "$target" ]; then
  target=${target/#\~/$HOME}
  target=${target%\"}
  target=${target#\"}
  case "$target" in
    /*) dir=$target ;;
    *) dir="$cwd/$target" ;;
  esac
fi
[ -z "$dir" ] && exit 0

top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
case "$top" in
  "$HOME"/source/*) ;;
  *) exit 0 ;;
esac

branch=$(git -C "$top" symbolic-ref --short HEAD 2>/dev/null) || exit 0
default=$(git -C "$top" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
default=${default#origin/}
[ -z "$default" ] && default=main

if [ "$branch" = "$default" ]; then
  echo "Blocked: a commit on $default in $top. Repos under ~/source ship through a branch: ~/.claude/bin/pr-cycle start <branch>, then commit there." >&2
  exit 2
fi

exit 0
