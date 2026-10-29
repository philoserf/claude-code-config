---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/ruff.toml"
---

- Python here is standalone scripts, run through uv (global, in `CLAUDE.md`). Every script opens with a PEP 723 block (`# /// script`) carrying `requires-python`, a stdlib-only one too—without it uv picks whichever interpreter it finds, and this machine has 3.9 through 3.15. Set `requires-python` to the oldest version the script needs, not the newest installed
- A script run as `./script.py` also gets the shebang `#!/usr/bin/env -S uv run --script` and the executable bit. One that only a Taskfile calls, as `uv run --script path/to/script.py`, needs neither
- Prefer the standard library. A dependency goes in the script's `dependencies` list, never a `requirements.txt` or a hand-made venv
- Lint and format with ruff through `uvx ruff check` and `uvx ruff format`—uvx fetches it, so it is in no Brewfile. Never black, isort, flake8 or pylint. The repo's lint or check task runs both; a read-only gate uses `ruff format --check`
- With no `ruff.toml`, ruff runs on its defaults. A repo that writes one starts from `select = ["ALL"]` and subtracts: every `ignore` entry carries a comment saying why, and no key restates a default (`ruff config <key>` shows it)
