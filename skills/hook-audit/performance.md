# Hook Performance

Hook performance is critical since PreToolUse hooks block user interaction.

## Performance Targets by Hook Type

| Hook Type    | Target | Rationale                                  |
| ------------ | ------ | ------------------------------------------ |
| PreToolUse   | <500ms | Blocks user interaction                    |
| PostToolUse  | <2s    | Runs after operation, less critical        |
| Notification | <100ms | Quick notification only                    |
| SessionStart | <5s    | Runs once at startup, more time acceptable |

## PreToolUse Hooks (<500ms)

These hooks block the user, so speed is critical.

### Optimization Strategies

#### 1. Early Exit for Non-Matching Files

```python
# Exit immediately if file doesn't match
if not file_path.endswith((".md", ".py", ".js")):
    sys.exit(0)

# Only validate specific paths
if "/.claude/" not in file_path:
    sys.exit(0)
```

**Impact**: Reduces 99% of hook executions to <1ms

#### 2. Lightweight Parsing

```python
# ✓ Fast: Regex for simple checks
import re
if not re.match(r'^---\n', content):
    sys.exit(0)

# ✗ Slow: Full AST parsing
import ast
tree = ast.parse(content)  # Expensive for just checking format
```

#### 3. Cache Expensive Operations

```python
import functools

@functools.lru_cache(maxsize=128)
def get_validation_rules(file_type):
    # Expensive operation, cache results
    return load_rules(file_type)
```

#### 4. Lazy Imports

```python
# ✓ Good: Import only when needed
if file_path.endswith(".yaml"):
    import yaml  # Only import if processing YAML

# ✗ Bad: Always import
import yaml  # Imported even if not used
```

### Example: validate-config.py (5ms timeout)

```python
# Early exits for non-matching files (lines 102-125)
if not file_path or not content:
    sys.exit(0)  # <1ms

if "/.claude/" not in file_path and not file_path.startswith(".claude/"):
    sys.exit(0)  # <1ms

if not file_path.endswith(".md"):
    sys.exit(0)  # <1ms

# File type detection (10-20ms for complex regex)
if "/agents/" in file_path and "/references/" not in file_path:
    file_type = "agent"
elif "/skills/" in file_path and "SKILL.md" in file_path:
    file_type = "skill"
else:
    sys.exit(0)  # Not our file, <1ms

# YAML parsing only for matching files (50-100ms)
frontmatter = extract_frontmatter(content)

# Validation (10-50ms depending on complexity)
errors = validate_agent(frontmatter, file_path)
```

**Total**: 70-180ms for matching files, <1ms for non-matching

## PostToolUse Hooks (<2s)

More time available since operation already completed.

### Suitable Operations

- **Auto-formatting**: gofmt, prettier (100-500ms)
- **Logging**: Write to log files (10-50ms)
- **Notifications**: Send notifications (50-200ms)
- **Metrics**: Track operations (10-100ms)

### Example: auto-format.sh

```bash
#!/usr/bin/env bash
# Auto-formatting (runs after Edit/Write)

stdin_data=$(cat)
file_path=$(echo "$stdin_data" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
    exit 0
fi

# Format based on extension
case "$file_path" in
    *.go)
        gofmt -w "$file_path" 2>/dev/null || true  # 50-200ms
        ;;
    *.js|*.jsx|*.ts|*.tsx|*.json|*.md)
        prettier --write "$file_path" 2>/dev/null || true  # 100-500ms
        ;;
esac

exit 0
```

**Performance**: 50-500ms, acceptable for PostToolUse

## Notification Hooks (<100ms)

Must be very fast, minimal processing.

### Example: notify-idle.sh

```bash
#!/usr/bin/env bash
# macOS notification (very fast)

osascript -e 'display notification "Ready for your input" with title "Claude Code"' 2>/dev/null || true

exit 0
```

**Performance**: 20-50ms

## SessionStart Hooks (<5s)

Runs once at startup, more expensive operations acceptable.

### Example: load-session-context.sh

```bash
#!/usr/bin/env bash
# Load git context (one-time, more time acceptable)

if [[ -d .git ]]; then
    # Get branch and status (100-500ms)
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    status=$(git status --short 2>/dev/null)

    # Get recent commits (50-200ms)
    recent=$(git log -5 --oneline 2>/dev/null)

    # Output context
    echo "Git Repository Detected" >&2
    echo "Branch: $branch" >&2
    # ... more context ...
fi

exit 0
```

**Performance**: 200-1000ms, acceptable for SessionStart

## Timeout Configuration

Configure timeouts in `settings.json` based on hook type:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "command": "python3 ~/.claude/hooks/validate-config.py",
            "timeout": 5000
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "command": "~/.claude/hooks/validate-bash-commands.py",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "command": "~/.claude/hooks/auto-format.sh",
            "timeout": 10000
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "Idle",
        "hooks": [
          {
            "command": "~/.claude/hooks/notify-idle.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "command": "~/.claude/hooks/load-session-context.sh",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

### Timeout Guidelines

**PreToolUse**: 5-10 seconds

- Must finish before blocking, but allows for complex validation
- Hook should finish in <500ms but timeout provides safety margin

**PostToolUse**: 10-30 seconds

- More time available for formatting, logging
- Hook should finish in <2s but timeout accommodates complex operations

**Notification**: 5 seconds

- Should be fast (<100ms) but timeout prevents hangs

**SessionStart**: 10-30 seconds

- One-time operation, more time acceptable
- Hook should finish in <5s but timeout for network operations

## Performance Anti-Patterns

### ✗ Wrong: No Early Exit

```python
# ✗ Bad: Parses all files
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    # Expensive parsing before checking file type
    import yaml
    config = yaml.safe_load(content)  # Slow!

    # Finally check if we need this
    if not file_path.endswith(".yaml"):
        sys.exit(0)
```

**Fix**:

```python
# ✓ Good: Early exit
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    # Check file type first
    if not file_path.endswith(".yaml"):
        sys.exit(0)  # Fast exit

    # Only parse if needed
    import yaml
    config = yaml.safe_load(content)
```

### ✗ Wrong: Expensive Operations in Hot Path

```python
# ✗ Bad: Network request in PreToolUse hook
import requests

try:
    # Blocks user for 1-5 seconds!
    response = requests.get("https://api.example.com/validate")
    if response.json()["valid"]:
        sys.exit(0)
    else:
        sys.exit(2)
except:
    sys.exit(0)
```

**Fix**:

```python
# ✓ Good: Move to PostToolUse or use cache
import functools
import time

@functools.lru_cache(maxsize=1)
def get_validation_status(cache_key):
    # Cache for 5 minutes
    import requests
    response = requests.get("https://api.example.com/validate")
    return response.json()["valid"]

# Use cached result (fast)
cache_key = int(time.time() / 300)  # 5-minute buckets
if not get_validation_status(cache_key):
    sys.exit(2)
```

### ✗ Wrong: Full File Read for Metadata

```python
# ✗ Bad: Read entire large file
with open(file_path, 'r') as f:
    content = f.read()  # Could be 1MB+

# Just need first 100 lines for frontmatter
frontmatter = extract_frontmatter(content)
```

**Fix**:

```python
# ✓ Good: Read only what's needed
with open(file_path, 'r') as f:
    # Read first 4KB (frontmatter is usually <1KB)
    content = f.read(4096)

frontmatter = extract_frontmatter(content)
```

## Profiling Hooks

### Python: cProfile

```python
import cProfile
import pstats

profiler = cProfile.Profile()
profiler.enable()

# Hook logic here
...

profiler.disable()
stats = pstats.Stats(profiler)
stats.sort_stats('cumtime')
stats.print_stats(10)  # Top 10 slowest functions
```

### Bash: time

```bash
time python3 ~/.claude/hooks/validate-config.py < test-input.json
# Shows: real, user, sys time
```

### Manual Timing

```python
import time

start = time.time()

# Operation to measure
result = expensive_function()

elapsed = time.time() - start
print(f"Operation took {elapsed*1000:.2f}ms", file=sys.stderr)
```

## Performance Checklist

- [ ] Early exit for non-matching files
- [ ] Timeout configured appropriately (5s PreToolUse, 10s PostToolUse)
- [ ] Hook finishes within target time (<500ms PreToolUse, <2s PostToolUse)
- [ ] Lazy imports (only import when needed)
- [ ] Cache expensive operations
- [ ] No network requests in PreToolUse hooks
- [ ] Read only necessary data (not entire large files)
- [ ] Regex instead of full parsing when possible
- [ ] Profiled to identify bottlenecks

## Testing Performance

### Test 1: Non-Matching File (Should be <1ms)

```bash
time echo '{"tool":"Write","tool_input":{"file_path":"not-relevant.txt","content":"test"}}' | \
  python3 hook.py
# Should show <0.001s
```

### Test 2: Matching File (Should be <500ms for PreToolUse)

```bash
time echo '{"tool":"Write","tool_input":{"file_path":".claude/agents/test.md","content":"---\nname: test\n---"}}' | \
  python3 hook.py
# Should show <0.5s
```

### Test 3: Load Testing (100 invocations)

```bash
for i in {1..100}; do
    echo '{"tool":"Write","tool_input":{"file_path":"test.md","content":"test"}}' | \
      python3 hook.py >/dev/null
done | time
# Should complete in reasonable time
```

## Summary

**Performance Rules**:

1. **PreToolUse**: Target <500ms, timeout 5-10s
2. **PostToolUse**: Target <2s, timeout 10-30s
3. **Notification**: Target <100ms, timeout 5s
4. **SessionStart**: Target <5s, timeout 10-30s
5. **Early exit** for non-matching files (<1ms)
6. **Cache** expensive operations
7. **Profile** to find bottlenecks
8. **Test** performance regularly

**When in doubt**: Optimize PreToolUse hooks first - they directly impact user experience.
