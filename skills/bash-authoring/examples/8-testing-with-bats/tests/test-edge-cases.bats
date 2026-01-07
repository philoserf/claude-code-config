#!/usr/bin/env bats
#
# Edge case tests
#

setup() {
    load ../script.sh
}

@test "add handles large numbers" {
    result=$(add 1000 2000)
    [ "$result" -eq 3000 ]
}

@test "process_file handles empty file" {
    empty_file="${BATS_TMPDIR}/empty.txt"
    touch "$empty_file"

    result=$(process_file "$empty_file")
    [ "$result" -eq 0 ]

    rm -f "$empty_file"
}

@test "process_file handles file with spaces in name" {
    spaced_file="${BATS_TMPDIR}/file with spaces.txt"
    echo "content" > "$spaced_file"

    result=$(process_file "$spaced_file")
    [ "$result" -eq 1 ]

    rm -f "$spaced_file"
}
