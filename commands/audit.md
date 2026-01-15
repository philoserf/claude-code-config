---
description: Audit Claude Code customizations for quality and correctness
---

# audit

Comprehensive audit of Claude Code customizations (agents, skills, commands, hooks, output-styles).

## Usage

`/audit [target] [scope]`

- **target**: Specific file, type ("skills", "hooks", "agents"), or "setup" for everything
- **scope**: "local" (.claude/), "personal" (~/.claude/), or "full" (both, default)

## Examples

```text
/audit                     # Full audit of entire setup
/audit skills              # Audit all skills
/audit my-skill            # Audit specific skill
/audit setup local         # Audit only project .claude/
/audit hooks personal      # Audit only ~/.claude/hooks/
```

## Delegation

This command invokes the **audit-coordinator** skill, which orchestrates specialized auditors:

- **audit-skill** - Skill discoverability and triggering
- **audit-agent** - Agent model selection and tool permissions
- **audit-hook** - Hook safety, exit codes, error handling
- **audit-command** - Command simplicity and delegation
- **audit-output-style** - Persona and behavior clarity
- **evaluator** - General structural validation (YAML, fields, format)

Reports are prioritized: Critical > Important > Nice-to-Have.
