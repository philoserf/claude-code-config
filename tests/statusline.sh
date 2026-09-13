#!/usr/bin/env bash
# Fixture tests for statusline-command.sh's git-status symbols.
#
# The script's header says it mirrors ~/.config/starship.toml, so the expectations
# below are starship's, measured from real repositories rather than read off its
# docs. Each case builds a throwaway repo in one state and asserts the symbol group
# the status line renders.
#
# When starship is on PATH the suite also runs it as an oracle, so a future starship
# change that moves a glyph is caught here rather than by eye. Without starship the
# recorded expectations still run -- that is why they are written out rather than
# derived.
#
# Usage: tests/statusline.sh

set -uo pipefail

SL="$HOME/.claude/statusline-command.sh"
PASS=0
FAIL=0

WORK="$(mktemp -d)"
cleanup() { cd /; rm -rf "$WORK"; }
trap cleanup EXIT

ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n         %s\n' "$1" "$2"; }

# Symbol group as the status line renders it: strip ANSI, drop dir and [branch].
symbols() { # $1 = repo dir
  printf '{"workspace":{"current_dir":"%s"},"model":{"display_name":""}}' "$1" \
    | sh "$SL" \
    | sed 's/\x1b\[[0-9;]*m//g' \
    | awk '{print $3}'
}

oracle() { # $1 = repo dir -> starship's own answer, or empty if unavailable
  command -v starship >/dev/null 2>&1 || return 0
  ( cd "$1" && starship module git_status 2>/dev/null \
      | sed 's/\x1b\[[0-9;]*m//g' | tr -d ' \n' )
}

repo() { # $1 = case name -> prints the repo path
  local d; d="$(mktemp -d "$WORK/fx.XXXXXX")"
  git -C "$d" init -q .
  git -C "$d" config user.email t@example.com
  git -C "$d" config user.name Test
  printf 'a\n' > "$d/f.txt"
  printf 'a\n' > "$d/g.txt"
  git -C "$d" add -A
  git -C "$d" commit -qm base
  printf '%s' "$d"
}

check() { # name  repo-dir  expected-symbols  [starship's answer, if it differs]
  local name="$1" d="$2" want="$3" orc_want="${4:-$3}" got orc
  got="$(symbols "$d")"
  if [ "$got" = "$want" ]; then ok "$name renders '$want'"
  else bad "$name renders '$want'" "got '$got'"; fi
  command -v starship >/dev/null 2>&1 || return 0
  orc="$(oracle "$d")"
  if [ "$orc" = "$orc_want" ]; then ok "$name matches starship"
  else bad "$name matches starship" "starship says '$orc', expected '$orc_want'"; fi
}

conflict() { # $1 = "modify" | "add" -> repo dir with an unmerged path
  local d; d="$(repo)"
  git -C "$d" branch other
  if [ "$1" = "modify" ]; then
    printf 'X\n' > "$d/f.txt"; git -C "$d" commit -qam x
    git -C "$d" checkout -q other
    printf 'Y\n' > "$d/f.txt"; git -C "$d" commit -qam y
  else
    printf 'X\n' > "$d/new.txt"; git -C "$d" add -A; git -C "$d" commit -qm x
    git -C "$d" checkout -q other
    printf 'Y\n' > "$d/new.txt"; git -C "$d" add -A; git -C "$d" commit -qm y
  fi
  git -C "$d" checkout -q -
  git -C "$d" merge --no-ff other >/dev/null 2>&1
  printf '%s' "$d"
}

echo "statusline: payload guards"

# A payload carrying neither workspace.current_dir nor cwd must not render the
# literal string jq prints for a missing key.
OUT="$(echo '{}' | sh "$SL" | sed 's/\x1b\[[0-9;]*m//g')"
case "$OUT" in
  null*) bad "empty payload does not render 'null'" "rendered: $OUT" ;;
  *)     ok  "empty payload does not render 'null'" ;;
esac

echo
echo "statusline: git status symbols"

D="$(repo)";                                          check "clean tree"      "$D" ""
D="$(repo)"; printf 'b\n' > "$D/f.txt";               check "worktree modify" "$D" "!"
D="$(repo)"; printf 'b\n' > "$D/f.txt"; git -C "$D" add f.txt
                                                      check "staged modify"   "$D" "+"
D="$(repo)"; printf 'b\n' > "$D/f.txt"; git -C "$D" add f.txt; printf 'c\n' > "$D/f.txt"
                                                      check "staged + worktree modify" "$D" "!+"
D="$(repo)"; printf 'n\n' > "$D/new.txt";             check "untracked"       "$D" "?"

# A rename is starship's own glyph, not a staged change.
D="$(repo)"; git -C "$D" mv f.txt r.txt;              check "renamed"         "$D" "»"
D="$(repo)"; git -C "$D" mv f.txt r.txt; printf 'b\n' > "$D/r.txt"
                                                      check "renamed then modified" "$D" "»!"
D="$(repo)"; git -C "$D" mv f.txt r.txt; rm "$D/r.txt"
                                                      check "renamed then deleted"  "$D" "✘»"

# The two cases the symbols missed entirely: a deletion in either column.
D="$(repo)"; rm "$D/f.txt";                           check "worktree delete" "$D" "✘"
D="$(repo)"; git -C "$D" rm -q f.txt;                 check "index delete"    "$D" "✘"
D="$(repo)"; printf 'b\n' > "$D/f.txt"; git -C "$D" add f.txt; rm "$D/f.txt"
                                                      check "staged then deleted"  "$D" "✘+"
D="$(repo)"; printf 'n\n' > "$D/new.txt"; git -C "$D" add new.txt; rm "$D/new.txt"
                                                      check "added then deleted"   "$D" "✘+"

# Unmerged paths are conflicted and nothing else -- AA used to count as staged too.
D="$(conflict modify)";                               check "both modified"   "$D" "="
D="$(conflict add)";                                  check "both added"      "$D" "="

echo
echo "statusline: ahead/behind, and the symbols before them"

# These two are the regression test for the brace bug: unbraced, `"$symbols\u21e1"`
# names the variable `symbols<0xe2>`, so the arrow does not merely render wrong --
# it discards every symbol accumulated before it.
tracked() { # -> repo dir with an upstream it is 1 commit ahead of
  local d up
  d="$(repo)"
  up="$(mktemp -d "$WORK/up.XXXXXX")"
  git -C "$up" init -q --bare
  git -C "$d" remote add origin "$up"
  git -C "$d" push -q -u origin HEAD >/dev/null 2>&1
  printf 'next\n' >> "$d/g.txt"
  git -C "$d" commit -qam ahead
  printf '%s' "$d"
}

# The script appends the commit count after the arrow; starship's default `ahead`
# symbol is the bare glyph. That divergence is deliberate, so it is recorded as the
# oracle's separate expectation rather than asserted away.
D="$(tracked)";                            check "ahead of upstream" "$D" "⇡1" "⇡"
D="$(tracked)"; printf 'b\n' > "$D/f.txt"; check "modified and ahead" "$D" "!⇡1" "!⇡"
D="$(tracked)"; printf 'n\n' > "$D/new.txt"; rm "$D/f.txt"
                                           check "deleted, untracked and ahead" "$D" "✘?⇡1" "✘?⇡"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
