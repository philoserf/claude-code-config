#!/usr/bin/env bash
# shellcheck disable=SC2016  # backticks in single quotes are literal Markdown, on purpose
# Is every quoted snippet in a walkthrough still in the code? The release gate's
# check 8, runnable on its own so a walkthrough pass can check its snippets
# without the other fourteen rows.
#
# A snippet labelled `path` — `symbol` (the form code-walkthrough writes) must
# appear verbatim in that file. A line that is only `...` marks an elided
# middle, as the skill allows (also as a comment, `// ... more ...`); each part
# on either side must then appear verbatim. Whitespace is ignored on both
# sides: a body quoted flush-left, or a line a markdown formatter re-wrapped,
# still matches. Any other change to the quoted text does not. This asks about
# content, never about history: a commit after the walkthrough that leaves its
# snippets intact cannot fail it, and an edit to quoted code fails it however
# recently the document was touched. It does not read the prose; nothing does.
#
# Paths in labels are relative to the repo root, so it runs from there.
#
# Usage: check-snippets.sh WALKTHROUGH
#   Prints each snippet not found, under the path it names, then one summary
#   line: "N snippets match" or "M of N not found".
#
# Exit codes:
#   0  every labelled snippet matches
#   1  one or more not found, or bad usage
#   4  no labelled snippets

set -uo pipefail

walkthrough="${1:?usage: check-snippets.sh WALKTHROUGH}"
[ -f "$walkthrough" ] || { echo "check-snippets: no such file: $walkthrough" >&2; exit 1; }
walkthrough="$(cd "$(dirname "$walkthrough")" && pwd)/$(basename "$walkthrough")"
if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then cd "$root" || exit 1; fi

label_re='^`([^`]+)` — `[^`]+`$'
# `...` alone, or after a comment marker: `// ... five more checks ...`.
elision_re='^[[:space:]]*(\.\.\.|(//|#|--|/?\*)[[:space:]]*\.\.\..*)[[:space:]]*$'
total=0
misses=0
snip_path=""
in_block=0
snippet=""
pieces=()
while IFS= read -r line || [ -n "$line" ]; do
  if [ "$in_block" = "1" ]; then
    if [ "$line" = '```' ]; then
      in_block=0
      total=$((total + 1))
      pieces+=("$snippet")
      ok=0
      if [ -f "$snip_path" ]; then
        source="$(tr -d '[:space:]' <"$snip_path")"
        ok=1
        for piece in "${pieces[@]}"; do
          piece="${piece//[[:space:]]/}"
          [[ "$source" == *"$piece"* ]] || ok=0
        done
      fi
      if [ "$ok" = "0" ]; then
        misses=$((misses + 1))
        printf '%s\n' "not found in $snip_path:" "${pieces[@]}" ""
      fi
      snip_path=""
    elif [[ "$line" =~ $elision_re ]]; then
      pieces+=("$snippet")
      snippet=""
    else
      snippet="${snippet:+$snippet$'\n'}$line"
    fi
  elif [[ "$line" =~ $label_re ]]; then
    snip_path="${BASH_REMATCH[1]}"
  elif [ -n "$snip_path" ] && [[ "$line" == '```'* ]]; then
    in_block=1
    snippet=""
    pieces=()
  elif [ -n "$line" ]; then
    # Only a fence directly under its label (blank lines aside) is checked.
    snip_path=""
  fi
done <"$walkthrough"

if [ "$total" -eq 0 ]; then
  echo "no labelled snippets"
  exit 4
elif [ "$misses" -eq 0 ]; then
  [ "$total" -eq 1 ] && echo "1 snippet matches" || echo "$total snippets match"
else
  echo "$misses of $total not found"
  exit 1
fi
