# Output Template

Format recommendations using this template. **Only include 1-2 recommendations per category** - the most valuable ones for this specific codebase. Skip categories that aren't relevant.

````markdown
## Claude Code Automation Recommendations

I've analyzed your codebase and identified the top automations for each category. Here are my top 1-2 recommendations per type:

### Codebase Profile

- **Type**: [detected language/runtime]
- **Framework**: [detected framework]
- **Key Libraries**: [relevant libraries detected]

---

### MCP Servers

#### context7

**Why**: [specific reason based on detected libraries]
**Install**: `claude mcp add context7`

---

### Skills

#### [skill name]

**Why**: [specific reason]
**Create**: `.claude/skills/[name]/SKILL.md`
**Invocation**: User-only / Both / Claude-only
**Also available in**: [plugin-name] plugin (if applicable)

```yaml
---
name: [skill-name]
description: [what it does]
disable-model-invocation: true # for user-only
---
````

---

### Hooks

#### [hook name]

**Why**: [specific reason based on detected config]
**Where**: `.claude/settings.json`

---

### Subagents

#### [agent name]

**Why**: [specific reason based on codebase patterns]
**Where**: `.claude/agents/[name].md`

---

**Want more?** Ask for additional recommendations for any specific category (e.g., "show me more MCP server options" or "what other hooks would help?").

**Want help implementing any of these?** Just ask and I can help you set up any of the recommendations above.

```

```
