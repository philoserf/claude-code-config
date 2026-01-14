# Python Version Management

## Installing Python Versions

### Basic Installation

```bash
# Install specific Python version
uv python install 3.12

# Install multiple versions
uv python install 3.11 3.12 3.13

# Install latest version
uv python install

# Install latest patch version
uv python install 3.12  # Installs latest 3.12.x
```

### Installation Options

```bash
# List available versions
uv python list --all-versions

# Install specific patch version
uv python install 3.12.1

# Install preview/beta versions
uv python install 3.13.0b1
```

## Managing Installed Versions

### Listing Versions

```bash
# List installed Python versions
uv python list

# List all available versions (from python.org)
uv python list --all-versions

# Find specific version
uv python list --all-versions | grep 3.12
```

### Removing Versions

```bash
# UV doesn't provide uninstall command
# Manually remove from:
# Linux: ~/.local/share/uv/python
# macOS: ~/Library/Application Support/uv/python
# Windows: %LOCALAPPDATA%\uv\python

# Remove specific version (manual)
rm -rf ~/.local/share/uv/python/cpython-3.11.0-*
```

## Pinning Python Versions

### Project-Level Pinning

```bash
# Pin Python version for project
uv python pin 3.12

# This creates/updates .python-version file
# Content: 3.12

# Pin specific patch version
uv python pin 3.12.1

# Pin minimum version
uv python pin ">=3.12"
```

### Using .python-version

```bash
# .python-version file format (one line):
3.12

# UV reads this file and:
# - Uses this Python version for uv venv
# - Uses this version for uv run
# - Respects it in CI/CD

# Multiple tools read .python-version:
# - pyenv
# - asdf
# - uv
```

### pyproject.toml Python Requirements

```toml
[project]
name = "my-project"
requires-python = ">=3.12"  # Minimum Python version

# UV checks this when:
# - Creating virtual environments
# - Installing dependencies
# - Running uv sync
```

## Using Specific Python Versions

### For Virtual Environments

```bash
# Create venv with specific Python version
uv venv --python 3.12

# Create venv with latest installed 3.11
uv venv --python 3.11

# Create venv with system Python
uv venv --python system
```

### For Running Commands

```bash
# Run with specific Python version
uv run --python 3.12 python script.py

# Run with latest installed 3.11
uv run --python 3.11 pytest

# Use specific Python path
uv run --python /usr/bin/python3 script.py
```

## Python Version Resolution

UV resolves Python versions in this order:

1. `--python` command-line flag
2. `.python-version` file in current/parent directories
3. `requires-python` in pyproject.toml
4. System Python

Example:

```bash
# Project structure:
# my-project/
#   .python-version  (contains: 3.12)
#   pyproject.toml   (requires-python = ">=3.11")

# This will use Python 3.12:
uv venv  # Uses .python-version

# This will use Python 3.11:
uv venv --python 3.11  # Flag overrides .python-version
```

## Cross-Platform Python Versions

### Platform-Specific Pythons

UV downloads pre-built Python binaries:

- **Linux**: Manylinux compatible builds
- **macOS**: Universal2 builds (supports Intel and Apple Silicon)
- **Windows**: Official python.org builds

```bash
# Works identically across platforms
uv python install 3.12
uv venv --python 3.12
```

### Platform Detection

```python
# Check Python platform in code
import platform
print(platform.python_version())  # 3.12.1
print(platform.system())          # Linux, Darwin, Windows
print(platform.machine())         # x86_64, arm64, AMD64
```

## Version Compatibility

### Testing Multiple Versions

```bash
# Test against multiple Python versions
for version in 3.11 3.12 3.13; do
    echo "Testing with Python $version"
    uv venv test-$version --python $version
    VIRTUAL_ENV=./test-$version uv run pytest
done
```

### Tox-Style Testing

```bash
# Create environments for different versions
uv venv .venv-py311 --python 3.11
uv venv .venv-py312 --python 3.12
uv venv .venv-py313 --python 3.13

# Run tests in each
VIRTUAL_ENV=.venv-py311 uv run pytest
VIRTUAL_ENV=.venv-py312 uv run pytest
VIRTUAL_ENV=.venv-py313 uv run pytest
```

### CI Matrix Testing

```yaml
# .github/workflows/test.yml
strategy:
  matrix:
    python-version: ["3.11", "3.12", "3.13"]

steps:
  - uses: astral-sh/setup-uv@v2
  - run: uv python install ${{ matrix.python-version }}
  - run: uv venv --python ${{ matrix.python-version }}
  - run: uv sync
  - run: uv run pytest
```

## Migration from pyenv

If currently using pyenv:

```bash
# pyenv workflow
pyenv install 3.12.1
pyenv local 3.12.1
python -m venv .venv

# Equivalent uv workflow
uv python install 3.12.1
uv python pin 3.12.1
uv venv

# Advantages:
# - No need for separate pyenv installation
# - Faster Python downloads
# - Integrated with package management
# - Works on Windows without WSL
```

## Best Practices

**Pin Python versions in projects:**

```bash
# Always create .python-version
uv python pin 3.12
git add .python-version
```

**Specify Python requirements:**

```toml
# In pyproject.toml
[project]
requires-python = ">=3.11,<4.0"
```

**Test across Python versions:**

```bash
# Before releasing, test with multiple versions
uv venv test-min --python 3.11  # Minimum supported
uv venv test-max --python 3.13  # Latest version
```

**Use specific versions in CI:**

```yaml
# Pin exact version for reproducibility
- run: uv python install 3.12.1
```

**Document Python requirements:**

```markdown
# README.md
## Requirements
- Python 3.12 or later
- UV package manager

## Setup
uv python install 3.12
uv sync
```

## Troubleshooting

### Wrong Python version used

```bash
# Check which Python UV will use
uv run python --version

# Check .python-version file
cat .python-version

# Check pyproject.toml
grep requires-python pyproject.toml

# Explicitly set version
uv python pin 3.12
uv venv --python 3.12
```

### Python version not found

```bash
# Install required version
uv python install 3.12

# List installed versions
uv python list

# If still not found, specify full path
uv venv --python /path/to/python3.12
```

### Incompatible Python version

```bash
# Error: requires-python = ">=3.12" but using 3.11

# Solution: install and use correct version
uv python install 3.12
uv python pin 3.12
uv venv --python 3.12
uv sync
```
