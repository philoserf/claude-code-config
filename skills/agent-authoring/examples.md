# Examples from Existing Agents

Real-world examples showing what makes a good agent, taken from production agents in use.

---

## Example 1: Read-Only Analyzer (audit-skill)

```yaml
---
name: audit-skill
description: Audits skills for discoverability and triggering effectiveness. Analyzes description quality, trigger phrase coverage, progressive disclosure, and metadata completeness to ensure skills are invoked appropriately.
model: sonnet
allowed_tools:
  - Read
  - Glob
  - Grep
  - Bash
---
## Focus Areas

- Description Completeness - What the skill does AND when to use it
- Trigger Phrase Coverage - Keywords and patterns that should activate
- Metadata Quality - Frontmatter completeness and accuracy
- Progressive Disclosure - SKILL.md size vs references/ structure
- Reference Organization - File structure, linking, navigation
- Tool Appropriateness - allowed-tools matches actual needs
```

**Why it's good**:

- Clear, specific focus areas with sub-details
- Right model (Sonnet for analysis requiring judgment)
- Minimal tools (read-only) - appropriate for analyzer
- Description explains what AND when to use it
- Focus areas show exactly what gets analyzed

**Pattern**: Read-Only Analyzer

---

## Example 2: Code Generator (code-generator)

```yaml
---
name: code-generator
description: Master of defensive Bash scripting for production automation, CI/CD pipelines, and system utilities. Expert in safe, portable, and testable shell scripts.
allowed_tools: ["Read", "Edit", "Write", "Grep", "Glob", "Bash", "Bash(git:*)"]
model: sonnet
---
## Focus Areas

- Defensive programming with strict error handling
- POSIX compliance and cross-platform portability
- Safe argument parsing and input validation
- Robust file operations and temporary resource management
- Process orchestration and pipeline safety
- Production-grade logging and error reporting
- Comprehensive testing with Bats framework
- Static analysis with ShellCheck and formatting with shfmt
```

**Why it's good**:

- Comprehensive tool access for code generation (Read, Edit, Write, Bash)
- Specific focus areas with technical depth
- Clear description identifying use cases (automation, CI/CD, utilities)
- Extensive approach section with concrete guidance (see agent file)
- Strong emphasis on safety and quality

**Pattern**: Code Generator/Modifier

---

## Example 3: Evaluator (evaluator)

```yaml
---
name: evaluator
description: Evaluates Claude Code customizations for correctness, clarity, and effectiveness. Expert in YAML validation, markdown formatting, tool permission analysis, and best practices for agents, commands, skills, hooks, and output-styles.
model: sonnet
allowed_tools:
  - Read
  - Glob
  - Grep
  - Bash
---
## Focus Areas

- YAML Frontmatter Validation - Required fields, syntax correctness
- Markdown Structure - Organization, readability, formatting
- Tool Permissions - Appropriateness of allowed-tools
- Description Quality - Clarity, completeness, trigger phrase coverage
- File Organization - Naming conventions, directory placement
- Progressive Disclosure - Context economy, reference file usage
- Integration Patterns - Compatibility with existing customizations
```

**Why it's good**:

- Focused tool set (read-only) - evaluator doesn't modify files
- Clear evaluation framework in approach section
- Specific focus areas with sub-categories
- Output format clearly defined (structured reports)
- Description lists all component types it handles

**Pattern**: Read-Only Analyzer

---

## Common Success Factors

All three examples share:

1. **Specific focus areas** - No vague "best practices" or "good code"
2. **Right model choice** - Sonnet for analysis and generation (Haiku would work for simpler analyzers)
3. **Appropriate tools** - Minimal set matching actual needs
4. **Clear descriptions** - What + when + key features
5. **Structured approach** - How the agent works is documented
6. **Real use cases** - Description identifies concrete scenarios

## Anti-Patterns to Avoid

Based on these examples, avoid:

- **Vague focus**: "Python expert" → Instead: "FastAPI REST APIs with SQLAlchemy ORM and pytest"
- **Wrong tools**: Read-only analyzer with Write access → Remove unnecessary tools
- **Poor description**: "Helps with bash" → Instead: "Master of defensive Bash scripting for production automation..."
- **Missing approach**: No methodology section → Add step-by-step process
- **Generic statements**: "Best practices" → Specific: "Defensive programming with strict error handling"
