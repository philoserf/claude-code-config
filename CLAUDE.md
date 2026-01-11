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

## Document Collection Management

> **Note**: This section contains domain-specific guidance for managing document collections. Consider moving this to project-specific CLAUDE.md files in document management projects rather than keeping it in global configuration. TRAVELLER project

### Organization Principles

- Organize by source/publisher first, then by type
- Maintain flat structures only for small collections (<30 files)
- Create subdirectories when folders exceed ~50 files
- Use consistent naming: Title Case with spaces as word separators
- Document file counts and organization in a README.md file in the collection root
- Run periodic audits to catch duplicates and naming drift
- Keep documentation updated (date stamp counts and updates)

### PDF Examination Tools

Standard workflow for unknown PDFs:

1. `pdfinfo filename.pdf` - Get metadata (Author, Title, Creator, Producer, page count, file size)
2. `pdftotext filename.pdf - | head -50` - Sample first 50 lines of content
3. Visual inspection if needed (Read tool for covers and title pages)

Look for:

- Publisher names in metadata and content
- Copyright notices and dates
- ISBN or product codes
- Edition markers or version numbers
- Visual style indicators (modern vs classic layout)

### Duplicate Prevention

- Check for duplicates before adding files
- Use consistent naming to avoid variations (spaces vs underscores, etc.)
- Remove duplicates immediately when found
- Prefer better-named/better-located version when choosing which to keep

Detection methods:

```bash
# Find files with same name in different locations
find . -type f -name "*.pdf" -exec basename {} \; | sort | uniq -d

# Find files with identical sizes (likely exact duplicates)
find . -type f -name "*.pdf" -exec stat -f "%z %N" {} \; | sort -n | uniq -D -w 10
```

### Naming Conventions for Document Collections

**Standard format**: Title Case with Spaces

- `Document Name Here.pdf` (correct)
- `document_name_here.pdf` (incorrect)
- `document-name-here.pdf` (incorrect)

**Edition/version markers**: Use parentheses

- `Book Title (2nd Edition).pdf`
- `Manual (Revised 2024).pdf`

**Avoid special characters**: `/ \ : * ? " < > |`

- Replace with hyphens or spaces

**Be consistent**: Establish rules in project README.md and follow them

### Collection Maintenance

**Regular audits** (monthly or after significant changes):

1. Verify file counts match documentation
2. Check for duplicate files
3. Identify naming convention violations
4. Update documentation dates

**Documentation hygiene**:

- Keep project README.md updated with accurate counts
- Date stamp all updates
- Document organization decisions and rationale
- Create review documents periodically to assess and plan improvements
