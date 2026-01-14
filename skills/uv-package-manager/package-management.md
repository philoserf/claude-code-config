# Package Management

## Adding Dependencies

### Basic Addition

```bash
# Add package (updates pyproject.toml and installs)
uv add requests

# Add multiple packages
uv add numpy pandas matplotlib

# Add with version constraint
uv add "django>=4.0,<5.0"
uv add "requests~=2.31.0"  # Compatible with 2.31.x

# Add from git repository
uv add git+https://github.com/user/repo.git

# Add from git with specific ref
uv add git+https://github.com/user/repo.git@v1.0.0
uv add git+https://github.com/user/repo.git@main

# Add from local path
uv add ./local-package

# Add editable local package
uv add -e ./local-package
```

### Development Dependencies

```bash
# Add dev dependency
uv add --dev pytest

# Add multiple dev dependencies
uv add --dev pytest pytest-cov black ruff mypy

# Common dev dependencies
uv add --dev \
  pytest pytest-cov pytest-asyncio \
  black ruff mypy \
  ipython ipdb
```

### Optional Dependencies

```bash
# Add to optional dependency group
uv add --optional docs sphinx sphinx-rtd-theme

# Add to specific extra
uv add --optional dev pytest black

# Install with optional dependencies
uv sync --extra docs
uv sync --all-extras
```

## Removing Dependencies

```bash
# Remove package
uv remove requests

# Remove dev dependency
uv remove --dev pytest

# Remove multiple packages
uv remove numpy pandas matplotlib
```

## Upgrading Dependencies

### Upgrade Specific Packages

```bash
# Upgrade specific package to latest version
uv add --upgrade requests
```

### Upgrade All Dependencies

```bash
# Update lockfile with latest versions
uv lock --upgrade

# Install updated dependencies
uv sync

# Combined: upgrade and install
uv lock --upgrade && uv sync
```

### Selective Upgrades

```bash
# Upgrade specific package in lockfile
uv lock --upgrade-package requests

# Upgrade multiple specific packages
uv lock --upgrade-package requests --upgrade-package urllib3
```

### Check for Updates

```bash
# Show outdated packages
uv tree --outdated

# Detailed dependency tree
uv tree
```

## Working with Lockfiles

### Creating and Updating Locks

```bash
# Generate/update uv.lock
uv lock

# Update without installing
uv lock --no-install

# Upgrade all packages in lock
uv lock --upgrade

# Upgrade specific package
uv lock --upgrade-package requests

# Check if lockfile is up to date
uv lock --check
```

### Installing from Lockfile

```bash
# Install exact versions from lockfile
uv sync --frozen

# Install without dev dependencies
uv sync --frozen --no-dev

# Install with specific extras
uv sync --frozen --extra docs

# Install with all extras
uv sync --frozen --all-extras
```

### Lockfile Best Practices

**Always commit uv.lock:**

```bash
git add uv.lock
git commit -m "Update dependencies"
```

**Use --frozen in CI/CD:**

```bash
# Ensures exact reproduction
uv sync --frozen
```

**Update regularly:**

```bash
# Weekly/monthly security updates
uv lock --upgrade
uv run pytest  # Verify tests pass
git commit -am "Update dependencies"
```

## Installing Packages

### From pyproject.toml

```bash
# Install all dependencies
uv sync

# Install without dev dependencies
uv sync --no-dev

# Install with specific extra
uv sync --extra docs

# Install with all extras
uv sync --all-extras
```

### From requirements.txt

```bash
# Install from requirements.txt
uv pip install -r requirements.txt

# Import into pyproject.toml
uv add -r requirements.txt
```

### Direct Installation (pip-style)

```bash
# Install package without adding to pyproject.toml
uv pip install requests

# Install specific version
uv pip install "requests==2.31.0"

# Install from git
uv pip install git+https://github.com/user/repo.git

# Uninstall package
uv pip uninstall requests
```

## Exporting Dependencies

### To requirements.txt

```bash
# Export all dependencies
uv export --format requirements-txt > requirements.txt

# Export with hashes (for security)
uv export --format requirements-txt --hash > requirements.txt

# Export without dev dependencies
uv export --format requirements-txt --no-dev > requirements.txt

# Freeze current environment (pip-style)
uv pip freeze > requirements.txt
```

## Package Resolution

### Understanding Resolution

UV's resolver ensures all dependencies are compatible:

```bash
# See resolution details
uv lock --verbose

# Dry run to see what would change
uv lock --dry-run
```

### Handling Conflicts

When conflicts occur:

```bash
# View conflict details
uv lock --verbose

# Try excluding problematic package
uv remove conflicting-package

# Or pin specific versions
uv add "package-a==1.0.0" "package-b==2.0.0"
```

### Version Constraints

```bash
# Exact version
uv add "requests==2.31.0"

# Minimum version
uv add "requests>=2.31.0"

# Compatible release (same as ~=)
uv add "requests~=2.31.0"  # Allows 2.31.x

# Version range
uv add "django>=4.0,<5.0"

# Exclude specific version
uv add "requests>=2.0,!=2.25.0"
```

## Advanced Package Operations

### Working with Indices

```bash
# Use custom index
uv pip install --index-url https://pypi.org/simple requests

# Use extra index
uv pip install --extra-index-url https://custom.pypi.org/simple package

# Configure in pyproject.toml
[tool.uv]
index-url = "https://pypi.org/simple"
extra-index-urls = ["https://custom.pypi.org/simple"]
```

### Offline Installation

```bash
# Install from cache only (no network)
uv pip install --offline requests

# Sync from lockfile offline
uv sync --frozen --offline
```

### Performance Tuning

```bash
# UV automatically uses:
# - Global cache at ~/.cache/uv (Linux) or ~/Library/Caches/uv (macOS)
# - Parallel downloads and installation
# - Incremental resolution

# Clear cache if needed
uv cache clean

# Show cache directory
uv cache dir
```

## Common Patterns

### Minimal Production Install

```bash
# Only production dependencies
uv sync --frozen --no-dev
```

### Development Setup

```bash
# All dependencies including dev
uv sync --all-extras
```

### Testing Against Multiple Versions

```bash
# Test with different package versions
uv add "django==4.2.*"
uv run pytest

uv add "django==5.0.*"
uv run pytest
```

### Security Audits

```bash
# Export with hashes for verification
uv export --format requirements-txt --hash > requirements.txt

# Review dependency tree
uv tree

# Check for known vulnerabilities (use external tool)
# pip-audit requirements.txt
```
