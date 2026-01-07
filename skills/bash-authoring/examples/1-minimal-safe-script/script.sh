#!/usr/bin/env bash
#
# Minimal Safe Bash Script Template
#
# This script demonstrates the absolute minimum defensive patterns
# that every bash script should include. Use this as a template for
# new scripts.
#
# See ANALYSIS.md for detailed explanation of each pattern.
#
# References:
# - ../patterns-and-conventions.md (Strict mode section)
# - ../safety-and-security.md (Basic safety)

#
# STRICT MODE - The foundation of defensive bash
#
# -e: Exit immediately if any command fails
# -u: Treat unset variables as errors
# -o pipefail: Detect failures in pipelines
#
# This is the single most important pattern in defensive bash.
# Without this, scripts will silently continue after errors.
#
set -euo pipefail

#
# ERROR HANDLING - Catch and report errors
#
# This trap catches any error and provides context about where it occurred.
# The ERR trap fires when set -e would cause the script to exit.
#
trap 'echo "Error on line $LINENO" >&2' ERR

#
# SCRIPT METADATA - Self-documentation
#
# Store script name and directory for reliable path operations.
# Using basename and dirname ensures portability.
#
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

#
# USAGE FUNCTION - Help text
#
# Every script should have a usage function showing how to use it.
# Print to stderr (>&2) so it doesn't interfere with script output.
#
usage() {
    cat >&2 <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <input-file>

Minimal safe bash script template demonstrating defensive patterns.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output

ARGUMENTS:
    input-file      File to process

EXAMPLES:
    $SCRIPT_NAME myfile.txt
    $SCRIPT_NAME --verbose data.txt

EOF
}

#
# MAIN FUNCTION - Script logic
#
# Encapsulating logic in a main function improves organization
# and makes testing easier.
#
main() {
    local input_file=""
    local verbose=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -*)
                echo "Error: Unknown option: $1" >&2
                usage
                exit 1
                ;;
            *)
                # First positional argument is the input file
                if [[ -z "$input_file" ]]; then
                    input_file="$1"
                else
                    echo "Error: Too many arguments" >&2
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$input_file" ]]; then
        echo "Error: input-file is required" >&2
        usage
        exit 1
    fi

    # Validate file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: File not found: $input_file" >&2
        exit 1
    fi

    # Main script logic
    if [[ "$verbose" == true ]]; then
        echo "Processing file: $input_file"
    fi

    # Example: Count lines in file
    local line_count
    line_count=$(wc -l < "$input_file")

    echo "File has $line_count lines"

    return 0
}

# Execute main function with all script arguments
# The "$@" preserves argument spacing and special characters
main "$@"
