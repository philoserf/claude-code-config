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
- Actual: {result}
- Status: PASS

**Test 2: PR Creation**

- Input: "Create a pull request for my feature branch"
- Expected: Skill pushes code, creates PR with gh, includes description
- Actual: {result}
- Status: PASS

**Test 3: Non-Trigger**

- Input: "What is git?"
- Expected: Skill does NOT trigger (informational query)
- Actual: {result}
- Status: PASS

## Agent Test Example (evaluator)

**Test 1: Agent Evaluation**

- Input: "Evaluate the test-runner agent"
- Expected: Reads test-runner.md, generates structured report with findings
- Actual: {result}
- Status: PASS

**Test 2: Invalid Target**

- Input: "Evaluate nonexistent-agent"
- Expected: Clear error message about missing agent
- Actual: {result}
- Status: PASS/FAIL

## Command Test Example (run-evaluator)

**Test 1: With Argument**

- Input: `/run-evaluator test-runner`
- Expected: Invokes evaluator on test-runner.md
- Actual: {result}
- Status: PASS

**Test 2: Without Argument**

- Input: `/run-evaluator`
- Expected: Evaluates all agents in agents/
- Actual: {result}
- Status: PASS

## Hook Test Example (validate_config.py)

**Test 1: Valid Agent Write**

- Input: Write to agents/test.md with valid frontmatter
- Expected: Hook exits 0 (allow)
- Actual: {result}
- Status: PASS

**Test 2: Invalid YAML**

- Input: Write to agents/test.md with broken YAML
- Expected: Hook exits 2 (block) with clear error
- Actual: {result}
- Status: PASS

**Test 3: Missing Required Field**

- Input: Write to agents/test.md without 'model' field
- Expected: Hook exits 2 (block) with specific error
- Actual: {result}
- Status: PASS
