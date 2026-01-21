#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = ["pyyaml>=6.0"]
# ///
# Config validation hook - validates YAML frontmatter in .claude/ files
# Runs on PreToolUse for Write/Edit operations
# Exit codes: 0 = allow, 2 = block

import json
import sys
import os
import re
import yaml

# Extension-specific validation rules
AGENT_REQUIRED_FIELDS = ["name", "description", "model"]
SKILL_REQUIRED_FIELDS = ["name", "description"]
OUTPUT_STYLE_REQUIRED_FIELDS = ["name", "description"]

VALID_MODELS = ["sonnet", "opus", "haiku"]


def extract_frontmatter(content):
    """Extract YAML frontmatter from markdown content."""
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None
    try:
        return yaml.safe_load(match.group(1))
    except yaml.YAMLError:
        return False


def validate_agent(frontmatter, file_path):
    """Validate agent frontmatter."""
    errors = []

    # Check required fields
    for field in AGENT_REQUIRED_FIELDS:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Validate model field
    if "model" in frontmatter:
        if frontmatter["model"] not in VALID_MODELS:
            errors.append(
                f"Invalid model: '{frontmatter['model']}'. Must be one of: {', '.join(VALID_MODELS)}"
            )

    # Check name matches filename
    filename = os.path.splitext(os.path.basename(file_path))[0]
    if "name" in frontmatter:
        if frontmatter["name"] != filename:
            errors.append(
                f"Name '{frontmatter['name']}' doesn't match filename '{filename}'"
            )

    return errors


def validate_skill(frontmatter, file_path):
    """Validate skill frontmatter."""
    errors = []

    # Check required fields
    for field in SKILL_REQUIRED_FIELDS:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Check description length (should be substantial for triggering)
    if "description" in frontmatter:
        desc_len = len(frontmatter["description"])
        if desc_len < 50:
            errors.append(
                f"Description too short ({desc_len} chars). Should be at least 50 chars and include what the skill does AND when to use it"
            )

    return errors


def validate_output_style(frontmatter):
    """Validate output-style frontmatter."""
    errors = []

    # Check required fields
    for field in OUTPUT_STYLE_REQUIRED_FIELDS:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    return errors


try:
    data = json.load(sys.stdin)

    # Early file path filtering - extract path first, before content
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path:
        sys.exit(0)

    # Only validate .claude/ files
    if "/.claude/" not in file_path and not file_path.startswith(".claude/"):
        sys.exit(0)

    # Only validate markdown files
    if not file_path.endswith(".md"):
        sys.exit(0)

    # Determine file type based on path
    # Agents are single files only (no subdirectories or references)
    if "/agents/" in file_path:
        file_type = "agent"
    elif "/skills/" in file_path and "SKILL.md" in file_path:
        file_type = "skill"
    elif "/output-styles/" in file_path:
        file_type = "output-style"
    else:
        # Don't validate other files (commands, references, README, etc.)
        sys.exit(0)

    # Only extract content after file path filtering passes
    content = data.get("tool_input", {}).get("content", "")

    if not content:
        sys.exit(0)

    # Extract and parse frontmatter
    frontmatter = extract_frontmatter(content)

    if frontmatter is None:
        print(f"Error: No YAML frontmatter found in {file_type} file", file=sys.stderr)
        print("Required format:", file=sys.stderr)
        print("---", file=sys.stderr)
        if file_type == "agent":
            print(
                f"name: {os.path.splitext(os.path.basename(file_path))[0]}",
                file=sys.stderr,
            )
            print(
                "description: Brief description of agent capabilities", file=sys.stderr
            )
            print("model: sonnet", file=sys.stderr)
        elif file_type == "skill":
            print("name: skill-name", file=sys.stderr)
            print(
                "description: Comprehensive description including when to use (50+ chars)",
                file=sys.stderr,
            )
        elif file_type == "output-style":
            print("name: Style Name", file=sys.stderr)
            print("description: Brief persona description", file=sys.stderr)
        print("---", file=sys.stderr)
        sys.exit(2)

    if frontmatter is False:
        print(f"Error: Invalid YAML syntax in {file_type} frontmatter", file=sys.stderr)
        print("Check for:", file=sys.stderr)
        print("  - Proper indentation", file=sys.stderr)
        print("  - Quoted strings with special characters", file=sys.stderr)
        print("  - Matching opening and closing quotes", file=sys.stderr)
        sys.exit(2)

    # Validate based on type
    errors = []
    if file_type == "agent":
        errors = validate_agent(frontmatter, file_path)
    elif file_type == "skill":
        errors = validate_skill(frontmatter, file_path)
    elif file_type == "output-style":
        errors = validate_output_style(frontmatter)

    if errors:
        print(
            f"Validation errors in {file_type} '{os.path.basename(file_path)}':",
            file=sys.stderr,
        )
        for error in errors:
            print(f"  • {error}", file=sys.stderr)
        sys.exit(2)

    # All validation passed
    sys.exit(0)

except Exception as e:
    # Don't block on unexpected errors
    print(f"Error in config validation hook: {e}", file=sys.stderr)
    sys.exit(0)
