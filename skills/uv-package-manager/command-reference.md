# Command Reference

## Essential Commands

### Project Management

```bash
# Initialize new project
uv init [PATH]              # Create new project with pyproject.toml
uv init .                   # Initialize in current directory

# Sync dependencies
uv sync                     # Install from pyproject.toml
uv sync --frozen            # Install exact versions from uv.lock
uv sync --no-dev            # Skip dev dependencies
uv sync --all-extras        # Include all optional dependencies
uv sync --extra NAME        # Include specific optional dependency group
```

### Package Management

```bash
# Add packages
uv add PACKAGE                           # Add and install package
uv add PACKAGE1 PACKAGE2                 # Add multiple packages
uv add "PACKAGE>=1.0,<2.0"              # Add with version constraint
uv add --dev PACKAGE                     # Add as dev dependency
uv add --optional GROUP PACKAGE          # Add to optional group
uv add -r requirements.txt               # Import from requirements.txt
uv add git+https://github.com/user/repo  # Add from git
uv add -e ./local-package                # Add editable local package

# Remove packages
uv remove PACKAGE                        # Remove package
uv remove --dev PACKAGE                  # Remove dev dependency
uv remove PACKAGE1 PACKAGE2              # Remove multiple packages

# Upgrade packages
uv add --upgrade PACKAGE                 # Upgrade specific package
uv lock --upgrade                        # Update all in lockfile
uv lock --upgrade-package PACKAGE        # Update specific in lockfile
```

### Virtual Environments

```bash
# Create virtual environment
uv venv                        # Create .venv with default Python
uv venv --python 3.12          # Create with specific Python version
uv venv ENV_NAME               # Create with custom name
uv venv --system-site-packages # Include system packages

# Use virtual environment (no activation needed)
uv run COMMAND                 # Run command in venv
uv run python script.py        # Run Python script
uv run pytest                  # Run installed CLI tool
uv run --python 3.11 python    # Run with specific Python version
```

### Python Version Management

```bash
# Install Python versions
uv python install VERSION      # Install specific version (e.g., 3.12)
uv python install              # Install latest version
uv python install 3.11 3.12    # Install multiple versions

# List Python versions
uv python list                 # List installed versions
uv python list --all-versions  # List all available versions

# Pin Python version
uv python pin VERSION          # Set project Python version
uv python pin 3.12             # Creates .python-version file
```

### Lockfile Management

```bash
# Lock management
uv lock                        # Generate/update uv.lock
uv lock --upgrade              # Upgrade all packages
uv lock --upgrade-package PKG  # Upgrade specific package
uv lock --no-install           # Lock without installing
uv lock --check                # Check if lockfile is current
```

### Export and Compatibility

```bash
# Export dependencies
uv export --format requirements-txt > requirements.txt
uv export --format requirements-txt --hash > requirements.txt
uv export --no-dev > requirements.txt

# Pip compatibility commands
uv pip install PACKAGE         # Install like pip (no pyproject.toml update)
uv pip uninstall PACKAGE       # Uninstall like pip
uv pip list                    # List installed packages
uv pip freeze                  # Output installed packages
uv pip show PACKAGE            # Show package details
```

### Information and Inspection

```bash
# Package information
uv tree                        # Show dependency tree
uv tree --outdated             # Show outdated packages

# Cache management
uv cache dir                   # Show cache directory
uv cache clean                 # Clear cache

# Version and help
uv --version                   # Show UV version
uv --help                      # Show help
uv COMMAND --help              # Show command-specific help
```

## Command Flags

### Common Flags Across Commands

```bash
--python VERSION               # Specify Python version
--frozen                       # Use exact versions from lockfile
--no-dev                       # Exclude dev dependencies
--all-extras                   # Include all optional dependencies
--extra NAME                   # Include specific optional dependency
--verbose, -v                  # Verbose output
--quiet, -q                    # Minimal output
--offline                      # No network access (use cache only)
```

### uv sync Flags

```bash
uv sync                        # Install all dependencies
uv sync --frozen               # Exact lockfile versions
uv sync --no-dev               # Skip dev dependencies
uv sync --all-extras           # All optional dependencies
uv sync --extra docs           # Specific extra group
uv sync --no-editable          # Install editables as regular packages
uv sync --offline              # Offline mode
```

### uv add Flags

```bash
uv add PACKAGE                 # Add to [project.dependencies]
uv add --dev PACKAGE           # Add to [project.optional-dependencies.dev]
uv add --optional GROUP PKG    # Add to specific optional group
uv add --upgrade PACKAGE       # Upgrade if already installed
uv add -e PATH                 # Add editable package
uv add -r FILE                 # Add from requirements file
```

### uv lock Flags

```bash
uv lock                        # Generate/update lockfile
uv lock --upgrade              # Upgrade all packages
uv lock --upgrade-package PKG  # Upgrade specific package
uv lock --no-install           # Don't install after locking
uv lock --check                # Check if lockfile is current
uv lock --dry-run              # Show what would change
uv lock --verbose              # Show resolution details
```

### uv run Flags

```bash
uv run COMMAND                 # Run in virtual environment
uv run --python 3.12 COMMAND   # Use specific Python version
uv run --no-sync COMMAND       # Don't sync before running
```

### uv venv Flags

```bash
uv venv                        # Create .venv
uv venv --python 3.12          # Specific Python version
uv venv --system-site-packages # Include system packages
uv venv --clear                # Recreate if exists
uv venv NAME                   # Custom name/location
```

## Pip Compatibility Commands

### Installation

```bash
uv pip install PACKAGE         # Install package
uv pip install PACKAGE==1.0.0  # Install specific version
uv pip install -r requirements.txt
uv pip install -e .            # Install current directory (editable)
uv pip install --upgrade PACKAGE
uv pip install --no-deps PACKAGE   # Skip dependencies
```

### Uninstallation

```bash
uv pip uninstall PACKAGE       # Uninstall package
uv pip uninstall -r requirements.txt
uv pip uninstall -y PACKAGE    # Skip confirmation
```

### Inspection

```bash
uv pip list                    # List installed packages
uv pip list --outdated         # Show outdated packages
uv pip show PACKAGE            # Show package info
uv pip freeze                  # Output installed packages
uv pip freeze > requirements.txt
```

## Advanced Usage

### Custom Indices

```bash
# Use custom index
uv pip install --index-url https://pypi.org/simple PACKAGE

# Extra index
uv pip install --extra-index-url https://custom.pypi.org/simple PACKAGE

# Configure in pyproject.toml
[tool.uv]
index-url = "https://pypi.org/simple"
extra-index-urls = ["https://custom.pypi.org/simple"]
```

### Environment Variables

```bash
# Set cache directory
export UV_CACHE_DIR=/custom/cache

# Set Python
export UV_PYTHON=3.12

# Verbose output
export UV_VERBOSE=1

# No network
export UV_OFFLINE=1
```

### Configuration File

```toml
# pyproject.toml
[tool.uv]
index-url = "https://pypi.org/simple"
extra-index-urls = []

[tool.uv.sources]
my-package = { git = "https://github.com/user/repo.git" }
```

## Workflow Examples

### New Project Setup

```bash
uv init my-project
cd my-project
uv python pin 3.12
uv add requests pandas
uv add --dev pytest black ruff
uv run python -m my_project
```

### Existing Project Setup

```bash
git clone https://github.com/user/project
cd project
uv sync --all-extras
uv run pytest
```

### Dependency Updates

```bash
# Update all
uv lock --upgrade
uv sync

# Update specific package
uv lock --upgrade-package requests
uv sync

# Check what's outdated
uv tree --outdated
```

### Testing Different Python Versions

```bash
# Python 3.11
uv venv test-311 --python 3.11
VIRTUAL_ENV=./test-311 uv run pytest

# Python 3.12
uv venv test-312 --python 3.12
VIRTUAL_ENV=./test-312 uv run pytest
```

### CI/CD Installation

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv python install 3.12
uv sync --frozen --no-dev

# Run tests
uv run pytest
```

### Exporting for Deployment

```bash
# Export with hashes
uv export --format requirements-txt --hash > requirements.txt

# Export production only
uv export --format requirements-txt --no-dev > requirements.txt
```

## Quick Reference Table

| Task                 | Command                               |
| -------------------- | ------------------------------------- |
| Create project       | `uv init`                             |
| Install dependencies | `uv sync`                             |
| Add package          | `uv add PACKAGE`                      |
| Remove package       | `uv remove PACKAGE`                   |
| Create venv          | `uv venv`                             |
| Run script           | `uv run python script.py`             |
| Run tests            | `uv run pytest`                       |
| Update all           | `uv lock --upgrade && uv sync`        |
| Update one           | `uv lock --upgrade-package PKG`       |
| Install Python       | `uv python install 3.12`              |
| Pin Python           | `uv python pin 3.12`                  |
| Show tree            | `uv tree`                             |
| Check outdated       | `uv tree --outdated`                  |
| Clear cache          | `uv cache clean`                      |
| Export requirements  | `uv export --format requirements-txt` |

## Comparison with Other Tools

| Task         | pip                               | poetry                        | uv                        |
| ------------ | --------------------------------- | ----------------------------- | ------------------------- |
| Create venv  | `python -m venv .venv`            | `poetry init`                 | `uv init`                 |
| Install deps | `pip install -r requirements.txt` | `poetry install`              | `uv sync`                 |
| Add package  | `pip install PKG && pip freeze`   | `poetry add PKG`              | `uv add PKG`              |
| Run script   | `python script.py`                | `poetry run python script.py` | `uv run python script.py` |
| Update all   | `pip install --upgrade PKG`       | `poetry update`               | `uv lock --upgrade`       |
| Lock deps    | `pip freeze > requirements.txt`   | `poetry lock`                 | `uv lock`                 |

## Tips and Tricks

**Always use --frozen in CI:**
`uv sync --frozen  # Exact reproduction`

**Prefer uv run over activation:**

```bash
# Instead of:
source .venv/bin/activate && python script.py

# Use:
uv run python script.py
```

**Check before upgrading:**

```bash
uv tree --outdated
uv lock --upgrade --dry-run
```

**Export for compatibility:**

```bash
# Keep requirements.txt updated for pip users
uv export --format requirements-txt > requirements.txt
```

**Use lockfile for reproducibility:**

```bash
# Always commit uv.lock
git add uv.lock
```
