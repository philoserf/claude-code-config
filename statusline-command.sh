#!/bin/sh
# Claude Code status line — mirrors ~/.config/starship.toml
# Directory (repo-relative truncation, cyan) + git branch (yellow) +
# git status (compact symbols, red) + prompt-cache health (dim) + context used
# (dim, yellow at 50%, red at 80%) + model display name without its parenthetical

input=$(cat)
# `//` only falls through on null/false, and `jq -r` prints a missing key as the
# four-character string "null" -- which would render as a directory named null.
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"
model=$(echo "$input" | jq -r '.model.display_name // empty')

trunc_len=3

# --- Directory: last N components, truncated to repo root when in a repo
repo_root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)

if [ -n "$repo_root" ]; then
  repo_name=$(basename "$repo_root")
  rel=$(git -C "$cwd" --no-optional-locks rev-parse --show-prefix 2>/dev/null)
  rel=${rel%/}
  if [ -n "$rel" ]; then
    full_path="$repo_name/$rel"
  else
    full_path="$repo_name"
  fi
else
  case "$cwd" in
    "$HOME") full_path="~" ;;
    "$HOME"/*) full_path="~/${cwd#"$HOME"/}" ;;
    *) full_path="$cwd" ;;
  esac
fi

dir=$(printf '%s' "$full_path" | awk -F/ -v n="$trunc_len" '{
  count = NF
  start = (count > n) ? count - n + 1 : 1
  out = ""
  for (i = start; i <= count; i++) out = out (out == "" ? "" : "/") $i
  print out
}')

line=$(printf '\033[1;36m%s\033[0m' "$dir")

# --- Git branch (yellow) --------------------------------------------------
if [ -n "$repo_root" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  if [ -n "$branch" ]; then
    line="$line $(printf '\033[33m[%s]\033[0m' "$branch")"
  fi

  # --- Git status: compact symbols (starship defaults), bold red ---------
  porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  # An unmerged path is its own category: starship counts it as conflicted and as
  # nothing else. Filter those lines out once and share the predicate, rather than
  # trying to encode the exclusion in each bracket -- `MD` and `AD` are a staged
  # change whose file was then deleted, so excluding on column 2 would be wrong.
  unmerged='^(DD|AU|UD|UA|DU|AA|UU)'
  conflicted=$(printf '%s\n' "$porcelain" | grep -Ec "$unmerged")
  # `D` and `R` are deliberately absent from the staged bracket: starship gives an
  # index deletion the deleted glyph and a rename the renamed glyph, neither of them
  # staged. A `D` in either column is a deletion.
  staged=$(printf '%s\n' "$porcelain" | grep -Ev "$unmerged" | grep -c '^[MAC]')
  deleted=$(printf '%s\n' "$porcelain" | grep -Ev "$unmerged" | grep -Ec '^(D.|.D)')
  renamed=$(printf '%s\n' "$porcelain" | grep -Ev "$unmerged" | grep -c '^R')
  modified=$(printf '%s\n' "$porcelain" | grep -c '^.[MT]')
  untracked=$(printf '%s\n' "$porcelain" | grep -c '^??')
  stashed=$(git -C "$cwd" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')

  ahead=0
  behind=0
  upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
    ahead=$(printf '%s' "$counts" | awk '{print $1+0}')
    behind=$(printf '%s' "$counts" | awk '{print $2+0}')
  fi

  # Braces are load-bearing on every one of these. In a multibyte locale bash reads
  # `"$symbols⇡"` as the variable `symbols<0xe2>` -- the glyph's first byte is taken
  # as part of the name -- which expands to nothing and discards every symbol
  # accumulated so far, leaving two stray bytes. `${symbols}` ends the name
  # explicitly. Starship's order: conflicted, stashed, deleted, renamed, modified, staged,
  # untracked, ahead, behind.
  symbols=""
  [ "$conflicted" -gt 0 ] && symbols="${symbols}="
  [ "$stashed" -gt 0 ] && symbols="${symbols}\$"
  [ "$deleted" -gt 0 ] && symbols="${symbols}✘"
  [ "$renamed" -gt 0 ] && symbols="${symbols}»"
  [ "$modified" -gt 0 ] && symbols="${symbols}!"
  [ "$staged" -gt 0 ] && symbols="${symbols}+"
  [ "$untracked" -gt 0 ] && symbols="${symbols}?"
  [ "$ahead" -gt 0 ] && symbols="${symbols}⇡${ahead}"
  [ "$behind" -gt 0 ] && symbols="${symbols}⇣${behind}"

  if [ -n "$symbols" ]; then
    line="$line $(printf '\033[1;31m%s\033[0m' "$symbols")"
  fi
fi

# --- Prompt cache: hit ratio, warm/cold, last miss cause -------------------
cache=$(printf '%s' "$input" | jq -r '
  .prompt_cache // empty
  | select(.caching_observed == true and .hit_ratio != null)
  | [ (.hit_ratio * 100 | round),
      (if .warm then "warm" else "cold" end),
      (.misses // 0),
      ((.last_miss_cause.causes // [])
        | map(sub("^likely_"; "") | gsub("_"; " ")) | join("/"))
    ] | @tsv')

if [ -n "$cache" ]; then
  pct=$(printf '%s' "$cache" | cut -f1)
  warm=$(printf '%s' "$cache" | cut -f2)
  misses=$(printf '%s' "$cache" | cut -f3)
  cause=$(printf '%s' "$cache" | cut -f4)

  if [ "$warm" = "warm" ]; then
    glyph="⚡"
  else
    glyph="❄"
  fi
  line="$line $(printf '\033[2m%s%s%%\033[0m' "$glyph" "$pct")"

  if [ "$misses" -gt 0 ]; then
    if [ -n "$cause" ]; then
      miss="✗$misses $cause"
    else
      miss="✗$misses"
    fi
    line="$line $(printf '\033[35m%s\033[0m' "$miss")"
  fi
fi

# --- Context window: share used and window size, colored as it fills -------
ctx=$(printf '%s' "$input" | jq -r '
  .context_window // empty
  | select(.used_percentage != null)
  | [ (.used_percentage | floor), (.context_window_size // 0) ] | @tsv')

if [ -n "$ctx" ]; then
  used=$(printf '%s' "$ctx" | cut -f1)
  size=$(printf '%s' "$ctx" | cut -f2 | awk '{
    if ($1 >= 1000000) printf "%gM", $1 / 1000000
    else if ($1 >= 1000) printf "%gk", $1 / 1000
  }')
  if [ "$used" -ge 80 ]; then
    color='31'
  elif [ "$used" -ge 50 ]; then
    color='33'
  else
    color='2'
  fi
  label="${used}%"
  [ -n "$size" ] && label="${label} of ${size}"
  line="$line $(printf '\033[%sm%s\033[0m' "$color" "$label")"
fi

# The window size now sits in the context segment, so drop the model's
# parenthetical: "Opus 5.5 (1M context)" -> "Opus 5.5".
model=${model% (*)}

printf '%s  %s' "$line" "$model"
