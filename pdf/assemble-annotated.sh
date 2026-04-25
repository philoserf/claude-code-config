#!/usr/bin/env bash
# Emit assembled markdown for the Annotated PDF style to stdout.
# shellcheck disable=SC2016  # backticks in printf format strings are literal markdown
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Extract a frontmatter field value from a markdown file.
# Usage: frontmatter_field <file> <field>
# Returns empty string if file has no frontmatter or field is absent.
frontmatter_field() {
	local file="$1"
	local field="$2"
	awk -v field="$field" '
    BEGIN { in_fm = 0; found = "" }
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; exit }
    in_fm {
      if (match($0, "^"field":[[:space:]]*")) {
        val = substr($0, RLENGTH + 1)
        gsub(/^["'\'']|["'\'']$/, "", val)
        found = val
        exit
      }
    }
    END { print found }
  ' "$file"
}

# Print the first non-empty paragraph of the body (skipping frontmatter).
first_paragraph() {
	local file="$1"
	awk '
    BEGIN { in_fm = 0; past_fm = 0; para = "" }
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; past_fm = 1; next }
    in_fm { next }
    !past_fm { past_fm = 1 }
    past_fm && /^#/ { next }
    past_fm && NF == 0 { if (para != "") exit; next }
    past_fm { para = (para == "" ? $0 : para " " $0) }
    END { print para }
  ' "$file"
}

emit_full() {
	local path="$1"
	local fence="${2:-}"
	printf '\n## `%s`\n\n' "$path"
	if [[ -n "$fence" ]]; then
		printf '```%s\n' "$fence"
		cat "$path"
		printf '\n```\n'
	else
		cat "$path"
		printf '\n'
	fi
}

printf '# Top-level documents\n'
for f in README.md THEORY.md CLAUDE.md; do
	[[ -f "$f" ]] && emit_full "$f"
done

printf '\n# Settings\n'
emit_full "settings.json" "json"

printf '\n# Rules\n\n'
printf 'Auto-loaded into every session as global user instructions.\n\n'
for f in rules/*.md; do
	emit_full "$f"
done

printf '\n# Skills\n\n'
for d in skills/*/; do
	d="${d%/}"
	name="$(basename "$d")"
	if [[ -f "$d/SKILL.md" ]]; then
		f="$d/SKILL.md"
		suffix=""
	elif [[ -f "$d/SKILL.md-off" ]]; then
		f="$d/SKILL.md-off"
		suffix=" _(disabled)_"
	else
		continue
	fi
	desc="$(frontmatter_field "$f" description)"
	summary="$(first_paragraph "$f")"
	printf '\n### %s%s\n\n' "$name" "$suffix"
	[[ -n "$desc" ]] && printf '**Description:** %s\n\n' "$desc"
	[[ -n "$summary" ]] && printf '%s\n' "$summary"
done

printf '\n# Agents\n\n'
for f in agents/*.md; do
	name="$(basename "$f" .md)"
	desc="$(frontmatter_field "$f" description)"
	summary="$(first_paragraph "$f")"
	printf '\n### %s\n\n' "$name"
	[[ -n "$desc" ]] && printf '**Description:** %s\n\n' "$desc"
	[[ -n "$summary" ]] && printf '%s\n' "$summary"
done

printf '\n# Hooks\n\n'
printf 'Hook scripts triggered by lifecycle events. Wiring lives in `settings.json`.\n\n'
for f in hooks/*; do
	[[ -f "$f" ]] || continue
	name="$(basename "$f")"
	printf '\n### %s\n\n' "$name"
	# Print the first non-shebang comment line as a one-line synopsis if present.
	synopsis="$(awk 'NR==1 && /^#!/ {next} /^#/ {sub(/^#[[:space:]]*/, ""); print; exit} !/^#/ {exit}' "$f")"
	[[ -n "$synopsis" ]] && printf '%s\n' "$synopsis"
done
