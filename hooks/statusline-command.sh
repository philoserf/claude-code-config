#!/usr/bin/env bash
# statusline-command.sh — Claude Code status line mirroring Starship prompt
# Shows: directory (repo-relative, truncated) | git branch | git status | model | context %

input=$(cat)

cwd=$(echo "$input" | jq -r '(.workspace.current_dir // .cwd)')
model=$(echo "$input" | jq -r '(.model.display_name // "")')
remaining=$(echo "$input" | jq -r '(.context_window.remaining_percentage // "")')

# --- Directory (truncated to 3 segments, repo-relative when in a git repo) ---
git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$git_root" ]; then
  rel="${cwd#"$git_root"/}"
  # If cwd IS the root, use the root basename
  [ "$rel" = "$cwd" ] && rel=$(basename "$git_root")
  dir_display="$rel"
else
  # Truncate to last 3 path segments
  dir_display=$(echo "$cwd" | awk -F'/' '{
    n=NF; if(n>3){printf "…"; for(i=n-2;i<=n;i++) printf "/" $i} else print $0
  }')
fi

# --- Git branch ---
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# --- Git status symbols (compact, matching Starship git_status defaults) ---
git_sym=""
if [ -n "$branch" ]; then
  status_output=$(git -C "$cwd" status --porcelain=v1 2>/dev/null)
  ahead_behind=$(git -C "$cwd" rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null)

  [[ $status_output == *"??"* ]] && git_sym+="?"
  [[ $status_output =~ ^.[^\ ] ]] && git_sym+="!"
  [[ $status_output =~ ^[MADRCU] ]] && git_sym+="+"
  if [ -n "$ahead_behind" ]; then
    behind=$(echo "$ahead_behind" | awk '{print $1}')
    ahead=$(echo "$ahead_behind" | awk '{print $2}')
    [ "$behind" -gt 0 ] 2>/dev/null && git_sym+="⇣"
    [ "$ahead" -gt 0 ] 2>/dev/null && git_sym+="⇡"
  fi
fi

# --- Assemble ---
parts=()
parts+=("$dir_display")
[ -n "$branch" ] && parts+=("$branch${git_sym:+ $git_sym}")
[ -n "$model" ] && parts+=("${model%% *}")
[ -n "$remaining" ] && parts+=("${remaining}%")

result=""
for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && result+=" · "
  result+="${parts[$i]}"
done
printf '%s' "$result"
