# Hook Examples

Concrete examples of good and bad hook patterns with before/after comparisons.

## Good Examples

### validate-config.py (187 lines) - Perfect PreToolUse Hook

**Purpose**: Validate YAML frontmatter in Claude Code customization files

**File**: `/Users/markayers/.claude/hooks/validate-config.py`

**Why It's Good**:

- ✓ Safe JSON parsing with try/except
- ✓ Correct exit codes (0 on error, 2 to block, never 1)
- ✓ Dependency checking (PyYAML with graceful degradation)
- ✓ Clear error messages with helpful hints
- ✓ File type validation before processing
- ✓ Early exits for non-matching files
- ✓ Fast performance (<100ms for most cases)

**Key Patterns**:

```python
#!/usr/bin/env python3
# 1. Clear header comment
# Config validation hook - validates YAML frontmatter in .claude/ files
# Runs on PreToolUse for Write/Edit operations
# Exit codes: 0 = allow, 2 = block

# 2. Dependency checking
try:
    import yaml
except ImportError:
    print("Warning: PyYAML not installed, skipping config validation", file=sys.stderr)
    sys.exit(0)  # Don't block

# 3. Safe JSON parsing
try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    # 4. Early exits for non-matching files
    if not file_path or not content:
        sys.exit(0)

    if "/.claude/" not in file_path and not file_path.startswith(".claude/"):
        sys.exit(0)

    if not file_path.endswith(".md"):
        sys.exit(0)

    # 5. File type detection
    if "/agents/" in file_path:
        file_type = "agent"
    elif "/skills/" in file_path and "SKILL.md" in file_path:
        file_type = "skill"
    else:
        sys.exit(0)  # Not our file type

    # 6. Validation logic
    frontmatter = extract_frontmatter(content)

    if frontmatter is None:
        print(f"Error: No YAML frontmatter found in {file_type} file", file=sys.stderr)
        sys.exit(2)  # Block

    if errors:
        print(f"Validation errors:", file=sys.stderr)
        for error in errors:
            print(f"  • {error}", file=sys.stderr)
        sys.exit(2)  # Block

    # 7. Success
    sys.exit(0)

# 8. Error handling - don't block on hook errors
except Exception as e:
    print(f"Error in config validation hook: {e}", file=sys.stderr)
    sys.exit(0)
```

**Performance**: <1ms for non-matching files, <100ms for validation

### log-git-commands.sh (13 lines) - Simple Informational Hook

**Purpose**: Log git, gh, and dotfile commands to stderr

**File**: `/Users/markayers/.claude/hooks/log-git-commands.sh`

**Why It's Good**:

- ✓ Simple and focused
- ✓ Safe jq parsing with `// empty` default
- ✓ Always exits 0 (informational only)
- ✓ Clear purpose
- ✓ Very fast (<5ms)

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# Log git, gh, and dot commands to stderr

stdin_data=$(cat)
command=$(echo "$stdin_data" | jq -r '.tool_input.command // empty')

if [[ "$command" =~ ^(git|gh|dot) ]]; then
    echo "[Hook] Git command: $command" >&2
fi

exit 0
```

**Pattern Analysis**:

1. Shebang line for bash
2. Clear header comment
3. Read stdin to variable
4. Safe jq parsing with default
5. Simple regex matching
6. Clear output to stderr
7. Always exits 0

## Before/After Refactorings

### Example 1: Missing try/except

**Before** (✗ Bad):

```python
#!/usr/bin/env python3
import json
import sys

# Will crash on invalid JSON!
data = json.load(sys.stdin)
file_path = data["tool_input"]["file_path"]  # Will crash if key missing

if not file_path.endswith(".py"):
    sys.exit(0)

# Validation logic...
if errors:
    sys.exit(2)
else:
    sys.exit(0)
```

**Problems**:

- No try/except wrapper
- Will crash on invalid JSON
- Direct key access (crashes if keys don't exist)
- No error handling for hook failures

**After** (✓ Good):

```python
#!/usr/bin/env python3
import json
import sys

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path:
        sys.exit(0)

    if not file_path.endswith(".py"):
        sys.exit(0)

    # Validation logic...
    if errors:
        sys.exit(2)
    else:
        sys.exit(0)

except Exception as e:
    print(f"Error in hook: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block on hook error
```

**Improvements**:

- Added try/except wrapper
- Safe JSON parsing with `.get()`
- Exit 0 on hook errors
- Clear error message

### Example 2: Wrong Exit Codes

**Before** (✗ Bad):

```python
#!/usr/bin/env python3
import json
import sys

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path.endswith(".md"):
        sys.exit(1)  # Wrong! Should be 0

    errors = validate_file(file_path)

    if errors:
        print("Validation failed", file=sys.stderr)
        sys.exit(1)  # Wrong! Should be 2

    sys.exit(0)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)  # Wrong! Should be 0
```

**Problems**:

- Uses exit 1 instead of 0 for non-matching files
- Uses exit 1 instead of 2 for validation failures
- Uses exit 1 instead of 0 for hook errors

**After** (✓ Good):

```python
#!/usr/bin/env python3
import json
import sys

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path.endswith(".md"):
        sys.exit(0)  # Not our file type, allow

    errors = validate_file(file_path)

    if errors:
        print("Validation failed:", file=sys.stderr)
        for error in errors:
            print(f"  • {error}", file=sys.stderr)
        sys.exit(2)  # Block operation

    sys.exit(0)  # Allow operation

except Exception as e:
    print(f"Error in hook: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block on hook error
```

**Improvements**:

- Exit 0 for non-matching files
- Exit 2 for validation failures
- Exit 0 for hook errors
- Better error messages

### Example 3: Missing Dependency Check

**Before** (✗ Bad):

```python
#!/usr/bin/env python3
import json
import sys
import yaml  # Crashes if PyYAML not installed!

try:
    data = json.load(sys.stdin)
    content = data.get("tool_input", {}).get("content", "")

    config = yaml.safe_load(content)

    # Validation...
    if errors:
        sys.exit(2)
    else:
        sys.exit(0)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Problems**:

- No dependency checking
- Crashes if PyYAML not installed
- Blocks user on missing dependency

**After** (✓ Good):

```python
#!/usr/bin/env python3
import json
import sys

# Check for optional dependency
try:
    import yaml
except ImportError:
    print("Warning: PyYAML not installed, skipping validation", file=sys.stderr)
    sys.exit(0)  # Don't block

try:
    data = json.load(sys.stdin)
    content = data.get("tool_input", {}).get("content", "")

    config = yaml.safe_load(content)

    # Validation...
    if errors:
        sys.exit(2)
    else:
        sys.exit(0)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Improvements**:

- Check dependency before use
- Exit 0 if missing (don't block)
- Clear warning message

### Example 4: No Early Exit

**Before** (✗ Bad):

```python
#!/usr/bin/env python3
import json
import sys
import yaml

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    # Expensive parsing BEFORE checking file type!
    config = yaml.safe_load(content)  # Slow for all files

    # Finally check if we need this
    if not file_path.endswith(".yaml"):
        sys.exit(0)

    # Now validate...
    if errors:
        sys.exit(2)

    sys.exit(0)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Problems**:

- No early exit
- Parses all files before checking type
- Slow performance (<500ms missed)

**After** (✓ Good):

```python
#!/usr/bin/env python3
import json
import sys

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    # Early exit for non-matching files
    if not file_path:
        sys.exit(0)

    if not file_path.endswith(".yaml"):
        sys.exit(0)  # Fast exit (<1ms)

    # Only import and parse if needed
    import yaml
    config = yaml.safe_load(content)

    # Now validate...
    if errors:
        sys.exit(2)

    sys.exit(0)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Improvements**:

- Early exit for non-matching files
- Lazy import (only import yaml if needed)
- Fast for non-matching files (<1ms)
- Expensive operations only when necessary

## Bad Examples (Anti-Patterns)

### Anti-Pattern 1: Blocking Hook (Worst Possible)

```python
#!/usr/bin/env python3
import json
import sys
import yaml

# Will crash on invalid JSON (blocks user)
data = json.load(sys.stdin)
file_path = data["tool_input"]["file_path"]  # Crashes if key missing
content = data["tool_input"]["content"]

# Will crash if PyYAML not installed (blocks user)
config = yaml.safe_load(content)

# Wrong exit code (blocks user on validation failure)
if not validate(config):
    sys.exit(1)  # Wrong! Should be 2

sys.exit(0)
```

**Problems** (Fatal):

- No try/except
- No dependency checking
- Direct key access
- Wrong exit code
- Will crash and block user

### Anti-Pattern 2: Silent Hook

```python
#!/usr/bin/env python3
import json
import sys

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path.endswith(".md"):
        sys.exit(0)

    errors = validate(file_path)

    if errors:
        # Silent! No error message
        sys.exit(2)

    sys.exit(0)

except Exception:
    # Silent! No error message
    sys.exit(0)
```

**Problems**:

- No error messages
- User doesn't know why operation blocked
- Hard to debug

### Anti-Pattern 3: Slow Hook

```python
#!/usr/bin/env python3
import json
import sys
import requests
import time

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    # Network request (1-5 seconds!) in PreToolUse hook
    response = requests.get("https://api.example.com/validate")
    if not response.json()["valid"]:
        sys.exit(2)

    # Unnecessary sleep
    time.sleep(1)

    sys.exit(0)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Problems**:

- Network request in PreToolUse (blocks user for 1-5s)
- Unnecessary delays
- > 500ms target missed

## Advanced Hook Types

### PostToolUse Hook - Auto-formatter

**Purpose**: Automatically format Go files after Write/Edit operations

**File**: `~/.claude/hooks/auto-format-go.sh`

**Why It's Good**:

- ✓ Runs after operation completes (non-blocking)
- ✓ Checks tool output for success before formatting
- ✓ Uses early exits for non-Go files
- ✓ Handles formatting errors gracefully
- ✓ Always exits 0 (can't block anyway)

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# Auto-format Go files after successful Write/Edit

stdin_data=$(cat)

# Extract file path and result
file_path=$(echo "$stdin_data" | jq -r '.tool_input.file_path // empty')
result=$(echo "$stdin_data" | jq -r '.result // empty')

# Early exits
if [[ -z "$file_path" ]]; then
    exit 0
fi

if [[ ! "$file_path" =~ \.go$ ]]; then
    exit 0  # Not a Go file
fi

# Check if tool operation succeeded
if [[ -z "$result" ]] || [[ "$result" == "null" ]]; then
    echo "Warning: Tool operation may have failed, skipping format" >&2
    exit 0
fi

# Format the file
if command -v gofmt &> /dev/null; then
    if gofmt -w "$file_path" 2>/dev/null; then
        echo "[Hook] Formatted Go file: $file_path" >&2
    else
        echo "Warning: gofmt failed for $file_path" >&2
    fi
else
    echo "Warning: gofmt not installed, skipping" >&2
fi

exit 0  # Always allow (PostToolUse can't block)
```

**Pattern Analysis**:

1. PostToolUse hooks receive both input and output
2. Check tool result to ensure operation succeeded
3. Early exits for non-matching files
4. Always exit 0 (operation already completed)
5. Graceful handling of missing tools

### Notification Hook - Desktop Alert on Idle

**Purpose**: Send desktop notification when Claude goes idle

**File**: `~/.claude/hooks/idle-notification.sh`

**Why It's Good**:

- ✓ Very fast (<100ms)
- ✓ Checks for notification tool availability
- ✓ Simple and focused
- ✓ Always exits 0

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# Send desktop notification on idle event

# Check for osascript (macOS)
if ! command -v osascript &> /dev/null; then
    exit 0  # Not on macOS, skip silently
fi

# Send notification
osascript -e 'display notification "Claude is now idle" with title "Claude Code"' 2>/dev/null

exit 0
```

**Cross-Platform Version**:

```python
#!/usr/bin/env python3
# Cross-platform idle notification

import sys
import platform
import subprocess

try:
    system = platform.system()

    if system == "Darwin":  # macOS
        subprocess.run([
            "osascript", "-e",
            'display notification "Claude is now idle" with title "Claude Code"'
        ], capture_output=True)
    elif system == "Linux":
        if subprocess.run(["which", "notify-send"], capture_output=True).returncode == 0:
            subprocess.run([
                "notify-send", "Claude Code", "Claude is now idle"
            ], capture_output=True)
    elif system == "Windows":
        # Could use windows toast notifications
        pass

    sys.exit(0)

except Exception as e:
    # Don't show errors for notifications
    sys.exit(0)
```

### SessionStart Hook - Load Git Context

**Purpose**: Load git repository information at session start

**File**: `~/.claude/hooks/load-git-context.sh`

**Why It's Good**:

- ✓ Runs once at session start
- ✓ Provides helpful context to stderr
- ✓ Handles non-git directories gracefully
- ✓ Fast enough for startup (<2s)

**Complete Implementation**:

```bash
#!/usr/bin/env bash
# Load git repository context at session start

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0  # Not a git repo, skip
fi

# Get git info
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
status=$(git status --porcelain 2>/dev/null | wc -l)
remote=$(git remote -v 2>/dev/null | head -n 1)

# Output context to stderr
echo "=== Git Context ===" >&2
echo "Branch: $branch" >&2
echo "Uncommitted changes: $status files" >&2
if [[ -n "$remote" ]]; then
    echo "Remote: $remote" >&2
fi
echo "==================" >&2

exit 0
```

## Edge Cases and Advanced Patterns

### Edge Case 1: External API Validation

**Purpose**: Validate API keys against external service (with caching)

**File**: `~/.claude/hooks/validate-api-key.py`

**Challenge**: Network requests are slow for PreToolUse hooks

**Solution**: Use caching and timeouts

```python
#!/usr/bin/env python3
import json
import sys
import os
import time
import hashlib

# Cache directory
CACHE_DIR = os.path.expanduser("~/.claude/hooks/.cache")
CACHE_DURATION = 3600  # 1 hour

def get_cache_path(key_hash):
    os.makedirs(CACHE_DIR, exist_ok=True)
    return os.path.join(CACHE_DIR, f"api_key_{key_hash}")

def is_cache_valid(cache_path):
    if not os.path.exists(cache_path):
        return False
    age = time.time() - os.path.getmtime(cache_path)
    return age < CACHE_DURATION

try:
    data = json.load(sys.stdin)
    content = data.get("tool_input", {}).get("content", "")

    # Early exit if no API key pattern
    if "api_key" not in content.lower():
        sys.exit(0)

    # Extract potential API key (simple example)
    import re
    matches = re.findall(r'api_key["\s:=]+([a-zA-Z0-9_-]{20,})', content)

    if not matches:
        sys.exit(0)

    for api_key in matches:
        key_hash = hashlib.sha256(api_key.encode()).hexdigest()
        cache_path = get_cache_path(key_hash)

        # Check cache first
        if is_cache_valid(cache_path):
            with open(cache_path, 'r') as f:
                if f.read() == "valid":
                    continue  # Cached as valid
                else:
                    print(f"Error: Invalid API key (cached)", file=sys.stderr)
                    sys.exit(2)

        # Validate with timeout (only if not cached)
        try:
            import requests
            response = requests.get(
                f"https://api.example.com/validate?key={api_key}",
                timeout=0.3  # Very short timeout for PreToolUse
            )

            if response.status_code == 200:
                # Cache valid result
                with open(cache_path, 'w') as f:
                    f.write("valid")
            else:
                print(f"Error: Invalid API key", file=sys.stderr)
                with open(cache_path, 'w') as f:
                    f.write("invalid")
                sys.exit(2)

        except requests.Timeout:
            # Timeout - allow operation (don't block on slow network)
            print("Warning: API validation timeout, allowing", file=sys.stderr)
            sys.exit(0)
        except Exception as e:
            # Other errors - allow (hook error, not validation error)
            print(f"Warning: Validation error: {e}", file=sys.stderr)
            sys.exit(0)

    sys.exit(0)

except Exception as e:
    print(f"Error in API validation hook: {e}", file=sys.stderr)
    sys.exit(0)
```

**Key Patterns**:

- Cache validation results (avoid repeated API calls)
- Use very short timeouts (300ms for PreToolUse)
- Allow operation on timeout (don't block on network issues)
- Exit 0 on hook errors

### Edge Case 2: Complex Regex Parsing

**Purpose**: Validate SQL injection patterns in code

**File**: `~/.claude/hooks/validate-sql.py`

**Challenge**: Complex regex can be slow and error-prone

```python
#!/usr/bin/env python3
import json
import sys
import re

# Compile patterns once (module level for performance)
SQL_INJECTION_PATTERNS = [
    re.compile(r'execute\s*\(\s*[\'"].*?\%s.*?[\'"]\s*%', re.IGNORECASE),
    re.compile(r'execute\s*\(\s*f[\'"].*?{.*?}', re.IGNORECASE),
    re.compile(r'execute\s*\(\s*.*?\+\s*', re.IGNORECASE),
    re.compile(r'\.raw\s*\(\s*f[\'"]', re.IGNORECASE),
]

SAFE_PATTERNS = [
    re.compile(r'execute\s*\(\s*[\'"].*?[\'"]\s*,\s*\[', re.IGNORECASE),  # Parameterized
    re.compile(r'\.prepare\s*\(', re.IGNORECASE),  # Prepared statements
]

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    # Early exits
    if not file_path or not content:
        sys.exit(0)

    # Only check SQL-related files
    if not any(ext in file_path for ext in ['.py', '.js', '.ts', '.go']):
        sys.exit(0)

    # Quick check - does content mention SQL?
    if 'execute' not in content.lower() and 'query' not in content.lower():
        sys.exit(0)

    # Check for safe patterns first (faster to allow than block)
    for pattern in SAFE_PATTERNS:
        if pattern.search(content):
            sys.exit(0)  # Safe pattern found

    # Check for dangerous patterns
    issues = []
    for i, line in enumerate(content.split('\n'), 1):
        for pattern in SQL_INJECTION_PATTERNS:
            if pattern.search(line):
                issues.append(f"Line {i}: Potential SQL injection: {line.strip()[:60]}")

    if issues:
        print("Error: Potential SQL injection vulnerabilities detected:", file=sys.stderr)
        for issue in issues[:5]:  # Limit output
            print(f"  • {issue}", file=sys.stderr)
        sys.exit(2)

    sys.exit(0)

except Exception as e:
    print(f"Error in SQL validation hook: {e}", file=sys.stderr)
    sys.exit(0)
```

**Key Patterns**:

- Compile regex patterns once at module level
- Check safe patterns first (faster to allow)
- Use early exits before expensive operations
- Limit output to avoid noise

### Edge Case 3: State Management Across Invocations

**Purpose**: Track file modification history across hook invocations

**File**: `~/.claude/hooks/track-changes.py`

**Challenge**: Hooks are stateless by default

**Solution**: Use filesystem for state persistence

```python
#!/usr/bin/env python3
import json
import sys
import os
import time

STATE_FILE = os.path.expanduser("~/.claude/hooks/.state/file_history.json")

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, 'r') as f:
                return json.load(f)
        except:
            return {}
    return {}

def save_state(state):
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f)

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path:
        sys.exit(0)

    # Load modification history
    state = load_state()

    # Get or create file entry
    if file_path not in state:
        state[file_path] = {
            "first_modified": time.time(),
            "modification_count": 0,
            "last_modified": None
        }

    # Update state
    state[file_path]["modification_count"] += 1
    state[file_path]["last_modified"] = time.time()

    # Check for rapid modifications (potential issue)
    if state[file_path]["modification_count"] > 10:
        time_span = time.time() - state[file_path]["first_modified"]
        if time_span < 60:  # 10+ mods in 1 minute
            print(f"Warning: {file_path} modified {state[file_path]['modification_count']} times in {time_span:.0f}s", file=sys.stderr)

    # Save state
    save_state(state)

    sys.exit(0)

except Exception as e:
    print(f"Error in change tracking hook: {e}", file=sys.stderr)
    sys.exit(0)
```

**Key Patterns**:

- Use filesystem for state persistence
- Handle missing/corrupt state gracefully
- Keep state files small (clean up old entries)
- Never block on state errors

### Edge Case 4: Multi-Language Hook (Python + Bash)

**Purpose**: Validate and format shell scripts

**File**: `~/.claude/hooks/validate-shell.py`

**Challenge**: Need to call external bash tools from Python

```python
#!/usr/bin/env python3
import json
import sys
import subprocess
import tempfile
import os

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    if not file_path or not content:
        sys.exit(0)

    # Only check shell scripts
    if not (file_path.endswith('.sh') or content.startswith('#!/bin/bash') or content.startswith('#!/usr/bin/env bash')):
        sys.exit(0)

    # Write content to temp file for validation
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
        temp_path = f.name
        f.write(content)

    try:
        # Check bash syntax
        result = subprocess.run(
            ['bash', '-n', temp_path],
            capture_output=True,
            timeout=1
        )

        if result.returncode != 0:
            print(f"Error: Invalid bash syntax:", file=sys.stderr)
            print(result.stderr.decode(), file=sys.stderr)
            sys.exit(2)

        # Check with shellcheck if available
        if subprocess.run(['which', 'shellcheck'], capture_output=True).returncode == 0:
            result = subprocess.run(
                ['shellcheck', '-f', 'gcc', temp_path],
                capture_output=True,
                timeout=2
            )

            if result.returncode != 0:
                print(f"Warning: ShellCheck issues found:", file=sys.stderr)
                print(result.stdout.decode(), file=sys.stderr)
                # Don't block on shellcheck warnings

        sys.exit(0)

    finally:
        # Clean up temp file
        if os.path.exists(temp_path):
            os.unlink(temp_path)

except subprocess.TimeoutExpired:
    print("Warning: Validation timeout", file=sys.stderr)
    sys.exit(0)
except Exception as e:
    print(f"Error in shell validation hook: {e}", file=sys.stderr)
    sys.exit(0)
```

**Key Patterns**:

- Use temp files for external tool validation
- Always clean up temp files (use finally)
- Set timeouts on subprocess calls
- Differentiate errors from warnings

## Additional Anti-Patterns

### Anti-Pattern 4: Network Call in PreToolUse

```python
#!/usr/bin/env python3
# ✗ Bad: Slow network call blocks user

import json
import sys
import requests

try:
    data = json.load(sys.stdin)
    content = data.get("tool_input", {}).get("content", "")

    # Network call without timeout (1-5 seconds!)
    response = requests.get("https://api.example.com/validate")

    if not response.json()["valid"]:
        sys.exit(2)

    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Problems**:

- Network call in PreToolUse blocks user
- No timeout (could hang indefinitely)
- No caching (repeated calls)
- Should use PostToolUse or cache results

**Fix**: See "Edge Case 1: External API Validation" above for caching solution.

### Anti-Pattern 5: Race Condition on Shared State

```python
#!/usr/bin/env python3
# ✗ Bad: Race condition on state file

import json

state_file = "/tmp/hook_state.json"

# Read state (race condition!)
with open(state_file, 'r') as f:
    state = json.load(f)

# Modify state
state["count"] += 1

# Write state (another hook might have written in between!)
with open(state_file, 'w') as f:
    json.dump(state, f)
```

**Problems**:

- No file locking
- Race condition between read and write
- State corruption possible

**Fix**:

```python
#!/usr/bin/env python3
# ✓ Good: Use file locking

import json
import fcntl

state_file = "/tmp/hook_state.json"

try:
    with open(state_file, 'r+') as f:
        # Acquire exclusive lock
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)

        try:
            state = json.load(f)
        except:
            state = {"count": 0}

        state["count"] += 1

        # Write back
        f.seek(0)
        f.truncate()
        json.dump(state, f)

        # Lock released automatically on close
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

### Anti-Pattern 6: Unsafe Temporary File Handling

```python
#!/usr/bin/env python3
# ✗ Bad: Insecure temp file handling

import os

# Predictable temp file name (security risk!)
temp_file = "/tmp/hook_temp.txt"

with open(temp_file, 'w') as f:
    f.write(content)

# Process file...

# Forgot to delete! (leaves sensitive data)
```

**Problems**:

- Predictable filename (security risk)
- No cleanup (leaks data)
- No error handling

**Fix**:

```python
#!/usr/bin/env python3
# ✓ Good: Secure temp file handling

import tempfile
import os

try:
    # Secure temp file with random name
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        temp_file = f.name
        f.write(content)

    try:
        # Process file...
        pass
    finally:
        # Always clean up
        if os.path.exists(temp_file):
            os.unlink(temp_file)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

### Anti-Pattern 7: Unsafe Shell Command Construction

```python
#!/usr/bin/env python3
# ✗ Bad: Shell injection vulnerability

import subprocess

file_path = data.get("tool_input", {}).get("file_path", "")

# Shell injection! (user could inject commands)
subprocess.run(f"cat {file_path} | grep error", shell=True)
```

**Problems**:

- Shell injection vulnerability
- Unsanitized user input
- Using shell=True unnecessarily

**Fix**:

```python
#!/usr/bin/env python3
# ✓ Good: Safe subprocess usage

import subprocess

file_path = data.get("tool_input", {}).get("file_path", "")

try:
    # No shell, pass as list
    result = subprocess.run(
        ['grep', 'error', file_path],
        capture_output=True,
        timeout=1
    )
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)
```

## Settings.json Registration Examples

### PreToolUse Hook

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
      }
    ]
  }
}
```

### PostToolUse Hook

```json
{
  "hooks": {
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
    ]
  }
}
```

### Multiple Hooks on Same Trigger

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "command": "~/.claude/hooks/log-git-commands.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

## Summary

**Good Hook Characteristics**:

1. ✓ Safe JSON parsing (try/except, .get())
2. ✓ Correct exit codes (0=allow, 2=block, never 1)
3. ✓ Dependency checking (exit 0 if missing)
4. ✓ Clear error messages to stderr
5. ✓ Early exits for non-matching files
6. ✓ Fast performance (<500ms PreToolUse)
7. ✓ Proper shebang and header comments
8. ✓ Registered correctly in settings.json

**Bad Hook Characteristics**:

1. ✗ No error handling (crashes block user)
2. ✗ Wrong exit codes (exit 1)
3. ✗ No dependency checking (import failures block)
4. ✗ Silent failures (no error messages)
5. ✗ No early exits (slow performance)
6. ✗ Network requests in PreToolUse (slow)
7. ✗ Direct key access (crashes if key missing)
8. ✗ Blocks user on hook errors

Study the good examples (validate-config.py, log-git-commands.sh) and avoid the anti-patterns!
