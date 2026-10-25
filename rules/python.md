---
paths:
  - "**/*.py"
  - "pyproject.toml"
  - "ruff.toml"
---

- Run Python through uv (global, in `CLAUDE.md`). A standalone script carries PEP 723 metadata (`# /// script` with `requires-python` and `dependencies`) and the shebang `#!/usr/bin/env -S uv run --script`, so `./script.py` and the repo's `uv run --script` resolve the same interpreter
- Prefer the standard library. A dependency goes in the script's `dependencies` block, never a `requirements.txt` or a hand-made venv
- Lint and format with ruff (`uvx ruff check`, `uvx ruff format`), on its defaults unless the repo's `ruff.toml` says otherwise; never black, isort or flake8
