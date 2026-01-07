#!/usr/bin/env python3
# Markdown validation hook - validates markdown files before Write/Edit
# Runs on PreToolUse for Edit/Write operations on *.md files
# Exit codes: 0 = allow, 2 = block

import json
import sys
import os
import subprocess
import tempfile
import shutil

try:
    data = json.load(sys.stdin)

    # Early file path filtering - extract path first, before content
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path:
        sys.exit(0)

    # Only validate markdown files
    if not file_path.endswith(".md"):
        sys.exit(0)

    # Check if markdownlint is available
    if not shutil.which("markdownlint"):
        # Don't block if markdownlint isn't installed
        sys.exit(0)

    # Only extract content after file path filtering passes
    content = data.get("tool_input", {}).get("content", "")

    if not content:
        sys.exit(0)

    # Create a temporary file with the same basename for accurate linting
    basename = os.path.basename(file_path)
    temp_dir = tempfile.mkdtemp()
    temp_file = os.path.join(temp_dir, basename)

    try:
        # Write content to temp file
        with open(temp_file, "w", encoding="utf-8") as f:
            f.write(content)

        # Run markdownlint on the temp file
        result = subprocess.run(
            ["markdownlint", temp_file],
            capture_output=True,
            text=True,
            timeout=5,
        )

        # Clean up temp file
        os.remove(temp_file)
        os.rmdir(temp_dir)

        # If markdownlint found errors (exit code 1), parse and report them
        if result.returncode == 1 and result.stderr:
            errors = []
            for line in result.stderr.strip().split("\n"):
                # Parse format: "file:line error RULE/name Message [Context: "..."]"
                if " error " in line:
                    # Extract the relevant parts after the temp filename
                    parts = line.split(" error ", 1)
                    if len(parts) == 2:
                        # Extract line number from first part
                        line_num = parts[0].split(":")[-1]
                        # Get error details
                        error_details = parts[1]
                        errors.append(f"Line {line_num}: {error_details}")

            if errors:
                print(
                    f"Error: Markdownlint validation failed for {os.path.basename(file_path)}",
                    file=sys.stderr,
                )
                for error in errors:
                    print(f"  • {error}", file=sys.stderr)
                print(
                    f"\nFix these issues before writing the file.",
                    file=sys.stderr,
                )
                print(
                    f"Tip: Run 'markdownlint --fix {file_path}' to auto-fix some issues.",
                    file=sys.stderr,
                )
                sys.exit(2)

        # No errors found, allow the operation
        sys.exit(0)

    except subprocess.TimeoutExpired:
        # Clean up on timeout
        if os.path.exists(temp_file):
            os.remove(temp_file)
        if os.path.exists(temp_dir):
            os.rmdir(temp_dir)
        # Don't block on timeout
        sys.exit(0)

except Exception as e:
    # Don't block on unexpected errors
    print(f"Warning: Error in markdown validation hook: {e}", file=sys.stderr)
    sys.exit(0)
