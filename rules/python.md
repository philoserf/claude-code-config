---
paths:
  - "**/*.py"
---

# Python Rules

## Package Management & Execution

- Use `uv` for all dependency and environment management
- Use `uvx` to run Python tools and scripts from PyPI
- For self-contained scripts, use PEP 723 inline dependencies in script headers
- Never use `pip`, `pip3`, `poetry`, or `pipenv`

## Inline Dependencies (PEP 723)

Self-contained scripts must declare dependencies as PEP 723 script metadata. Example:

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "requests>=2.28",
#     "click>=8.0",
# ]
# ///

import requests
import click
```

Run with: `uvx --script <file.py>`

## Code Style

- Use Black for code formatting
- Use Ruff for linting
- Use type hints for function signatures
- Prefer f-strings for string formatting
- Use pathlib for filesystem operations
- Handle exceptions explicitly; avoid bare `except:` clauses
