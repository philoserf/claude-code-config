# JSON stdin Handling

Claude Code hooks receive JSON data via stdin. Safe parsing is critical to prevent crashes and ensure graceful degradation.

## Core Principle

**Always use safe parsing with `.get()` methods and try/except blocks.**

Never use direct key access (`data["key"]`) - it will crash if the key doesn't exist.

## Python Patterns

### Safe Parsing Pattern (Recommended)

```python
import json
import sys

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    # Safe to use file_path and content here
    # Empty strings if keys don't exist

except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block on parsing error

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block on unexpected error
```

**Key Points**:

1. `json.load(sys.stdin)` - Parse stdin directly
2. `.get("key", default)` - Safe access with default
3. Nested `.get()` - `data.get("outer", {}).get("inner", "")`
4. `try/except` - Handle malformed JSON
5. `sys.exit(0)` - Don't block on parsing errors

### Example from validate-config.py (Lines 96-102)

```python
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    if not file_path or not content:
        sys.exit(0)

    # Continue with validation...
```

**Pattern Analysis**:

- Uses `json.load(sys.stdin)` for direct parsing
- Uses `.get()` with empty dict default for nesting
- Checks for empty values and exits early
- Wrapped in try/except (lines 96, 184-187)

### Anti-Pattern: Direct Key Access

```python
# ✗ Bad: Will crash if keys don't exist
try:
    data = json.load(sys.stdin)
    file_path = data["tool_input"]["file_path"]  # Crashes if key missing
    content = data["tool_input"]["content"]      # Crashes if key missing
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Problems**:

- Crashes if `tool_input` key doesn't exist
- Crashes if `file_path` or `content` keys don't exist
- Forces error handling path instead of graceful defaults

**Fix**:

```python
# ✓ Good: Safe with defaults
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

### Common JSON Structure

Different hook types receive different JSON structures:

#### PreToolUse Hooks

```json
{
  "tool": "Write",
  "tool_input": {
    "file_path": "/path/to/file.md",
    "content": "file contents..."
  }
}
```

**Safe Access**:

```python
tool = data.get("tool", "")
file_path = data.get("tool_input", {}).get("file_path", "")
content = data.get("tool_input", {}).get("content", "")
```

#### PostToolUse Hooks

```json
{
  "tool": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.md",
    "old_string": "...",
    "new_string": "..."
  },
  "tool_output": "success message"
}
```

**Safe Access**:

```python
tool = data.get("tool", "")
file_path = data.get("tool_input", {}).get("file_path", "")
old_string = data.get("tool_input", {}).get("old_string", "")
new_string = data.get("tool_input", {}).get("new_string", "")
output = data.get("tool_output", "")
```

#### Bash Tool (PreToolUse)

```json
{
  "tool": "Bash",
  "tool_input": {
    "command": "git status",
    "description": "Show working tree status"
  }
}
```

**Safe Access**:

```python
tool = data.get("tool", "")
command = data.get("tool_input", {}).get("command", "")
description = data.get("tool_input", {}).get("description", "")
```

## Bash Patterns

### Using jq for JSON Parsing

```bash
#!/usr/bin/env bash

# Read stdin to variable
stdin_data=$(cat)

# Parse specific fields with jq
# Use '// empty' for default empty string
tool=$(echo "$stdin_data" | jq -r '.tool // empty')
file_path=$(echo "$stdin_data" | jq -r '.tool_input.file_path // empty')
content=$(echo "$stdin_data" | jq -r '.tool_input.content // empty')

# Check if we got data
if [[ -z "$tool" ]]; then
    echo "Error: No tool in JSON" >&2
    exit 0  # Don't block
fi

# Use the parsed data
echo "Processing tool: $tool" >&2

exit 0
```

**Key Points**:

1. `stdin_data=$(cat)` - Read all stdin to variable
2. `jq -r '.path // empty'` - Extract with default empty
3. `[[ -z "$var" ]]` - Check for empty values
4. Exit 0 on parsing errors

### Example from log-git-commands.sh

```bash
#!/usr/bin/env bash

stdin_data=$(cat)
command=$(echo "$stdin_data" | jq -r '.tool_input.command // empty')

if [[ "$command" =~ ^(git|gh|dot) ]]; then
    echo "[Hook] Git command: $command" >&2
fi

exit 0
```

**Pattern Analysis**:

- Simple: just extracts command field
- Uses `// empty` default
- Safe regex match with `[[ =~ ]]`
- Always exits 0 (informational only)

### Anti-Pattern: Unsafe Bash Parsing

```bash
# ✗ Bad: No error handling
stdin_data=$(cat)
file_path=$(echo "$stdin_data" | jq -r '.tool_input.file_path')
# Crashes if file_path doesn't exist
```

**Fix**:

```bash
# ✓ Good: Safe with default
stdin_data=$(cat)
file_path=$(echo "$stdin_data" | jq -r '.tool_input.file_path // empty')

# Check for empty
if [[ -z "$file_path" ]]; then
    exit 0  # No file path, skip
fi
```

## Validation After Parsing

After safely parsing JSON, validate the data before using it:

### Python Validation

```python
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    # Validate we got required data
    if not file_path or not content:
        sys.exit(0)  # Missing data, skip

    # Validate file type
    if not file_path.endswith(".md"):
        sys.exit(0)  # Not our file type, skip

    # Validate path
    if "/.claude/" not in file_path:
        sys.exit(0)  # Not in .claude/, skip

    # Now safe to process
    # ... validation logic ...

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

### Bash Validation

```bash
#!/usr/bin/env bash

stdin_data=$(cat)
file_path=$(echo "$stdin_data" | jq -r '.tool_input.file_path // empty')

# Validate we got data
if [[ -z "$file_path" ]]; then
    exit 0
fi

# Validate file extension
if [[ ! "$file_path" =~ \.md$ ]]; then
    exit 0
fi

# Now safe to process
echo "Processing: $file_path" >&2

exit 0
```

## Complete Examples

### Python Hook with Full Safety

```python
#!/usr/bin/env python3
import json
import sys

try:
    # Parse JSON safely
    data = json.load(sys.stdin)
    tool = data.get("tool", "")
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    # Validate required fields
    if not file_path or not content:
        sys.exit(0)

    # Validate file type
    if not file_path.endswith(".py"):
        sys.exit(0)

    # Process the file
    errors = []

    # ... validation logic ...

    if errors:
        print("Validation errors:", file=sys.stderr)
        for error in errors:
            print(f"  • {error}", file=sys.stderr)
        sys.exit(2)  # Block operation

    # Success
    sys.exit(0)

except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON: {e}", file=sys.stderr)
    sys.exit(0)

except Exception as e:
    print(f"Error in hook: {e}", file=sys.stderr)
    sys.exit(0)
```

### Bash Hook with Full Safety

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read and parse JSON
stdin_data=$(cat)
tool=$(echo "$stdin_data" | jq -r '.tool // empty')
command=$(echo "$stdin_data" | jq -r '.tool_input.command // empty')

# Validate we got data
if [[ -z "$tool" ]] || [[ -z "$command" ]]; then
    exit 0
fi

# Only process Bash tool
if [[ "$tool" != "Bash" ]]; then
    exit 0
fi

# Process command
if [[ "$command" =~ ^git ]]; then
    echo "[Hook] Git command detected: $command" >&2
fi

# Always allow (informational only)
exit 0
```

## Testing JSON Handling

### Test 1: Valid JSON

```bash
echo '{"tool":"Write","tool_input":{"file_path":"test.md","content":"hello"}}' | \
  python3 hook.py
# Should work correctly
```

### Test 2: Missing Keys

```bash
echo '{"tool":"Write","tool_input":{}}' | python3 hook.py
# Should exit 0 (no file_path or content)
```

### Test 3: Invalid JSON

```bash
echo '{invalid json}' | python3 hook.py
# Should exit 0 (parsing error, don't block)
```

### Test 4: Empty stdin

```bash
echo '' | python3 hook.py
# Should exit 0 (no input)
```

## Summary

**Safe JSON Handling Checklist**:

- [ ] Use `json.load(sys.stdin)` in Python or `jq` in Bash
- [ ] Use `.get()` with defaults, never direct key access
- [ ] Wrap in try/except (Python) or check for empty (Bash)
- [ ] Validate required fields after parsing
- [ ] Exit 0 on parsing errors (don't block user)
- [ ] Test with valid JSON, missing keys, invalid JSON, and empty stdin

**Golden Rule**: If parsing fails, exit 0 - it's a hook error, not a validation error.
