# Virtual Environment Management

## Creating Virtual Environments

### Basic Creation

```bash
# Create virtual environment in .venv
uv venv

# Creates:
# - .venv/ directory
# - Uses Python version from .python-version if exists
# - Otherwise uses system Python
```

### With Specific Python Version

```bash
# Create with specific version
uv venv --python 3.12

# Create with custom name
uv venv my-env

# Create with system site packages
uv venv --system-site-packages

# Specify custom location
uv venv /path/to/venv
```

## Using Virtual Environments

### Option 1: uv run (Recommended)

No activation needed - uv automatically detects and uses .venv:

```bash
# Run Python script
uv run python script.py

# Run installed CLI tool
uv run pytest
uv run black .
uv run mypy src/

# Run with specific Python version
uv run --python 3.11 python script.py

# Pass arguments
uv run python script.py --arg value

# Run module
uv run python -m http.server 8000
```

**Advantages:**

- No activation/deactivation needed
- Works consistently across platforms
- Automatically creates venv if missing
- Cannot accidentally use wrong environment

### Option 2: Manual Activation

Traditional activation for interactive work:

```bash
# Linux/macOS
source .venv/bin/activate

# Windows (Command Prompt)
.venv\Scripts\activate.bat

# Windows (PowerShell)
.venv\Scripts\Activate.ps1

# Deactivate
deactivate
```

## Environment Detection

UV automatically detects virtual environments in this order:

1. .venv in current directory
2. Virtual environment from VIRTUAL_ENV variable
3. .venv in parent directories (walks up)
4. System Python

```bash
# Verify which environment uv will use
uv run python -c "import sys; print(sys.prefix)"
```

## Managing Multiple Environments

### Per-Project Environments

```bash
# Project 1
cd ~/projects/project1
uv venv
uv sync

# Project 2
cd ~/projects/project2
uv venv
uv sync

# Each project has isolated .venv
```

### Named Environments

```bash
# Create named environments
uv venv env-py311 --python 3.11
uv venv env-py312 --python 3.12

# Use specific environment
VIRTUAL_ENV=./env-py311 uv run python script.py
VIRTUAL_ENV=./env-py312 uv run python script.py
```

### Testing Across Python Versions

```bash
# Test with Python 3.11
uv venv test-311 --python 3.11
uv run --python 3.11 pytest

# Test with Python 3.12
uv venv test-312 --python 3.12
uv run --python 3.12 pytest
```

## Environment Inspection

```bash
# Show installed packages
uv pip list

# Show dependency tree
uv tree

# Show outdated packages
uv tree --outdated

# Freeze installed packages
uv pip freeze

# Export to requirements.txt
uv pip freeze > requirements.txt
```

## Cleaning and Recreating

```bash
# Remove virtual environment
rm -rf .venv

# Recreate from lockfile
uv sync

# Recreate with specific Python version
uv venv --python 3.12
uv sync
```

## Integration with IDEs

### VS Code

```json
// .vscode/settings.json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "python.testing.pytestEnabled": true,
  "python.testing.pytestArgs": ["-v"]
}
```

### PyCharm

1. File → Settings → Project → Python Interpreter
2. Click gear icon → Add
3. Select "Existing environment"
4. Choose `.venv/bin/python`

### Command Line

```bash
# Set environment variable
export VIRTUAL_ENV=/path/to/.venv
export PATH="$VIRTUAL_ENV/bin:$PATH"

# Or use direnv with .envrc:
# echo 'export VIRTUAL_ENV=.venv' > .envrc
# echo 'PATH_add $VIRTUAL_ENV/bin' >> .envrc
# direnv allow
```

## Best Practices

**Always use .venv name:**

- Standard location IDEs look for
- Git ignores by default
- uv automatically detects

**Prefer uv run over activation:**

- More reliable and consistent
- Works in CI/CD without modification
- Cannot forget to activate

**Don't commit .venv:**

- Add to .gitignore
- Recreate from uv.lock instead
- Reduces repository size

**Pin Python version:**

- Use `uv python pin 3.12`
- Creates .python-version file
- Ensures consistent environment across team

**Separate dev dependencies:**

- Use `uv add --dev` for dev tools
- Keeps production installs lean
- Clear separation of concerns
