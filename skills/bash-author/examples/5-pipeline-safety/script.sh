#!/usr/bin/env bash
#
# Pipeline Safety Example
#
# Demonstrates safe processing of files with special characters (spaces, newlines)
# using NUL-delimited data and proper iteration patterns.
#
# References:
# - ../patterns-and-conventions.md (Pipeline safety, null-delimited data)

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

usage() {
    cat >&2 <<EOF
Usage: $SCRIPT_NAME <directory>

Safely process files with special characters in names.
Demonstrates: find -print0, xargs -0, while IFS= read -r -d ''

EOF
}

main() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
        usage
        exit 0
    fi

    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory not found: $dir" >&2
        exit 1
    fi

    echo "Processing files in: $dir"
    echo

    # SAFE: Using -print0 and null-delimited processing
    echo "Method 1: find with -print0 and while read -d ''"
    while IFS= read -r -d '' file; do
        echo "  Processing: $file"
        # Do work with "$file" here
    done < <(find "$dir" -type f -print0)
    echo

    # SAFE: Using find -print0 with xargs -0
    echo "Method 2: find -print0 with xargs -0"
    find "$dir" -type f -print0 | xargs -0 -I {} echo "  Processing: {}"
    echo

    # SAFE: Glob with nullglob
    echo "Method 3: Glob with nullglob and array"
    shopt -s nullglob  # Glob expands to nothing if no matches
    local files=("$dir"/*)
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "  Processing: $file"
        fi
    done
    shopt -u nullglob
    echo

    echo "All files processed safely!"
}

main "$@"
