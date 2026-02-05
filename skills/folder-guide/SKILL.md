---
name: folder-guide
description: Provides guidance on organizing folder structures and file system layouts for any project. Use when planning project organization, reorganizing messy directories, setting up folder hierarchies, designing directory layouts, structuring repositories, cleaning up files, suggesting folder structures, establishing naming conventions, or when you need help with folder structure or file organization. Helps with writing projects, code projects, document collections, or any file organization task.
allowed-tools: [Read, Grep, Glob]
# model: haiku
---

# Folder Organization Guidance

This skill provides **guidance and recommendations** for organizing folder structures and file system layouts. It helps you design effective file organization but doesn't automatically reorganize files.

## User Preferences

The user prefers simple, practical systems with a typical pattern:

- drafts
- published

The user prefers top-level folders for nesting but repository design is flexible. Recommend whatever system best fits the task, keeping things simple.

## Quick Examples

- **Writing projects**: `/rewrite/v1`, `/rewrite/v2` for versioned; `/rewrite/drafts` for text-only
- **Document collections**: Organize by publisher first, then type; split at ~50 files
- **Code projects**: `/src`, `/tests`, `/docs`, `/scripts`
- **Media libraries**: By date (`/2024/01-January`) or event (`/Vacation-2024`)
- **Research**: `/papers`, `/notes`, `/writing`, `/data`, `/references`

For detailed walkthroughs and templates, see [examples-and-workflows.md](examples-and-workflows.md).

## General Principles

- **Start simple**: Use one file/folder until you need more
- **Split when needed**: Create subdirectories when folders get too large (~50+ items)
- **Name consistently**: Establish conventions early
- **Document structure**: Add README.md explaining organization when non-obvious
- **Follow the simplest solution that will get the job done**

## Common Organization Problems

### Too Many Files in One Folder

When a folder exceeds ~50 items, it becomes hard to navigate:

- **Solution**: Create subdirectories by logical grouping (type, date, category)
- **Example**: Split `/documents` into `/documents/contracts`, `/documents/reports`, `/documents/invoices`

### Deeply Nested Structures

More than 3-4 levels of nesting makes files hard to find:

- **Solution**: Flatten by combining middle levels or using more descriptive names
- **Example**: `/projects/client/2024/Q1/reports` → `/projects/client-2024-Q1-reports`

### Inconsistent Naming

Mixed conventions (spaces vs dashes, capitalization) cause confusion:

- **Solution**: Pick one convention and apply consistently
- **Recommended**: kebab-case for code projects, Title Case for documents

## References

For detailed guidance on specific topics, see the reference documentation:

### [document-collection-organization.md](document-collection-organization.md)

Comprehensive guide for organizing PDF and document collections:

- Publisher-first hierarchy strategies
- Size thresholds and when to split directories (30/50/100+ file triggers)
- PDF examination workflow (pdfinfo, pdftotext)
- Duplicate prevention and detection methods
- Periodic audit processes and checklists
- Collection README.md templates
- Handling inherited disorganized collections

### [naming-conventions.md](naming-conventions.md)

Complete naming conventions for all file types:

- Document collections: Title Case with spaces
- Code projects: kebab-case for directories, language-specific for files
- Media libraries: date-based (YYYY-MM-DD) vs event-based naming
- Research papers: Author-Year-Title patterns
- Common mistakes and how to fix them
- Batch renaming strategies and scripts
- Enforcement during audits

### [organization-patterns.md](organization-patterns.md)

Decision frameworks and pattern selection:

- Pattern decision tree (topic, chronological, publisher, type, project, hybrid)
- When to split directories (quantitative and qualitative triggers)
- Anti-patterns to avoid (excessive nesting, premature organization, misc dumping grounds)
- Reorganization strategies and when to reorganize
- Effective pattern combinations

### [examples-and-workflows.md](examples-and-workflows.md)

Step-by-step walkthroughs and templates:

- Organizing 200+ PDF research collection (complete 6-hour workflow)
- Migrating from disorganized to organized structure
- README.md templates for document and code collections
- Quarterly collection audit checklist
- Adding new files to existing collections
- Reorganizing when structure is outgrown
