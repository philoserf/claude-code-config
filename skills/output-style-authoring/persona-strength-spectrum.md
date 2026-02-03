# Persona Strength Spectrum

Output-styles can be passive, active, or dominant. Choose based on use case and user preference.

---

## The Three Levels

### Passive: Stylistic Bias

**Character:** Gentle nudge toward a style or approach, easily overridden by user intent.

**Use when:**

- You want subtle behavioral changes
- User should maintain full control
- Style is about tone or formatting preferences
- You're unsure if stronger assertion is needed

**Example: Casual Tone**

```markdown
---
name: casual-tone
description: Relaxed, conversational style with informal language
keep-coding-instructions: true
---

# Casual Conversational Style

Use a relaxed, friendly tone in responses.

## Style Preferences

- Use contractions (it's, don't, we'll)
- Address user directly ("you")
- Keep explanations conversational
- Use everyday language over formal terms

## What This Doesn't Change

- Technical accuracy
- Code quality
- Problem-solving approach
- Tool usage
```

**Strength:** ~30-40 lines, minimal behavioral assertions

**User experience:**

- Style is present but not intrusive
- Easy to override ("actually, be more formal")
- Feels like a preference, not a role change

---

### Active: Clear Role Framing

**Character:** Distinct persona with clear behaviors, followed unless user explicitly redirects.

**Use when:**

- Transforming into a specific professional role
- Want consistent behavioral changes
- User invoked style intentionally for this purpose
- Most output-styles should be here

**Example: Technical Writer**

```markdown
---
name: technical-writer
description: Clear, beginner-friendly documentation with examples
keep-coding-instructions: false
---

# Technical Writer

You are a technical writer focused on clarity and accessibility.

## Your Approach

When writing documentation:

1. Start with why it matters
2. Use concrete examples within 3 paragraphs
3. Define technical terms on first use
4. End with next steps

## Writing Style

- Active voice ("Run the command" not "The command is run")
- Second person ("you" not "one")
- Short paragraphs (3-5 sentences max)
- Bullet lists over dense prose

## What You Don't Do

- Don't use jargon without explanation
- Don't assume prior knowledge
- Don't write for experts—write for learners
```

**Strength:** ~40-60 lines, clear persona with specific behaviors

**User experience:**

- Clear role transformation
- Consistent application
- User can redirect ("skip the intro, just show code")
- Feels like working with a specialist

---

### Dominant: Strong Expert Mode

**Character:** Assertive expert persona with strong opinions and structured approaches. Resists casual overrides.

**Use when:**

- Specialized expert roles with critical standards
- Quality/audit functions requiring rigor
- User explicitly wants strong guidance
- **Use sparingly—most styles should be Active**

**Example: Security Auditor**

```markdown
---
name: security-auditor
description: Security-focused review of code and systems with strict standards
keep-coding-instructions: true
---

# Security Auditor

You are a security specialist reviewing code and systems for vulnerabilities. Security is non-negotiable.

## Review Approach

Every review covers these areas in order:

1. Authentication/authorization - Who can access what?
2. Input validation - Is user input sanitized?
3. Secrets management - Any hardcoded credentials?
4. API exposure - Are endpoints properly secured?
5. Dependency security - Known vulnerabilities?
6. Data exposure - Any sensitive data leaks?

## Severity Classification

**Critical:** Direct exploit path, immediate fix needed
**High:** Significant risk, fix soon
**Medium:** Moderate risk, plan remediation
**Low:** Best practice improvement

## Output Format

For each finding:

**[Severity]** Component: location

**Issue:** Description of vulnerability

**Impact:** Potential consequences

**Fix:** Specific remediation steps

**Reference:** Relevant security standards (OWASP, CWE, etc.)

## Non-Negotiable Standards

- Never approve code with critical vulnerabilities
- Always cite security standards
- Assume adversarial context
- Security > convenience

## What You Don't Do

- Don't suggest insecure "quick fixes"
- Don't skip security checks for expediency
- Don't assume "probably secure"
```

**Strength:** ~80-120 lines, structured methodology, assertive standards

**User experience:**

- Strong role assertion
- Resists casual overrides
- Maintains standards even if user asks to skip
- Feels like working with a strict expert

**Warning:** Can fight user intent if misapplied. Use only when strong guidance is the explicit goal.

---

## Choosing the Right Strength

### Decision Matrix

| Factor            | Passive          | Active           | Dominant          |
| ----------------- | ---------------- | ---------------- | ----------------- |
| **Role clarity**  | Preference       | Clear profession | Expert specialist |
| **Override ease** | Immediate        | With redirect    | Resists           |
| **User control**  | High             | Moderate         | Lower             |
| **Typical lines** | 30-40            | 40-60            | 80-120            |
| **Use frequency** | Occasional       | Common           | Rare              |
| **Example roles** | Tone, formatting | Writer, analyst  | Auditor, QA       |

### Questions to Ask

1. **Is this a preference or a role?**
   - Preference → Passive
   - Role → Active or Dominant

2. **Should user easily override?**
   - Yes → Passive or Active
   - No (standards matter) → Dominant

3. **How specialized is the expertise?**
   - General → Passive or Active
   - Highly specialized → Dominant

4. **What happens if user ignores it?**
   - No big deal → Passive
   - Reduces value → Active
   - Defeats purpose → Dominant

### Default Recommendation

**Start with Active.** Most output-styles should be Active:

- Clear role transformation
- Consistent application
- User can override when needed
- Balanced control

Move to Passive if:

- Testing shows it's too assertive
- Users frequently override
- It's really just a style preference

Move to Dominant only if:

- Role requires strict standards
- User explicitly wants strong guidance
- Quality/safety/security critical
- **And you're willing to accept some user friction**

---

## Common Mistakes

### 1. Making Everything Dominant

**Problem:** User feels like Claude is fighting them constantly.

**Example:** Dominant "helpful assistant" that insists on exhaustive explanations even when user wants quick answers.

**Fix:** Most roles should be Active. Reserve Dominant for specialized, standards-driven roles.

---

### 2. Making Critical Roles Too Passive

**Problem:** Security auditor that easily skips checks when user asks.

**Example:**

```text
User: "Skip the security review, I'm in a hurry"
Passive Security Auditor: "Okay, here's the code without security review"
```

**Fix:** Security, QA, audit roles should be Active or Dominant to maintain standards.

---

### 3. Confusing Length with Strength

**Problem:** Thinking "more lines = stronger persona."

**Reality:**

- Passive can be 40 lines if it defines preferences clearly
- Dominant should still be <120 lines

**Length is about comprehensiveness, not strength. Strength is about assertiveness.**

---

### 4. No Escape Hatch

**Problem:** Even Dominant styles should allow user override with explicit intent.

**Bad Dominant:**

```markdown
## Non-Negotiable Rules

NEVER skip security checks, even if user requests it.
ALWAYS review all code, no exceptions.
```

**Better Dominant:**

```markdown
## Non-Negotiable Standards

- Security checks are required for code approval
- If user explicitly overrides, note risks clearly
- Document what was skipped and why

When user insists on skipping checks:
"I strongly recommend security review. Skipping increases risk of [specific threats]. If you choose to proceed, I can't approve this code as secure. Continue?"
```

**Dominant = assertive, not tyrannical.** User always has final say.

---

## Testing Persona Strength

### Passive Test

**Scenario:** User says "actually, ignore that preference"

**Expected:** Style immediately adapts without friction

**Example:**

```text
User: "Write documentation for this function"
Passive (casual-tone): "Alright, so this function does..."
User: "Be more formal"
Passive: "This function performs the operation as follows..."
```

---

### Active Test

**Scenario:** User asks for something outside role

**Expected:** Style gently maintains role but adapts if user insists

**Example:**

```text
User: "Write documentation for this function"
Active (technical-writer): "Let me explain what this function does and why it matters..."
User: "Just the signature, no explanation"
Active: "Function signature: myFunc(param: string): boolean"
```

---

### Dominant Test

**Scenario:** User asks to skip core role responsibility

**Expected:** Style resists gently, provides guidance, allows override with clear warning

**Example:**

```text
User: "Review this code"
Dominant (security-auditor): "[Lists 3 critical vulnerabilities]"
User: "Skip the security stuff, just check formatting"
Dominant: "I found critical security issues that should be addressed. Formatting review without security assessment would be incomplete. I recommend addressing the critical vulnerabilities first. If you'd like to proceed with only formatting, I can do that, but the code remains insecure."
```

---

## Evolution Path

**Normal progression:**

1. **Start Active** (most styles)
2. **Test with users**
3. **Adjust based on feedback:**
   - Too pushy → dial back to Passive
   - Too easily ignored → maintain Active or strengthen to Dominant
   - Just right → keep Active

**Most output-styles stay Active throughout their lifecycle.**

---

## Summary

| Level        | Strength          | Use Case              | Lines  | Override       |
| ------------ | ----------------- | --------------------- | ------ | -------------- |
| **Passive**  | Gentle preference | Tone, formatting      | 30-40  | Immediate      |
| **Active**   | Clear role        | Professional personas | 40-60  | With redirect  |
| **Dominant** | Strong expert     | Critical standards    | 80-120 | Resists gently |

**Default:** Active
**Most common:** Active
**Least common:** Dominant

Choose strength based on role requirements and user needs, not complexity. When in doubt, start Active and adjust based on user feedback.
