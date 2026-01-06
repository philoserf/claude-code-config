# Safety and Security Patterns

Comprehensive security practices and defensive programming patterns for production Bash scripts.

## Defensive Programming

- Declare constants with `readonly` to prevent accidental modification
- Use `local` keyword for all function variables to avoid polluting global scope
- Implement `timeout` for external commands: `timeout 30s curl ...` prevents hangs
- Validate file permissions before operations: `[[ -r "$file" ]] || exit 1`
- Use process substitution `<(command)` instead of temporary files when possible
- Check exit codes of all security-critical operations explicitly
- Use `trap` to ensure cleanup happens even on abnormal exit

See [patterns-and-conventions.md](patterns-and-conventions.md) for strict mode and error handling details.

## Input Validation and Sanitization

- Sanitize user input before using in commands or file operations
- Validate numeric input with pattern matching: `[[ $num =~ ^[0-9]+$ ]]`
- Never use `eval` on user input; use arrays for dynamic command construction
- Validate environment variables before using: `: "${REQUIRED_VAR:?not set}"`
- Use `--` to separate options from arguments: `rm -rf -- "$user_input"`

## Secure File Operations

- Use `mktemp` for safe temporary file creation with proper cleanup
- Safe temp handling: `trap 'rm -rf "$tmpdir"' EXIT; tmpdir=$(mktemp -d)`
- Set restrictive umask for sensitive operations: `(umask 077; touch "$secure_file")`
- Validate file permissions before operations
- Use NUL-safe patterns for filenames: `find -print0 | while IFS= read -r -d '' file; do ...; done`

## Security Best Practices

- Log security-relevant operations (authentication, privilege changes, file access)
- Avoid bashisms when POSIX compliance is required
- Document when using Bash-specific features
- Never commit secrets, credentials, or environment files
- Use restrictive file permissions for sensitive scripts

## Security Scanning & Hardening

### Static Analysis Security Testing (SAST)

- **Semgrep**: Integrate with custom rules for shell-specific vulnerabilities
- **ShellCheck**: Enable security-focused rules with `enable=all` configuration
- **CodeQL**: GitHub's security scanning for shell scripts

### Secrets Detection

- **gitleaks**: Prevent credential leaks in git history
- **trufflehog**: Scan for high-entropy strings and secrets
- Configure pre-commit hooks to block secrets before commit

### Supply Chain Security

- Verify checksums of sourced external scripts
- Document dependencies and external tools for compliance (SBOM)
- Lock dependencies to specific versions to prevent breaking changes
- Scan dependencies for known vulnerabilities

### Sandboxing and Isolation

- Run untrusted scripts in containers with restricted privileges
- Use principle of least privilege (avoid unnecessary root/sudo)
- Audit scripts for unnecessary root/sudo requirements

### Audit Logging

- Log all security-relevant operations to syslog
- Use `logger` command for system log integration
- Include context in error logs (stack traces, environment info)
- Example: `log_info() { logger -t "$SCRIPT_NAME" -p user.info "$*"; echo "[INFO] $*" >&2; }`

### Container Security

- Scan script execution environments for vulnerabilities
- Use official bash:5.2 Docker images for reproducible environments
- Minimize attack surface in container images
