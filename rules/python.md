---
paths:
  - "**/*.py"
---

- Use `uv` exclusively (never pip/poetry/pipenv); use `uvx` for PyPI tools
- Self-contained scripts must use PEP 723 inline dependencies:
```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = ["requests>=2.28", "click>=8.0"]
# ///

import requests
import click
```
- Run with: `uvx --script <file.py>`
- Use Black for formatting and Ruff for linting
- Use type hints for function signatures
- Prefer f-strings for string formatting
- Use pathlib for filesystem operations
- Handle exceptions explicitly; avoid bare `except:` clauses
