# Installation and Setup

## Installation Methods

### macOS/Linux (Recommended)

`curl -LsSf https://astral.sh/uv/install.sh | sh`

### Windows (PowerShell)

```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Alternative Methods

```bash
# Using pip (if you already have Python)
pip install uv

# Using Homebrew (macOS)
brew install uv

# Using cargo (if you have Rust)
cargo install --git https://github.com/astral-sh/uv uv
```

## Verification

```bash
uv --version
# Expected output: uv 0.x.x
```

If `uv` command not found, add to PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.cargo/bin:$PATH"

# Reload shell configuration
source ~/.bashrc  # or source ~/.zshrc
```

## Quick Start Workflows

### Create New Project

```bash
# Initialize new project
uv init my-project
cd my-project

# What gets created:
# - pyproject.toml (project configuration)
# - .python-version (Python version pin)
# - README.md (project readme)
# - .gitignore (git ignore file)

# Set Python version
uv python pin 3.12

# Add dependencies
uv add requests pandas

# Add dev dependencies
uv add --dev pytest black ruff

# Create project structure
mkdir -p src/my_project tests

# Run application
uv run python -m my_project
```

### Clone Existing Project

```bash
# Clone repository
git clone https://github.com/user/project.git
cd project

# Install dependencies (creates venv automatically)
uv sync

# Install with dev dependencies
uv sync --all-extras

# Run application
uv run python app.py

# Run tests
uv run pytest
```

### Initialize in Existing Directory

```bash
# Navigate to project
cd existing-project

# Initialize uv configuration
uv init .

# This creates:
# - pyproject.toml (if doesn't exist)
# - .python-version
# - Updates .gitignore

# Import from requirements.txt
uv add -r requirements.txt

# Or just sync if pyproject.toml exists
uv sync
```

## First-Time Configuration

### Set Python Version Globally

```bash
# Install Python version
uv python install 3.12

# List installed versions
uv python list

# List all available versions
uv python list --all-versions
```

### Cache Configuration

UV uses a global cache to speed up installations:

```bash
# Cache locations:
# Linux: ~/.cache/uv
# macOS: ~/Library/Caches/uv
# Windows: %LOCALAPPDATA%\uv\cache

# Check cache location
uv cache dir

# Check cache size
du -sh $(uv cache dir)

# Clear cache (if needed)
uv cache clean
```

## Project Structure Best Practices

Recommended project layout:

```text
my-project/
├── .python-version        # Python version (created by uv python pin)
├── pyproject.toml         # Project config and dependencies
├── uv.lock               # Lockfile (commit this!)
├── .gitignore            # Git ignore (.venv, __pycache__, etc.)
├── README.md             # Project documentation
├── src/                  # Source code
│   └── my_project/
│       ├── __init__.py
│       └── main.py
├── tests/                # Test files
│   └── test_main.py
└── .venv/                # Virtual environment (don't commit)
```

## Updating UV

```bash
# Self-update uv to latest version
uv self update

# Or reinstall with install script
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Uninstallation

```bash
# Remove uv binary
rm ~/.cargo/bin/uv

# Remove cache
rm -rf ~/.cache/uv  # Linux
rm -rf ~/Library/Caches/uv  # macOS
```
