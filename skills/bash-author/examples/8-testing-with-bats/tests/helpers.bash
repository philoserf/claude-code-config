# Test helper functions

# Create a temp file with content
create_temp_file() {
    local content="$1"
    local file="${BATS_TMPDIR}/temp-${RANDOM}.txt"
    echo -e "$content" > "$file"
    echo "$file"
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    [[ -f "$file" ]]
}

# Assert output contains string
assert_output_contains() {
    local expected="$1"
    [[ "$output" =~ $expected ]]
}
