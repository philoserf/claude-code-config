# Examples

This document provides good and poor examples of Claude Code customizations for comparison.

## Contents

- [Good Agent Example](#good-agent-example)
- [Poor Skill Example](#poor-skill-example)
- [Good Command Example](#good-command-example)
- [Poor Command Example](#poor-command-example)
- [Good Hook Example](#good-hook-example)
- [Poor Hook Example](#poor-hook-example)
- [Good Output-Style Example](#good-output-style-example)
- [Poor Output-Style Example](#poor-output-style-example)

## Good Agent Example

```markdown
---
name: bash-scripting
description: Master of defensive Bash scripting for production automation, CI/CD pipelines, and system utilities. Expert in safe, portable, and testable shell scripts.
model: sonnet
---

## Focus Areas

- Defensive programming patterns
- Portability across Unix-like systems
- Error handling and validation
- Safe argument parsing
- Temporary resource management
- Production-grade logging
- Cross-platform compatibility
- ShellCheck compliance
- Testing strategies
- CI/CD integration

## Approach

1. Analyze requirements and platform constraints
2. Design solution using defensive programming principles
3. Implement with strict error handling (set -euo pipefail)
4. Validate inputs and sanitize outputs
5. Add comprehensive logging and error reporting
6. Test on multiple platforms (macOS, Linux)
7. Document assumptions and requirements
8. Ensure ShellCheck compliance

Output: Production-ready Bash script with full error handling, portability checks, and comprehensive documentation.
```

**Assessment**: PASS

- Clear, specific description with technology details
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
- Not using SKILL.md filename convention
- Generic, unhelpful content

**Fix**:

```markdown
---
name: task-automation
description: Automates common development workflows including git operations, code formatting, testing, and deployment. Use when you need to streamline repetitive tasks, create project templates, or orchestrate multi-step processes.
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
description: Format markdown files for consistent style
---

# format-md

Format markdown files for consistent style.

**Usage:** `/format-md [file-path]`

**Delegation:** Invokes the **text-editing** skill with mode=format.
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

## Good Output-Style Example

```markdown
---
name: concise-engineer
description: Terse, technical communication style for experienced developers. Skips preamble, uses code over prose, and favors bullet points over paragraphs.
---

## Persona

Senior engineer in code review mode. Direct, precise, no filler.

## Tone

- Declarative statements over hedging
- Code snippets preferred over descriptions
- Bullet points over paragraphs
- Skip "Sure!" / "Great question!" preamble
```

**Assessment**: PASS

- Clear, specific description with use case context
- Well-defined persona in one sentence
- Concrete tone guidelines with examples of what to do
- Appropriate scope — guides style without over-constraining

## Poor Output-Style Example

```markdown
---
name: friendly
description: Be friendly
---

Be nice and friendly to the user. Use a warm tone. Make them feel welcome.
```

**Issues**:

- Description too short (<50 chars) and vague
- No structured persona definition
- No specific tone guidelines (what does "warm" mean in practice?)
- Missing use case explanation — when would someone choose this over default?
