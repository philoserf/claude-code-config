---
name: audit
description: Run comprehensive audits of Claude Code customizations in background. Delegates to audit-coordinator skill.
model: inherit
allowed_tools:
  - Skill
  - Read
  - Glob
  - Grep
---

## Purpose

Run comprehensive quality audits on Claude Code customizations (agents, skills, commands, hooks, output-styles).

## Delegation

This agent delegates to **audit-coordinator** for core functionality.

## Approach

1. Accept target specification (file path, component type, or scope)
2. Invoke audit-coordinator skill with appropriate arguments
3. Return consolidated audit findings
