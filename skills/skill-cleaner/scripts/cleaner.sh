#!/usr/bin/env zsh
set -euo pipefail

SKILLS_ROOT="${SKILLS_ROOT:-$HOME/.claude/skills}"
TRANSCRIPTS_ROOT="${TRANSCRIPTS_ROOT:-$HOME/.claude/projects}"
LOOKBACK_DAYS="${LOOKBACK_DAYS:-60}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) LOOKBACK_DAYS="$2"; shift 2 ;;
    --root) SKILLS_ROOT="$2"; shift 2 ;;
    --transcripts) TRANSCRIPTS_ROOT="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
usage: cleaner.sh [--days N] [--root DIR] [--transcripts DIR]

Audits ~/.claude/skills/ for unused entries, duplicate names, missing
descriptions, and long descriptions. Reads .jsonl transcripts under
~/.claude/projects/ from the last N days (default 60).
EOF
      exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -d "$SKILLS_ROOT" ]] || { echo "skills root not found: $SKILLS_ROOT" >&2; exit 1; }

extract_field() {
  awk -v f="$1" '
    /^---$/ { c++; if (c == 2) exit; next }
    c == 1 && $0 ~ "^"f":" {
      sub("^"f": *", "")
      sub(/^"/, ""); sub(/"$/, "")
      sub(/^'\''/, ""); sub(/'\''$/, "")
      print; exit
    }
  ' "$2"
}

skill_files=()
while IFS= read -r line; do skill_files+=("$line"); done < <(find "$SKILLS_ROOT" -mindepth 2 -maxdepth 2 -name SKILL.md -type f | sort)
total=${#skill_files[@]}

cutoff_date=$(date -v-"${LOOKBACK_DAYS}d" '+%Y-%m-%d')
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
transcript_count=0
if [[ -d "$TRANSCRIPTS_ROOT" ]]; then
  while IFS= read -r -d '' f; do
    cat "$f" >> "$tmp"
    transcript_count=$((transcript_count + 1))
  done < <(find "$TRANSCRIPTS_ROOT" -name "*.jsonl" -type f -newermt "$cutoff_date" -print0 2>/dev/null)
fi

typeset -A by_name
typeset -a unused_skills=()
typeset -a missing_desc=()
typeset -a desc_lens=()
typeset -a duplicates=()

for sf in "${skill_files[@]}"; do
  dir=$(dirname "$sf")
  dirname=$(basename "$dir")
  name=$(extract_field name "$sf")
  [[ -z "$name" ]] && name="$dirname"
  desc=$(extract_field description "$sf")

  if [[ -z "$desc" ]]; then
    missing_desc+=("$dirname")
  fi

  desc_lens+=("${#desc}:$name")

  if [[ -n "${by_name[$name]:-}" ]]; then
    duplicates+=("$name — ${by_name[$name]} vs $dir")
  else
    by_name[$name]="$dir"
  fi

  count=0
  if [[ -s "$tmp" ]]; then
    name_re=$(printf '%s' "$name" | sed 's/[.[\*^$()+?{|]/\\&/g')
    count=$(rg -c -e "/${name_re}(\$|[^A-Za-z0-9_-])" -e "skills/${name_re}/SKILL\.md" -e "\"skill\":\"${name_re}\"" "$tmp" 2>/dev/null || echo 0)
  fi
  if [[ "$count" -eq 0 ]]; then
    unused_skills+=("$name")
  fi
done

echo "# Skill Audit"
echo
echo "- Root: \`$SKILLS_ROOT\`"
echo "- Skills scanned: $total"
echo "- Transcripts scanned: $transcript_count (last ${LOOKBACK_DAYS}d)"
echo

echo "## Unused (no reference in ${LOOKBACK_DAYS}d)"
if [[ ${#unused_skills[@]} -eq 0 ]]; then
  echo "_None._"
else
  for s in "${unused_skills[@]}"; do echo "- $s"; done
fi
echo

echo "## Longest descriptions (top 5)"
printf '%s\n' "${desc_lens[@]}" | sort -t: -k1 -nr | head -5 | while IFS=: read -r len name; do
  echo "- $name ($len chars)"
done
echo

echo "## Duplicates"
if [[ ${#duplicates[@]} -eq 0 ]]; then
  echo "_None._"
else
  for d in "${duplicates[@]}"; do echo "- $d"; done
fi
echo

echo "## Missing description"
if [[ ${#missing_desc[@]} -eq 0 ]]; then
  echo "_None._"
else
  for s in "${missing_desc[@]}"; do echo "- $s"; done
fi
