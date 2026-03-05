---
name: local-issues
description: Review this codebase for bugs, design issues, and code cleanliness problems. Be specific and cite file paths and line numbers.
---

Review this codebase for bugs, design issues, and code cleanliness problems. Be specific and cite file paths and line numbers.

Scope the review to `$ARGUMENTS` if provided, otherwise review the entire project.

For each issue found:

1. Check for duplicates in both GitHub issues (`gh issue list`) and the local `.issues/` directory
2. Skip if a matching issue already exists
3. Otherwise, create a markdown file in `.issues/` with a descriptive kebab-case filename

Each issue file should follow this format:

```text
# Title

**Location:** `file:line`

## Description

What's wrong and why it matters.

## Suggested fix

Concrete recommendation.
```
