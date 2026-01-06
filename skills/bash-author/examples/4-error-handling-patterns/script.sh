#!/usr/bin/env bash
#
# Error Handling Patterns Example
#
# Demonstrates comprehensive error handling strategies including:
# - ERR trap with context
# - Error recovery
# - Graceful degradation
# - Explicit error checking
#
# References:
# - ../error-handling.md
# - ../patterns-and-conventions.md

set -Eeuo pipefail

# Enhanced error handler with context
error_handler() {
    local line_number=$1
    local command="$2"
    local error_code="${3:-1}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "ERROR: Script failed" >&2
    echo "  Line:    $line_number" >&2
    echo "  Command: $command" >&2
    echo "  Code:    $error_code" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
}

# Trap ERR with enhanced error reporting
# -E ensures trap is inherited by functions
trap 'error_handler ${LINENO} "$BASH_COMMAND" $?' ERR

# Explicitly check command success
check_command() {
    local description="$1"
    shift

    echo "Running: $description"
    if ! "$@"; then
        echo "Error: $description failed" >&2
        return 1
    fi

    echo "  ✓ Success"
    return 0
}

# Attempt operation with fallback
try_with_fallback() {
    local primary_cmd=("$@")

    if "${primary_cmd[@]}" 2>/dev/null; then
        return 0
    else
        echo "  Primary method failed, using fallback" >&2
        # Fallback logic here
        return 0
    fi
}

main() {
    echo "Demonstrating error handling patterns..."
    echo

    # Pattern 1: Explicit command checking
    echo "Pattern 1: Explicit Success Verification"
    check_command "Create test file" touch /tmp/test-file.txt
    check_command "Write to file" sh -c 'echo "test" > /tmp/test-file.txt'
    echo

    # Pattern 2: Conditional error handling
    echo "Pattern 2: Conditional Error Handling"
    if [[ -f /tmp/test-file.txt ]]; then
        echo "  ✓ File exists, proceeding"
    else
        echo "  ✗ File missing, cannot proceed" >&2
        exit 1
    fi
    echo

    # Pattern 3: Allow specific failures
    echo "Pattern 3: Expected Failures (set +e temporarily)"
    set +e  # Temporarily allow failures
    grep "nonexistent" /tmp/test-file.txt >/dev/null 2>&1
    local grep_exit=$?
    set -e  # Re-enable exit on error

    if [[ $grep_exit -ne 0 ]]; then
        echo "  ✓ Pattern not found (expected)"
    fi
    echo

    # Pattern 4: Defensive coding
    echo "Pattern 4: Defensive Checks Before Operations"
    local file="/tmp/test-file.txt"
    if [[ -r "$file" ]] && [[ -w "$file" ]]; then
        cat "$file"
        echo "  ✓ File is readable and writable"
    fi
    echo

    # Cleanup
    rm -f /tmp/test-file.txt

    echo "All error handling patterns demonstrated successfully!"
}

main "$@"
