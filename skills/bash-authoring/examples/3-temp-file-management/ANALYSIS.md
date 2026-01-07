# Analysis: Temporary File Management

## Key Patterns

### 1. Secure Temp File Creation with mktemp

```bash
TEMP_FILE=$(mktemp -t "${SCRIPT_NAME}.XXXXXXXXXX")
```

**Why mktemp?**

- Creates file with random, unpredictable name
- Sets restrictive permissions (0600 - owner only)
- Prevents race conditions and symlink attacks
- Returns absolute path

**Never do this**:

```bash
# INSECURE - predictable name, race conditions
TEMP_FILE="/tmp/myfile.$$"  # BAD!
```

### 2. EXIT Trap for Guaranteed Cleanup

```bash
trap cleanup EXIT
```

**Why EXIT trap?**

- Runs on normal exit, errors, and interrupts
- Guarantees cleanup even if script fails
- Handles Ctrl+C gracefully

### 3. Cleanup Verification

```bash
rm -f "$TEMP_FILE"
if [[ -f "$TEMP_FILE" ]]; then
    echo "Warning: Failed to remove temporary file" >&2
fi
```

**Always verify cleanup succeeded** to catch permission issues or full disk.

## Testing

```bash
# Normal operation
echo -e "line 3\nline 1\nline 2" > test.txt
./script.sh test.txt
# Verify temp file cleaned up: ls /tmp/${SCRIPT_NAME}.* should be empty

# Test cleanup on error (simulate by killing script mid-execution)
./script.sh large-file.txt &
sleep 0.5
kill %1
# Temp file should still be cleaned up
```

## References

- [patterns-and-conventions.md](../../patterns-and-conventions.md)
- [safety-and-security.md](../../safety-and-security.md)
