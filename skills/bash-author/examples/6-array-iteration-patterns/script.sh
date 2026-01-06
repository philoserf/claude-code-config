#!/usr/bin/env bash
#
# Array Iteration Patterns Example
#
# Demonstrates safe array operations: creation, iteration, and manipulation.
#
# References:
# - ../patterns-and-conventions.md (Arrays)

set -euo pipefail

main() {
    echo "Array Iteration Patterns"
    echo "========================"
    echo

    # Pattern 1: Array creation from command output
    echo "Pattern 1: mapfile/readarray"
    local -a lines
    mapfile -t lines < <(seq 1 5)
    echo "  Created array with ${#lines[@]} elements"
    echo

    # Pattern 2: Safe iteration
    echo "Pattern 2: Safe iteration with quoted expansion"
    for item in "${lines[@]}"; do
        echo "  Item: $item"
    done
    echo

    # Pattern 3: Array with spaces
    echo "Pattern 3: Elements with spaces"
    local -a items=("item one" "item two" "item three")
    for item in "${items[@]}"; do
        echo "  Processing: '$item'"
    done
    echo

    # Pattern 4: Indexed access
    echo "Pattern 4: Indexed access"
    echo "  First: ${items[0]}"
    echo "  Last:  ${items[-1]}"
    echo "  Count: ${#items[@]}"
    echo

    # Pattern 5: Array modification
    echo "Pattern 5: Adding elements"
    items+=("item four")
    echo "  New count: ${#items[@]}"
    echo

    # Pattern 6: Processing with index
    echo "Pattern 6: Iteration with index"
    for i in "${!items[@]}"; do
        echo "  [$i] = ${items[$i]}"
    done

    echo
    echo "All array patterns demonstrated!"
}

main "$@"
