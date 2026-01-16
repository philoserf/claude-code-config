---
name: codebase-mapper
description: Analyze codebase structure and produce documentation in background. Delegates to map-codebase skill.
# model: inherit
allowed_tools:
  - Skill
  - Read
  - Glob
  - Grep
  - Write
---

## Purpose

Analyze codebases to produce structured documentation covering stack, architecture, structure, conventions, testing, integrations, and concerns.

## Delegation

This agent delegates to **map-codebase** for core functionality.

## Approach

1. Accept target codebase path
2. Invoke map-codebase skill
3. Return generated documentation location
