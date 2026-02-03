# Error Handling Patterns

Hooks must handle errors gracefully to avoid blocking users due to infrastructure problems.

## Golden Rule

**Hook errors must exit 0, not block the user.**

Only validation failures should exit 2 (PreToolUse hooks only).

## Core Pattern: Try/Except Wrapper

Every hook should wrap its logic in try/except:

```python
#!/usr/bin/env python3
import json
import sys

try:
    # Hook logic here
    data = json.load(sys.stdin)
    # ... validation ...

    if validation_failed:
        sys.exit(2)  # Block operation

    sys.exit(0)  # Allow operation

except Exception as e:
    # Hook error - don't block user
    print(f"Error in hook: {e}", file=sys.stderr)
    sys.exit(0)
```

## Dependency Checking

Check for optional dependencies gracefully:

### Python Dependencies

```python
#!/usr/bin/env python3
import json
import sys

# Check for optional dependency
try:
    import yaml
except ImportError:
    print("Warning: PyYAML not installed, skipping validation", file=sys.stderr)
    sys.exit(0)  # Don't block user

# Dependency available, continue
try:
    data = json.load(sys.stdin)
    # ... use yaml module ...

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Example from validate-config.py (Lines 12-16)**:

```python
try:
    import yaml
except ImportError:
    # PyYAML not available - don't block
    print("Warning: PyYAML not installed, skipping config validation", file=sys.stderr)
    sys.exit(0)
```

**Key Pattern**:

- Check imports at module level
- Exit 0 if missing (informational message)
- Continue only if available

### Bash Dependencies

```bash
#!/usr/bin/env bash

# Check for required command
if ! command -v jq &> /dev/null; then
    echo "Warning: jq not installed, skipping" >&2
    exit 0
fi

# jq available, continue
stdin_data=$(cat)
file_path=$(echo "$stdin_data" | jq -r '.tool_input.file_path // empty')

exit 0
```

## Error Messages

Error messages should be:

1. **Clear** - Explain what went wrong
2. **To stderr** - Use `file=sys.stderr` or `>&2`
3. **Contextual** - Include relevant details

### Good Error Messages

```python
# ✓ Good: Clear, specific, helpful
print(f"Error: No YAML frontmatter found in {file_type} file", file=sys.stderr)
print(f"Error: Invalid YAML syntax in {file_type} frontmatter", file=sys.stderr)
print(f"Validation errors in {file_type} '{os.path.basename(file_path)}':", file=sys.stderr)
```

### Bad Error Messages

```python
# ✗ Bad: Vague, not helpful
print("Error", file=sys.stderr)
print("Failed", file=sys.stderr)
print("Something went wrong", file=sys.stderr)
```

## Example from validate-config.py

Complete error handling pattern (Lines 96-187):

```python
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    if not file_path or not content:
        sys.exit(0)

    # ... validation logic ...

    if frontmatter is None:
        print(f"Error: No YAML frontmatter found in {file_type} file", file=sys.stderr)
        print(f"Required format:", file=sys.stderr)
        # ... show expected format ...
        sys.exit(2)  # Block

    if frontmatter is False:
        print(f"Error: Invalid YAML syntax in {file_type} frontmatter", file=sys.stderr)
        print(f"Check for:", file=sys.stderr)
        print(f"  - Proper indentation", file=sys.stderr)
        # ... more hints ...
        sys.exit(2)  # Block

    if errors:
        print(f"Validation errors in {file_type} '{os.path.basename(file_path)}':", file=sys.stderr)
        for error in errors:
            print(f"  • {error}", file=sys.stderr)
        sys.exit(2)  # Block

    # All validation passed
    sys.exit(0)

except Exception as e:
    # Don't block on unexpected errors
    print(f"Error in config validation hook: {e}", file=sys.stderr)
    sys.exit(0)
```

**Pattern Analysis**:

1. **Outer try/except** wraps everything (lines 96, 184-187)
2. **Early exits** for non-matching files (lines 102, 106, 110, 125)
3. **Clear error messages** with context (lines 131-161, 173-178)
4. **Exit 2 for validation failures** (lines 153, 161, 179)
5. **Exit 0 for hook errors** (line 187)

## Common Error Scenarios

### 1. Missing File

```python
try:
    with open(file_path, 'r') as f:
        content = f.read()
except FileNotFoundError:
    print(f"Warning: File not found: {file_path}", file=sys.stderr)
    sys.exit(0)  # Not a validation error, hook issue
except Exception as e:
    print(f"Error reading file: {e}", file=sys.stderr)
    sys.exit(0)
```

### 2. Permission Error

```python
try:
    with open(file_path, 'w') as f:
        f.write(content)
except PermissionError:
    print(f"Warning: Permission denied: {file_path}", file=sys.stderr)
    sys.exit(0)  # Hook can't write, don't block
except Exception as e:
    print(f"Error writing file: {e}", file=sys.stderr)
    sys.exit(0)
```

### 3. Invalid Data Format

```python
try:
    config = yaml.safe_load(content)
except yaml.YAMLError as e:
    # This IS a validation error - block
    print(f"Error: Invalid YAML syntax: {e}", file=sys.stderr)
    sys.exit(2)
except Exception as e:
    # Unexpected error - don't block
    print(f"Error parsing YAML: {e}", file=sys.stderr)
    sys.exit(0)
```

### 4. Timeout Approaching

```python
import signal

def timeout_handler(signum, frame):
    print("Warning: Hook timeout approaching, exiting", file=sys.stderr)
    sys.exit(0)  # Don't block

# Set alarm for slightly before timeout
signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(timeout_seconds - 1)

try:
    # Hook logic
    ...
finally:
    signal.alarm(0)  # Cancel alarm
```

## Graceful Degradation

Hooks should degrade gracefully when encountering problems:

### Level 1: Full Functionality

```python
try:
    import yaml
    # Full YAML validation available
    config = yaml.safe_load(content)
    # ... comprehensive validation ...
except ImportError:
    # Degrade to Level 2
    pass
```

### Level 2: Basic Checks

```python
if 'yaml' not in sys.modules:
    # YAML not available, do basic checks
    if not content.startswith('---'):
        print("Warning: Missing frontmatter delimiter", file=sys.stderr)
        sys.exit(2)
```

### Level 3: Skip Gracefully

```python
if critical_dependency_missing:
    print("Warning: Skipping validation, dependency not available", file=sys.stderr)
    sys.exit(0)
```

## Anti-Patterns

### ✗ Wrong: Blocking on Hook Error

```python
# ✗ Bad: Blocks user on hook error
try:
    config = yaml.safe_load(content)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)  # Wrong! This blocks the user
```

**Fix**:

```python
# ✓ Good: Don't block on hook error
try:
    config = yaml.safe_load(content)
except yaml.YAMLError as e:
    # Validation error - block
    print(f"Invalid YAML: {e}", file=sys.stderr)
    sys.exit(2)
except Exception as e:
    # Hook error - don't block
    print(f"Error in hook: {e}", file=sys.stderr)
    sys.exit(0)
```

### ✗ Wrong: No Error Handling

```python
# ✗ Bad: No try/except
data = json.load(sys.stdin)  # Crashes on invalid JSON
config = yaml.safe_load(content)  # Crashes on invalid YAML
```

**Fix**:

```python
# ✓ Good: Proper error handling
try:
    data = json.load(sys.stdin)
    config = yaml.safe_load(content)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

### ✗ Wrong: Vague Error Messages

```python
# ✗ Bad: Not helpful
except Exception as e:
    print("Error", file=sys.stderr)
    sys.exit(0)
```

**Fix**:

```python
# ✓ Good: Specific and helpful
except yaml.YAMLError as e:
    print(f"Error: Invalid YAML syntax: {e}", file=sys.stderr)
    sys.exit(2)
except Exception as e:
    print(f"Error in config validation hook: {e}", file=sys.stderr)
    sys.exit(0)
```

### ✗ Wrong: Silent Failures

```python
# ✗ Bad: No error message
except Exception:
    sys.exit(0)
```

**Fix**:

```python
# ✓ Good: Log the error
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

## Error Handling Checklist

Use this checklist to audit hook error handling:

- [ ] Entire hook logic wrapped in try/except
- [ ] Dependencies checked before use
- [ ] Missing dependencies exit 0 (not 1 or 2)
- [ ] Validation errors exit 2 (PreToolUse only)
- [ ] Hook errors exit 0
- [ ] Error messages clear and specific
- [ ] Error messages go to stderr
- [ ] Graceful degradation when dependencies missing
- [ ] No silent failures (always log errors)
- [ ] Different exception types handled appropriately

## Testing Error Handling

Test these scenarios:

### Test 1: Missing Dependency

```bash
# Rename dependency temporarily
mv /path/to/dependency /path/to/dependency.bak
echo '{"tool":"Write","tool_input":{"file_path":"test.md","content":"test"}}' | \
  python3 hook.py
echo $?  # Should be 0
mv /path/to/dependency.bak /path/to/dependency
```

### Test 2: Invalid JSON

```bash
echo 'invalid json' | python3 hook.py
echo $?  # Should be 0
```

### Test 3: Missing Keys

```bash
echo '{"tool":"Write"}' | python3 hook.py
echo $?  # Should be 0
```

### Test 4: Validation Error

```bash
echo '{"tool":"Write","tool_input":{"file_path":"test.md","content":"invalid"}}' | \
  python3 hook.py
echo $?  # Should be 2
```

## Summary

**Error Handling Principles**:

1. **Wrap everything** in try/except
2. **Check dependencies** before use
3. **Exit 0** on hook errors
4. **Exit 2** on validation failures (PreToolUse only)
5. **Clear messages** to stderr
6. **Degrade gracefully** when dependencies missing
7. **Test error paths** thoroughly

**When in doubt, exit 0 and log the error** - never block the user due to hook infrastructure problems.
