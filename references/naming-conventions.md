# Naming Conventions

Consistent naming patterns for Claude Code subagents, skills, and hooks to improve discoverability, avoid conflicts, and communicate intent clearly.

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

- `test-runner.md` - Runs and fixes tests
- `security-reviewer.md` - Reviews code for security issues
- `api-designer.md` - Designs API endpoints and contracts
- `performance-optimizer.md` - Analyzes and optimizes performance
- `debugger.md` - Debugs errors and unexpected behavior

### Guidelines

- Use action verbs for behavior-focused agents (`test-runner`, `code-reviewer`)
- Use role nouns for specialized expertise (`debugger`, `architect`)
- Avoid generic names like `helper.md` or `agent.md`
- Include phrases like "use PROACTIVELY" or "MUST BE USED" in description field for automatic invocation

### Built-in Subagents (Reference Only)

- `explore` - Fast, read-only codebase exploration (Haiku, limited tools)
- `plan` - Research and planning in plan mode (Sonnet, read tools)
- General-purpose - Complex multi-step tasks requiring both exploration and action (Sonnet, all tools)

## Agent Skills (`.claude/skills/`)

### Naming Pattern

`{capability}/SKILL.md` where `{capability}` is kebab-case

**Core Principle**: Skills describe **capabilities** (what they do), not agents/actors (who does it).

- ✅ `code-review` (capability: reviewing code)
- ❌ `code-reviewer` (actor: who reviews)

### Skill Suffix Patterns

Skills should use consistent suffixes based on their primary function. Choose the pattern that best matches the skill's capability.

#### 1. Validation/Analysis Skills

**Pattern**: `{target}-audit` or `{target}-review`

Use the action (audit, review, analyze) not the actor (auditor, reviewer, analyzer).

**Examples**:

- `code-review/` - Reviews code for quality and patterns
- `security-review/` - Reviews for security vulnerabilities
- `evaluator/` - Validates Claude Code customizations

**When to use**:

- Skill validates, analyzes, or reviews existing artifacts
- Primary output is a report or assessment
- Read-only analysis (no modifications)

**Rationale**: The capability is "auditing" or "reviewing", not "being an auditor". This aligns with other capability-focused names.

#### 2. Creation/Guidance Skills

**Pattern**: `{target}-authoring` or `{technology}-scripting`

**Examples**:

- `version-control/` - Guides git operations and best practices
- `pdf/` - PDF manipulation toolkit

**When to use**:

- Skill guides users in creating new artifacts
- Provides templates, patterns, and best practices
- Interactive guidance with AskUserQuestion
- Educational/advisory nature

**Rationale**: "Authoring" clearly indicates creation guidance. "Scripting" is language-specific for writing code.

#### 3. Processing/Transformation Skills

**Pattern**: `{action}-{target}` or `{target}-{processor}`

**Examples**:

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

- `version-control/` - Complete git commit and PR workflows
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
- `pdf/` - PDF manipulation toolkit
- `uv-package-manager/` - Python package management

**When to use**:

- Skill provides specific utility function
- Narrow, focused purpose
- Tool-like behavior

**Rationale**: Flexible pattern for utilities that don't fit other categories.

### Suffix Decision Matrix

Quick reference for choosing the right suffix:

| If the skill...                       | Use pattern           | Example             |
| ------------------------------------- | --------------------- | ------------------- |
| Validates/analyzes existing artifacts | `{target}-audit`      | `code-review`       |
| Transforms/processes inputs           | `{action}-{target}`   | `pdf`               |
| Automates multi-step workflows        | `{domain}-workflow`   | `version-control`   |
| Coordinates other skills/agents       | `{scope}-coordinator` | `audit-coordinator` |
| Provides interactive assistance       | `{domain}-assistant`  | `editing-assistant` |
| Provides specialized utility          | `{purpose}-{noun}`    | `organize-folders`  |

### Common Naming Mistakes

**❌ Using actor nouns instead of capabilities**:

- Bad: `code-reviewer/` (who reviews)
- Good: `code-review/` (capability: reviewing)

**❌ Mixing singular and plural**:

- Bad: `pdf-processor/` vs `pdfs-processor/`
- Good: Choose one convention and stick to it (`pdf/`)

**❌ Overly generic names**:

- Bad: `helper/`, `assistant/`, `tool/`
- Good: `editing-assistant/`, `refactor-helper/`

**❌ Redundant qualifiers**:

- Bad: `bash-script-audit/` (script is implied)
- Good: `code-review/`

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
✗ code-reviewer/
✗ security-checker/
✓ code-review/
✓ evaluator/
```

**Recommended migration**:

```bash
# Rename skill directories
mv code-reviewer code-review
mv security-checker security-review
```

**After renaming, update**:

1. **Frontmatter name field** in SKILL.md: `name: code-review`
2. **Skill invocations** that reference the old name
3. **Documentation** that mentions the old name
4. **Command files** that delegate to the skill: `/review-code` → uses `code-review`

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
User: "Review my code"
Expected: Should invoke code-review skill
```

**Verify command delegation**:

```text
User: "/review-code my-file"
Expected: Command should delegate to code-review skill
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

| Component       | Location                 | Pattern                 | Example                 |
| --------------- | ------------------------ | ----------------------- | ----------------------- |
| Subagent        | `.claude/agents/`        | `{domain}-{role}.md`    | `test-runner.md`        |
| Skill (general) | `.claude/skills/{name}/` | `{capability}/SKILL.md` | `version-control/SKILL.md` |
| Skill (audit)   | `.claude/skills/`        | `{target}-audit/`       | `code-review/`          |
| Skill (process) | `.claude/skills/`        | `{action}-{target}/`    | `pdf/`                  |
| Skill (coord)   | `.claude/skills/`        | `{scope}-coordinator/`  | `audit-coordinator/`    |
| Hook            | `.claude/hooks/`         | `{purpose}.{ext}`       | `validate-config.py`    |

---

**Next Steps**:

- Ready to implement? See [Frontmatter Requirements](frontmatter-requirements.md) for YAML specs
- Need help choosing component type? See [When to Use What](when-to-use-what.md)
