# Analysis: Testing with Bats

## Bats Framework

Bats (Bash Automated Testing System) provides a TAP-compliant testing
framework for bash scripts.

### Installation

```bash
# macOS
brew install bats-core

# Or from source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

## Test Structure

```bash
@test "description" {
    # Test code
    [ condition ]
}
```

### Setup and Teardown

```bash
setup() {
    # Runs before each test
}

teardown() {
    # Runs after each test
}
```

## Assertions

- `[ condition ]` - Standard test
- `run command` - Capture exit code and output
- `$status` - Exit code from `run`
- `$output` - Output from `run`

## Writing Testable Scripts

### 1. Use Functions

```bash
# Testable
calculate() {
    echo $(($1 + $2))
}

# Hard to test
result=$(($a + $b))
echo $result
```

### 2. Make Script Sourceable

```bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

Allows sourcing for testing without executing.

### 3. Return Values

Use `return` for status, `echo` for output:

```bash
process() {
    if error; then
        echo "Error message" >&2
        return 1
    fi
    echo "result"
    return 0
}
```

## Running Tests

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/test-basic.bats

# Verbose output
bats -tap tests/
```

## Test Coverage

Aim to test:

- Happy path (normal usage)
- Error cases
- Edge cases
- Boundary conditions

## References

- [tools-and-frameworks.md](../../tools-and-frameworks.md)
- Bats docs: <https://bats-core.readthedocs.io/>
