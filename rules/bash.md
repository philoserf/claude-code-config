---
globs:
  - "**/*.sh"
  - "bin/**"
---

- Must pass `shellcheck` and `shfmt`
- Run `shfmt --write <file>` to format; `shellcheck <file>` to validate
- Include shebang line (`#!/usr/bin/env bash` or `#!/bin/bash`)
- Quote variables to prevent word splitting: `"$var"` not `$var`
- Check exit codes and handle errors explicitly
- Use meaningful names for functions and variables
- Set error handling flags: `set -euo pipefail`
- Avoid bare `grep` or `sed` without explicit error handling
