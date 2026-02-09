#!/usr/bin/env bash
# Claude Code statusline — reads JSON from stdin, outputs colored single-line status
set -euo pipefail

# Colors (ANSI)
CYAN='\033[36m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'
RESET='\033[0m'
SEP=" │ "

# Read JSON from stdin
INPUT=$(cat)

# Extract fields via jq
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
MODEL=$(echo "$INPUT" | jq -r '.model // empty')
CONTEXT_USED=$(echo "$INPUT" | jq -r '.context.used // 0')
CONTEXT_TOTAL=$(echo "$INPUT" | jq -r '.context.total // 1')
OUTPUT_STYLE=$(echo "$INPUT" | jq -r 'if .output_style | type == "object" then .output_style.name else .output_style end // "default"')

# Shorten home directory
SHORT_CWD="${CWD/#$HOME/~}"

# Model display name
case "$MODEL" in
  *opus*) MODEL_NAME="Opus" ;;
  *sonnet*) MODEL_NAME="Sonnet" ;;
  *haiku*) MODEL_NAME="Haiku" ;;
  *) MODEL_NAME="${MODEL:-unknown}" ;;
esac

# Context remaining percentage
if [ "$CONTEXT_TOTAL" -gt 0 ] 2>/dev/null; then
  CTX_REMAINING=$(( (CONTEXT_TOTAL - CONTEXT_USED) * 100 / CONTEXT_TOTAL ))
else
  CTX_REMAINING=100
fi

if [ "$CTX_REMAINING" -gt 50 ]; then
  CTX_COLOR="$GREEN"
elif [ "$CTX_REMAINING" -ge 20 ]; then
  CTX_COLOR="$YELLOW"
else
  CTX_COLOR="$RED"
fi

# Output style segment (hidden when "default")
STYLE_SEGMENT=""
if [ -n "$OUTPUT_STYLE" ] && [ "$OUTPUT_STYLE" != "default" ]; then
  STYLE_SEGMENT="${SEP}${MAGENTA}${OUTPUT_STYLE}${RESET}"
fi

# Compose status line
printf "%b%s%b%s%b%s%b%s%bctx:%d%%%b%b" \
  "$CYAN" "$SHORT_CWD" "$RESET" \
  "$SEP" \
  "$BLUE" "$MODEL_NAME" "$RESET" \
  "$SEP" \
  "$CTX_COLOR" "$CTX_REMAINING" "$RESET" \
  "$STYLE_SEGMENT"
