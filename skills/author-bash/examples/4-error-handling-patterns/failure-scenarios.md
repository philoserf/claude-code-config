# Failure Scenarios

## Common Failure Points

### 1. File Operations

- **Failure**: File doesn't exist
- **Detection**: `[[ ! -f "$file" ]]`
- **Recovery**: Create with defaults or exit with clear error

### 2. Permission Issues

- **Failure**: Cannot read/write file
- **Detection**: `[[ ! -r "$file" ]]` or `[[ ! -w "$file" ]]`
- **Recovery**: Request elevated permissions or use alternative location

### 3. Network Operations

- **Failure**: Connection timeout, DNS failure
- **Detection**: Check exit code, parse error output
- **Recovery**: Retry with backoff, use cached data, fail gracefully

### 4. External Command Missing

- **Failure**: Required tool not installed
- **Detection**: `command -v tool_name`
- **Recovery**: Provide installation instructions, use fallback method

### 5. Disk Full

- **Failure**: Cannot write to disk
- **Detection**: Check exit codes from write operations
- **Recovery**: Clean up temp files, use alternative location, exit cleanly

## Testing Each Scenario

```bash
# Test missing file
./script.sh /nonexistent/path

# Test permission denied
chmod 000 test-file
./script.sh test-file
chmod 644 test-file

# Test disk full (simulation)
# Create small filesystem and fill it
```
