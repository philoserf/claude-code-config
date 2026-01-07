#!/usr/bin/env bash
#
# Verify cleanup works correctly
#

set -euo pipefail

echo "Testing cleanup on normal exit..."
echo -e "test\ndata\nlines" > test-input.txt
./script.sh test-input.txt

echo
echo "Testing cleanup on error..."
./script.sh nonexistent-file.txt 2>/dev/null || echo "Script failed as expected"

echo
echo "Checking for leftover temp files..."
count=$(find /tmp -name "script.sh.*" 2>/dev/null | wc -l)
if [[ $count -eq 0 ]]; then
    echo "✓ No temp files left behind"
else
    echo "✗ Warning: Found $count temp files in /tmp"
    find /tmp -name "script.sh.*" 2>/dev/null
fi

rm -f test-input.txt
