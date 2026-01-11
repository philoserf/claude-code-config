# COGITA·DISCE·NECTE·ENUNTIA

## Technical Environment

- macOS on Apple M4 MacBook Air and M4 Pro Mac Mini
- iOS/iPadOS on iPhone Air and iPad Pro (M4)
- fish shell, ghostty, vscode, git, gh
- Obsidian for knowledge management

## Tool Preferences

### Version Control

- Use `gh` for GitHub-specific operations (PRs, issues, workflows)
- Use `git` for standard version control operations
- Prefer `gh pr create` over manual GitHub UI navigation
- Use `gh api` for GitHub API interactions

### Editor

- VSCode is the primary editor
- Respect existing workspace settings
- Use project-specific extensions when configured

### Terminal

- Ghostty is the primary terminal
- Use fish shell for persoanl terminal setup
- Use bash for scripting

## Principles

- Yes, and… - Build on ideas constructively
- Name things once - Avoid duplication
- Embrace simplicity - Choose the simplest solution
- Ask permission once - Don't repeatedly confirm
- Assume good intentions - Trust and collaborate
- Use one file/folder until needed - Start simple, split when necessary
- Accept defaults first, deviate when justified - Don't prematurely optimize

## Code Preferences

### General

- Write clear, idiomatic code for the language in use
- Prioritize readability and maintainability over cleverness
- Use descriptive variable and function names
- Keep functions small and focused on a single responsibility
- Prefer composition over inheritance

### Go

- Follow Go idioms and conventions
- Use `gofmt` for formatting
- Handle errors explicitly, don't ignore them
- Use interfaces for abstraction
- Keep dependencies minimal

### JavaScript/TypeScript

- Use modern ES6+ features
- Prefer `const` over `let`, avoid `var`
- Use async/await over raw promises
- Follow project's existing style (ESLint/Prettier configs)

### Python

- Use `uv` for self-contained scripts with inline dependencies
- Use Black and Ruff
- Use type hints for function signatures
- Handle exceptions explicitly, avoid bare `except:` clauses
- Prefer f-strings for string formatting
- Use pathlib for file system operations
- Keep virtual environments isolated per project

### Shell Scripting

- Use fish shell syntax for interactive scripts and personal automation
- Use bash for portable/shareable scripts
- Include shebang line (`#!/usr/bin/env fish` or `#!/bin/bash`)
- Quote variables to prevent word splitting
- Use meaningful names for functions and variables
- Check exit codes and handle errors explicitly
- Prefer built-in commands over external utilities for portability
- Use shfmt and shellcheck

### Documentation

- Write comments for "why", not "what"
- Document public APIs and exported functions
- Keep documentation close to code
- Update docs when code changes

### Testing

- Write tests for new features and bug fixes
- Follow the existing test structure in the project
- Use descriptive test names that explain what is being tested
- Aim for clear, maintainable tests over 100% coverage

### Git Workflow

- Write atomic commits with clear, descriptive messages
- Use conventional commit format when specified
- Keep commits focused on a single logical change
- Don't commit secrets, credentials, or environment files

## Project-Specific Guidance

For document collection management guidance (PDF examination, duplicate prevention, naming conventions, etc.), see:

- **~/Documents/Traveller/CLAUDE.md** - Traveller RPG collection management
