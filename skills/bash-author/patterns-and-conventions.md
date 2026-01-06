# Defensive Programming Patterns and Code Conventions

Core patterns and conventions for writing safe, readable, and maintainable Bash scripts.

## Strict Mode and Error Handling

- Always use strict mode with `set -Eeuo pipefail` and proper error trapping
- Use `shopt -s inherit_errexit` for better error propagation in Bash 4.4+
- Implement error context: `trap 'echo "Error at line $LINENO: exit $?" >&2' ERR` for debugging
- Validate inputs with `: "${VAR:?message}"` for required environment variables
- Check exit codes of all security-critical operations explicitly
- Use `trap` to ensure cleanup happens even on abnormal exit

## Variable Handling

- Quote all variable expansions to prevent word splitting and globbing issues
- Employ `IFS=$'\n\t'` to prevent unwanted word splitting on spaces
- Declare constants with `readonly` to prevent accidental modification
- Use `local` keyword for all function variables to avoid polluting global scope
- Validate numeric input with pattern matching: `[[ $num =~ ^[0-9]+$ ]]`
- Use function returns with `declare -g result` for returning complex data from functions

## Conditionals and Tests

- Use `[[ ]]` for Bash conditionals, fall back to `[ ]` for POSIX compliance
- Validate file permissions before operations: `[[ -r "$file" ]] || exit 1`
- Use binary-safe patterns: `find -print0 | while IFS= read -r -d '' file; do ...; done`
- End option parsing with `--` and use `rm -rf -- "$dir"` for safe operations

## Arrays and Iteration

- Prefer arrays and proper iteration over unsafe patterns like `for f in $(ls)`
- Use `readarray`/`mapfile` for safe array population from command output
- Use binary-safe arrays: `readarray -d '' files < <(find . -print0)`
- Use `xargs -0` with NUL boundaries for safe subprocess orchestration

## Command Execution

- Use command substitution `$()` instead of backticks for readability
- Prefer `printf` over `echo` for predictable output formatting
- Never use `eval` on user input; use arrays for dynamic command construction
- Use process substitution `<(command)` instead of temporary files when possible
- Use `--` to separate options from arguments: `rm -rf -- "$user_input"`

## Naming Conventions

- Use consistent naming: snake_case for functions/variables, UPPER_CASE for constants
- Use descriptive function names that explain purpose: `validate_input_file` not `check_file`
- Extract magic numbers and strings to named constants at top of script

## Code Organization

- Add section headers with comment blocks to organize related functions
- Keep functions under 50 lines; refactor larger functions into smaller components
- Group related functions together with descriptive section headers
- Use blank lines to separate logical blocks within functions
- Document function parameters and return values in header comments
- Place opening braces on same line for consistency: `function_name() {`

## Code Style

- Use long-form options in scripts for clarity: `--verbose` instead of `-v`
- Add inline comments for non-obvious logic, avoid stating the obvious
- Maintain consistent indentation (2 or 4 spaces, never tabs mixed with spaces)

## Script Directory Detection

Implement robust script directory detection:

```bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
```

## Debugging Support

- Support `--trace` mode with `set -x` opt-in for detailed debugging
- Design scripts to be idempotent and support dry-run modes
