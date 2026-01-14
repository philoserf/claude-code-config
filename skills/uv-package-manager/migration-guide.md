# Migration Guide

## Migrating from pip + requirements.txt

### Before: pip Workflow

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt

# Add new package
pip install requests
pip freeze > requirements.txt

# Update packages
pip install --upgrade requests
pip freeze > requirements.txt
```

### After: uv Workflow

```bash
# Initialize project (creates pyproject.toml)
uv init

# Import from requirements.txt
uv add -r requirements.txt

# Or install directly
uv sync  # if pyproject.toml already exists

# Add new package (automatic install + updates pyproject.toml)
uv add requests

# Update packages
uv lock --upgrade
uv sync
```

### Migration Steps

1. **Initialize uv configuration:**
   `uv init .`

2. **Import existing requirements:**

   ```bash
   # Import production dependencies
   uv add -r requirements.txt

   # Import dev dependencies
   uv add -r requirements-dev.txt --dev
   ```

3. **Verify installation:**

   ```bash
   uv sync
   uv run python -c "import requests; print(requests.__version__)"
   ```

4. **Update version control:**

   ```bash
   git add pyproject.toml uv.lock .python-version
   git add .gitignore  # if updated
   git commit -m "Migrate from pip to uv"
   ```

5. **Optional: Remove old files:**

   ```bash
   # Keep requirements.txt for backwards compatibility, or remove:
   git rm requirements.txt requirements-dev.txt
   ```

### Coexistence Strategy

Keep both for transition period:

```bash
# Keep requirements.txt in sync
uv export --format requirements-txt --no-dev > requirements.txt
uv export --format requirements-txt --extra dev > requirements-dev.txt

# Update both
git add requirements.txt requirements-dev.txt pyproject.toml uv.lock
```

## Migrating from Poetry

### Before: Poetry Workflow

```bash
# Initialize project
poetry init

# Add dependencies
poetry add requests

# Add dev dependencies
poetry add --group dev pytest

# Install dependencies
poetry install

# Run commands
poetry run python script.py
poetry run pytest
```

### After: uv Workflow

```bash
# Initialize project
uv init

# Add dependencies
uv add requests

# Add dev dependencies
uv add --dev pytest

# Install dependencies
uv sync

# Run commands
uv run python script.py
uv run pytest
```

### Migration Steps

1. **UV can read existing Poetry configuration:**

   ```bash
   # If you already have pyproject.toml with [tool.poetry]
   uv sync  # UV reads poetry config automatically
   ```

2. **Optional: Modernize to standard [project] format:**

   ```toml
   # Before (Poetry format)
   [tool.poetry]
   name = "my-project"
   version = "0.1.0"

   [tool.poetry.dependencies]
   python = "^3.11"
   requests = "^2.31.0"

   [tool.poetry.group.dev.dependencies]
   pytest = "^7.4.0"

   # After (Standard format, UV native)
   [project]
   name = "my-project"
   version = "0.1.0"
   requires-python = ">=3.11"
   dependencies = [
       "requests>=2.31.0",
   ]

   [project.optional-dependencies]
   dev = [
       "pytest>=7.4.0",
   ]
   ```

3. **Update lock file:**
   `uv lock`

4. **Remove Poetry:**

   ```bash
   # Optional: remove poetry.lock
   git rm poetry.lock
   git add uv.lock
   git commit -m "Migrate from poetry.lock to uv.lock"
   ```

### Version Constraint Translation

Poetry uses caret (^) and tilde (~) constraints:

```toml
# Poetry
[tool.poetry.dependencies]
requests = "^2.31.0"  # Allows >=2.31.0, <3.0.0
pandas = "~2.1.0"     # Allows >=2.1.0, <2.2.0

# UV equivalent
[project]
dependencies = [
    "requests>=2.31.0,<3.0.0",
    "pandas>=2.1.0,<2.2.0",
]
```

### Performance Comparison

```bash
# Poetry
time poetry install
# ~15-25 seconds

# UV
time uv sync
# ~2-4 seconds (6-8x faster)
```

## Migrating from pip-tools

### Before: pip-tools Workflow

```bash
# Create requirements.in
echo "requests>=2.31.0" > requirements.in

# Compile to requirements.txt
pip-compile requirements.in

# Install
pip-sync requirements.txt

# Update
pip-compile --upgrade requirements.in
pip-sync requirements.txt
```

### After: uv Workflow

```bash
# Create pyproject.toml
uv init
uv add "requests>=2.31.0"

# Generate lockfile
uv lock

# Install
uv sync --frozen

# Update
uv lock --upgrade
uv sync
```

### Migration Steps

1. **Convert requirements.in to pyproject.toml:**

   ```bash
   uv init
   uv add -r requirements.in
   uv add -r requirements-dev.in --dev
   ```

2. **Generate lockfile:**
   `uv lock`

3. **Test installation:**

   ```bash
   uv sync --frozen
   uv run pytest
   ```

4. **Update version control:**

   ```bash
   git add pyproject.toml uv.lock
   git commit -m "Migrate from pip-tools to uv"
   ```

### Compatibility Mode

Export to pip-tools format when needed:

```bash
# Export to requirements.txt (pip-tools compatible)
uv export --format requirements-txt > requirements.txt

# With hashes (like pip-compile --generate-hashes)
uv export --format requirements-txt --hash > requirements.txt
```

## Migrating from conda

### Before: conda Workflow

```bash
# Create environment
conda create -n myenv python=3.12

# Activate
conda activate myenv

# Install packages
conda install numpy pandas

# Install from requirements
pip install -r requirements.txt

# Export environment
conda env export > environment.yml
```

### After: uv Workflow

```bash
# Initialize with specific Python
uv python install 3.12
uv python pin 3.12
uv venv

# Add packages
uv add numpy pandas

# Import requirements
uv add -r requirements.txt

# Export lockfile
uv lock
```

### Migration Considerations

**Conda provides system-level packages (C libraries, etc.):**

- UV only manages Python packages
- System dependencies must be installed separately:

  ```bash
  # Ubuntu/Debian
  sudo apt-get install libhdf5-dev

  # macOS
  brew install hdf5
  ```

**Python-only projects:**

- Full migration possible
- UV is faster and lighter

**Projects with heavy system dependencies:**

- Consider Docker for reproducibility
- Or keep conda for system deps, use UV for Python deps

### Hybrid Approach

Use conda for system environment, UV for Python packages:

```bash
# Create conda environment with Python only
conda create -n myenv python=3.12
conda activate myenv

# Use UV for Python packages
uv sync
uv run python script.py
```

## Migrating CI/CD

### From pip CI/CD

```yaml
# Before (pip)
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.12'
    cache: 'pip'

- name: Install dependencies
  run: |
    pip install -r requirements.txt

# After (uv)
- name: Install uv
  uses: astral-sh/setup-uv@v2
  with:
    enable-cache: true

- name: Set up Python
  run: uv python install 3.12

- name: Install dependencies
  run: uv sync --frozen
```

### From Poetry CI/CD

```yaml
# Before (Poetry)
- name: Install Poetry
  run: pipx install poetry

- name: Install dependencies
  run: poetry install

- name: Run tests
  run: poetry run pytest

# After (uv)
- uses: astral-sh/setup-uv@v2
  with:
    enable-cache: true

- run: uv sync --frozen

- run: uv run pytest
```

### Docker Migration

```dockerfile
# Before (pip)
FROM python:3.12-slim
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# After (uv)
FROM python:3.12-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
COPY . .
```

## Team Migration Strategy

### Phase 1: Preparation (Week 1)

1. **Pilot on non-critical project:**

   ```bash
   # Test on small project
   cd test-project
   uv init
   uv add -r requirements.txt
   uv sync
   ```

2. **Document team workflow:**
   - Installation instructions
   - Common commands comparison
   - Troubleshooting guide

3. **Set up CI/CD on pilot:**
   - Update GitHub Actions
   - Verify builds pass
   - Measure performance improvement

### Phase 2: Team Onboarding (Week 2)

1. **Team communication:**
   - Share benefits (speed, simplicity)
   - Provide training session
   - Distribute documentation

2. **Install UV on developer machines:**
   `curl -LsSf https://astral.sh/uv/install.sh | sh`

3. **Migrate one project together:**
   - Live migration session
   - Address questions
   - Document any issues

### Phase 3: Gradual Migration (Weeks 3-6)

1. **Migrate projects incrementally:**
   - Start with newest projects
   - Low-risk projects first
   - High-impact projects last

2. **Maintain backwards compatibility:**

   ```bash
   # Keep requirements.txt updated
   uv export --format requirements-txt > requirements.txt
   ```

3. **Update documentation:**
   - README.md setup instructions
   - Contributing guidelines
   - CI/CD docs

### Phase 4: Full Adoption (Week 7+)

1. **Remove legacy tooling:**

   ```bash
   git rm requirements.txt
   git rm poetry.lock
   ```

2. **Update templates:**
   - Project templates use UV
   - CI/CD templates use UV
   - Documentation defaults to UV

3. **Measure success:**
   - Installation time reduction
   - Developer satisfaction
   - CI/CD speed improvement

## Rollback Plan

If migration issues occur:

1. **Keep requirements.txt updated:**

   ```bash
   uv export --format requirements-txt > requirements.txt
   git add requirements.txt
   ```

2. **Fallback to pip:**

   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Preserve both lockfiles temporarily:**

   ```bash
   # Keep both until confident
   git add uv.lock poetry.lock
   ```

## Common Migration Issues

### Issue: Different package versions resolved

**Solution:** Check version constraints:

```bash
# Compare resolutions
uv lock --verbose
poetry show  # or pip list
```

### Issue: Git dependencies not working

**Solution:** Use [tool.uv.sources]:

```toml
[tool.uv.sources]
my-package = { git = "https://github.com/user/repo.git" }
```

### Issue: CI/CD slower than expected

**Solution:** Enable caching:

```yaml
- uses: astral-sh/setup-uv@v2
  with:
    enable-cache: true
    cache-dependency-glob: "uv.lock"
```

### Issue: Team resistance to change

**Solution:**

- Show speed improvements
- Highlight simplified workflow
- Provide comprehensive documentation
- Offer pairing sessions

## Success Metrics

Track these to measure migration success:

- **Installation time:** Before vs After
- **CI/CD duration:** Before vs After
- **Developer satisfaction:** Survey results
- **Onboarding time:** New developers setup time
- **Dependency update frequency:** Before vs After
