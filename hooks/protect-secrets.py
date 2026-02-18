#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# ///
# Secret protection hook - blocks all tool operations targeting Archive/keys/
# Runs on PreToolUse for Read, Write, Edit, Bash
# Exit codes: 0 = allow, 2 = block

import json
import sys
import re

PROTECTED_PATH = "Archive/keys"

try:
    data = json.load(sys.stdin)
    tool_input = data.get("tool_input", {})
    tool_name = data.get("tool_name", "")

    # Check file-path tools (Read, Write, Edit)
    file_path = tool_input.get("file_path", "")
    if file_path and PROTECTED_PATH in file_path:
        print("Blocked: Archive/keys/ contains cryptographic material", file=sys.stderr)
        sys.exit(2)

    # Check Bash commands for paths targeting Archive/keys
    command = tool_input.get("command", "")
    if command and re.search(r"Archive/keys", command):
        print("Blocked: Archive/keys/ contains cryptographic material", file=sys.stderr)
        sys.exit(2)

    # Check Glob/Grep path parameter
    path = tool_input.get("path", "")
    if path and PROTECTED_PATH in path:
        print("Blocked: Archive/keys/ contains cryptographic material", file=sys.stderr)
        sys.exit(2)

    # Check Glob pattern (could match into Archive/keys/)
    pattern = tool_input.get("pattern", "")
    if pattern and PROTECTED_PATH in pattern:
        print("Blocked: Archive/keys/ contains cryptographic material", file=sys.stderr)
        sys.exit(2)

    sys.exit(0)

except Exception:
    sys.exit(0)  # Don't block on errors
