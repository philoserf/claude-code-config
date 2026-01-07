---
description: Comprehensive audit of Claude Code configuration with optional scope
argument-hint: "[local|personal|full]"
---

# audit-setup

Comprehensive audit of Claude Code configuration with optional scope selection.

**Usage:**

- `/audit-setup` - Audit full setup (both personal and project, default)
- `/audit-setup local` or `/audit-setup project` - Audit `.claude/` in current directory only
- `/audit-setup personal` or `/audit-setup user` - Audit `~/.claude/` global configuration only
- `/audit-setup full` or `/audit-setup both` - Audit everything (explicit full scope)

**Scopes:**

- **Local/Project**: Audit `.claude/` in current directory (project-specific customizations)
- **Personal/User**: Audit `~/.claude/` global configuration (user-level customizations)
- **Full**: Audit both scopes with conflict detection (default)

**Target**: ${ARGUMENTS:-full setup (both personal and project)}

**Delegation:** Invokes the **audit-coordinator** skill for complete setup evaluation including inventory, configuration health, tool permissions, integration analysis, context economy, and security assessment. The skill automatically detects scope from arguments and filters audit targets accordingly.
