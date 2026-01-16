---
name: validator
description: Quick structural validation of Claude Code customization files. Delegates to evaluator skill.
# model: haiku
allowed_tools:
  - Skill
  - Read
  - Glob
  - Grep
---

## Purpose

Perform fast structural validation of customization files including YAML syntax, required fields, naming conventions, and file organization.

## Delegation

This agent delegates to **evaluator** for core functionality.

## Approach

1. Accept target file or directory
2. Invoke evaluator skill
3. Return validation results
