#!/usr/bin/env bash
# Emit assembled markdown for the Full PDF style to stdout.
# shellcheck disable=SC2016  # backticks in printf format strings are literal markdown
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

emit_file() {
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

ext_to_fence() {
	case "$1" in
	*.sh) echo "bash" ;;
	*.py) echo "python" ;;
	*.js) echo "javascript" ;;
	*) echo "text" ;;
	esac
}

printf '# Top-level documents\n'
for f in README.md THEORY.md CLAUDE.md; do
	[[ -f "$f" ]] && emit_file "$f"
done

printf '\n# Settings\n'
emit_file "settings.json" "json"

printf '\n# Rules\n'
for f in rules/*.md; do
	emit_file "$f"
done

printf '\n# Skills\n'
for d in skills/*/; do
	d="${d%/}"
	if [[ -f "$d/SKILL.md" ]]; then
		emit_file "$d/SKILL.md"
	elif [[ -f "$d/SKILL.md-off" ]]; then
		printf '\n## `%s/SKILL.md-off` _(disabled)_\n\n' "$d"
		cat "$d/SKILL.md-off"
		printf '\n'
	fi
done

printf '\n# Agents\n'
for f in agents/*.md; do
	emit_file "$f"
done

printf '\n# Hooks\n'
for f in hooks/*; do
	[[ -f "$f" ]] || continue
	fence="$(ext_to_fence "$f")"
	emit_file "$f" "$fence"
done
