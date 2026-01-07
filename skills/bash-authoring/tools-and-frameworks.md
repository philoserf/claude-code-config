# Essential Tools and Frameworks

Comprehensive guide to the Bash scripting ecosystem including static analysis, testing frameworks, and development tools.

## Static Analysis & Formatting

### ShellCheck

The essential static analyzer for shell scripts.

**Installation**:

```bash
brew install shellcheck           # macOS
apt-get install shellcheck        # Debian/Ubuntu
```

**Configuration** (`.shellcheckrc`):

```bash
enable=all
external-sources=true
severity=style
```

**Usage**:

```bash
shellcheck script.sh
shellcheck -f json script.sh      # JSON output for CI
shellcheck -e SC2034 script.sh    # Exclude specific warnings
```

**Key Features**:

- Detects common bugs and anti-patterns
- Suggests best practices
- Extensive wiki with explanations
- Integration with editors and CI/CD

### shfmt

Shell script formatter for consistent code style.

**Installation**:

```bash
brew install shfmt                # macOS
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

**Standard Configuration**:

```bash
shfmt -i 2 -ci -bn -sr -kp script.sh
```

Flags:

- `-i 2`: 2-space indentation
- `-ci`: Indent switch cases
- `-bn`: Binary ops on newlines
- `-sr`: Redirect operators followed by space
- `-kp`: Keep column alignment

**Format all scripts**:

```bash
shfmt -w *.sh
```

### checkbashisms

Detect Bash-specific constructs for POSIX portability.

**Installation**:

```bash
apt-get install devscripts        # Debian/Ubuntu
brew install checkbashisms        # macOS
```

**Usage**:

```bash
checkbashisms script.sh
```

### Semgrep

SAST tool with custom rules for shell-specific security issues.

**Installation**:

```bash
brew install semgrep              # macOS
pip install semgrep               # Python
```

**Usage**:

```bash
semgrep --config=auto script.sh
```

### CodeQL

GitHub's security scanning for shell scripts (integrated in GitHub Actions).

## Testing Frameworks

### bats-core

Maintained Bash testing framework with TAP output.

**Installation**:

```bash
brew install bats-core            # macOS
npm install -g bats               # npm
```

**Usage**:

```bash
bats test/*.bats
```

**Example test**:

```bash
#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

@test "check file exists" {
  [ -f /etc/passwd ]
}
```

**Helpers**:

- `bats-support`: Additional assertions
- `bats-assert`: Better assertion messages
- `bats-file`: File system assertions

### shellspec

BDD-style testing framework with rich assertions.

**Installation**:

```bash
curl -fsSL https://git.io/shellspec | sh
```

**Usage**:

```bash
shellspec
```

**Example**:

```bash
Describe 'Example'
  It 'adds numbers'
    When call add 2 3
    The output should equal 5
  End
End
```

### shunit2

xUnit-style testing framework.

**Installation**:

```bash
brew install shunit2              # macOS
```

**Example**:

```bash
testEquality() {
  assertEquals 1 1
}

. shunit2
```

### bashing

Testing framework with mocking support.

Features:

- Mock external commands
- Test isolation
- Fixture support

## Modern Development Tools

### bashly

CLI framework generator for building command-line applications.

**Installation**:

```bash
gem install bashly
```

**Usage**:

```bash
bashly init
bashly generate
```

Creates structured CLI with argument parsing, help generation, and subcommands.

### basher

Bash package manager for dependency management.

**Installation**:

```bash
git clone https://github.com/basherpm/basher.git ~/.basher
```

**Usage**:

```bash
basher install username/repo@version
```

### bpkg

Alternative bash package manager with npm-like interface.

**Installation**:

```bash
curl -sLo- https://get.bpkg.sh | bash
```

**Usage**:

```bash
bpkg install username/repo -g
```

### shdoc

Generate markdown documentation from shell script comments.

**Installation**:

```bash
brew install shdoc                # macOS
```

**Usage**:

```bash
shdoc < script.sh > README.md
```

**Comment format**:

```bash
# @description Process input files
# @arg $1 string Input file path
# @exitcode 0 Success
# @exitcode 1 File not found
process_file() {
  # implementation
}
```

### shellman

Generate man pages from shell scripts.

**Installation**:

```bash
pip install shellman
```

**Usage**:

```bash
shellman -o script.1 script.sh
man ./script.1
```

## CI/CD & Automation Tools

### pre-commit

Multi-language pre-commit hook framework.

**Installation**:

```bash
brew install pre-commit           # macOS
pip install pre-commit            # Python
```

**Setup**:

```bash
pre-commit install
```

See [documentation-and-ci-cd.md](documentation-and-ci-cd.md) for configuration examples.

### actionlint

GitHub Actions workflow linter.

**Installation**:

```bash
brew install actionlint           # macOS
```

**Usage**:

```bash
actionlint
```

### gitleaks

Secrets scanning to prevent credential leaks.

**Installation**:

```bash
brew install gitleaks             # macOS
```

**Usage**:

```bash
gitleaks detect
gitleaks protect                  # Pre-commit scanning
```

### Makefile

Automation for lint, format, test, and release workflows.

**Example**:

```makefile
.PHONY: lint format test

lint:
 shellcheck *.sh

format:
 shfmt -w *.sh

test:
 bats test/*.bats

all: lint format test
```

## External Resources

### Style Guides & Best Practices

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) - Comprehensive style guide
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls) - Common mistakes catalog
- [Bash Hackers Wiki](https://wiki.bash-hackers.org/) - Comprehensive documentation
- [Defensive BASH Programming](https://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/) - Modern patterns

### Tool Documentation

- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki) - Extensive error code documentation
- [shfmt Documentation](https://github.com/mvdan/sh) - Formatter flags and options
- [bats-core Documentation](https://bats-core.readthedocs.io/) - Testing framework guide
- [bashly Documentation](https://bashly.dannyb.co/) - CLI framework tutorials

### Security & Advanced Topics

- [Bash Security Best Practices](https://github.com/carlospolop/PEASS-ng) - Security patterns
- [Awesome Bash](https://github.com/awesome-lists/awesome-bash) - Curated resources
- [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible) - Built-in alternatives to external commands

## Tool Selection Matrix

| Need            | Tool          | Alternative        |
| --------------- | ------------- | ------------------ |
| Static analysis | ShellCheck    | CodeQL             |
| Formatting      | shfmt         | -                  |
| Testing         | bats-core     | shellspec, shunit2 |
| CLI framework   | bashly        | -                  |
| Documentation   | shdoc         | shellman           |
| Dependencies    | basher        | bpkg               |
| Pre-commit      | pre-commit    | Manual hooks       |
| Secrets scan    | gitleaks      | trufflehog         |
| POSIX check     | checkbashisms | ShellCheck         |
