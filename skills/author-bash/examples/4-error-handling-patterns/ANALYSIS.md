# Analysis: Error Handling Patterns

## Key Patterns

### 1. Enhanced ERR Trap with Context

```bash
error_handler() {
    local line_number=$1
    local command="$2"
    local error_code="${3:-1}"
    echo "ERROR at line $line_number: $command (exit: $error_code)" >&2
}

trap 'error_handler ${LINENO} "$BASH_COMMAND" $?' ERR
```

Provides detailed error context when failures occur.

### 2. Explicit Command Checking

```bash
check_command() {
    local description="$1"
    shift
    if ! "$@"; then
        echo "Error: $description failed" >&2
        return 1
    fi
}
```

Makes success verification explicit and provides context.

### 3. Expected Failures

```bash
set +e  # Temporarily allow failures
command_that_might_fail
exit_code=$?
set -e  # Re-enable

if [[ $exit_code -ne 0 ]]; then
    # Handle expected failure
fi
```

Handles cases where failure is acceptable.

### 4. Recovery Strategies

- Retry logic for transient failures
- Fallback to alternative methods
- Graceful degradation
- Cleanup on error

## Testing Failure Scenarios

Create `failure-scenarios.md` to document:

- What can fail
- How to handle each failure
- Recovery strategies
- When to fail vs. degrade

## References

- [patterns-and-conventions.md](../../patterns-and-conventions.md) -
  Strict Mode and Error Handling section
