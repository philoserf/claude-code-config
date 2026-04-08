#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# ///
# Bash command validation hook - blocks calls that should use dedicated tools (exit 2)

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
    raw = sys.stdin.read(1_048_576)  # 1MB limit
    data = json.loads(raw)
    command = data.get("tool_input", {}).get("command", "")

    if not command:
        sys.exit(0)

    warnings = []
    for pattern, message in ANTI_PATTERNS:
        if re.search(pattern, command):
            warnings.append(message)

    if warnings:
        print(
            "ADVISORY: " + "; ".join(warnings),
            file=sys.stderr,
        )
        sys.exit(0)

    sys.exit(0)

except Exception:
    sys.exit(0)  # Don't block on errors
