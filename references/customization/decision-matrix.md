# Claude Code Component Decision Matrix

Quick reference for choosing the right component type. For detailed scenarios, migration paths, and examples, see [when-to-use-what.md](when-to-use-what.md).

**Implementation Details**:

- [Naming Conventions](naming-conventions.md) - Naming patterns for all components
- [Frontmatter Requirements](frontmatter-requirements.md) - YAML specification

## Decision Matrix: Claude Code Component Selection

| **Criterion**     | **Skill**                              | **Subagent**                | **Command**             | **Output Style**             | **Hook**                 |
| ----------------- | -------------------------------------- | --------------------------- | ----------------------- | ---------------------------- | ------------------------ |
| **Trigger**       | Auto (Claude detects need)             | Auto or explicit            | Explicit (`/command`)   | Session-level                | Event-based (lifecycle)  |
| **Context**       | Inherits main conversation             | Isolated, separate context  | Main conversation       | Replaces system prompt       | Injected at event point  |
| **Tool Access**   | Same as main agent (unless restricted) | Configurable subset         | Same as invoker         | Full default tools           | N/A (executes shell)     |
| **Statefulness**  | Stateless (per invocation)             | Stateful (own conversation) | Stateless               | Session-persistent           | Stateless                |
| **Primary Use**   | Domain knowledge/best practices        | Complex isolated tasks      | Quick reusable prompts  | Transform Claude's persona   | Deterministic automation |
| **File Location** | `.claude/skills/*/SKILL.md`            | `.claude/agents/*.md`       | `.claude/commands/*.md` | `.claude/output-styles/*.md` | `.claude/settings.json`  |
| **Scope Options** | Project, User, Plugin                  | Project, User, Plugin       | Project, User, Plugin   | Project, User                | Project, User, Plugin    |

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

**Commands** — Frequently-used prompt templates

- Repetitive prompts with parameter substitution
- Team-shared workflows that don't need auto-triggering
- Quick access to common instructions
- Arguments via `$ARGUMENTS`, `$1`, `$2` syntax

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

### **Decision Flow**

```text
Need automatic execution based on task context?
├─ Yes → Need isolation from main conversation?
│  ├─ Yes → **Subagent**
│  └─ No → **Skill**
└─ No → Need manual invocation?
   ├─ Yes → **Command**
   └─ No → Need guaranteed execution at events?
      ├─ Yes → **Hook**
      └─ No → Need to transform Claude's core behavior?
         └─ Yes → **Output Style**
```

### **Key Distinctions**

**Skill vs Command**: Skills auto-trigger when Claude detects relevance; commands require `/command` invocation.

**Skill vs Subagent**: Skills add knowledge to current context; subagents run isolated with own tools/conversation.

**Skill vs MCP**: Skills teach _how_ to use tools; MCP provides _what_ tools exist.

**Hook vs Skill**: Hooks guarantee execution (deterministic shell scripts); skills provide guidance Claude may/may not follow.

**Output Style vs CLAUDE.md**: Output styles _replace_ system prompt; `CLAUDE.md` _appends_ user message.

---

**Sources**:

- [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Skills](https://code.claude.com/docs/en/skills)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [Output Styles](https://code.claude.com/docs/en/output-styles)
- [Hooks](https://code.claude.com/docs/en/hooks)

---

**Next Steps**:

- Chosen component type? See [Naming Conventions](naming-conventions.md) for naming patterns
- Ready to implement? See [Frontmatter Requirements](frontmatter-requirements.md) for YAML specs
