# CI/CD and Docker Integration

## GitHub Actions

### Basic Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v2
        with:
          enable-cache: true
          cache-dependency-glob: "uv.lock"

      - name: Set up Python
        run: uv python install 3.12

      - name: Install dependencies
        run: uv sync --frozen

      - name: Run tests
        run: uv run pytest

      - name: Run linting
        run: |
          uv run ruff check .
          uv run black --check .
```

### Matrix Testing

```yaml
# .github/workflows/test-matrix.yml
name: Test Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ["3.11", "3.12", "3.13"]

    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v2
        with:
          enable-cache: true

      - name: Set up Python ${{ matrix.python-version }}
        run: uv python install ${{ matrix.python-version }}

      - name: Install dependencies
        run: uv sync --frozen --all-extras

      - name: Run tests
        run: uv run pytest
```

### With Coverage

```yaml
# .github/workflows/coverage.yml
name: Coverage

on: [push, pull_request]

jobs:
  coverage:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: astral-sh/setup-uv@v2
        with:
          enable-cache: true

      - run: uv python install 3.12

      - run: uv sync --frozen

      - name: Run tests with coverage
        run: uv run pytest --cov=src --cov-report=xml

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

### With Artifacts

```yaml
# .github/workflows/build.yml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: astral-sh/setup-uv@v2

      - run: uv python install 3.12

      - run: uv sync --frozen

      - name: Build package
        run: uv build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/
```

## GitLab CI

```yaml
# .gitlab-ci.yml
image: python:3.12-slim

stages:
  - test
  - build

before_script:
  - curl -LsSf https://astral.sh/uv/install.sh | sh
  - export PATH="$HOME/.cargo/bin:$PATH"

test:
  stage: test
  script:
    - uv python install 3.12
    - uv sync --frozen
    - uv run pytest
  cache:
    paths:
      - .venv/
      - ~/.cache/uv/

lint:
  stage: test
  script:
    - uv sync --frozen
    - uv run ruff check .
    - uv run black --check .

build:
  stage: build
  script:
    - uv build
  artifacts:
    paths:
      - dist/
  only:
    - main
```

## CircleCI

```yaml
# .circleci/config.yml
version: 2.1

jobs:
  test:
    docker:
      - image: cimg/python:3.12

    steps:
      - checkout

      - run:
          name: Install uv
          command: curl -LsSf https://astral.sh/uv/install.sh | sh

      - run:
          name: Add uv to PATH
          command: echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> $BASH_ENV

      - restore_cache:
          keys:
            - uv-cache-{{ checksum "uv.lock" }}
            - uv-cache-

      - run:
          name: Install dependencies
          command: uv sync --frozen

      - run:
          name: Run tests
          command: uv run pytest

      - save_cache:
          key: uv-cache-{{ checksum "uv.lock" }}
          paths:
            - ~/.cache/uv

workflows:
  test:
    jobs:
      - test
```

## Docker Integration

### Basic Dockerfile

```dockerfile
FROM python:3.12-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-dev

# Copy application code
COPY . .

# Run application
CMD ["uv", "run", "python", "-m", "my_project"]
```

### Multi-Stage Build

```dockerfile
# Build stage
FROM python:3.12-slim AS builder

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Install dependencies to virtual environment
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-editable

# Runtime stage
FROM python:3.12-slim

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.venv .venv

# Copy application code
COPY . .

# Use virtual environment
ENV PATH="/app/.venv/bin:$PATH"

# Run application
CMD ["python", "-m", "my_project"]
```

### Optimized with Cache Mount

```dockerfile
FROM python:3.12-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies with cache mount
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Copy application
COPY . .

CMD ["uv", "run", "python", "-m", "my_project"]
```

### Development Dockerfile

```dockerfile
# Dockerfile.dev
FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install all dependencies including dev
RUN uv sync --frozen --all-extras

# Copy application
COPY . .

# Expose port for development server
EXPOSE 8000

# Run with auto-reload
CMD ["uv", "run", "python", "-m", "my_project", "--reload"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    volumes:
      - .:/app
    environment:
      - ENVIRONMENT=production

  dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8000:8000"
    volumes:
      - .:/app
      - /app/.venv  # Don't mount venv
    environment:
      - ENVIRONMENT=development
    command: uv run python -m my_project --reload
```

## Performance Optimizations

### Caching Strategies

**GitHub Actions:**

```yaml
- uses: astral-sh/setup-uv@v2
  with:
    enable-cache: true
    cache-dependency-glob: "uv.lock"
```

**GitLab CI:**

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .venv/
    - ~/.cache/uv/
```

**Docker:**

```dockerfile
# Layer caching - copy dependencies first
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# Then copy code (changes more frequently)
COPY . .
```

### Parallel Installations

UV automatically parallelizes installations. No configuration needed.

```bash
# UV does this automatically:
# - Parallel downloads
# - Parallel wheel builds
# - Parallel installations
```

### Offline Mode

For air-gapped environments:

```bash
# Populate cache on internet-connected machine
uv sync

# Export cache
tar czf uv-cache.tar.gz ~/.cache/uv

# On offline machine
tar xzf uv-cache.tar.gz -C ~/

# Install offline
uv sync --offline
```

## Production Deployment

### Preparation

```bash
# Lock dependencies
uv lock

# Export for audit
uv export --format requirements-txt --hash > requirements.txt

# Verify lockfile is committed
git add uv.lock
git commit -m "Lock dependencies for production"
```

### Deployment Script

```bash
#!/bin/bash
set -euo pipefail

# Install uv if not present
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Install exact dependencies from lockfile
uv sync --frozen --no-dev

# Run migrations (example)
uv run alembic upgrade head

# Start application
uv run gunicorn my_project.wsgi:application
```

### systemd Service

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/myapp
Environment="PATH=/home/www-data/.cargo/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/home/www-data/.cargo/bin/uv run gunicorn my_project.wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
```

### Kubernetes Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: myapp:latest
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: production
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
```

## Security Best Practices

### Dependency Hashing

```bash
# Export with hashes for verification
uv export --format requirements-txt --hash > requirements.txt

# Install with hash verification
uv pip install -r requirements.txt --require-hashes
```

### Minimal Images

```dockerfile
# Use slim or alpine base images
FROM python:3.12-slim

# Don't install dev dependencies
RUN uv sync --frozen --no-dev

# Run as non-root user
RUN useradd -m -u 1000 appuser
USER appuser
```

### Security Scanning

```yaml
# .github/workflows/security.yml
- name: Security scan
  run: |
    uv run pip-audit
    uv run bandit -r src/
```

## Troubleshooting

### CI Cache Issues

```yaml
# Clear cache if corrupt
- name: Clear cache
  run: uv cache clean
```

### Permission Issues in Docker

```dockerfile
# Run as non-root
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
```

### Slow Docker Builds

```dockerfile
# Use cache mounts
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen

# Or use multi-stage builds
FROM python:3.12-slim AS builder
# ...build stage...
FROM python:3.12-slim
COPY --from=builder /app/.venv .venv
```
