# Common Issues in Agent Configurations

Catalog of frequent problems and their fixes when auditing agents.

## Issue 1: Opus Overuse

**Problem**: Using Opus when Sonnet would suffice

**Example**:

```yaml
model: opus # Expensive for this task
```

**Impact**: 5-10x higher cost for minimal benefit

**Fix**:

```yaml
model: sonnet # Balanced choice
```

**When Opus is justified**: Complex architectural design, deep reasoning required

## Issue 2: Generic Focus Areas

**Problem**: Vague, abstract expertise definitions

**Example**:

```markdown
## Focus Areas

- Programming best practices
- Code quality
- Good design patterns
```

**Fix**:

```markdown
## Focus Areas

- Defensive programming with strict error handling
- SOLID principles in TypeScript applications
- Test-driven development with Jest and React Testing Library
```

## Issue 3: Missing Tool Restrictions

**Problem**: No allowed_tools specified

**Impact**: Agent has unrestricted access (security risk)

**Fix**:

```yaml
allowed_tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
```

## Issue 4: Tool Restrictions Too Restrictive

**Problem**: Missing tools that agent needs

**Example**:

```yaml
allowed_tools: [Read, Grep] # Too limited for code generator
```

Agent content mentions Write and Edit but they're not allowed.

**Fix**: Add missing tools or remove references to them.

## Issue 5: Incomplete Approach

**Problem**: Vague methodology without steps

**Example**:

```markdown
## Approach

Follow best practices and write good code.
```

**Fix**:

```markdown
## Approach

1. Analyze requirements and constraints
2. Design architecture using SOLID principles
3. Implement with test-driven development
4. Review for security and performance
5. Document with inline comments and README

Output: Production-ready code with full test coverage
```

## Issue 6: Oversized Single File

**Problem**: Agent file >500 lines without references/ directory

**Example**:

```text
agents/
└── my-agent.md  # 750 lines - too large
```

**Impact**:

- Slow to load and parse
- Hard to navigate
- High context usage
- Difficult to maintain

**Fix**:

Extract detailed content to references/ directory:

```text
agents/
└── my-agent/
    ├── my-agent.md         # <400 lines, core workflow
    └── references/
        ├── detailed-guide.md
        ├── examples.md
        └── reference-tables.md
```

**When to refactor**:

- Agent >500 lines: Consider references
- Agent >800 lines: Must use references

## Issue 7: References at Wrong Location

**Problem**: Reference files at agent root instead of references/ subdirectory

**Example**:

```text
agents/
└── my-agent/
    ├── my-agent.md
    ├── examples.md      # ✗ Wrong - should be in references/
    └── guide.md         # ✗ Wrong - should be in references/
```

**Fix**:

```text
agents/
└── my-agent/
    ├── my-agent.md
    └── references/      # ✓ Correct location
        ├── examples.md
        └── guide.md
```

**Why this matters**: Agents use references/ subdirectory (unlike skills which use flat structure)

## Issue 8: Orphaned Reference Files

**Problem**: Files in references/ not linked from main agent file

**Impact**:

- Users can't discover them
- Content is hidden
- Wasted context

**Example**:

Main file has no "Reference Files" section, or missing links.

**Fix**:

Add clear reference section at top of agent file:

```markdown
## Reference Files

This agent uses reference materials in the `references/` directory:

- [examples.md](references/examples.md) - Concrete examples and patterns
- [guide.md](references/guide.md) - Detailed implementation guide
```

**Validation**: Every file in references/ must be linked from main file.
