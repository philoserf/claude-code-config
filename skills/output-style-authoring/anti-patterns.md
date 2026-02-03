# Output-Style Anti-Patterns

Warning signs your output-style is over-built, invasive, or misaligned. Use these as diagnostic checks.

## Critical Smells

### 1. Reads Like a User Checklist

**Smell:** The style contains step-by-step instructions for the _user_ to follow, not behavioral guidance for Claude.

**Example (wrong):**

```markdown
## Your Approach

1. User should clone the repository
2. User should run npm install
3. User should configure .env file
4. User should start the server
```

**Why it's wrong:** Output-styles define WHO Claude is, not task instructions for users.

**Fix:** Either remove it (not persona guidance) or reframe as Claude's behavior:

```markdown
## Your Approach

When helping with setup:
- Explain each step's purpose before showing commands
- Verify prerequisites before suggesting installation
- Catch common errors proactively
```

---

### 2. Removing Mid-Session Would Break Conversation

**Smell:** If you deactivated the output-style halfway through a session, the conversation would become incoherent.

**Test:** Ask yourself: "Could I switch to default Claude mid-conversation without confusing the user?"

**Example (wrong):** Style that establishes complex state, special terminology, or multi-turn protocols.

**Why it's wrong:** Style is too invasive—it's not transforming behavior, it's creating dependencies.

**Fix:** Styles should be **stateless personality overlays**, not session frameworks.

---

### 3. Persona vs Process Blur

**Smell:** The style specifies detailed workflows, execution steps, or algorithmic processes rather than behavioral characteristics.

**Example (wrong):**

```markdown
## Code Review Process

1. Clone the repository
2. Run static analysis tools: eslint, prettier, typescript
3. Check for these 47 specific issues:
   - Missing error handling on line 23
   - Improper null checks...
[continues for 80 lines of process steps]
```

**Why it's wrong:** This is a **process specification**, not a persona. Claude becomes a rigid script executor.

**Fix:** Specify the **approach and mindset**, not the algorithm:

```markdown
## Code Review Approach

Focus on:
- Security vulnerabilities first
- Readability and maintainability
- Common error patterns in this language

Present findings with:
- Severity level (Critical/Important/Optional)
- Specific location
- Explanation of impact
- Suggested fix
```

---

### 4. Over 100 Lines Without Justification

**Smell:** Output-style exceeds 100 lines and you can't justify each section.

**Diagnostic test:** For each section, ask:

- Does this define WHO Claude is? (keep)
- Does this specify HOW to execute tasks? (remove—that's process)
- Could Claude infer this from context? (remove—redundant)
- Is this rarely used? (remove—premature optimization)

**Why it's wrong:** Long styles become maintenance burdens and often contain process specifications disguised as persona.

**Fix:**

- Aim for 40-80 lines for most styles
- Quality/audit roles might justify 80-120 lines
- > 120 lines: almost certainly over-built

---

### 5. Multiple Personas in One File

**Smell:** Style tries to be multiple roles: "You are a teacher AND a code reviewer AND a project manager..."

**Example (wrong):**

```markdown
# Multi-Role Assistant

When teaching, you...
When reviewing code, you...
When managing projects, you...
When analyzing data, you...
```

**Why it's wrong:** Dilutes each persona. Unclear which role dominates. Creates confusion.

**Fix:** Split into separate styles:

- `teacher.md`
- `code-reviewer.md`
- `project-manager.md`
- `data-analyst.md`

---

### 6. Trying to Restrict Tools

**Smell:** Style attempts to prevent Claude from using certain tools.

**Example (wrong):**

```markdown
## Tool Usage

- Never use Write tool
- Never use Bash tool
- Only use Read tool
```

**Why it's wrong:** Output-styles can't enforce tool restrictions. If you need tool restriction, use an Agent or Skill.

**Fix:** Use the right component type:

- Output-style: Transforms behavior, keeps all tools
- Agent: Separate context with tool restrictions
- Skill: Knowledge applied conditionally with tool restrictions

---

### 7. Adjective Overload Without Behavioral Specificity

**Smell:** Lots of adjectives ("helpful," "thorough," "clear") but no concrete behavioral directives.

**Example (wrong):**

```markdown
# Helpful Assistant

You are helpful, thorough, clear, concise, friendly, professional, and detailed.
```

**Why it's wrong:** Adjectives don't change behavior. Claude already tries to be these things. No transformation occurs.

**Fix:** Define **concrete behaviors** that exemplify those qualities:

```markdown
# Technical Writer

You are a technical writer focused on clarity.

When explaining concepts:
- Define technical terms on first use
- Use concrete examples within 3 paragraphs
- Avoid jargon unless explaining it
```

---

### 8. Hypothetical Future Requirements

**Smell:** Adding features "just in case" or "it might be useful someday."

**Example (wrong):**

```markdown
## Advanced Configuration (not currently used)

In case we need to support multiple languages...
In case we need to integrate with external APIs...
```

**Why it's wrong:** Premature optimization. Adds complexity without proven need.

**Fix:** **YAGNI** (You Aren't Gonna Need It). Build only for current, proven needs. Add features when they're actually needed.

---

### 9. Style Fights User Intent

**Smell:** Users frequently override or ignore the style's directives. They say things like "actually, just..." or "ignore that and..."

**Example:** Style insists on formal tone, but user wants casual conversation. Constant friction.

**Why it's wrong:** Style is too dominant. It's enforcing preferences instead of adapting to user intent.

**Fix:** Use [persona-strength-spectrum.md](persona-strength-spectrum.md):

- Passive: Stylistic bias (easily overridden)
- Active: Clear role (followed unless user redirects)
- Dominant: Strong expert mode (only for specialized use)

Most styles should be **Active**, not Dominant.

---

### 10. Duplicate Content from Skills/Agents

**Smell:** Output-style repeats comprehensive knowledge that exists in a skill.

**Example (wrong):** Creating `python-expert` output-style that duplicates content from `python-best-practices` skill.

**Why it's wrong:** Violates "name things once" principle. Creates maintenance burden.

**Fix:**

- Skills: Comprehensive knowledge, auto-triggers conditionally
- Output-styles: Behavior transformation, user-activated
- If knowledge exists in skill, output-style should reference it, not duplicate it

---

## Diagnostic Checklist

Run this checklist on any output-style >60 lines:

- [ ] **One-sentence persona:** Can I describe this in one sentence?
- [ ] **Mid-session removal:** Could I deactivate this mid-conversation without breaking context?
- [ ] **WHO not HOW:** Does this define who Claude is, not how to execute tasks?
- [ ] **Line count:** Is each section above 50 lines justified?
- [ ] **Single persona:** Is this one clear role, not multiple?
- [ ] **No tool restrictions:** Am I trying to restrict tools? (use Agent instead)
- [ ] **Concrete behaviors:** Are directives specific, not just adjectives?
- [ ] **Proven need:** Is every section addressing a real, current need?
- [ ] **User alignment:** Does this enhance user intent or fight it?
- [ ] **No duplication:** Does this duplicate skill/agent content?

**Scoring:**

- 10/10: Excellent, well-scoped style
- 7-9/10: Good, minor refinements possible
- 4-6/10: Needs work, likely over-built
- 0-3/10: Significantly over-built or misaligned

---

## Recovery Strategies

**If you've over-built an output-style:**

1. **Extract to skill:** If it contains comprehensive knowledge → make it a skill
2. **Split personas:** If it has multiple roles → create separate styles
3. **Strip process:** Remove HOW, keep only WHO
4. **Test removal:** Verify mid-session deactivation works
5. **Compress:** Target 40-80 lines for most styles
6. **Focus:** One clear persona, specific behaviors

**Remember:** Output-styles are personality overlays, not instruction manuals. Keep them focused, concise, and aligned with user intent.

---

## Good Examples (for comparison)

**Technical Writer (40 lines):**

- Clear persona: Technical writer
- 4 behavioral directives
- Boundaries defined
- No process specifications

**QA Tester (50 lines):**

- Clear persona: QA specialist
- Testing mindset defined
- Output format specified
- Still focused on approach, not rigid process

**Content Editor (65 lines):**

- Clear persona: Editor
- 4-pass editing approach
- Issue classification
- Boundaries defined

**None exceed 80 lines. None specify rigid processes. All define WHO, not HOW.**

See [minimal-template.md](minimal-template.md) for baseline starter and [complete-examples.md](complete-examples.md) for production examples.
