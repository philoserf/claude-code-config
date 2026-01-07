#!/usr/bin/env bats
#
# Basic tests for script.sh
#
# Run with: bats tests/

setup() {
    # Load script for testing (source it)
    load ../script.sh

    # Create test file
    TEST_FILE="${BATS_TMPDIR}/test-input.txt"
    echo -e "line 1\nline 2\nline 3" > "$TEST_FILE"
}

teardown() {
    # Cleanup
    rm -f "$TEST_FILE"
}

@test "add function works correctly" {
    result=$(add 2 3)
    [ "$result" -eq 5 ]
}

@test "add handles zero" {
    result=$(add 0 5)
    [ "$result" -eq 5 ]
}

@test "process_file counts lines correctly" {
    result=$(process_file "$TEST_FILE")
    [ "$result" -eq 3 ]
}

@test "process_file fails on missing file" {
    run process_file "/nonexistent/file.txt"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: File not found" ]]
}

@test "main requires argument" {
    run main
    [ "$status" -eq 1 ]
}

@test "main works with valid file" {
    run main "$TEST_FILE"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "3 lines" ]]
}
