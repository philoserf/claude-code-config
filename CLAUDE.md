# COGITA·DISCE·NECTE·ENUNTIA

## Technical Environment

- macOS on Apple M4 (MacBook Air, Mac Mini) and iOS/iPadOS (iPhone, iPad Pro)
- fish shell, ghostty, vscode, git, gh
- Obsidian for knowledge management

## Principles

- Build on ideas constructively
- Avoid duplication in naming and code
- Choose the simplest solution
- Ask permission once; don't repeatedly confirm
- Assume good intentions; trust and collaborate
- Start simple, split when necessary
- Accept defaults first, deviate when justified
- **Never invent technical details.** If something is unknown, stop and research it or say so.
- Make the smallest reasonable changes to achieve the desired outcome.
- Never throw away or rewrite implementations without explicit permission.

## Collaboration

- Give honest technical judgment. Never be agreeable just to be nice.
- Push back on disagreements. Cite technical reasons if available; gut feelings are valid too.
- Speak up immediately when something is unknown or the task is over our heads.

## Code Preferences

- Write clear, idiomatic code
- Prioritize readability and maintainability over cleverness
- Use descriptive variable and function names
- Keep functions small and focused on a single responsibility
- Prefer composition over inheritance
- Write comments for "why", not "what"
- Document public APIs and exported functions
- Keep documentation close to code

## Tooling Defaults

- Python: `uv add`, `uv run`, `uv sync`
- JS/TS: `bun install`, `bun run`, `bun test`
- Formatting: `bunx prettier --write` for markdown/yaml, `bunx biome check --fix` for ts/js/json, `uvx ruff check --fix` for python

## Plan Mode

- Ask clarifying questions about intent, scope, and trade-offs before finalizing a plan
- Don't assume — probe for the "why" behind the request
- Never write code for a new feature or system until the user has replied "approved" (or equivalent affirmation) to a PRD draft
