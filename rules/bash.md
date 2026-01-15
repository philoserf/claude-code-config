---
paths:
  - "**/*.sh"
  - "bin/**"
---

# Bash Rules

## Code Quality Standards

- All bash scripts must pass `shellcheck` without warnings or errors
- All bash scripts must be formatted with `shfmt`
- Run `shfmt --write <file>` to auto-format
- Run `shellcheck <file>` to validate; fix all reported issues

## Script Structure

- Include shebang line (`#!/usr/bin/env bash` or `#!/bin/bash` for portable scripts)
- Use bash idioms and conventions
- Quote variables to prevent word splitting: `"$var"` not `$var`
- Check exit codes and handle errors explicitly
- Use meaningful names for functions and variables

## Defensive Programming

- Set error handling flags where appropriate: `set -euo pipefail`
- Avoid bare `grep` or `sed` without explicit error handling
- Don't ignore command failures silently
