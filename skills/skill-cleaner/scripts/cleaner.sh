#!/usr/bin/env zsh
set -euo pipefail

SKILLS_ROOT="${SKILLS_ROOT:-$HOME/.claude/skills}"
TRANSCRIPTS_ROOT="${TRANSCRIPTS_ROOT:-$HOME/.claude/projects}"
USAGE_LOG="${USAGE_LOG:-$HOME/.claude/state/skill-usage.jsonl}"
LOOKBACK_DAYS="${LOOKBACK_DAYS:-60}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) LOOKBACK_DAYS="$2"; shift 2 ;;
    --root) SKILLS_ROOT="$2"; shift 2 ;;
    --transcripts) TRANSCRIPTS_ROOT="$2"; shift 2 ;;
    --usage-log) USAGE_LOG="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
usage: cleaner.sh [--days N] [--root DIR] [--transcripts DIR] [--usage-log FILE]

Audits ~/.claude/skills/ for unused entries, duplicate names, missing
descriptions, and long descriptions.

Unused detection uses the usage log written by the log-skill-use.sh
PostToolUse hook (default ~/.claude/state/skill-usage.jsonl) as ground
truth. Until that log covers the full lookback window it falls back to
grepping .jsonl transcripts under ~/.claude/projects/ (last N days,
default 60), which is a weaker heuristic.
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
cutoff_iso="${cutoff_date}T00:00:00Z"

# --- Ground truth: the usage log written by the log-skill-use.sh hook ---------
typeset -A log_count log_last
log_records_total=0        # records within the lookback window
log_records_all=0          # every record, for coverage
log_oldest=""
have_jq=0
command -v jq >/dev/null 2>&1 && have_jq=1

if [[ $have_jq -eq 1 && -s "$USAGE_LOG" ]]; then
  while IFS=$'\t' read -r ts sk; do
    [[ -z "$ts" || -z "$sk" ]] && continue
    log_records_all=$((log_records_all + 1))
    if [[ -z "$log_oldest" || "$ts" < "$log_oldest" ]]; then log_oldest="$ts"; fi
    if [[ "$ts" > "$cutoff_iso" ]]; then
      log_records_total=$((log_records_total + 1))
      log_count[$sk]=$(( ${log_count[$sk]:-0} + 1 ))
      if [[ -z "${log_last[$sk]:-}" || "$ts" > "${log_last[$sk]}" ]]; then log_last[$sk]="$ts"; fi
    fi
  done < <(jq -rR 'fromjson? | [.ts, .skill] | @tsv' "$USAGE_LOG" 2>/dev/null)
fi

use_log=0
[[ $log_records_all -gt 0 ]] && use_log=1

# Log coverage in whole days (how far back the log actually reaches).
coverage_days=""
if [[ -n "$log_oldest" ]]; then
  old_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$log_oldest" '+%s' 2>/dev/null || echo "")
  if [[ -n "$old_epoch" ]]; then
    coverage_days=$(( ( $(date '+%s') - old_epoch ) / 86400 ))
  fi
fi

# --- Fallback: transcript grep, only when the usage log is empty --------------
tmp=""
transcript_count=0
if [[ $use_log -eq 0 ]]; then
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' EXIT
  if [[ -d "$TRANSCRIPTS_ROOT" ]]; then
    while IFS= read -r -d '' f; do
      cat "$f" >> "$tmp"
      transcript_count=$((transcript_count + 1))
    done < <(find "$TRANSCRIPTS_ROOT" -name "*.jsonl" -type f -newermt "$cutoff_date" -print0 2>/dev/null)
  fi
fi

typeset -A by_name
typeset -a unused_skills=()
typeset -a missing_desc=()
typeset -a desc_lens=()
typeset -a duplicates=()
typeset -a used_lines=()

for sf in "${skill_files[@]}"; do
  dir=$(dirname "$sf")
  dirname=$(basename "$dir")
  name=$(extract_field name "$sf")
  [[ -z "$name" ]] && name="$dirname"
  desc=$(extract_field description "$sf")

  [[ -z "$desc" ]] && missing_desc+=("$dirname")
  desc_lens+=("${#desc}:$name")

  if [[ -n "${by_name[$name]:-}" ]]; then
    duplicates+=("$name — ${by_name[$name]} vs $dir")
  else
    by_name[$name]="$dir"
  fi

  if [[ $use_log -eq 1 ]]; then
    count=${log_count[$name]:-0}
    if [[ "$count" -eq 0 ]]; then
      unused_skills+=("$name")
    else
      used_lines+=("${count}\t${log_last[$name]}\t${name}")
    fi
  else
    count=0
    if [[ -n "$tmp" && -s "$tmp" ]]; then
      name_re=$(printf '%s' "$name" | sed 's/[.[\*^$()+?{|]/\\&/g')
      count=$(rg -c -e "/${name_re}(\$|[^A-Za-z0-9_-])" -e "skills/${name_re}/SKILL\.md" -e "\"skill\":\"${name_re}\"" "$tmp" 2>/dev/null || echo 0)
    fi
    [[ "$count" -eq 0 ]] && unused_skills+=("$name")
  fi
done

echo "# Skill Audit"
echo
echo "- Root: \`$SKILLS_ROOT\`"
echo "- Skills scanned: $total"
if [[ $use_log -eq 1 ]]; then
  echo "- Source: usage log (\`$USAGE_LOG\`) — $log_records_all records, $log_records_total in last ${LOOKBACK_DAYS}d"
  if [[ -n "$coverage_days" ]]; then
    echo "- Log coverage: ~${coverage_days}d (oldest record ${log_oldest%%T*})"
  fi
else
  echo "- Source: transcript heuristic — usage log \`$USAGE_LOG\` is empty or missing"
  echo "- Transcripts scanned: $transcript_count (last ${LOOKBACK_DAYS}d)"
fi
echo

echo "## Unused (no invocation in ${LOOKBACK_DAYS}d)"
if [[ $use_log -eq 1 && -n "$coverage_days" && "$coverage_days" -lt "$LOOKBACK_DAYS" ]]; then
  echo "> ⚠ Provisional — the usage log only reaches back ~${coverage_days}d, less than the"
  echo "> ${LOOKBACK_DAYS}d window. A skill listed here may simply predate the log. Treat as"
  echo "> candidates, not confirmed-unused, until coverage catches up."
  echo
elif [[ $use_log -eq 0 ]]; then
  echo "> ⚠ Heuristic — based on transcript greps, not the usage log. Install the"
  echo "> log-skill-use.sh hook (see SKILL.md) for ground-truth detection."
  echo
fi
if [[ ${#unused_skills[@]} -eq 0 ]]; then
  echo "_None._"
else
  for s in "${unused_skills[@]}"; do echo "- $s"; done
fi
echo

if [[ $use_log -eq 1 ]]; then
  echo "## Usage (last ${LOOKBACK_DAYS}d, most-used first)"
  if [[ ${#used_lines[@]} -eq 0 ]]; then
    echo "_No invocations recorded yet._"
  else
    printf '%b\n' "${used_lines[@]}" | sort -t$'\t' -k1 -nr | while IFS=$'\t' read -r c last nm; do
      echo "- $nm — ${c}× (last ${last%%T*})"
    done
  fi
  echo
fi

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
