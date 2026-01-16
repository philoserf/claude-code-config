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

**Problem**: Agent file >500 lines

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

Since agents must be single files (no references supported), you have two options:

1. **Trim content**: Remove non-essential sections, keep focus narrow
2. **Convert to skill**: Skills support reference files for progressive disclosure

**Convert to skill example**:

```text
skills/my-capability/
├── SKILL.md                  # Core workflow
├── detailed-guide.md         # Reference file
├── examples.md               # Reference file
└── reference-tables.md       # Reference file
```

**When to convert**:

- Agent >500 lines: Consider skill conversion
- Agent needs reference material: Must convert to skill

## Issue 7: Agent Has Subdirectory

**Problem**: Agent structured as directory instead of single file

**Example**:

```text
agents/
└── my-agent/              # ✗ Wrong - agents are single files
    ├── my-agent.md
    └── references/
```

**Fix**:

Agents must be single files. Either:

1. Inline all content into single file (if <500 lines)
2. Convert to skill (if needs references)

```text
agents/
└── my-agent.md            # ✓ Correct - single file
```

**Why this matters**: Claude Code specification requires agents to be single files. Subdirectories and references are not supported for agents.
