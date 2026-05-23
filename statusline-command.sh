#!/bin/sh
# Claude Code status line — derived from ~/.zshrc PS1 fallback
# Bold blue basename of cwd, plus model display name
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name')
printf '\033[1;34m%s\033[0m  %s' "$dir" "$model"
