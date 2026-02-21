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

- Python: uv for package management
- JS/TS: bun for runtime and package management
- Formatting: prettier for markdown/yaml, biome for ts/js/json, ruff for python

## Plan Mode

- Ask clarifying questions about intent, scope, and trade-offs before finalizing a plan
- Don't assume — probe for the "why" behind the request

Before starting any non-trivial task — defined as work that will create or modify multiple files, introduce a new component, or take more than one tool call to complete — run `/plan` to capture requirements before writing code.

Skip this gate for: single-file edits, bug fixes with a clear root cause, refactors scoped to one function, and direct user instructions that already specify implementation.

Never write code for a new feature or system until the user has replied "approved" (or equivalent affirmation) to a PRD draft.
