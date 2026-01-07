#!/usr/bin/env bash
#
# Parameter Validation Example
#
# Demonstrates comprehensive input validation strategies for bash scripts.
# Covers: required vs optional parameters, type validation, range checking,
# file existence, and providing helpful error messages.
#
# See ANALYSIS.md for detailed explanation.
#
# References:
# - ../patterns-and-conventions.md (Parameter validation)
# - ../safety-and-security.md (Input validation)

set -euo pipefail

trap 'echo "Error on line $LINENO" >&2' ERR

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

usage() {
    cat >&2 <<EOF
Usage: $SCRIPT_NAME [OPTIONS] --input <file> --output <file>

Demonstrates comprehensive parameter validation patterns.

REQUIRED OPTIONS:
    --input <file>      Input file to process (must exist)
    --output <file>     Output file to create (must not exist)

OPTIONAL OPTIONS:
    --count <number>    Number of iterations (default: 1, range: 1-100)
    --format <type>     Output format: json|xml|csv (default: json)
    --verbose           Enable verbose output
    -h, --help          Show this help message

EXAMPLES:
    $SCRIPT_NAME --input data.txt --output result.txt
    $SCRIPT_NAME --input data.txt --output result.txt --count 10
    $SCRIPT_NAME --input data.txt --output result.txt --format csv --verbose

EOF
}

# Validation helper functions

# Check if value is a positive integer
is_positive_integer() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -gt 0 ]]
}

# Check if value is in range
is_in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    [[ "$value" -ge "$min" ]] && [[ "$value" -le "$max" ]]
}

# Check if value is in allowed list
is_in_list() {
    local value="$1"
    shift
    local allowed=("$@")

    for item in "${allowed[@]}"; do
        if [[ "$value" == "$item" ]]; then
            return 0
        fi
    done
    return 1
}

main() {
    # Parameters with default values
    local input_file=""
    local output_file=""
    local count=1
    local format="json"
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --input)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --input requires an argument" >&2
                    exit 1
                fi
                input_file="$2"
                shift 2
                ;;
            --output)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --output requires an argument" >&2
                    exit 1
                fi
                output_file="$2"
                shift 2
                ;;
            --count)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --count requires an argument" >&2
                    exit 1
                fi
                count="$2"
                shift 2
                ;;
            --format)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --format requires an argument" >&2
                    exit 1
                fi
                format="$2"
                shift 2
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                usage
                exit 1
                ;;
        esac
    done

    # Validate required parameters
    if [[ -z "$input_file" ]]; then
        echo "Error: --input is required" >&2
        usage
        exit 1
    fi

    if [[ -z "$output_file" ]]; then
        echo "Error: --output is required" >&2
        usage
        exit 1
    fi

    # Validate input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file does not exist: $input_file" >&2
        exit 1
    fi

    # Validate input file is readable
    if [[ ! -r "$input_file" ]]; then
        echo "Error: Input file is not readable: $input_file" >&2
        exit 1
    fi

    # Validate output file doesn't exist (prevent accidental overwrite)
    if [[ -e "$output_file" ]]; then
        echo "Error: Output file already exists: $output_file" >&2
        echo "Remove it first or choose a different output file" >&2
        exit 1
    fi

    # Validate output directory exists and is writable
    local output_dir
    output_dir="$(dirname "$output_file")"
    if [[ ! -d "$output_dir" ]]; then
        echo "Error: Output directory does not exist: $output_dir" >&2
        exit 1
    fi
    if [[ ! -w "$output_dir" ]]; then
        echo "Error: Output directory is not writable: $output_dir" >&2
        exit 1
    fi

    # Validate count is a positive integer
    if ! is_positive_integer "$count"; then
        echo "Error: --count must be a positive integer, got: $count" >&2
        exit 1
    fi

    # Validate count is in acceptable range
    if ! is_in_range "$count" 1 100; then
        echo "Error: --count must be between 1 and 100, got: $count" >&2
        exit 1
    fi

    # Validate format is one of allowed values
    local -r allowed_formats=("json" "xml" "csv")
    if ! is_in_list "$format" "${allowed_formats[@]}"; then
        echo "Error: --format must be one of: ${allowed_formats[*]}, got: $format" >&2
        exit 1
    fi

    # All validation passed - log configuration if verbose
    if [[ "$verbose" == true ]]; then
        echo "Configuration validated:"
        echo "  Input file:  $input_file"
        echo "  Output file: $output_file"
        echo "  Count:       $count"
        echo "  Format:      $format"
        echo
    fi

    # Main processing logic
    if [[ "$verbose" == true ]]; then
        echo "Processing $count iterations..."
    fi

    for ((i=1; i<=count; i++)); do
        if [[ "$verbose" == true ]]; then
            echo "  Iteration $i/$count"
        fi
    done

    # Create output file (simplified example)
    cat "$input_file" > "$output_file"

    echo "Successfully created: $output_file (format: $format)"

    return 0
}

main "$@"
