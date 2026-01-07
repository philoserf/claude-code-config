# Agents vs Skills vs Commands

Decision guide for choosing the right customization type for your use case.

---

## Decision Matrix

| Aspect                | Agent                      | Skill                      | Command                  |
| --------------------- | -------------------------- | -------------------------- | ------------------------ |
| **Invocation**        | Auto or manual             | Auto only                  | Manual only (`/command`) |
| **Complexity**        | High (separate subprocess) | Medium-High                | Low (delegates)          |
| **Model choice**      | Configurable per agent     | Inherits from parent       | Inherits (or subprocess) |
| **Tool restrictions** | Yes (allowed_tools)        | Yes (allowed-tools)        | Yes (if subprocess)      |
| **Context**           | Isolated subprocess        | Main conversation          | Main conversation        |
| **Use case**          | Complex, focused tasks     | Domain knowledge/workflows | User shortcuts           |

---

## Use an Agent when

- Task requires different model than main conversation
- Need strict tool restrictions for security/focus
- Want isolated context (separate from main conversation)
- Complex, specialized capability needed
- Can be auto-triggered OR manually invoked
- Task benefits from subprocess isolation

**Examples**:

- Code analysis agent with read-only tools
- Language-specific code generator
- Security auditor with restricted permissions

---

## Use a Skill when

- Adding domain knowledge to main conversation
- Auto-triggering is important (skill discovery)
- Complex workflows in main context
- Progressive disclosure with co-located reference files
- Want to extend base capabilities automatically
- Need to provide specialized knowledge

**Examples**:

- Git workflow automation
- PDF processing expertise
- Editing and proofreading assistance
- Shell script auditing knowledge

---

## Use a Command when

- User wants explicit shortcut
- Simple delegation to agent/skill
- Frequently-used prompt pattern
- User controls invocation timing
- Creating convenience wrapper
- One-liner that delegates

**Examples**:

- `/create-agent` - delegates to author-agent skill
- `/audit-agent` - invokes evaluator agent
- `/automate-git` - delegates to git-workflow skill

---

## Decision Flow

```text
Start: What are you building?

├─ Is it a user-typed shortcut?
│  └─ YES → Command (delegates to agent or skill)
│
├─ Does it need a different model or strict tool restrictions?
│  └─ YES → Agent (subprocess with custom config)
│
├─ Does it add specialized knowledge to main conversation?
│  └─ YES → Skill (extends base capabilities)
│
└─ Not sure?
   └─ Start with Skill, convert to Agent if needed
```

---

## Common Scenarios

### Scenario: "I want to add Python expertise"

**Option 1**: Agent (python-expert)

- Use if: Need to restrict tools, use different model, or isolate context
- Pros: Strict control, custom model, isolated
- Cons: More complex, separate context

**Option 2**: Skill (python-expert)

- Use if: Want to extend main conversation with Python knowledge
- Pros: Auto-triggers, integrates with main conversation
- Cons: Inherits model and context from parent

**Recommendation**: Start with Skill unless you need agent-specific features

### Scenario: "I want a shortcut for common task"

**Answer**: Command

- Create `/task-name` command
- Delegate to appropriate agent or skill
- Keep command simple (no complex logic)

### Scenario: "I need to analyze code with read-only access"

**Answer**: Agent

- Use read-only tools (Read, Grep, Glob, Bash)
- Model: Haiku (fast) or Sonnet (more judgment)
- Pattern: Read-Only Analyzer

### Scenario: "I want to teach Claude about my domain"

**Answer**: Skill

- Add domain expertise via SKILL.md
- Use co-located reference files for detailed documentation
- Auto-triggers when relevant queries appear

---

## Migration Paths

### Skill → Agent

When to migrate:

- Need different model (Haiku for speed, Opus for complexity)
- Need strict tool restrictions
- Want isolated context

How:

1. Copy skill content to agent file
2. Add model and allowed_tools to frontmatter
3. Test in isolated context
4. Update invoking commands if needed

### Agent → Skill

When to migrate:

- Agent doesn't need isolation
- Want auto-triggering in main conversation
- Don't need custom model or tool restrictions

How:

1. Copy agent content to SKILL.md
2. Remove model and allowed_tools from frontmatter
3. Test auto-triggering
4. Consider progressive disclosure with co-located reference files

### Command → Skill

When to migrate:

- Command has complex logic (should delegate instead)
- Want auto-triggering instead of manual invocation

How:

1. Extract logic to new skill
2. Update command to delegate to skill
3. Keep command simple

---

## Quick Reference

**Choose Agent for**: Isolation, custom model, strict tools, subprocess
**Choose Skill for**: Domain knowledge, auto-trigger, main conversation
**Choose Command for**: User shortcuts, simple delegation, explicit control
