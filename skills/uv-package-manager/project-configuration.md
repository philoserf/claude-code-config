# Project Configuration

## pyproject.toml Basics

### Minimal Configuration

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "My awesome project"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.31.0",
]
```

### Complete Configuration

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "Production-ready Python application"
readme = "README.md"
requires-python = ">=3.11"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "you@example.com"}
]
keywords = ["python", "example", "cli"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    "requests>=2.31.0",
    "pydantic>=2.0.0",
    "click>=8.1.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
    "mypy>=1.5.0",
]
docs = [
    "sphinx>=7.0.0",
    "sphinx-rtd-theme>=1.3.0",
]
test = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-mock>=3.11.0",
]

[project.scripts]
my-cli = "my_project.cli:main"

[project.urls]
Homepage = "https://github.com/user/my-project"
Documentation = "https://my-project.readthedocs.io"
Repository = "https://github.com/user/my-project"
Issues = "https://github.com/user/my-project/issues"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.uv]
dev-dependencies = []  # Additional dev dependencies managed by uv

[tool.uv.sources]
# Custom package sources
# my-package = { git = "https://github.com/user/repo.git" }
# local-package = { path = "./local-package", editable = true }
```

## Dependency Management

### Version Constraints

```toml
[project]
dependencies = [
    "requests==2.31.0",           # Exact version
    "django>=4.0,<5.0",           # Range
    "numpy~=1.24.0",              # Compatible release (1.24.x)
    "pandas>=2.0.0",              # Minimum version
    "scipy!=1.11.0,>=1.10.0",    # Exclude specific version
]
```

### Optional Dependencies

```toml
[project.optional-dependencies]
# Development tools
dev = [
    "pytest>=7.4.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
]

# Documentation
docs = [
    "sphinx>=7.0.0",
    "myst-parser>=2.0.0",
]

# Database extras
postgres = ["psycopg2-binary>=2.9.0"]
mysql = ["mysqlclient>=2.2.0"]

# All extras combined
all = [
    "pytest>=7.4.0",
    "black>=23.0.0",
    "sphinx>=7.0.0",
    "psycopg2-binary>=2.9.0",
    "mysqlclient>=2.2.0",
]
```

Install with extras:

```bash
# Install with dev dependencies
uv sync --extra dev

# Install with multiple extras
uv sync --extra dev --extra docs

# Install all extras
uv sync --all-extras
```

### Git and Local Dependencies

```toml
[tool.uv.sources]
# Git dependencies
my-lib = { git = "https://github.com/user/my-lib.git" }
my-lib-tag = { git = "https://github.com/user/my-lib.git", tag = "v1.0.0" }
my-lib-branch = { git = "https://github.com/user/my-lib.git", branch = "main" }
my-lib-commit = { git = "https://github.com/user/my-lib.git", rev = "abc123" }

# Local dependencies
local-package = { path = "./packages/local-package" }
editable-package = { path = "./packages/editable", editable = true }

# URL dependencies
remote-wheel = { url = "https://example.com/package-1.0.0-py3-none-any.whl" }
```

## UV-Specific Configuration

### Tool Configuration

```toml
[tool.uv]
# Additional dev dependencies not in [project.optional-dependencies]
dev-dependencies = [
    # Dependencies only for local development
]

# Custom package indices
index-url = "https://pypi.org/simple"
extra-index-urls = [
    "https://custom.pypi.org/simple",
]

# Dependency sources
[tool.uv.sources]
my-package = { git = "https://github.com/user/repo.git" }
```

### Workspace Configuration

```toml
[tool.uv.workspace]
members = [
    "packages/*",
    "apps/*",
]

exclude = [
    "packages/legacy",
]
```

## Monorepo and Workspace Support

### Workspace Structure

```text
monorepo/
├── pyproject.toml          # Root workspace config
├── uv.lock                 # Shared lockfile
├── packages/
│   ├── package-a/
│   │   ├── pyproject.toml
│   │   └── src/package_a/
│   └── package-b/
│       ├── pyproject.toml
│       └── src/package_b/
└── apps/
    └── web-app/
        ├── pyproject.toml
        └── src/web_app/
```

### Root pyproject.toml

```toml
[tool.uv.workspace]
members = ["packages/*", "apps/*"]

[project]
name = "my-monorepo"
version = "0.1.0"
requires-python = ">=3.11"

# Shared dependencies for all workspace members
dependencies = [
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
]
```

### Workspace Member

```toml
# packages/package-a/pyproject.toml
[project]
name = "package-a"
version = "0.1.0"
requires-python = ">=3.11"

dependencies = [
    "requests>=2.31.0",
    "package-b",  # Internal workspace dependency
]

[tool.uv.sources]
# Reference another workspace package
package-b = { workspace = true }
```

### Workspace Commands

```bash
# Install all workspace members
uv sync

# Add workspace dependency
cd packages/package-a
uv add --path ../package-b

# Or use workspace reference
uv add package-b
```

## Build Configuration

### Using Hatchling

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/my_project"]

[tool.hatch.version]
path = "src/my_project/__init__.py"
```

### Using Setuptools

```toml
[build-system]
requires = ["setuptools>=68.0", "wheel"]
build-backend = "setuptools.build_meta"

[tool.setuptools]
packages = ["my_project"]
package-dir = {"" = "src"}

[tool.setuptools.dynamic]
version = {attr = "my_project.__version__"}
```

### Using Poetry

```toml
[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.poetry]
name = "my-project"
version = "0.1.0"
description = "My project"
authors = ["Your Name <you@example.com>"]

# UV can read [tool.poetry.dependencies]
[tool.poetry.dependencies]
python = "^3.11"
requests = "^2.31.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
```

## Scripts and Entry Points

### Console Scripts

```toml
[project.scripts]
my-cli = "my_project.cli:main"
my-tool = "my_project.tools:run"
```

Usage after installation:

```bash
uv sync
uv run my-cli --help
uv run my-tool
```

### GUI Scripts

```toml
[project.gui-scripts]
my-gui = "my_project.gui:main"
```

## Tool Integration

### Ruff Configuration

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]
ignore = ["E501"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

### Black Configuration

```toml
[tool.black]
line-length = 100
target-version = ["py311", "py312"]
include = '\.pyi?$'
```

### MyPy Configuration

```toml
[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```

### Pytest Configuration

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--strict-markers",
    "--strict-config",
    "-ra",
    "--cov=my_project",
    "--cov-report=term-missing",
]
```

## Migration from Other Tools

### From requirements.txt

```bash
# Import dependencies
uv add -r requirements.txt
uv add -r requirements-dev.txt --dev

# Result: Creates pyproject.toml with dependencies
```

### From Poetry

UV can read existing `pyproject.toml` with `[tool.poetry]` sections:

```bash
# Just sync - UV reads poetry config
uv sync

# No migration needed, but can modernize to [project] if desired
```

### From setup.py

Convert setup.py to pyproject.toml:

```python
# Old setup.py
setup(
    name="my-project",
    version="0.1.0",
    install_requires=["requests>=2.31.0"],
)
```

```toml
# New pyproject.toml
[project]
name = "my-project"
version = "0.1.0"
dependencies = ["requests>=2.31.0"]

[build-system]
requires = ["setuptools>=68.0"]
build-backend = "setuptools.build_meta"
```

## Best Practices

**Use requires-python:**

```toml
# Always specify Python version requirements
[project]
requires-python = ">=3.11"
```

**Organize optional dependencies:**

```toml
# Separate by purpose
[project.optional-dependencies]
dev = [...]      # Development tools
test = [...]     # Testing only
docs = [...]     # Documentation
prod = [...]     # Production extras
```

**Pin Python versions:**

```bash
# Create .python-version alongside pyproject.toml
uv python pin 3.12
```

**Use workspace for monorepos:**

```toml
# Share dependencies across packages
[tool.uv.workspace]
members = ["packages/*"]
```

**Commit lockfile:**

```bash
# Always commit uv.lock
git add uv.lock pyproject.toml
git commit -m "Update dependencies"
```
