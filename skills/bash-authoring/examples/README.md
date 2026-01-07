# Bash Scripting Examples

Runnable examples demonstrating defensive bash scripting patterns, progressing from basic to advanced.

## Learning Path

Follow examples in order for structured learning:

1. **[1-minimal-safe-script/](1-minimal-safe-script/)** - Foundation template
2. **[2-parameter-validation/](2-parameter-validation/)** - Input handling
3. **[3-temp-file-management/](3-temp-file-management/)** - Resource lifecycle
4. **[4-error-handling-patterns/](4-error-handling-patterns/)** - Comprehensive errors
5. **[5-pipeline-safety/](5-pipeline-safety/)** - Binary-safe processing
6. **[6-array-iteration-patterns/](6-array-iteration-patterns/)** - Array operations
7. **[7-production-deployment-script/](7-production-deployment-script/)** - Real-world automation
8. **[8-testing-with-bats/](8-testing-with-bats/)** - Test-driven development

## Quick Reference

### By Pattern

| Pattern                         | Example       |
| ------------------------------- | ------------- |
| Strict mode (set -euo pipefail) | 1, all others |
| Error handling (trap ERR)       | 1, 4, 7       |
| Parameter validation            | 2, 7          |
| Temporary files                 | 3, 7          |
| EXIT trap cleanup               | 3, 7          |
| Pipeline safety                 | 5, 6          |
| Array iteration                 | 6, 7          |
| Logging                         | 7             |
| Dry-run mode                    | 7             |
| Testing with Bats               | 8             |

### By Use Case

| Need                                           | See Example |
| ---------------------------------------------- | ----------- |
| "How do I start a new bash script?"            | 1           |
| "How do I validate script arguments?"          | 2           |
| "How do I safely handle temporary files?"      | 3           |
| "How do I handle errors properly?"             | 4           |
| "How do I process files with spaces in names?" | 5           |
| "How do I safely iterate over arrays?"         | 6           |
| "What does a production script look like?"     | 7           |
| "How do I test bash scripts?"                  | 8           |

## Running the Examples

Each example contains:

- `script.sh` - Runnable bash script demonstrating the pattern
- `ANALYSIS.md` - Detailed explanation of patterns used
- Supporting files - Test data, test scripts, or checklists

### To run an example

```bash
cd 1-minimal-safe-script
chmod +x script.sh
./script.sh --help
```

### To verify with ShellCheck

```bash
shellcheck script.sh
# Should produce no warnings for all examples
```

## Prerequisites

- **Bash 4.0+** recommended (some features require it)
- **ShellCheck** for linting: `brew install shellcheck` (macOS)
- **Bats** for testing (example 8): `brew install bats-core` (macOS)

## Cross-References to Reference Docs

Each example references specific sections from the author-bash reference documentation:

- **[patterns-and-conventions.md](../patterns-and-conventions.md)** -
  Core patterns and error handling strategies
- **[safety-and-security.md](../safety-and-security.md)** - Security
  practices and input validation
- **[tools-and-frameworks.md](../tools-and-frameworks.md)** - Testing
  and tooling (ShellCheck, Bats)

## Contributing

When adding new examples:

1. Follow the numbered naming pattern
2. Include script.sh, ANALYSIS.md, and relevant test files
3. Ensure ShellCheck passes with no warnings
4. Add comprehensive comments in script
5. Reference back to relevant pattern docs
6. Update this README with new example
