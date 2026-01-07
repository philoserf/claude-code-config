#!/usr/bin/env bash
#
# Example Script for Testing with Bats
#
# This is a simple script we'll write tests for.
# Demonstrates testable bash script design.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

# Pure functions are easy to test
add() {
    local a=$1
    local b=$2
    echo $((a + b))
}

# Testable file operations
process_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi

    wc -l < "$file"
}

# Main function - also testable
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $SCRIPT_NAME <file>" >&2
        return 1
    fi

    local file="$1"
    local line_count

    line_count=$(process_file "$file")
    echo "File has $line_count lines"
}

# Only run main if not being sourced (for testing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
