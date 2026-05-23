---
allowed-tools:
  - Read
  - Bash
  - Glob
description: Runs Python code quality checks. Use when checking Python quality, linting, type checking, running tests, validating Python code, or running python checks. Covers formatting and linting with ruff, type checking with mypy, and test execution with pytest.
effort: low
paths:
  - "**/*.py"
  - "pyproject.toml"
---

# Python Quality Gate

Run a standardized set of Python quality checks. Auto-fix what's fixable, report the rest with specific locations.

## Prerequisites

Verify these tools are available before running checks. All run via `uvx` — no global installs needed.

- `ruff` — formatter and linter (`uvx ruff`)
- `mypy` — static type checker (`uvx mypy`)
- `pytest` — test runner (`uv run pytest`)

## Check Sequence

Run checks in this order. Formatting first so later tools analyze clean code.

### 1. Format (auto-fix)

Run `uvx ruff format .` — report which files were modified. If no files changed, report "formatting clean."

### 2. Lint fix (auto-fix)

Run `uvx ruff check --fix .` — apply safe auto-fixes. Report which rules were fixed and in which files.

### 3. Lint (report)

Run `uvx ruff check .` — report remaining issues with file, line, rule code, and message. If a `pyproject.toml` or `ruff.toml` exists, it's picked up automatically.

### 4. Type check (report)

Run `uvx mypy .` or `uvx mypy src/` depending on project layout. If no type hints exist in the project, skip this step and note it in the summary. If `mypy` config exists in `pyproject.toml`, it's picked up automatically.

### 5. Test (report)

Run `uv run pytest` — if a `pyproject.toml` with `[tool.pytest]` or a `pytest.ini`/`conftest.py` exists. Use `-x` for fail-fast only if the user requests it. Report pass/fail counts. If no tests exist, note it in the summary.

## Output

After all checks complete, present a summary table:

```text
| Check       | Status | Details            |
|-------------|--------|--------------------|
| ruff format | FIXED  | 3 files formatted  |
| ruff fix    | FIXED  | 5 auto-fixes       |
| ruff check  | WARN   | 2 issues remaining |
| mypy        | PASS   |                    |
| pytest      | FAIL   | 8 passed, 2 failed |
```

Then list specific issues grouped by file, with line numbers and rule codes. Offer to fix reported issues if the user wants.

## Project Detection

- **uv project**: `pyproject.toml` with `[project]` — use `uv run` for pytest
- **PEP 723 scripts**: Single files with inline metadata — use `uv run --script`
- **No project file**: Run tools directly via `uvx` against `.py` files

## Do not use when

- Checking code in another language — use the matching `bash-quality-gate`, `go-quality-gate`, or `typescript-quality-gate`
- Deep structural refactoring — use `refactor-clean`
- Reviewing a staged or branch diff — use `diff-review`
