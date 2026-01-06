# Documentation Standards and CI/CD Integration

Comprehensive documentation practices and continuous integration setup for production Bash scripts.

## Documentation Standards

### Help and Usage

- Implement `--help` and `-h` flags showing usage, options, and examples
- Provide `--version` flag displaying script version and copyright information
- Include usage examples in help output for common use cases
- Document all command-line options with descriptions of their purpose
- List required vs optional arguments clearly in usage message
- Provide troubleshooting section in help for common issues

### Exit Codes

Document exit codes clearly:

- `0`: Success
- `1`: General errors
- `2-127`: Specific error codes for different failure modes
- `128+N`: Fatal signals (e.g., 130 for SIGINT/Ctrl+C)

### Script Headers

Include header comment block with:

- Script purpose and description
- Author and contact information
- Modification date and version
- License information
- Prerequisites (required commands and versions)

### Environment Variables

- Document environment variables the script uses or requires
- List default values
- Specify whether required or optional

### Generated Documentation

- **shdoc**: Generate markdown documentation from special comment formats
- **shellman**: Create man pages using structured comments for system integration
- **Architecture diagrams**: Use Mermaid or GraphViz for complex scripts

## CI/CD Integration

### GitHub Actions

**ShellCheck Integration**:

```yaml
- name: Run ShellCheck
  uses: ludeeus/action-shellcheck@master
  with:
    severity: warning
```

- Use `shellcheck-problem-matchers` for inline annotations
- Enable auto-fix suggestions in PR comments
- Configure severity levels (error, warning, info, style)

### Pre-commit Hooks

Configure `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck
  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.7.0-1
    hooks:
      - id: shfmt
  - repo: https://github.com/duggan/pre-commit-checkbashisms
    rev: v2.21.4
    hooks:
      - id: checkbashisms
```

See [tools-and-frameworks.md](tools-and-frameworks.md) for tool installation and configuration.

### Matrix Testing

Test across multiple Bash versions and platforms:

```yaml
strategy:
  matrix:
    bash-version: ['4.4', '5.0', '5.1', '5.2']
    os: [ubuntu-latest, macos-latest]
```

Benefits:

- Verify compatibility across versions
- Catch platform-specific issues
- Ensure fallbacks work correctly

### Container Testing

Use official bash Docker images for reproducible tests:

```yaml
container:
  image: bash:5.2
```

### Automation Workflow

Example complete workflow:

```yaml
name: Shell Script CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: ShellCheck
        run: shellcheck *.sh
      - name: Format check
        run: shfmt -d *.sh
      - name: Run tests
        run: bats test/
```

### Additional CI/CD Tools

- **CodeQL**: Enable shell script scanning for security vulnerabilities
- **Actionlint**: Validate GitHub Actions workflow files that use shell scripts
- **Coverage reporting**: Track test coverage and fail on regressions
- **Automated releases**: Tag versions and generate changelogs automatically

### Quality Gates

Set quality standards in CI/CD:

- All ShellCheck warnings must be addressed
- Test coverage must meet threshold (e.g., 80%)
- All tests must pass
- Scripts must be formatted with shfmt
- Security scans must pass

## Integration with Testing

See [tools-and-frameworks.md](tools-and-frameworks.md) for testing framework setup (bats-core, shellspec, shunit2).

Example test invocation in CI:

```bash
bats test/*.bats
shellspec spec/
```
