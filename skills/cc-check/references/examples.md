# Test Case Examples

This document provides concrete examples of test cases for different types of Claude Code customizations.

## Skill Test Example (vc-ship)

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

## Hook Test Example (auto-format.sh)

**Test 1: Markdown File Edit**

- Input: Edit to a `.md` file triggers PostToolUse hook
- Expected: Hook exits 0, prettier formats the file
- Actual: Exit code 0, file formatted with prettier
- Status: PASS

**Test 2: Non-Markdown File**

- Input: Edit to a `.py` file triggers PostToolUse hook
- Expected: Hook exits 0, skips formatting (not a supported file type)
- Actual: Exit code 0, no formatting applied
- Status: PASS

**Test 3: Missing Prettier**

- Input: Edit on system without prettier installed
- Expected: Hook exits 0 gracefully (doesn't block the edit)
- Actual: Exit code 0, warning logged but edit proceeds
- Status: PASS
