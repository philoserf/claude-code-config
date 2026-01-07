# Exit Code Semantics

Claude Code hooks use specific exit codes to communicate whether operations should proceed or be blocked.

## Exit Code Reference

| Exit Code | Meaning         | When to Use                                    |
| --------- | --------------- | ---------------------------------------------- |
| **0**     | Allow operation | Validation passed OR hook encountered an error |
| **2**     | Block operation | Validation failed (PreToolUse only)            |
| **1**     | Reserved        | DO NOT USE - reserved for system errors        |

## Critical Rule: Hook Errors Always Exit 0

**When a hook itself encounters an error** (missing dependency, crash, etc.), it MUST exit 0, not 1 or 2.

**Why**: Hooks should never block the user due to hook infrastructure problems. Only block when validating user actions.

## Exit 0: Allow Operation

Use exit 0 in these scenarios:

### 1. Validation Passed

````python
# Validation succeeded, allow operation
if no_errors:
    sys.exit(0)
```text

### 2. Hook Error (Critical)

```python
# Hook crashed - don't block user
try:
    # Hook logic
    ...
except Exception as e:
    print(f"Hook error: {e}", file=sys.stderr)
    sys.exit(0)  # Allow operation despite hook failure
```text

### 3. Missing Dependency

```python
# Dependency not available - degrade gracefully
try:
    import yaml
except ImportError:
    print("Warning: PyYAML not installed, skipping validation", file=sys.stderr)
    sys.exit(0)  # Don't block user
```text

### 4. File Type Doesn't Match

```python
# Hook only validates specific files
if not file_path.endswith(".md"):
    sys.exit(0)  # Not relevant, allow operation
```text

### 5. PostToolUse/Notification/SessionStart Hooks

```python
# These hook types can't block anyway
# Always exit 0 (exit code is ignored)
sys.exit(0)
```text

## Exit 2: Block Operation

Use exit 2 ONLY in PreToolUse hooks when **validation fails**:

### When to Block

**Valid Blocking Scenarios**:

- File content violates required format (invalid YAML, JSON, etc.)
- Security policy violation (writing secrets, dangerous commands)
- Required fields missing
- Invalid configuration

**Example**:

```python
# Validate YAML frontmatter
if errors:
    print(f"Validation errors:", file=sys.stderr)
    for error in errors:
        print(f"  • {error}", file=sys.stderr)
    sys.exit(2)  # Block operation

# No errors, allow
sys.exit(0)
```text

### When NOT to Block

**Invalid Blocking Scenarios**:

- Hook can't parse input (hook error, not validation error)
- Missing dependency (infrastructure problem)
- Hook timeout (performance issue)
- File doesn't need validation (type mismatch)

## Exit 1: Reserved (Never Use)

Exit code 1 is reserved and should NEVER be used by hooks.

**Why**: Exit 1 is for general errors and creates ambiguity - is it a hook error or validation failure?

**Use 0 or 2 instead**:

- Hook error? → Exit 0
- Validation failed? → Exit 2

## Examples from Actual Hooks

### validate-config.py (Lines 96-187)

Perfect example of exit code usage:

```python
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    if not file_path or not content:
        sys.exit(0)  # No input, allow

    # Only validate .claude/ files
    if "/.claude/" not in file_path and not file_path.startswith(".claude/"):
        sys.exit(0)  # Not relevant, allow

    # Only validate markdown files
    if not file_path.endswith(".md"):
        sys.exit(0)  # Not relevant, allow

    # ... validation logic ...

    if errors:
        print(f"Validation errors:", file=sys.stderr)
        for error in errors:
            print(f"  • {error}", file=sys.stderr)
        sys.exit(2)  # Block operation

    # All validation passed
    sys.exit(0)

except Exception as e:
    # Don't block on unexpected errors
    print(f"Error in config validation hook: {e}", file=sys.stderr)
    sys.exit(0)  # Allow operation despite hook error
```text

**Key Patterns**:

1. Exit 0 for non-matching files (lines 102, 106, 110, 125)
2. Exit 2 for validation failures (line 179)
3. Exit 0 on hook exceptions (line 187)
4. Exit 0 when validation passes (line 182)

### log-git-commands.sh

Simple informational hook (always exits 0):

```bash
#!/usr/bin/env bash
# Always exits 0 - informational only, never blocks

stdin_data=$(cat)
command=$(echo "$stdin_data" | jq -r '.tool_input.command // empty')

if [[ "$command" =~ ^(git|gh|dot) ]]; then
    echo "[Hook] Git command: $command" >&2
fi

exit 0  # Always allow
```text

**Pattern**: Informational hooks never block, always exit 0.

## Anti-Patterns

### ✗ Wrong: Exit 1 on Validation Failure

```python
# ✗ Bad: Using exit 1
if errors:
    print(f"Validation failed", file=sys.stderr)
    sys.exit(1)  # Wrong! Use 2 to block
```text

**Fix**:

```python
# ✓ Good: Using exit 2
if errors:
    print(f"Validation failed", file=sys.stderr)
    sys.exit(2)  # Correct
```text

### ✗ Wrong: Exit Non-Zero on Hook Error

```python
# ✗ Bad: Blocking on hook error
try:
    result = some_operation()
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)  # Wrong! Blocks user
```text

**Fix**:

```python
# ✓ Good: Allow on hook error
try:
    result = some_operation()
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block user
```text

### ✗ Wrong: Exit 2 from Non-PreToolUse Hook

```python
# ✗ Bad: PostToolUse trying to block
# PostToolUse hook (runs AFTER operation)
if formatting_failed:
    sys.exit(2)  # Wrong! Operation already happened
```text

**Fix**:

```python
# ✓ Good: Exit 0 (can't block anyway)
if formatting_failed:
    print(f"Warning: Formatting failed", file=sys.stderr)
    sys.exit(0)  # Exit code ignored for PostToolUse
```text

### ✗ Wrong: Implicit Exit (No Explicit Exit)

```python
# ✗ Bad: No explicit exit
if errors:
    print(f"Errors found", file=sys.stderr)
    # Implicitly exits 0 - doesn't block!
```text

**Fix**:

```python
# ✓ Good: Explicit exit 2
if errors:
    print(f"Errors found", file=sys.stderr)
    sys.exit(2)  # Explicit block
```text

## Decision Tree

Use this decision tree to choose the correct exit code:

```text
Is this a PreToolUse hook?
├─ No → Always exit 0 (other hook types can't block)
└─ Yes
   └─ Did the hook complete successfully?
      ├─ No (exception/error in hook) → Exit 0 (don't block on hook failure)
      └─ Yes
         └─ Did validation pass?
            ├─ Yes → Exit 0 (allow operation)
            └─ No → Exit 2 (block operation)
```text

## Testing Exit Codes

Test hooks with different scenarios:

### Test 1: Happy Path

```bash
echo '{"tool":"Write","tool_input":{"file_path":"test.md","content":"valid"}}' | \
  python3 hook.py
echo $?  # Should be 0
```text

### Test 2: Validation Failure

```bash
echo '{"tool":"Write","tool_input":{"file_path":"test.md","content":"invalid"}}' | \
  python3 hook.py
echo $?  # Should be 2
```text

### Test 3: Hook Error

```bash
echo 'invalid json' | python3 hook.py
echo $?  # Should be 0 (hook error, don't block)
```text

## Summary

**Simple Rules**:

1. Validation passed → Exit 0
2. Validation failed (PreToolUse only) → Exit 2
3. Hook error → Exit 0
4. Never use Exit 1
5. All non-PreToolUse hooks always exit 0

**When in doubt, exit 0** - it's better to allow an operation than to block the user due to a hook bug.
````
