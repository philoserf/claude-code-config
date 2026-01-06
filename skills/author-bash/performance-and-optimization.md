# Performance and Optimization

Optimization techniques, profiling strategies, and observability patterns for high-performance Bash scripts.

## Performance Optimization Techniques

### Avoid Subshells

- Avoid subshells in loops; use `while read` instead of `for i in $(cat file)`
- Example: `while IFS= read -r line; do ...; done < file` (fast) vs `for line in $(cat file); do ...; done` (slow)
- Process files line-by-line for large files instead of loading entire file into memory

### Use Built-ins

- Use Bash built-ins over external commands when possible
- `[[ ]]` instead of `test` or `[ ]` (built-in is faster)
- `${var//pattern/replacement}` instead of `sed` for simple substitutions
- Arithmetic expansion `$(( ))` instead of `expr` for calculations

### Batch Operations

- Batch operations instead of repeated single operations
- Use one `sed` command with multiple expressions: `sed -e 's/foo/bar/' -e 's/baz/qux/'`
- Avoid repeated command substitutions; store result in variable once

### Array Operations

- Use `mapfile`/`readarray` for efficient array population from command output
- Example: `mapfile -t lines < file` instead of `lines=($(cat file))`
- Use associative arrays for lookups instead of repeated grepping

### Output Formatting

- Prefer `printf` over `echo` for formatted output (faster and more reliable)
- Use here-documents for multi-line output instead of multiple echo commands

### Parallel Processing

- Use `xargs -P` for parallel processing when operations are independent
- Example: `find . -name '*.txt' -print0 | xargs -0 -P $(nproc) -n 1 process_file`
- Balance parallelism: `$(nproc)` gives CPU core count
- Be aware of resource constraints when using parallel processing

## Performance Profiling

### Built-in Timing

Use `time` command for basic profiling:

```bash
time ./script.sh
```

Detailed resource usage with GNU time:

```bash
/usr/bin/time -v ./script.sh
```

### Custom Timing

Use `TIMEFORMAT` for custom timing output:

```bash
TIMEFORMAT='Real: %R, User: %U, System: %S'
time {
  # code to measure
}
```

### Microsecond Precision (Bash 5.2+)

```bash
start=$EPOCHREALTIME
# code to measure
end=$EPOCHREALTIME
elapsed=$(bc <<< "$end - $start")
```

See [advanced-techniques.md](advanced-techniques.md) for more profiling patterns.

## Observability & Logging

### Structured Logging

Output JSON for log aggregation systems:

```bash
log_json() {
  local level=$1
  local message=$2
  printf '{"timestamp":"%s","level":"%s","message":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$level" "$message"
}
```

### Log Levels

Implement configurable verbosity:

```bash
# DEBUG=4, INFO=3, WARN=2, ERROR=1
LOG_LEVEL=${LOG_LEVEL:-3}

log_debug() { [[ $LOG_LEVEL -ge 4 ]] && echo "[DEBUG] $*" >&2; }
log_info()  { [[ $LOG_LEVEL -ge 3 ]] && echo "[INFO] $*" >&2; }
log_warn()  { [[ $LOG_LEVEL -ge 2 ]] && echo "[WARN] $*" >&2; }
log_error() { [[ $LOG_LEVEL -ge 1 ]] && echo "[ERROR] $*" >&2; }
```

### Syslog Integration

Use `logger` command for system log integration:

```bash
log_info() {
  logger -t "$SCRIPT_NAME" -p user.info "$*"
  echo "[INFO] $*" >&2
}
```

### Distributed Tracing

Add trace IDs for multi-script workflow correlation:

```bash
TRACE_ID=${TRACE_ID:-$(uuidgen)}
export TRACE_ID

log_with_trace() {
  echo "[TRACE:$TRACE_ID] $*" >&2
}
```

### Metrics Export

Output Prometheus-format metrics:

```bash
echo "# TYPE script_duration_seconds gauge"
echo "script_duration_seconds $elapsed"
echo "# TYPE script_lines_processed counter"
echo "script_lines_processed $count"
```

### Error Context

Include stack traces and environment info in error logs:

```bash
trap 'echo "Error at line $LINENO in $BASH_SOURCE: exit code $?" >&2' ERR
```

### Log Rotation

For long-running scripts, implement log rotation:

```bash
if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE") -gt 10485760 ]]; then
  mv "$LOG_FILE" "$LOG_FILE.1"
fi
```

### Performance Metrics

Track execution time, resource usage, and external call latency:

```bash
track_performance() {
  local start=$SECONDS
  "$@"
  local duration=$((SECONDS - start))
  echo "Command '$*' took ${duration}s" >&2
}
```
