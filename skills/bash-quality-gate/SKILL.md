---
name: bash-quality-gate
description: >-
  Runs shell script quality checks — formatting, static analysis, and
  portability. Use when checking shell script quality, linting bash code, or
  validating scripts with shellcheck and shfmt.
---

# Bash Quality Gate

Run a standardized set of shell script quality checks. Auto-fix what's fixable, report the rest with specific locations.

## Prerequisites

Verify these tools are available before running checks. Both are installed via Homebrew.

- `shfmt` — shell formatter (`brew install shfmt`)
- `shellcheck` — static analysis (`brew install shellcheck`)

## Check Sequence

Run checks in this order. Formatting first so shellcheck analyzes clean code.

### 1. Format (auto-fix)

Run `shfmt -w -i 2 -ci -bn .` on all `.sh` files — report which files were modified. If no files changed, report "formatting clean."

Flags:

- `-i 2` — 2-space indent
- `-ci` — indent switch cases
- `-bn` — binary ops start of line

If a project has an `.editorconfig`, `shfmt` picks it up automatically — skip the explicit flags.

### 2. Lint (report)

Run `shellcheck -x *.sh **/*.sh` — report issues with file, line, rule code, and severity. The `-x` flag follows `source` directives.

If scripts lack a shebang, shellcheck defaults to `sh`. Note any scripts missing shebangs and suggest adding them.

### 3. Portability (report)

Run `shellcheck --shell=sh *.sh **/*.sh` — check POSIX compliance. Report bash-specific constructs that would break on `sh`/`dash`. Skip this step if all scripts explicitly declare `#!/bin/bash` or `#!/usr/bin/env bash` — they've opted into bash.

## Output

After all checks complete, present a summary table:

```text
| Check       | Status | Details              |
|-------------|--------|----------------------|
| shfmt       | FIXED  | 2 files formatted    |
| shellcheck  | WARN   | 3 issues (1 error)   |
| portability | SKIP   | All scripts use bash |
```

Then list specific issues grouped by file, with line numbers and ShellCheck codes (e.g., SC2086). Offer to fix reported issues if the user wants.

## File Discovery

- Find scripts by extension: `*.sh`
- Find scripts by shebang: `#!/bin/bash`, `#!/bin/sh`, `#!/usr/bin/env bash`
- Check the current directory and subdirectories
- Skip `node_modules/`, `.git/`, and `vendor/` directories
