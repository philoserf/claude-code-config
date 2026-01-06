# Analysis: Minimal Safe Script

## Overview

This example demonstrates the **absolute minimum defensive patterns** that every bash script should include. Think of this as a template to copy when starting any new bash script.

## Patterns Demonstrated

### 1. Strict Mode (`set -euo pipefail`)

**Location**: Line 20

```bash
set -euo pipefail
```

**What it does**:

- `-e`: Exit immediately if any command returns non-zero exit code
- `-u`: Treat undefined variables as errors (prevents typos)
- `-o pipefail`: Make pipelines fail if any command in the pipe fails

**Why it matters**:
Without strict mode, bash scripts silently continue after errors. This leads to:

- Commands failing without notice
- Working with empty variables due to typos
- Pipeline failures masked by the last command's success

**Example without strict mode**:

```bash
# BAD - Without set -e
rm important-file.txt  # Fails silently if file doesn't exist
echo "File deleted successfully"  # This still prints!
```

**Example with strict mode**:

```bash
# GOOD - With set -e
set -e
rm important-file.txt  # Script exits here if file doesn't exist
echo "File deleted successfully"  # Never reached on error
```

### 2. Error Trap (`trap 'echo "Error on line $LINENO" >&2' ERR`)

**Location**: Line 29

```bash
trap 'echo "Error on line $LINENO" >&2' ERR
```

**What it does**:

- Catches errors that would cause script to exit (due to `set -e`)
- Reports the line number where error occurred
- Prints to stderr (`>&2`) to separate error output from normal output

**Why it matters**:
When a script fails, you need to know WHERE it failed. The line number helps you quickly locate the problem, especially in longer scripts.

**Example output**:

```text
Error on line 89
Error: File not found: missing.txt
```

### 3. Script Metadata (SCRIPT_NAME, SCRIPT_DIR)

**Location**: Lines 35-36

```bash
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
```

**What it does**:

- `SCRIPT_NAME`: Extract just the script filename (not full path)
- `SCRIPT_DIR`: Get absolute path to script's directory
- `readonly`: Prevent accidental modification

**Why it matters**:

- Use `SCRIPT_NAME` in usage/error messages (looks professional)
- Use `SCRIPT_DIR` to reference files relative to script location
- Absolute paths prevent issues when script is called from different directories

**Example usage**:

```bash
# Load config file in same directory as script
config_file="$SCRIPT_DIR/config.conf"
source "$config_file"
```

### 4. Usage Function

**Location**: Lines 42-59

**What it does**:

- Provides help text explaining how to use the script
- Shows options, arguments, and examples
- Prints to stderr (`>&2`) so it doesn't interfere with piped output

**Why it matters**:

- Makes scripts self-documenting
- Users can quickly understand how to use script with `--help`
- Future you will appreciate having clear documentation

**Best practices**:

- Include all options and arguments
- Provide at least 1-2 usage examples
- Explain what the script does in one sentence

### 5. Argument Parsing with Validation

**Location**: Lines 70-97

**What it does**:

- Parses options (`-v`, `--help`) and positional arguments
- Validates required arguments are provided
- Validates arguments meet requirements (e.g., file exists)

**Key techniques**:

```bash
while [[ $# -gt 0 ]]; do  # Loop while arguments remain
    case "$1" in           # Pattern match argument
        -h|--help)         # Handle flag
            usage
            exit 0
            ;;
        -*)                # Catch unknown options
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)                 # Handle positional argument
            input_file="$1"
            shift
            ;;
    esac
done
```

**Why it matters**:

- Prevents cryptic errors later in script
- Provides clear error messages for invalid input
- Fails fast with actionable feedback

### 6. Main Function Pattern

**Location**: Lines 65-115

```bash
main() {
    # All script logic here
}

main "$@"
```

**What it does**:

- Encapsulates all script logic in a function
- Makes code more organized and testable
- Clearly separates initialization from execution

**Why it matters**:

- Easy to test (can source script and call main with test args)
- Variables are local by default (reduces side effects)
- Clear entry point for reading code

## How This Template Prevents Common Errors

### Error Type 1: Typo in Variable Name

**Without patterns**:

```bash
# BAD
filename="data.txt"
rm $fliename  # Typo - silently does nothing or deletes wrong file!
```

**With patterns**:

```bash
# GOOD
set -u
filename="data.txt"
rm "$fliename"  # Error: fliename: unbound variable
```

### Error Type 2: Command Failure Goes Unnoticed

**Without patterns**:

```bash
# BAD
curl https://api.example.com/data > data.json
process data.json  # Processes empty/incomplete file if curl failed
```

**With patterns**:

```bash
# GOOD
set -e
curl https://api.example.com/data > data.json  # Script exits if curl fails
process data.json  # Only reached if curl succeeded
```

### Error Type 3: Pipeline Failure Masked

**Without patterns**:

```bash
# BAD
cat file.txt | grep pattern | wc -l
# Returns 0 even if cat or grep fails! (only checks wc exit code)
```

**With patterns**:

```bash
# GOOD
set -o pipefail
cat file.txt | grep pattern | wc -l
# Fails if any command in pipeline fails
```

## Running This Example

```bash
# Make executable
chmod +x script.sh

# Show help
./script.sh --help

# Create test file
echo -e "line 1\nline 2\nline 3" > test.txt

# Run with test file
./script.sh test.txt

# Run with verbose flag
./script.sh --verbose test.txt

# Test error handling - missing file
./script.sh nonexistent.txt
# Output: Error: File not found: nonexistent.txt

# Test error handling - missing required argument
./script.sh
# Output: Error: input-file is required
```

## Verify with ShellCheck

```bash
shellcheck script.sh
# Should return no errors or warnings
```

## Key Takeaways

1. **Always start with strict mode**: `set -euo pipefail` is non-negotiable
2. **Always add error trap**: Know WHERE errors occur
3. **Always provide usage function**: Scripts are self-documenting
4. **Always validate inputs**: Fail fast with clear messages
5. **Always quote variables**: Prevents word splitting issues

## Next Steps

- **Example 2**: Learn comprehensive parameter validation
- **Example 3**: Learn temporary file handling
- **Example 4**: Learn advanced error handling patterns

## References

- [patterns-and-conventions.md](../../patterns-and-conventions.md) - Strict mode details
- [safety-and-security.md](../../safety-and-security.md) - Security best practices
