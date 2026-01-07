#!/usr/bin/env bash
#
# Temporary File Management Example
#
# Demonstrates safe creation, usage, and cleanup of temporary files.
# Key patterns: mktemp, EXIT trap, cleanup verification
#
# References:
# - ../patterns-and-conventions.md (Temp file handling)
# - ../safety-and-security.md (Secure temp files)

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

# Temporary file will be created and tracked
TEMP_FILE=""

# Cleanup function - called on EXIT
cleanup() {
    local exit_code=$?

    if [[ -n "$TEMP_FILE" ]] && [[ -f "$TEMP_FILE" ]]; then
        echo "Cleaning up temporary file: $TEMP_FILE" >&2
        rm -f "$TEMP_FILE"

        # Verify cleanup succeeded
        if [[ -f "$TEMP_FILE" ]]; then
            echo "Warning: Failed to remove temporary file: $TEMP_FILE" >&2
        fi
    fi

    exit "$exit_code"
}

# Register cleanup function to run on EXIT
# This ensures cleanup happens even if script fails
trap cleanup EXIT

usage() {
    cat >&2 <<EOF
Usage: $SCRIPT_NAME <input-file>

Demonstrates safe temporary file handling with automatic cleanup.

This script:
1. Creates a secure temporary file using mktemp
2. Processes data using the temp file
3. Automatically cleans up on exit (success or failure)

EOF
}

main() {
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        usage
        exit 0
    fi

    local input_file="$1"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: File not found: $input_file" >&2
        exit 1
    fi

    # Create secure temporary file
    # -t provides template: basename.XXXXXXXXXX
    # mktemp creates file with random name and mode 0600 (owner read/write only)
    TEMP_FILE=$(mktemp -t "${SCRIPT_NAME}.XXXXXXXXXX")

    echo "Created temporary file: $TEMP_FILE"

    # Process data using temporary file
    # Example: sort input file into temp, then process
    sort "$input_file" > "$TEMP_FILE"

    # Simulate work with temp file
    local line_count
    line_count=$(wc -l < "$TEMP_FILE")
    echo "Processed $line_count lines"

    # Temp file will be automatically cleaned up by EXIT trap
    # No need for explicit rm here - cleanup() handles it

    echo "Success - temp file will be cleaned up automatically"

    return 0
}

main "$@"
