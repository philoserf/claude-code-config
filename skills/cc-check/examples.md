---
name: Test Case Examples
description: Concrete test case examples for skills, agents, commands, and hooks with expected inputs and outputs
---

# Test Case Examples

This document provides concrete examples of test cases for different types of Claude Code customizations.

## Skill Test Example (version-control)

**Test 1: Commit Creation**

- Input: "Help me commit these changes with atomic commits"
- Expected: Skill triggers, analyzes changes, creates organized commits
- Actual: Skill triggered, analyzed 5 files, created 3 atomic commits with conventional prefixes
- Status: PASS

**Test 2: PR Creation**

- Input: "Create a pull request for my feature branch"
- Expected: Skill pushes code, creates PR with gh, includes description
- Actual: Pushed to origin/feature-auth, created PR #42 with auto-generated summary
- Status: PASS

**Test 3: Non-Trigger**

- Input: "What is git?"
- Expected: Skill does NOT trigger (informational query)
- Actual: No skill invocation; Claude answered with general git explanation
- Status: PASS

## Agent Test Example (cc-lint)

**Test 1: Agent Evaluation**

- Input: "Evaluate the bash agent"
- Expected: Reads bash-scripting.md, generates structured report with findings
- Actual: Read agents/bash-scripting.md, produced lint report with 2 warnings (missing focus areas, description could be more specific)
- Status: PASS

**Test 2: Invalid Target**

- Input: "Evaluate nonexistent-agent"
- Expected: Clear error message about missing agent
- Actual: Error: "Agent 'nonexistent-agent' not found in agents/ directory"
- Status: PASS

## Command Test Example (version-control)

**Test 1: With Branch Argument**

- Input: `/version-control feature/new-feature`
- Expected: Creates branch and sets up workflow
- Actual: Created branch feature/new-feature, switched to branch, displayed workflow guidance
- Status: PASS

**Test 2: Without Argument**

- Input: `/version-control`
- Expected: Shows current workflow status
- Actual: Displayed current branch (main), staged files (3), and available actions
- Status: PASS

## Hook Test Example (validate_config.py)

**Test 1: Valid Agent Write**

- Input: Write to agents/test.md with valid frontmatter
- Expected: Hook exits 0 (allow)
- Actual: Exit code 0, write allowed
- Status: PASS

**Test 2: Invalid YAML**

- Input: Write to agents/test.md with broken YAML
- Expected: Hook exits 2 (block) with clear error
- Actual: Exit code 2, message: "YAML parse error at line 3: unexpected character"
- Status: PASS

**Test 3: Missing Required Field**

- Input: Write to agents/test.md without 'model' field
- Expected: Hook exits 2 (block) with specific error
- Actual: Exit code 2, message: "Missing required field: model"
- Status: PASS
