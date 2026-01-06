# Naming Conventions

Consistent naming patterns for Claude Code subagents, commands, skills, and hooks to improve discoverability, avoid conflicts, and communicate intent clearly.

**Related Documentation**:

- [Frontmatter Requirements](frontmatter-requirements.md) - YAML specifications for each component type
- [When to Use What](when-to-use-what.md) - Decision guide for choosing component types
- [Decision Matrix](decision-matrix.md) - Quick comparison table

## Core Principles

1. **Kebab-case for files**: All files use lowercase with hyphens (`my-component.md`)
2. **Descriptive names**: Names should clearly indicate purpose and scope
3. **Consistency**: Use same terminology across filenames, descriptions, and documentation

## Subagents (`.claude/agents/`)

### Naming Pattern

`{domain}-{role}.md` or `{action}-{target}.md`

### Examples

- `claude-code-test-runner.md` - Runs and fixes tests
- `security-reviewer.md` - Reviews code for security issues
- `api-designer.md` - Designs API endpoints and contracts
- `performance-optimizer.md` - Analyzes and optimizes performance
- `debugger.md` - Debugs errors and unexpected behavior

### Guidelines

- Use action verbs for behavior-focused agents (`claude-code-test-runner`, `code-reviewer`)
- Use role nouns for specialized expertise (`debugger`, `architect`)
- Avoid generic names like `helper.md` or `agent.md`
- Include phrases like "use PROACTIVELY" or "MUST BE USED" in description field for automatic invocation

### Built-in Subagents (Reference Only)

- `explore` - Fast, read-only codebase exploration (Haiku, limited tools)
- `plan` - Research and planning in plan mode (Sonnet, read tools)
- General-purpose - Complex multi-step tasks requiring both exploration and action (Sonnet, all tools)

## Slash Commands (`.claude/commands/`)

### Naming Pattern

`{action}.md` or `{action}-{target}.md`

### Examples

- `optimize.md` - Analyze and optimize performance
- `security-review.md` - Review for security vulnerabilities
- `fix-issue.md` - Fix specific GitHub issues
- `test.md` - Run tests with optional pattern

### Guidelines

- Use imperative verbs (`optimize`, `review`, `fix`, `generate`)
- Use `$ARGUMENTS` for all arguments, `$1`, `$2` for positional parameters
- Commands require `description` in frontmatter to appear in `/help` and be model-invocable via SlashCommand tool

### Command Action Verbs

Commands should use action verbs that align with the skills they delegate to. Standard verbs and their usage:

**audit** - Validate, analyze, or review existing artifacts

- Pattern: `audit-{target}` delegates to `{target}-audit` skill
- Examples: `audit-agent`, `audit-bash`, `audit-skill`
- Use when: Invoking validation/analysis skills

**create** - Guide creation of new artifacts

- Pattern: `create-{target}` delegates to `{target}-authoring` skill
- Examples: `create-agent`, `create-skill`, `create-command`
- Use when: Invoking authoring/guidance skills

**automate** - Execute multi-step workflows

- Pattern: `automate-{domain}` delegates to `{domain}-workflow` skill
- Examples: `automate-git` → `git-workflow`
- Use when: Invoking workflow automation skills

**process** - Transform or manipulate inputs

- Pattern: `process-{target}` delegates to `process-{target}` skill
- Examples: `process-pdfs`
- Use when: Invoking transformation skills

### Delegation Alignment Principle

**Commands should align with the skills they delegate to:**

✅ **Good alignment** (verb matches skill capability):

- `audit-agent` → `agent-audit` (audit action → audit capability)
- `create-skill` → `skill-authoring` (create action → authoring capability)
- `automate-git` → `git-workflow` (automate action → workflow capability)

❌ **Poor alignment** (verb mismatch):

- `validate-agent` → `agent-audit` (validate vs audit confusion)
- `analyze-setup` → `audit-coordinator` (analyze vs audit semantic drift)

**Guideline**: Use command verbs that semantically match the skill's suffix pattern. This creates a predictable, consistent user experience.

### Qualifier Guidelines

Avoid redundant qualifiers when context is obvious:

❌ **Unnecessary qualifiers**:

- `audit-skill` - "claude" is redundant (all skills are Claude skills)
- `audit-setup` - "claude" is redundant (context is clear)

✅ **Clean names**:

- `test-skill` or `audit-skill`
- `audit-setup`

**Exception**: Keep qualifiers when they distinguish between similar targets:

- `git-workflow` - distinguishes from other workflow types
- `bash-audit` - distinguishes from other audit types

### Command → Skill Reference Table

Current command inventory and delegation patterns:

| Command               | Delegates To             | Alignment         |
| --------------------- | ------------------------ | ----------------- |
| `audit-agent`         | `agent-audit`            | ✅ Perfect        |
| `audit-bash`          | `bash-audit`             | ✅ Perfect        |
| `audit-command`       | `command-audit`          | ✅ Perfect        |
| `audit-hook`          | `hook-audit`             | ✅ Perfect        |
| `audit-output-style`  | `output-style-audit`     | ✅ Perfect        |
| `audit-setup`         | `audit-coordinator`      | ✅ Semantic match |
| `audit-skill`         | `skill-audit`            | ✅ Perfect        |
| `automate-git`        | `git-workflow`           | ✅ Semantic match |
| `create-agent`        | `agent-authoring`        | ✅ Semantic match |
| `create-command`      | `command-authoring`      | ✅ Semantic match |
| `create-output-style` | `output-style-authoring` | ✅ Semantic match |
| `create-skill`        | `skill-authoring`        | ✅ Semantic match |

**Pattern**: `{action}-{target}` command → `{target}-{capability}` skill

This alignment ensures users can intuitively predict command names based on the capabilities they want to invoke.

## Agent Skills (`.claude/skills/`)

### Naming Pattern

`{capability}/SKILL.md` where `{capability}` is kebab-case

**Core Principle**: Skills describe **capabilities** (what they do), not agents/actors (who does it).

- ✅ `bash-audit` (capability: auditing bash)
- ❌ `bash-auditor` (actor: who audits)

### Skill Suffix Patterns

Skills should use consistent suffixes based on their primary function. Choose the pattern that best matches the skill's capability.

#### 1. Validation/Analysis Skills

**Pattern**: `{target}-audit` or `{target}-review`

Use the action (audit, review, analyze) not the actor (auditor, reviewer, analyzer).

**Examples**:

- `bash-audit/` - Audits bash scripts for safety and best practices
- `skill-audit/` - Audits skills for discoverability
- `agent-audit/` - Audits agents for correctness
- `code-review/` - Reviews code for quality and patterns
- `security-review/` - Reviews for security vulnerabilities

**When to use**:

- Skill validates, analyzes, or reviews existing artifacts
- Primary output is a report or assessment
- Read-only analysis (no modifications)

**Rationale**: The capability is "auditing" or "reviewing", not "being an auditor". This aligns with other capability-focused names.

#### 2. Creation/Guidance Skills

**Pattern**: `{target}-authoring` or `{technology}-scripting`

**Examples**:

- `agent-authoring/` - Guides creation of agents
- `skill-authoring/` - Guides creation of skills
- `command-authoring/` - Guides creation of commands
- `output-style-authoring/` - Guides creation of output-styles
- `bash-scripting/` - Master of bash script creation

**When to use**:

- Skill guides users in creating new artifacts
- Provides templates, patterns, and best practices
- Interactive guidance with AskUserQuestion
- Educational/advisory nature

**Rationale**: "Authoring" clearly indicates creation guidance. "Scripting" is language-specific for writing code.

#### 3. Processing/Transformation Skills

**Pattern**: `{action}-{target}` or `{target}-{processor}`

**Examples**:

- `process-pdfs/` - PDF manipulation and extraction
- `format-code/` - Code formatting and style
- `optimize-images/` - Image compression and conversion
- `data-transform/` - Data processing and transformation

**When to use**:

- Skill modifies or transforms inputs
- Produces new outputs from existing inputs
- Active processing/computation

**Rationale**: Action verbs (process, format, optimize) emphasize transformation capability.

#### 4. Workflow/Automation Skills

**Pattern**: `{domain}-workflow` or `{process}-automation`

**Examples**:

- `git-workflow/` - Complete git commit and PR workflows
- `test-automation/` - Automated testing workflows
- `deploy-automation/` - Deployment automation
- `release-workflow/` - Release management workflows

**When to use**:

- Skill orchestrates multi-step processes
- Automates complex workflows
- Coordinates multiple operations

**Rationale**: "Workflow" indicates orchestration. "Automation" emphasizes hands-free execution.

#### 5. Coordination/Orchestration Skills

**Pattern**: `{scope}-coordinator` or `{scope}-orchestrator`

**Examples**:

- `audit-coordinator/` - Coordinates multiple specialized auditors
- `test-coordinator/` - Coordinates test execution across suites
- `build-orchestrator/` - Orchestrates build processes

**When to use**:

- Skill delegates to other skills/agents
- Compiles results from multiple sources
- Manages complex multi-tool workflows
- Uses Skill and/or Task tools for delegation

**Rationale**: "Coordinator" and "orchestrator" are actors, but they describe a **capability** (coordination) that requires agent-like behavior. This is an exception to the capability-first rule because coordination inherently requires an orchestrating entity.

#### 6. Assistant/Helper Skills

**Pattern**: `{domain}-assistant` or `{purpose}-helper`

**Examples**:

- `editing-assistant/` - Comprehensive text editing and improvement
- `refactor-assistant/` - Code refactoring guidance
- `debug-helper/` - Debugging assistance

**When to use**:

- Skill provides interactive assistance
- Broad scope within a domain
- Combines multiple related capabilities

**Rationale**: "Assistant" indicates interactive, broad-scope help. Use sparingly for truly comprehensive helpers.

#### 7. Utility/Tool Skills

**Pattern**: `{purpose}-{noun}` or `{action}-{object}`

**Examples**:

- `organize-folders/` - Folder organization guidance
- `bash-scripting/` - Defensive bash scripting guide
- `markdown-formatter/` - Markdown formatting utilities

**When to use**:

- Skill provides specific utility function
- Narrow, focused purpose
- Tool-like behavior

**Rationale**: Flexible pattern for utilities that don't fit other categories.

### Suffix Decision Matrix

Quick reference for choosing the right suffix:

| If the skill...                       | Use pattern            | Example             |
| ------------------------------------- | ---------------------- | ------------------- |
| Validates/analyzes existing artifacts | `{target}-audit`       | `bash-audit`        |
| Guides creation of new artifacts      | `{target}-authoring`   | `agent-authoring`   |
| Transforms/processes inputs           | `{action}-{target}`    | `process-pdfs`      |
| Automates multi-step workflows        | `{domain}-workflow`    | `git-workflow`      |
| Coordinates other skills/agents       | `{scope}-coordinator`  | `audit-coordinator` |
| Provides interactive assistance       | `{domain}-assistant`   | `editing-assistant` |
| Writes code in specific language      | `{language}-scripting` | `bash-scripting`    |
| Provides specialized utility          | `{purpose}-{noun}`     | `organize-folders`  |

### Common Naming Mistakes

**❌ Using actor nouns instead of capabilities**:

- Bad: `bash-auditor/` (who audits)
- Good: `bash-audit/` (capability: auditing)

**❌ Mixing singular and plural**:

- Bad: `pdf-processor/` vs `pdfs-processor/`
- Good: Choose one convention and stick to it (`process-pdfs/`)

**❌ Overly generic names**:

- Bad: `helper/`, `assistant/`, `tool/`
- Good: `editing-assistant/`, `refactor-helper/`

**❌ Redundant qualifiers**:

- Bad: `bash-script-audit/` (script is implied)
- Good: `bash-audit/`

**❌ Inconsistent verb forms**:

- Bad: `reviewing-code/` (gerund)
- Good: `code-review/` (noun form of action)

### Guidelines

- Directory name becomes the skill identifier
- `SKILL.md` is mandatory and contains the main instructions
- Use descriptive, capability-focused names
- Supporting files (scripts, templates, configs) organize by function
- Skills are model-invoked (automatic) vs commands which are user-invoked (manual)
- Claude reads supporting files via progressive disclosure when needed
- **Consistency check**: If you have multiple related skills, ensure they use the same suffix pattern
- **Discovery test**: The name should help Claude discover the skill when users ask for that capability

### Migration Guide for Existing Skills

If you have skills using inconsistent patterns, here's how to align them with the naming model:

#### Pattern: `-auditor` → `-audit`

**Current inconsistency**:

```text
✗ agent-auditor/
✗ skill-auditor/
✗ hook-auditor/
✗ command-auditor/
✗ output-style-auditor/
✓ bash-audit/
✓ claude-code-audit/
```

**Recommended migration**:

```bash
# Rename skill directories
mv agent-auditor agent-audit
mv skill-auditor skill-audit
mv hook-auditor hook-audit
mv command-auditor command-audit
mv output-style-auditor output-style-audit
```

**After renaming, update**:

1. **Frontmatter name field** in SKILL.md: `name: agent-audit`
2. **Skill invocations** that reference the old name
3. **Documentation** that mentions the old name
4. **Command files** that delegate to the skill: `/audit-agent` → uses `agent-audit`

**Impact assessment**:

- Low risk: Skill names are directory-based, so renaming is safe
- Update needed: Commands, documentation, cross-references
- Test after: Verify skill still triggers correctly with new name

#### Migration Checklist

For each renamed skill:

- [ ] Rename directory: `old-name/` → `new-name/`
- [ ] Update SKILL.md frontmatter: `name: new-name`
- [ ] Update skill description if it mentions the old name
- [ ] Search for references: `grep -r "old-name" ~/.claude/`
- [ ] Update command files that invoke the skill
- [ ] Update documentation mentioning the skill
- [ ] Test invocation: Verify skill triggers with natural queries
- [ ] Update any skills that reference this skill via Skill tool

#### Testing After Migration

**Verify skill triggering**:

```text
User: "Audit my agent"
Expected: Should invoke agent-audit skill
```

**Verify command delegation**:

```text
User: "/audit-agent my-agent"
Expected: Command should delegate to agent-audit skill
```

**Verify cross-references**:

- Check audit-coordinator skill references
- Check documentation in other skills
- Verify examples in authoring guides

## Hooks (Scripts in `hooks/` directory)

### Naming Pattern

`{purpose}.sh` or `{purpose}.py`

### Examples

- `validate-config.py` - Validates YAML frontmatter
- `auto-format.sh` - Formats code after edits
- `log-git-commands.sh` - Logs git operations
- `notify-idle.sh` - Desktop notifications

### Guidelines

- Use descriptive, purpose-focused names
- Include file extension (`.sh`, `.py`, etc.)
- Must be executable (`chmod +x`)
- Configure in `settings.json` hooks section

## File Naming Quick Reference

| Component       | Location                 | Pattern                 | Example                      |
| --------------- | ------------------------ | ----------------------- | ---------------------------- |
| Subagent        | `.claude/agents/`        | `{domain}-{role}.md`    | `claude-code-test-runner.md` |
| Command         | `.claude/commands/`      | `{action}-{target}.md`  | `fix-issue.md`               |
| Skill (general) | `.claude/skills/{name}/` | `{capability}/SKILL.md` | `bash-audit/SKILL.md`        |
| Skill (audit)   | `.claude/skills/`        | `{target}-audit/`       | `bash-audit/`                |
| Skill (author)  | `.claude/skills/`        | `{target}-authoring/`   | `agent-authoring/`           |
| Skill (process) | `.claude/skills/`        | `{action}-{target}/`    | `process-pdfs/`              |
| Skill (coord)   | `.claude/skills/`        | `{scope}-coordinator/`  | `audit-coordinator/`         |
| Hook            | `.claude/hooks/`         | `{purpose}.{ext}`       | `validate-config.py`         |

## Skills vs Commands Decision Guide

| Aspect     | Slash Commands            | Agent Skills                          |
| ---------- | ------------------------- | ------------------------------------- |
| Invocation | User-invoked (`/command`) | Model-invoked (automatic)             |
| Complexity | Simple prompts            | Complex capabilities                  |
| Structure  | Single `.md` file         | Directory with `SKILL.md` + resources |
| Files      | One file only             | Multiple files, scripts, templates    |

**Use commands for:**

- Frequently-used prompts you invoke explicitly
- Quick templates and reminders
- Actions requiring explicit user control

**Use skills for:**

- Capabilities Claude should discover automatically
- Complex workflows with multiple steps
- Reference materials organized across files

---

**Next Steps**:

- Ready to implement? See [Frontmatter Requirements](frontmatter-requirements.md) for YAML specs
- Need help choosing component type? See [When to Use What](when-to-use-what.md)
