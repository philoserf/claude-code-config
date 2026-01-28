#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# ///
# Bash command validation hook - suggests better tools for common operations

import json
import sys
import re

# Patterns to detect and suggestions
ANTI_PATTERNS = [
    (r"\bgrep\s", "Consider using Grep tool instead of grep command"),
    (r"\bfind\s+.*-name\b", "Consider using Glob tool instead of find command"),
    (r"\bcat\s+\S+\.(go|ts|js|py|md)", "Consider using Read tool instead of cat"),
    (r"\bsed\s+", "Consider using Edit tool for file modifications"),
    (r"\bawk\s+", "Consider using Edit tool for file modifications"),
]

try:
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command", "")

    if not command:
        sys.exit(0)

    warnings = []
    for pattern, message in ANTI_PATTERNS:
        if re.search(pattern, command):
            warnings.append(message)

    if warnings:
        print("⚠️  Command suggestions:")
        for warning in warnings:
            print(f"  • {warning}")
        # Don't block, just inform (output to stdout so Claude sees it)

    sys.exit(0)

except Exception:
    sys.exit(0)  # Don't block on errors
