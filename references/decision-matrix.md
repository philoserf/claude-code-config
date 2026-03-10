# Claude Code Component Decision Matrix

Comprehensive guide for choosing the right component type, with scenarios and migration paths.

**Implementation Details**:

- [Naming Conventions](naming-conventions.md) - Naming patterns for all components
- [Frontmatter Requirements](frontmatter-requirements.md) - YAML specification

## Contents

- Decision Matrix: Claude Code Component Selection
  - When to Use Each Component
  - Decision Flow
  - Key Distinctions
  - Related Component Types
- Common Scenarios
- Migration Paths

## Decision Matrix: Claude Code Component Selection

| **Criterion**     | **Skill**                              | **Subagent**                | **Rule**                     | **Output Style**             | **Hook**                 | **Plugin**                         |
| ----------------- | -------------------------------------- | --------------------------- | ---------------------------- | ---------------------------- | ------------------------ | ---------------------------------- |
| **Trigger**       | Auto (Claude detects need)             | Auto or explicit            | Session start or file match  | Session-level                | Event-based (lifecycle)  | On install                         |
| **Context**       | Inherits main conversation             | Isolated, separate context  | Injected into context        | Replaces system prompt       | Injected at event point  | Bundles other components           |
| **Tool Access**   | Same as main agent (unless restricted) | Configurable subset         | N/A (instructions only)      | Full default tools           | N/A (executes shell)     | Configurable per bundled component |
| **Statefulness**  | Stateless (per invocation)             | Stateful (own conversation) | Session-persistent           | Session-persistent           | Stateless                | Persistent (installed)             |
| **Primary Use**   | Domain knowledge/best practices        | Complex isolated tasks      | Modular, scoped instructions | Transform Claude's persona   | Deterministic automation | Distributable extension bundles    |
| **File Location** | `.claude/skills/*/SKILL.md`            | `.claude/agents/*.md`       | `.claude/rules/*.md`         | `.claude/output-styles/*.md` | `.claude/settings.json`  | `.claude-plugin/plugin.json`       |
| **Scope Options** | Project, User, Plugin                  | Project, User, Plugin       | Project, User                | Project, User                | Project, User, Plugin    | Installable                        |

> **Note on Commands**: `.claude/commands/*.md` still work but are a legacy path. Skills with `user-invocable: true` are the preferred replacement. Commands support `$ARGUMENTS`, `$1`, `$2` parameter substitution and trigger via `/command-name`. Migrate to skills for auto-triggering and richer configuration.

### **When to Use Each Component**

**Skills** — Domain expertise that Claude should know

- Coding standards/patterns for your codebase
- Domain-specific knowledge (API schemas, data models)
- Multi-file guidance with progressive disclosure
- Tool usage patterns (how to use MCP servers correctly)

**Subagents** — Isolated, specialized task execution

- Different tool permissions than main agent
- Complex multi-step workflows requiring isolation
- Different model selection (e.g., Haiku for speed)
- Tasks requiring separate conversation history

**Rules** — Modular, path-scoped instructions

- Topic-specific guidelines (e.g., `markdown.md`, `git.md`, `web.md`)
- Path-conditional behavior via `paths` frontmatter globs
- Always-on constraints that don't need auto-triggering logic
- Splitting a large CLAUDE.md into focused, maintainable pieces

**Output Styles** — Fundamental behavior transformation

- Non-engineering use cases (writing, research, education)
- Complete system prompt replacement
- Session-wide persona changes
- Built-in: Default, Explanatory, Learning

**Hooks** — Guaranteed execution at lifecycle events

- Automatic formatting (post-edit)
- Compliance logging (all bash commands)
- Permission validation (pre-tool-use)
- Custom notifications
- File protection (block sensitive paths)

**Plugins** — Distributable extension bundles

- Packaging skills, agents, hooks, and MCP servers for sharing
- Versioned, namespaced collections (`plugin-name:skill-name`)
- Third-party integrations that need multiple component types
- Team-wide or community distribution

### **Decision Flow**

```text
Need automatic execution based on task context?
├─ Yes → Need isolation from main conversation?
│  ├─ Yes → **Subagent**
│  └─ No → **Skill**
└─ No → Need always-on instructions?
   ├─ Yes → Scoped to file paths or topics?
   │  ├─ Yes → **Rule**
   │  └─ No → Part of project root config? → **CLAUDE.md**
   └─ No → Need guaranteed execution at events?
      ├─ Yes → **Hook**
      └─ No → Need to transform Claude's core behavior?
         ├─ Yes → **Output Style**
         └─ No → Distributing multiple components together?
            └─ Yes → **Plugin**
```

### **Key Distinctions**

**Skill vs Rule**: Skills are task-specific knowledge loaded on demand; rules are always-on instructions loaded at session start or file match.

**Skill vs Subagent**: Skills add knowledge to current context; subagents run isolated with own tools/conversation.

**Skill vs MCP**: Skills teach _how_ to use tools; MCP provides _what_ tools exist.

**Rule vs CLAUDE.md**: Rules are modular and path-scoped; CLAUDE.md is monolithic project-level config. Rules split a growing CLAUDE.md into focused files.

**Hook vs Skill**: Hooks guarantee execution (deterministic shell scripts); skills provide guidance Claude may/may not follow.

**Output Style vs CLAUDE.md**: Output styles _replace_ system prompt; `CLAUDE.md` _appends_ user message.

**Plugin vs Standalone**: Standalone components are project-specific; plugins are distributable, versioned, and namespaced bundles.

### **Related Component Types**

These aren't decision-matrix alternatives but are part of the customization ecosystem:

**MCP Servers** — External tool integrations

- Configured in `.mcp.json` (project) or `~/.claude.json` (user)
- Provide tools from databases, APIs, monitoring, GitHub, Slack, etc.
- Types: HTTP, stdio
- Always available when configured; Claude uses tools as needed

**LSP Servers** — Language-specific code intelligence

- Configured in `.lsp.json`
- Provide real-time type checking and diagnostics
- Auto-loaded; language-specific (TypeScript, Python, Go, Rust, etc.)

## Common Scenarios

### "I want to add Python expertise"

**Option 1: Skill** (recommended start)

- Auto-triggers when Python queries appear
- Integrates with main conversation
- Use `references/` for detailed docs

**Option 2: Subagent** (when you need more control)

- Restrict to read-only tools for analysis
- Use different model (Haiku for speed)
- Isolate context for focused tasks

**Recommendation**: Start with a skill, migrate to subagent if you need isolation or tool restrictions.

### "I need read-only code analysis"

**Answer: Subagent**

- Restrict tools to `Read`, `Grep`, `Glob`, `Bash`
- Model: Haiku (fast) or Sonnet (more judgment)
- Isolated context keeps analysis separate from main work

### "I want Claude to write like a technical writer"

**Answer: Output Style**

- Changes behavior and tone for entire session
- Use `keep-coding-instructions: false` for non-engineering roles
- Activate with `/output-style technical-writer`

### "I need to enforce a policy automatically"

**Answer: Hook**

- Guaranteed execution (can't be forgotten or skipped)
- Fast shell script (<100ms execution time)
- Uses exit codes (0=allow, 2=block)
- Configure in settings.json

**Examples**: Block commits without issue numbers, validate YAML before writes, log all bash commands, auto-format after edits.

### "I have language-specific coding standards"

**Answer: Rule with `paths` frontmatter**

- Loads only when Claude reads matching files
- Keeps standards close to the languages they apply to
- Example: `paths: ["**/*.go", "go.mod"]` for Go conventions

### "I want to share my setup with my team"

**Answer: Plugin**

- Bundle skills, agents, hooks, and MCP servers together
- Versioned and namespaced for clean installation
- Team members install with `/plugin install`

## Migration Paths

### Skill → Subagent

**When to migrate**:

- Need different model (Haiku for speed, Opus for complexity)
- Need strict tool restrictions
- Want isolated context

**How**:

1. Copy skill content to `.claude/agents/<name>.md`
2. Add `model` and `tools` to frontmatter
3. Test in isolated context
4. Update invoking patterns if needed

### Subagent → Skill

**When to migrate**:

- Agent doesn't need isolation
- Want auto-triggering in main conversation
- Don't need custom model or tool restrictions

**How**:

1. Create `skills/<name>/SKILL.md` with skill content
2. Remove model and tools from frontmatter (keep `name`, `description`)
3. Test auto-triggering
4. Consider progressive disclosure with `references/`

### CLAUDE.md → Rules

**When to migrate**:

- CLAUDE.md is growing too large
- Some instructions only apply to certain file types
- Want modular, maintainable config

**How**:

1. Extract topic sections into `.claude/rules/<topic>.md`
2. Add `paths` frontmatter for language/file-specific rules
3. Keep project-wide instructions in CLAUDE.md
4. Rules load automatically — no additional config needed

### Command → Skill

**When to migrate**:

- Want auto-triggering (not just `/command` invocation)
- Need richer frontmatter options (`model`, `context`, `hooks`)
- Want progressive disclosure with `references/`

**How**:

1. Create `skills/<name>/SKILL.md` with command content
2. Add `name` and `description` frontmatter
3. Set `user-invocable: true` to keep `/name` access
4. Move `$ARGUMENTS` substitutions (same syntax works in skills)
5. Delete the old command file

---

**Sources**:

- [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Skills](https://code.claude.com/docs/en/skills)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [Output Styles](https://code.claude.com/docs/en/output-styles)
- [Hooks](https://code.claude.com/docs/en/hooks)
- [Rules](https://code.claude.com/docs/en/rules)
- [Plugins](https://code.claude.com/docs/en/plugins)

---

**Next Steps**:

- Chosen component type? See [Naming Conventions](naming-conventions.md) for naming patterns
- Ready to implement? See [Frontmatter Requirements](frontmatter-requirements.md) for YAML specs
- Need hook events reference? See [Hook Events](hook-events.md) for lifecycle documentation
