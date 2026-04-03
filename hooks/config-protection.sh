#!/bin/bash
# Config-protection hook - warns when editing linter/formatter configs
# Runs as PreToolUse on Edit|Write — warns user (exit 1), does not block Claude
#
# Note: Intentionally no 'set -euo pipefail' - hooks must exit 0 (allow) or 1 (warn user)

file_path="${TOOL_FILE_PATH:-}"

if [ -z "$file_path" ]; then
	if command -v jq &>/dev/null; then
		if ! file_path=$(jq -r '.tool_input.file_path // empty' 2>/dev/null); then
			exit 0
		fi
	else
		exit 0
	fi
fi

if [ -z "$file_path" ]; then
	exit 0
fi

basename=$(basename "$file_path")

# Protected config file patterns
case "$basename" in
.eslintrc* | eslint.config.* | \
	biome.json | \
	.prettierrc* | prettier.config.* | \
	.golangci.yml | .golangci.yaml | \
	ruff.toml | \
	.shellcheckrc | \
	.markdownlint* | \
	.yamllint | .yamllint.yaml | \
	.editorconfig | \
	.stylelintrc* | \
	tsconfig.json | tsconfig.*.json)
	echo "Warning: modifying linter/formatter config ($basename). Fix the code, not the config." >&2
	exit 1
	;;
pyproject.toml)
	echo "Warning: modifying pyproject.toml — if changing ruff/linter settings, fix the code instead." >&2
	exit 1
	;;
esac

exit 0
