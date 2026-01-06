#!/usr/bin/env bash
#
# Simple smoke tests for minimal-safe-script
#
# This demonstrates basic testing without a framework.
# See example 8 for comprehensive testing with Bats.
#

set -euo pipefail

readonly SCRIPT="./script.sh"
readonly TEST_FILE="test-input.txt"

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Test counter
tests_passed=0
tests_failed=0

# Helper function: run test and check result
run_test() {
    local test_name="$1"
    local expected_exit_code="$2"
    shift 2
    local actual_exit_code=0

    # Run command, capture exit code
    "$@" >/dev/null 2>&1 || actual_exit_code=$?

    if [[ $actual_exit_code -eq $expected_exit_code ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((tests_passed++))
    else
        echo -e "${RED}✗${NC} $test_name (expected exit $expected_exit_code, got $actual_exit_code)"
        ((tests_failed++))
    fi
}

echo "Running smoke tests for minimal-safe-script..."
echo

# Setup: Create test file
echo -e "line 1\nline 2\nline 3" > "$TEST_FILE"

# Test 1: Help flag should exit 0
run_test "Help flag exits successfully" 0 "$SCRIPT" --help

# Test 2: Script works with valid file
run_test "Script processes valid file" 0 "$SCRIPT" "$TEST_FILE"

# Test 3: Script fails with missing file
run_test "Script rejects missing file" 1 "$SCRIPT" "nonexistent.txt"

# Test 4: Script fails without arguments
run_test "Script requires arguments" 1 "$SCRIPT"

# Test 5: Verbose flag works
run_test "Verbose flag works" 0 "$SCRIPT" --verbose "$TEST_FILE"

# Test 6: Unknown flag is rejected
run_test "Unknown flag is rejected" 1 "$SCRIPT" --unknown "$TEST_FILE"

# Cleanup
rm -f "$TEST_FILE"

# Results
echo
echo "===================="
echo "Tests passed: $tests_passed"
echo "Tests failed: $tests_failed"
echo "===================="

# Exit with failure if any tests failed
[[ $tests_failed -eq 0 ]]
