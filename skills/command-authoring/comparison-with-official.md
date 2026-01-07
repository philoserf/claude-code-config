# Comparison: Official command-development Skill

This document compares Anthropic's official `command-development` skill (from their plugin-dev package) with our `author-command` skill, excluding plugin-specific features.

**Date Created**: 2026-01-03
**Last Updated**: 2026-01-06
**Official version**: 0.2.0
**Our version**: Current

---

## Status

**Current State:** Most identified improvements from the official skill have NOT yet been implemented. Some basic improvements (Common Mistakes, Tips) exist but comprehensive technical documentation is missing.

**Related Discussions:**

- [Issue 81](https://github.com/philoserf/claude-code-setup/issues/81) - Consider standardizing _-authoring naming to_-development to align with official conventions

## Naming Convention Consideration

**Current naming:** `author-command`

**Official naming:** `command-development`

**Implications:**

- Aligning with official naming would mean renaming to `command-development`
- Would affect: skill name, file paths, documentation, user references
- Decision on Issue 81 should be resolved before implementing major improvements
- Impacts coordination with other authoring skills (author-skill, author-agent, author-output-style)

**Trade-offs:**

- **Pro alignment:** Consistency with official conventions, familiar to users of official docs
- **Pro current:** Established in workflows, "authoring" clearly conveys purpose
- **Breaking change:** Renaming requires user migration and documentation updates

---

## Executive Summary

### What They Have That We Don't

1. **Comprehensive frontmatter field documentation** - Detailed specs for all YAML fields
2. **Dynamic arguments documentation** - `$ARGUMENTS`, `$1`, `$2`, positional args
3. **File references (@syntax)** - How to include file contents in commands
4. **Bash execution (!` syntax)** - Inline bash for dynamic context
5. **Command organization patterns** - Flat vs namespaced structures
6. **Validation patterns** - Argument validation, file existence checks, error handling
7. **Common command patterns** - Review, Testing, Documentation, Workflow patterns
8. **Troubleshooting section** - Common problems and solutions
9. **Critical framing** - "Commands are instructions FOR Claude, not messages to users"

### What We Have That They Don't

1. **Focus on delegation over implementation** - Strong emphasis on simple delegation
2. **Design pattern taxonomy** - Four clear patterns with selection criteria
3. **Step-by-step creation process** - Structured 7-step workflow
4. **Delegation clarity** - Emphasis on documenting delegation targets
5. **Commands vs Skills decision guide** - When to use each
6. **Simplicity emphasis** - "Commands should be simple" philosophy
7. **Concrete examples with analysis** - Real examples with "Why it's good" commentary

### Key Philosophical Differences

**Official**: Comprehensive technical reference covering all features
**Ours**: Opinionated guide emphasizing simplicity and delegation

---

## Detailed Analysis

## 1. Skill Description & Triggering

### Official

```yaml
description: This skill should be used when the user asks to "create a slash command",
"add a command", "write a custom command", "define command arguments",
"use command frontmatter", "organize commands", "create command with file references",
"interactive command", "use AskUserQuestion in command", or needs guidance on
slash command structure, YAML frontmatter fields, dynamic arguments, bash execution
in commands, user interaction patterns, or command development best practices for Claude Code.
```

**Analysis**:

- Very comprehensive list of triggers
- Includes technical features (frontmatter, arguments, file references)
- Covers interaction patterns
- Plugin-oriented (mentions AskUserQuestion in commands)

### Ours

```yaml
description: Guide for authoring, creating, writing, building, reviewing, or
improving slash commands that delegate to agents or skills. Use when designing
/commands for user shortcuts, fixing existing commands, or learning command best
practices. Helps design simple command files, choose delegation targets, handle
arguments, and decide when to use commands vs skills. Also triggers when asking
how to create commands, whether to use a command vs skill, or understanding command
patterns. Expert in command patterns, best practices, and keeping commands focused.
```

**Analysis**:

- Emphasizes delegation to agents/skills
- Focuses on "shortcuts" concept
- Includes decision guidance (commands vs skills)
- Shorter but still comprehensive

**Recommendation**: Consider adding these triggers to ours:

- "define command arguments"
- "use command frontmatter"
- "handle command arguments"

---

## 2. Core Philosophy

### Official: "Commands are Instructions FOR Claude"

Their critical insight (lines 30-52):

> Commands are written for agent consumption, not human consumption.
> When a user invokes `/command-name`, the command content becomes Claude's instructions.
> Write commands as directives TO Claude about what to do, not as messages TO the user.

**Example**:
✅ Correct: "Review this code for security vulnerabilities including..."
❌ Incorrect: "This command will review your code for security issues."

**Impact**: This is a **fundamental framing** that prevents user-facing documentation in command prompts.

### Ours: "Commands Should Be Simple"

Our golden rule (lines 42-76):

> Commands delegate, they don't implement.

**Example**:
✅ Good: Simple delegation to agent/skill
❌ Bad: 50 lines of implementation details

**Impact**: This prevents complexity bloat and keeps commands maintainable.

**Synthesis**: Both philosophies are valuable:

- Theirs: Prevents wrong audience (writing to users vs Claude)
- Ours: Prevents wrong scope (implementing vs delegating)

**Recommendation**: Add their "instructions FOR Claude" framing to our skill.

---

## 3. Frontmatter Documentation

### Official Coverage

Comprehensive field documentation (lines 112-193):

1. **description** - Brief description, shown in `/help`, under 60 chars
2. **allowed-tools** - Tool restrictions (Read, Write, Bash(git:\*), etc.)
3. **model** - Specify model (sonnet, opus, haiku)
4. **argument-hint** - Document expected arguments for autocomplete
5. **disable-model-invocation** - Prevent programmatic calling

Each field includes:

- Purpose
- Type
- Default value
- Example YAML
- Best practices
- Use cases

### Our Coverage

Minimal frontmatter mention:

- We mention description is "required"
- Reference to argument-hint in examples
- No detailed field documentation

**Gap Analysis**:
We're missing comprehensive coverage of:

- `allowed-tools` - Critical for security/permissions
- `model` - Important for performance/cost
- `disable-model-invocation` - Controls programmatic access

**Recommendation**: Add frontmatter reference file documenting all official fields.

---

## 4. Dynamic Arguments

### Official Coverage (lines 195-264)

**Three argument patterns**:

1. **$ARGUMENTS** - All arguments as single string

   ```markdown
   Fix issue #$ARGUMENTS following coding standards
   # /fix-issue 123 → "Fix issue #123 following coding standards"
   ```

2. **Positional ($1, $2, $3)** - Individual argument access

   ```markdown
   Review pull request #$1 with priority level $2
   # /review-pr 123 high → "Review pull request #123 with priority level high"
   ```

3. **Combined** - Mix positional and remaining

   ```markdown
   Deploy $1 to $2 environment with options: $3
   # /deploy api staging --force → "Deploy api to staging environment with options: --force"
   ```

### Our Coverage

Minimal argument documentation:

- Mention of `$ARGUMENTS` and `$1, $2` in creation process
- No detailed examples or patterns
- No explanation of differences

**Gap**: We don't teach users **how** to use arguments effectively.

**Recommendation**: Add arguments reference file with:

- When to use $ARGUMENTS vs positional
- How arguments are substituted
- Common patterns
- Edge cases (missing args, spaces, etc.)

---

## 5. File References (@syntax)

### Official Coverage (lines 265-315)

**Three file reference patterns**:

1. **Dynamic file with argument**

   ```markdown
   Review @$1 for code quality
   # /review-file src/api/users.ts → reads that file
   ```

2. **Multiple file references**

   ```markdown
   Compare @src/old-version.js with @src/new-version.js
   ```

3. **Static file references**

   ```markdown
   Review @package.json and @tsconfig.json for consistency
   ```

### Our Coverage

**None** - We don't document file references at all.

**Gap**: Users don't know they can include file contents in commands.

**Recommendation**: Add file references to our documentation:

- When to use @ syntax vs asking Claude to read files
- How it's processed (file read before command execution)
- Best practices (relative paths, file existence)

---

## 6. Bash Execution (!` syntax)

### Official Coverage (lines 316-327)

Mentions bash execution with deferred details:

> Commands can execute bash commands inline to dynamically gather context
> For complete syntax, examples, and best practices, see `references/plugin-features-reference.md`

**Use cases mentioned**:

- Include dynamic context (git status, environment vars)
- Gather project/repository state
- Build context-aware workflows

### Our Coverage

**None** - We don't mention bash execution.

**Gap**: Missing a powerful feature for dynamic commands.

**Decision Point**: Do we want to include this?

- **Pros**: Enables dynamic, context-aware commands
- **Cons**: Adds complexity, potential security issues, goes against our "simplicity" philosophy

**Recommendation**: Document with caution, emphasize:

- Use sparingly
- Delegate to agents/skills for complex logic
- Security implications of bash execution
- Should enhance delegation, not replace it

---

## 7. Command Organization

### Official Coverage (lines 328-369)

**Two organization patterns**:

1. **Flat structure** (5-15 commands)

   ```text
   .claude/commands/
   ├── build.md
   ├── test.md
   └── deploy.md
   ```

2. **Namespaced structure** (15+ commands)

   ```text
   .claude/commands/
   ├── ci/
   │   ├── build.md    # /build (project:ci)
   │   └── test.md     # /test (project:ci)
   └── git/
       └── commit.md   # /commit (project:git)
   ```

**Benefits of namespacing**:

- Logical grouping
- Namespace shown in `/help`
- Easier to find related commands

### Our Coverage

**None** - We don't cover organization patterns.

**Gap**: Users with many commands don't know about namespacing.

**Recommendation**: Add organization guidance:

- When to use flat vs namespaced
- How namespacing works
- Impact on `/help` display
- Migration path (flat → namespaced)

---

## 8. Validation Patterns

### Official Coverage (lines 751-829)

**Four validation types**:

1. **Argument validation**

   ```markdown
   Validate environment: !`echo "$1" | grep -E "^(dev|staging|prod)$" || echo "INVALID"`

   If $1 is valid environment:
     Deploy to $1
   Otherwise:
     Explain valid environments
   ```

2. **File existence checks**

   ```markdown
   Check file exists: !`test -f $1 && echo "EXISTS" || echo "MISSING"`
   ```

3. **Resource validation**

   ```markdown
   Validate setup:
   - Script: !`test -x script.sh && echo "✓" || echo "✗"`
   - Config: !`test -f config.json && echo "✓" || echo "✗"`
   ```

4. **Error handling**

   ```markdown
   Execute build: !`bash build.sh 2>&1 || echo "BUILD_FAILED"`

   If build succeeded:
     Report success
   If build failed:
     Analyze errors and suggest fixes
   ```

### Our Coverage

**None** - We don't cover validation.

**Gap**: Commands fail ungracefully with bad input.

**Decision Point**: Do validation patterns fit our delegation philosophy?

- **Consider**: If commands delegate to agents/skills, the agent/skill should validate
- **But**: Basic argument checking can prevent bad delegations

**Recommendation**: Add minimal validation guidance:

- Validate arguments before delegation
- Let agents/skills handle complex validation
- Provide helpful error messages
- Use AskUserQuestion for clarification when needed

---

## 9. Common Command Patterns

### Official Coverage (lines 434-501)

**Four reusable patterns**:

1. **Review Pattern**

   ```markdown
   Files changed: !`git diff --name-only`
   Review each file for: quality, bugs, tests, docs
   ```

2. **Testing Pattern**

   ```markdown
   Run tests: !`npm test $1`
   Analyze results and suggest fixes
   ```

3. **Documentation Pattern**

   ```markdown
   Generate docs for @$1 including:
   - Function descriptions
   - Parameters
   - Usage examples
   ```

4. **Workflow Pattern**

   ```markdown
   PR #$1 Workflow:
   1. Fetch PR: !`gh pr view $1`
   2. Review changes
   3. Run checks
   ```

### Our Coverage

**Different focus**: We provide patterns based on delegation complexity:

- Pattern 1: Simple Agent Delegator
- Pattern 2: Skill Delegator
- Pattern 3: Documented Agent Delegator
- Pattern 4: Multi-Agent Orchestrator

**Comparison**:

- **Theirs**: Task-based patterns (what the command does)
- **Ours**: Structure-based patterns (how the command delegates)

**Synthesis**: Both are valuable:

- Task patterns help users solve specific problems
- Structure patterns help users build well-organized commands

**Recommendation**: Keep our structure patterns, optionally add task pattern examples.

---

## 10. Troubleshooting

### Official Coverage (lines 502-526)

**Four common problems**:

1. **Command not appearing**
   - Check correct directory
   - Verify `.md` extension
   - Ensure valid Markdown
   - Restart Claude Code

2. **Arguments not working**
   - Verify syntax ($1, $2)
   - Check argument-hint
   - No extra spaces

3. **Bash execution failing**
   - Check allowed-tools
   - Verify syntax
   - Test in terminal
   - Check permissions

4. **File references not working**
   - Verify @ syntax
   - Check file path
   - Ensure Read tool allowed

### Our Coverage

**None** - We don't have troubleshooting.

**Gap**: Users hit problems with no guidance.

**Recommendation**: Add troubleshooting section covering:

- Command not appearing in `/help`
- Arguments not substituting
- Delegation not working
- Common syntax errors

---

## 11. Best Practices

### Official (lines 370-433)

**Five categories**:

1. **Command Design**
   - Single responsibility
   - Clear descriptions
   - Explicit dependencies (allowed-tools)
   - Document arguments (argument-hint)
   - Consistent naming (verb-noun)

2. **Argument Handling**
   - Validate arguments
   - Provide defaults
   - Document format
   - Handle edge cases

3. **File References**
   - Explicit paths
   - Check existence
   - Relative paths
   - Glob support

4. **Bash Commands**
   - Limit scope (Bash(git:_) not Bash(_))
   - Safe commands (no destructive ops)
   - Handle errors
   - Keep fast

5. **Documentation**
   - Add comments
   - Provide examples
   - List requirements
   - Version commands

### Ours (lines 167-188)

**Eight tips**:

1. Keep commands under 50 lines
2. Delegate, don't implement
3. Test with `/help`
4. Use descriptive names
5. Document delegation target
6. Make purpose clear
7. Optional arguments better
8. Start simple

**Comparison**:

- **Theirs**: Comprehensive, technical, covers all features
- **Ours**: Focused on simplicity and delegation

**Synthesis**: Our tips are more philosophical, theirs more practical.

**Recommendation**: Combine both:

- Keep our delegation philosophy
- Add their practical technical advice

---

## 12. Structure & Organization

### Official

**834 lines** organized as:

- Overview and basics (lines 1-73)
- File format (74-111)
- Frontmatter fields (112-193)
- Dynamic features (194-327)
- Organization (328-369)
- Best practices (370-433)
- Common patterns (434-501)
- Troubleshooting (502-526)
- Plugin features (527-829) - EXCLUDED from comparison
- References to additional docs (830-834)

**Progressive disclosure**: Main file + reference files

### Ours

**212 lines** in SKILL.md + **3 reference files** (346 lines total):

- Main: Philosophy, structure, quick reference
- References: Design patterns, creation process, examples

**Progressive disclosure**: Well implemented with references

**Comparison**:

- **Theirs**: All features in one comprehensive file
- **Ours**: Core concepts in main file, details in references

**Recommendation**: Our structure is good, add reference files for:

- Frontmatter fields
- Dynamic features (arguments, file refs, bash)
- Organization patterns
- Troubleshooting

---

## Actionable Improvements

### Priority 1: Critical Additions

1. **Add "Instructions FOR Claude" framing**
   - Explain commands are directives to Claude, not messages to users
   - Show correct vs incorrect examples
   - Emphasize in philosophy section

2. **Create frontmatter-fields.md reference**
   - Document all official fields (description, allowed-tools, model, argument-hint, disable-model-invocation)
   - Purpose, type, default, examples for each
   - Best practices per field

3. **Create dynamic-features.md reference**
   - Arguments: $ARGUMENTS, $1-$9, when to use each
   - File references: @ syntax, patterns, best practices
   - Bash execution: !` syntax, use cases, security concerns

### Priority 2: Enhanced Coverage

1. **Add command-organization.md reference**
   - Flat vs namespaced structures
   - When to use each
   - Migration guidance
   - Impact on `/help` display

2. **Add troubleshooting section to main SKILL.md**
   - Common problems and solutions
   - Command not appearing
   - Arguments not working
   - Delegation issues

3. **Expand best practices**
   - Keep our delegation philosophy
   - Add technical practices from official:
     - allowed-tools scoping
     - argument validation
     - safe bash commands
     - consistent naming conventions

### Priority 3: Optional Enhancements

1. **Add task-based pattern examples**
   - Review pattern
   - Testing pattern
   - Documentation pattern
   - Workflow pattern
   - Show how these work with delegation

2. **Add validation guidance**
   - When to validate in command vs agent
   - Basic argument checking
   - Error message best practices
   - Using AskUserQuestion for clarification

3. **Expand examples**
   - Show more argument patterns
   - File reference examples
   - Validation examples
   - Multi-step workflow examples

---

## What NOT to Add (Plugin-Specific)

Excluded from comparison (official lines 527-829):

1. **CLAUDE_PLUGIN_ROOT variable** - Plugin environment variable
2. **Plugin command organization** - Plugin-specific namespacing
3. **Plugin command patterns** - Configuration-based, template-based, multi-script
4. **Integration with plugin components** - Agents, skills, hooks coordination
5. **Plugin resource validation** - Plugin-specific resource checks

**Why excluded**: These are plugin development features not applicable to general command authoring.

---

## Philosophy Synthesis

### Official Approach

- **Comprehensive technical reference**
- Covers all features equally
- Enables power users
- Plugin-oriented

### Our Approach

- **Opinionated simplicity guide**
- Emphasizes delegation over implementation
- Keeps commands focused and maintainable
- User command-oriented

### Recommended Synthesis

**Keep our core philosophy**:

- Commands should be simple
- Delegate, don't implement
- Clear focus on agents/skills

**Add their technical depth**:

- Comprehensive frontmatter documentation
- Dynamic features (arguments, files, bash)
- Practical best practices
- Troubleshooting guidance

**Result**: Simple, delegation-focused philosophy with comprehensive technical reference when users need advanced features.

---

## Implementation Checklist

### Completed ✅

- ✅ Basic "Common Mistakes to Avoid" section exists (lines 167-176 in SKILL.md)
- ✅ "Tips for Success" section exists (lines 179-188 in SKILL.md)
- ✅ "Quick Start Checklist" section exists (lines 204-216 in SKILL.md)

### Not Yet Implemented ⬜

#### Priority 1: Critical Additions

- ⬜ Add "Instructions FOR Claude" framing to main SKILL.md
  - Explain commands are directives to Claude, not messages to users
  - Show correct vs incorrect examples (✅/❌ format)
  - Emphasize in philosophy section

- ⬜ Create references/frontmatter-fields.md
  - Document all official fields: description, allowed-tools, model, argument-hint, disable-model-invocation
  - Purpose, type, default, examples for each field
  - Best practices per field

- ⬜ Create references/dynamic-features.md
  - Arguments: $ARGUMENTS, $1-$9, when to use each
  - File references: @ syntax, patterns, best practices
  - Bash execution: !` syntax, use cases, security concerns

#### Priority 2: Enhanced Coverage

- ⬜ Create references/command-organization.md
  - Flat vs namespaced structures
  - When to use each
  - Migration guidance
  - Impact on `/help` display

- ⬜ Expand troubleshooting section
  - Currently minimal (only in Common Mistakes)
  - Add: Command not appearing, arguments not working, delegation issues
  - Add: File references not working, bash execution problems

- ⬜ Expand best practices with official's technical details
  - allowed-tools scoping (Bash(git:_) not Bash(_))
  - Argument validation patterns
  - Safe bash commands
  - Consistent naming conventions

- ⬜ Update skill description with additional triggers
  - "define command arguments"
  - "use command frontmatter"
  - "handle command arguments"
  - "file references in commands"

#### Priority 3: Optional Enhancements

- ⬜ Add task-based pattern examples
  - Review pattern, Testing pattern, Documentation pattern, Workflow pattern
  - Show how these work with our delegation philosophy

- ⬜ Add validation guidance
  - When to validate in command vs agent
  - Basic argument checking
  - Error message best practices

- ⬜ Test skill discoverability with new feature queries

---

## Current State Assessment

### Strengths We Maintain

**Philosophical clarity:**

- Strong emphasis on delegation over implementation
- Clear "Commands Should Be Simple" philosophy
- Good decision guidance (commands vs skills)
- Focus on maintainability and single responsibility

**Structural advantages:**

- Reference files for design patterns, creation process, examples
- Progressive disclosure with command-design-patterns.md, command-creation-process.md, command-examples.md
- Quick Start Checklist for practical guidance
- Basic Common Mistakes and Tips sections

**Our unique contributions:**

- Four design pattern taxonomy with selection criteria
- Structured 7-step creation workflow
- Strong emphasis on delegation documentation
- Concrete examples with "Why it's good" analysis

### Gaps Identified from Official command-development

**Missing critical features:**

- "Instructions FOR Claude" framing (commands are directives TO Claude, not messages TO users)
- Comprehensive frontmatter field documentation (allowed-tools, model, argument-hint, disable-model-invocation)
- Dynamic features documentation (arguments, file references, bash execution)
- Command organization patterns (flat vs namespaced)

**Incomplete coverage:**

- Minimal troubleshooting (only Common Mistakes section)
- Limited technical best practices
- No validation patterns
- No task-based pattern examples (review, testing, documentation, workflow)

**Line count:**

- Official: ~834 lines (excluding plugin-specific ~300 lines = ~534 lines relevant)
- Ours: 226 lines in SKILL.md + 346 lines in references = 572 lines total
- We're comparable in size but cover different ground

### Recommended Path Forward

**Phase 1: Critical foundations (aligns with Priority 1)**

1. Resolve naming convention (Issue 81) before major changes
2. Add "Instructions FOR Claude" framing to philosophy section
3. Create references/frontmatter-fields.md for comprehensive field documentation
4. Create references/dynamic-features.md for arguments, file refs, bash execution

**Phase 2: Enhanced coverage (aligns with Priority 2)**

1. Create references/command-organization.md for flat vs namespaced structures
2. Expand troubleshooting into dedicated section or reference file
3. Enhance best practices with official's technical details
4. Update skill description with additional triggers

**Phase 3: Optional enhancements (aligns with Priority 3)**

1. Add task-based pattern examples (review, testing, documentation, workflow)
2. Document validation patterns
3. Test skill discoverability with feature-specific queries

### Implementation Strategy

**Option A: Incremental** - Add reference files one at a time, test discoverability between changes

**Option B: Comprehensive** - Implement all Priority 1 improvements together, ensuring consistency

**Recommendation:** Option A (incremental) allows for:

- Testing each addition's impact on discoverability
- User feedback between changes
- Reduced risk of disrupting existing workflows
- Flexibility to pause if naming convention changes (Issue 81)

---

## Conclusion

The official skill is a comprehensive technical reference covering all command features. Our skill is an opinionated guide emphasizing simplicity and delegation.

**Current reality**: We have good philosophical foundations and some basic improvements (Common Mistakes, Tips, Checklist), but lack comprehensive technical documentation for dynamic features, frontmatter fields, and organization patterns.

**Best path forward**: Enhance our skill with the official's technical depth while maintaining our philosophical focus on simplicity and delegation.

**Key additions needed**:

1. "Instructions FOR Claude" framing (critical)
2. Frontmatter field reference (essential)
3. Dynamic features reference (essential)
4. Organization patterns (helpful)
5. Enhanced troubleshooting (helpful)

**Result**: A skill that guides users toward simple, maintainable commands while providing comprehensive technical documentation when needed. Our delegation philosophy remains central, but users gain access to advanced features when their use cases require them.
