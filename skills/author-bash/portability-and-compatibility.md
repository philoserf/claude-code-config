# Portability and Compatibility

Cross-platform compatibility guidelines and Bash version-specific features for portable shell scripts.

## Shebang and Environment

- Use `#!/usr/bin/env bash` shebang for portability across systems
- Document minimum version requirements in script header comments
- Validate required external commands exist: `command -v jq &>/dev/null || exit 1`
- Use built-in Bash features over external commands when possible for portability

## Version Checking

Check Bash version at script start for version-specific features:

```bash
# Require Bash 4.4+
(( BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 4 )) || {
  echo "Error: Bash 4.4+ required" >&2
  exit 1
}
```

## Platform Detection

Detect platform differences and handle accordingly:

```bash
case "$(uname -s)" in
  Linux*)
    # Linux-specific code
    ;;
  Darwin*)
    # macOS-specific code
    ;;
  *BSD*)
    # BSD-specific code
    ;;
esac
```

## Tool Differences

Handle GNU vs BSD tool differences:

- **sed**: GNU uses `sed -i`, BSD uses `sed -i ''`
- **date**: Different format options between platforms
- **find**: Different flag support
- **stat**: Completely different syntax

Provide fallback implementations for platform-specific features.

## Testing Strategy

- Test scripts on all target platforms (Linux, macOS, BSD variants)
- Use matrix testing in CI/CD across platforms
- Document platform-specific behavior in comments

See [documentation-and-ci-cd.md](documentation-and-ci-cd.md) for CI/CD matrix testing setup.

## Modern Bash Features by Version

### Bash 4.3+

- `wait -n`: Wait for any background job to complete
- Nameref variables: `declare -n ref=varname` creates reference to another variable

### Bash 4.4+

- `${parameter@Q}`: Shell-quoted output for safe embedding
- `${parameter@E}`: Escape sequence expansion
- `${parameter@P}`: Prompt expansion
- `${parameter@A}`: Assignment format
- `mapfile -d delim`: Custom delimiters for reading
- `shopt -s inherit_errexit`: Better error propagation in command substitution

### Bash 5.0+

- Associative array improvements
- `${var@U}`: Uppercase conversion
- `${var@L}`: Lowercase conversion
- Enhanced `${parameter@operator}` transformations

### Bash 5.1+

- `compat` shopt options for compatibility mode
- Enhanced transformation operators

### Bash 5.2+

- `varredir_close` option for automatic file descriptor cleanup
- Improved `exec` error handling
- `EPOCHREALTIME`: Microsecond precision timestamps

## Version Feature Matrix

| Feature           | Bash Version | Fallback                         |
| ----------------- | ------------ | -------------------------------- |
| `wait -n`         | 4.3+         | Poll with `jobs -p`              |
| Nameref variables | 4.3+         | Use global variables             |
| `inherit_errexit` | 4.4+         | Manual error checking            |
| `${var@Q}`        | 4.4+         | Manual quoting with `printf %q`  |
| `${var@U}`        | 5.0+         | Use `tr '[:lower:]' '[:upper:]'` |
| `EPOCHREALTIME`   | 5.2+         | Use `date +%s.%N`                |

## Version Checking Before Features

Always check version before using modern features:

```bash
# Check for Bash 5.2+
if [[ ${BASH_VERSINFO[0]} -ge 5 && ${BASH_VERSINFO[1]} -ge 2 ]]; then
  # Use EPOCHREALTIME
  timestamp=$EPOCHREALTIME
else
  # Fallback
  timestamp=$(date +%s.%N)
fi
```

## POSIX Compliance

When POSIX compliance is required:

- Avoid Bash-specific features (arrays, `[[]]`, etc.)
- Use `[ ]` instead of `[[ ]]`
- Use `#!/bin/sh` shebang
- Test with `checkbashisms` to detect Bash-specific constructs
- Document when using Bash-specific features

See [tools-and-frameworks.md](tools-and-frameworks.md) for `checkbashisms` setup.
