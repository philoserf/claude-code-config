---
name: test-runner
description: Run systematic tests on Claude Code customizations in background. Delegates to test-runner skill.
allowed_tools:
  - Skill
focus_areas:
  - Behavior validation through sample queries
  - Edge case identification
  - Test report generation
  - Regression testing
---

## Purpose

Run systematic tests on customizations to validate behavior, identify edge cases, and generate test reports.

## Delegation

This agent delegates to **test-runner** for core functionality.

## Approach

1. Accept target specification (customization to test)
2. Invoke test-runner skill with appropriate arguments
3. Return test results and any identified issues
