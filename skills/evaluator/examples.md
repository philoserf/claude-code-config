# Examples

This document provides good and poor examples of Claude Code customizations for comparison.

## Good Agent Example

```markdown
---
name: test-runner
description: Runs systematic tests on Claude Code customizations. Executes sample queries, validates responses, generates test reports, and identifies edge cases for agents, commands, skills, and hooks.
model: sonnet
---

## Focus Areas

- Test query generation
- Response validation
- Edge case identification
- Report generation
- Regression testing
- Performance benchmarking
- Coverage analysis
- Integration testing
- Error scenario handling
- Documentation verification

## Approach

1. Analyze target customization structure
2. Generate appropriate test queries
3. Execute tests with validation criteria
4. Capture and analyze responses
5. Identify edge cases and failure modes
6. Generate structured test report
7. Document findings and recommendations
8. Track regression over time

Output: Comprehensive test report with pass/fail status, edge cases, and recommendations.
```

**Assessment**: PASS

- Clear, specific description with purpose details
- Comprehensive focus areas (10 specific items)
- Concrete approach with methodology steps
- Appropriate model selection (Sonnet for balanced capability)
- Well-organized and professional

## Poor Skill Example

```markdown
---
name: helper
description: Helps with things
---

# Helper Skill

## When to Use

Use this skill when you need help with various tasks.

## What It Does

This skill helps you accomplish different goals.
```

**Issues**:

- Description too vague and short (<50 chars)
- "When to Use" in body instead of frontmatter description
- No specifics about capabilities or use cases
- Missing allowed-tools specification
- Not using SKILL.md filename convention
- Generic, unhelpful content

**Fix**:

```markdown
---
name: task-automation
description: Automates common development workflows including git operations, code formatting, testing, and deployment. Use when you need to streamline repetitive tasks, create project templates, or orchestrate multi-step processes.
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Task Automation Skill

This skill provides automation for common development workflows.

## Capabilities

- Git workflow automation (commit, branch, PR creation)
- Code formatting and linting
- Test execution and reporting
- Build and deployment pipelines
- Project scaffolding

## Reference Files

See [workflow-patterns.md](workflow-patterns.md) for detailed automation patterns.
```

## Good Command Example

```markdown
---
description: Run git workflow operations with best practices
---

# version-control

Automate git workflows with branch management, atomic commits, and PRs.

**Usage:** `/version-control [operation]`

**Delegation:** Invokes the **version-control** skill for comprehensive git operations.
```

**Assessment**: PASS

- Clear, concise description
- Simple delegation pattern
- Usage instructions provided
- Minimal, focused scope
- 8 lines total (appropriate for simple command)

## Poor Command Example

```markdown
---
description: Does code stuff
---

# code-helper

This command helps you with code.

Use it when you need to:
- Write code
- Fix code
- Improve code
- Understand code

It will analyze your request and figure out what to do. It uses various
tools and techniques to provide comprehensive code assistance. It can handle
multiple programming languages and frameworks. It integrates with your
development environment and follows best practices.

Just invoke it with your request and it will handle the rest!
```

**Issues**:

- Vague description and purpose
- No clear delegation target
- Too much generic explanation (14 lines of fluff)
- No specific capabilities listed
- Missing usage instructions
- Unclear what it actually does
- Should probably be broken into multiple focused commands

## Good Hook Example

```python
#!/usr/bin/env python3
# Validates YAML frontmatter before Write/Edit operations
# Exit codes: 0=allow, 2=block

import json
import sys

try:
    import yaml
except ImportError:
    print("Warning: PyYAML not installed, skipping validation", file=sys.stderr)
    sys.exit(0)

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")
    content = data.get("tool_input", {}).get("content", "")

    if not file_path.endswith(".md"):
        sys.exit(0)

    # Validation logic here...

    sys.exit(0)  # Allow operation

except Exception as e:
    print(f"Error in hook: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block user on hook errors
```

**Assessment**: PASS

- Correct shebang line
- Safe JSON parsing with .get() defaults
- Dependency checking with graceful fallback
- Proper exit codes (0=allow, 2=block)
- Comprehensive error handling
- Clear comments explaining purpose

## Poor Hook Example

```python
#!/usr/bin/python
# Validation hook

import json
import sys

data = json.loads(sys.stdin.read())
path = data["tool_input"]["file_path"]

if ".md" in path:
    # Do validation
    result = validate(path)
    if not result:
        sys.exit(1)
```

**Issues**:

- Wrong shebang (should be `#!/usr/bin/env python3`)
- No error handling (will crash on malformed JSON)
- Direct key access (no .get() defaults)
- Wrong exit code (using 1 instead of 2 to block)
- No stderr messages explaining failures
- Missing try/except to prevent blocking user
- Incomplete validation logic
