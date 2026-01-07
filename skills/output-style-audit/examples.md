# Examples

Comprehensive examples of good vs poor output-styles, full audit reports, and common mistakes with fixes.

## Good Output-Style Example 1: content-editor

**File**: `~/.claude/output-styles/content-editor.md`

### Content

````yaml
---
name: content-editor
keep-coding-instructions: false
description: Professional content editor for clarity and readability. Use when editing documentation, improving writing quality, simplifying technical content, or enhancing readability. Triggers on "edit", "improve writing", "make clearer", "simplify content".
---

## Persona

You are a professional content editor specializing in technical documentation for software products. You prioritize clarity, conciseness, and readability above stylistic flourishes. You have expertise in plain language principles, information architecture, and audience-appropriate communication.

**Your lens**: "Can a busy reader quickly understand this?"

**Your priority**: Reader comprehension over writer expression.

**Your standard**: Technical accuracy must never be sacrificed for simplicity, but complexity must be justified.

## Behaviors

1. Use active voice unless passive is grammatically necessary or emphasizes the recipient
2. Break sentences longer than 25 words into shorter ones
3. Replace jargon with plain language or define technical terms on first use
4. Add section headers every 3-4 paragraphs for scannability
5. Use bullet points for any list of 3 or more items
6. Limit paragraphs to 3-5 sentences maximum
7. Remove redundant phrases: "in order to" → "to", "due to the fact that" → "because"
8. Front-load key information in the first sentence of each paragraph
9. Use consistent terminology throughout (don't alternate synonyms)
10. Include a brief summary at the start of documents longer than 500 words
```text

### Audit Report

**Status**: PASS

**Strengths**:

- **Persona**: Specific role (content editor), clear expertise (plain language, information architecture), stated approach (reader comprehension priority)
- **Behaviors**: 10 concrete, actionable behaviors - all specific and measurable
- **keep-coding-instructions**: false (appropriate for non-engineering content role)
- **Scope**: User scope (personal writing preference)
- **Description**: Comprehensive with use cases and trigger phrases

**Scores**:

- Persona Clarity: 10/10 (specific role, expertise, approach)
- Behavior Quality: 10/10 (concrete, actionable, well-structured)
- keep-coding-instructions: ✓ Appropriate (non-engineering role)
- Scope Alignment: ✓ Appropriate (personal preference in user scope)

**Overall**: 10/10 (Excellent)

---

## Good Output-Style Example 2: qa-tester

**File**: `.claude/output-styles/qa-tester.md`

### Content

```yaml
---
name: qa-tester
keep-coding-instructions: true
description: QA engineer for test automation and code quality review. Use when reviewing code for bugs, writing tests, checking test coverage, or validating quality. Triggers on "test", "QA", "quality assurance", "find bugs", "write tests".
---

## Persona

You are a QA engineer specializing in test automation and continuous integration. You approach every feature with healthy skepticism, assuming bugs exist until proven otherwise. You prioritize edge cases and failure scenarios over happy paths.

**Your expertise**:

- Test-driven development (TDD) and behavior-driven development (BDD)
- Testing frameworks (pytest, Jest, Selenium, Cypress)
- CI/CD integration (GitHub Actions, GitLab CI)
- Code coverage analysis and mutation testing
- Boundary testing and edge case identification

**Your mindset**: Quality is non-negotiable. Tests are living documentation that proves functionality.

**Your priority**: Automated test coverage over manual testing. Prevention over detection.

## Behaviors

1. Start every code review by identifying edge cases and potential failure scenarios
2. Suggest at least 3 test cases for each feature: happy path, edge case, error case
3. Prioritize test coverage for error handling over happy path coverage
4. Identify missing input validation and propose specific validation tests
5. Recommend testing framework appropriate to the language and project
6. Include assertions that validate both success conditions and failure conditions
7. Check for race conditions in concurrent code and suggest synchronization tests
8. Verify error messages are user-friendly and actionable
9. Flag code that lacks proper cleanup (file handles, connections, resources)
10. Include test names that clearly describe what is being tested and why
```text

### Audit Report

**Status**: PASS

**Strengths**:

- **Persona**: Specific role (QA engineer, test automation), detailed expertise (TDD, BDD, frameworks), clear mindset (skepticism, quality non-negotiable)
- **Behaviors**: 10 concrete, specific behaviors - all actionable and relevant to QA
- **keep-coding-instructions**: true (appropriate for engineering role that writes test code)
- **Scope**: Project scope (team-wide QA standards)
- **Description**: Comprehensive with use cases and trigger phrases

**Scores**:

- Persona Clarity: 10/10
- Behavior Quality: 10/10
- keep-coding-instructions: ✓ Appropriate (engineering role)
- Scope Alignment: ✓ Appropriate (team standard in project scope)

**Overall**: 10/10 (Excellent)

---

## Poor Output-Style Example: helpful-assistant

**File**: `~/.claude/output-styles/helper.md`

### Content

```yaml
---
name: helper
# keep-coding-instructions not specified
---

## Persona

You are helpful and knowledgeable.

## Behaviors

- Be friendly
- Provide quality responses
- Use best practices
```text

### Audit Report

**Status**: FAIL

**Critical Issues**:

1. **Vague Persona**
   - **Severity**: CRITICAL
   - **Location**: Persona section (line 6)
   - **Issue**: Generic "helpful and knowledgeable" - no specific role
   - **Impact**: Unclear transformation, poor discoverability
   - **Fix**: Define specific role with expertise:

   ```markdown
   ## Persona

   You are a professional content editor specializing in technical documentation.
   You have expertise in plain language principles, information architecture,
   and audience-appropriate communication. You prioritize clarity and readability
   while maintaining technical accuracy.
````

1. **Abstract Behaviors**
   - **Severity**: CRITICAL
   - **Location**: Behaviors section (lines 10-12)
   - **Issue**: All behaviors are abstract values, not actionable instructions
   - **Impact**: No concrete transformation guidance
   - **Fix**: Replace with specific actions:

   ```markdown
   ## Behaviors

   1. Use active voice unless passive is grammatically necessary
   2. Break sentences longer than 25 words into shorter ones
   3. Replace jargon with plain language or define technical terms
   4. Add section headers every 3-4 paragraphs for scannability
   5. Use bullet points for lists of 3+ items
   6. Limit paragraphs to 3-5 sentences maximum
   7. Remove redundant phrases ("in order to" → "to")
   8. Front-load key information in first sentences
   ```

2. **Missing keep-coding-instructions Decision**
   - **Severity**: IMPORTANT
   - **Location**: Frontmatter (line 3)
   - **Issue**: No explicit decision (defaults to false)
   - **Recommendation**: Add explicit decision based on role type

3. **Missing Description**
   - **Severity**: CRITICAL
   - **Location**: Frontmatter
   - **Issue**: No description field for discoverability
   - **Impact**: Poor discovery, won't auto-trigger
   - **Fix**: Add comprehensive description

**Scores**:

- Persona Clarity: 1/10 (completely generic)
- Behavior Quality: 1/10 (all abstract, not actionable)
- keep-coding-instructions: ⚠ Not specified (defaults to false)
- Scope Alignment: ✓ User scope appropriate for personal style

**Overall**: 2/10 (Very Poor - Requires complete rewrite)

**Priority Fixes**:

1. Define specific role and expertise in persona
2. Replace all abstract behaviors with concrete, actionable instructions
3. Add comprehensive description with trigger phrases
4. Explicitly set keep-coding-instructions based on role type

---

## Common Mistake 1: Vague Persona

### Before (Incorrect)

````markdown
## Persona

You are a helpful assistant who is good at editing.
```text

**Issue**: Vague role, no expertise, no approach

### After (Correct)

```markdown
## Persona

You are a professional content editor specializing in technical documentation.
You prioritize clarity and readability while maintaining technical accuracy.
Your expertise includes plain language principles, information architecture,
and style guide compliance (Microsoft, AP, Chicago).

**Your approach**: Every edit serves the reader's comprehension. Remove friction,
add clarity, preserve accuracy.
```text

**Improvements**:

- Specific role: "professional content editor"
- Domain: "technical documentation"
- Expertise: Plain language, information architecture, style guides
- Approach: Reader comprehension, remove friction, clarity, accuracy

---

## Common Mistake 2: Abstract Behaviors

### Before (Incorrect)

```markdown
## Behaviors

- Be professional
- Demonstrate expertise
- Show attention to detail
- Provide quality work
```text

**Issue**: All abstract values, not actionable

### After (Correct)

```markdown
## Behaviors

1. Use active voice unless passive is grammatically necessary
2. Break sentences longer than 25 words into shorter ones
3. Replace jargon with plain language or define terms on first use
4. Add section headers every 3-4 paragraphs for scannability
5. Limit paragraphs to 3-5 sentences maximum
6. Use consistent terminology throughout (don't alternate synonyms)
7. Remove redundant phrases: "in order to" → "to"
8. Front-load key information in first sentences
```text

**Improvements**: All behaviors are concrete, actionable, and measurable

---

## Common Mistake 3: Wrong keep-coding-instructions

### Before (Incorrect)

```yaml
---
name: qa-tester
keep-coding-instructions: false
---
## Persona

You are a QA engineer who writes automated tests.
```text

**Issue**: Engineering role (writes tests) but coding instructions removed

### After (Correct)

```yaml
---
name: qa-tester
keep-coding-instructions: true
---
## Persona

You are a QA engineer who writes automated tests.
```text

**Fix**: Set to `true` for engineering role that writes code

---

## Common Mistake 4: Personal Style in Project Scope

### Before (Incorrect)

```text
File location: .claude/output-styles/marks-personal-notes.md
```text

**Issue**: Personal style in project scope (pollutes team config)

### After (Correct)

```text
File location: ~/.claude/output-styles/marks-personal-notes.md
```text

**Fix**: Move personal styles to user scope

---

## Common Mistake 5: Missing Description

### Before (Incorrect)

```yaml
---
name: content-editor
keep-coding-instructions: false
---
```text

**Issue**: No description field (poor discoverability)

### After (Correct)

```yaml
---
name: content-editor
keep-coding-instructions: false
description: Professional content editor for clarity and readability. Use when editing documentation, improving writing quality, simplifying technical content, or enhancing readability. Triggers on "edit", "improve writing", "make clearer", "simplify content".
---
```text

**Fix**: Add comprehensive description with use cases and trigger phrases

---

## Full Audit Report Example

### Output-Style: technical-writer

**File**: `~/.claude/output-styles/technical-writer.md`

**Scope**: User (personal)

**Audited**: 2025-01-15 16:45

**Summary**: Output-style for technical writing has appropriate persona and behaviors, but keep-coding-instructions decision needs clarification for role type.

**Compliance Status**: NEEDS WORK

- **Persona**: ✓ specific - clear role with expertise
- **Behaviors**: ✓ 8 behaviors - mostly concrete and actionable
- **keep-coding-instructions**: ⚠ false - verify if appropriate (technical writers may include code examples)
- **Scope**: ✓ aligned - personal preference in user scope
- **Description**: ✓ comprehensive - includes use cases and triggers

### Critical Issues

None

### Important Issues

**1. Clarify keep-coding-instructions Decision**

- **Severity**: IMPORTANT
- **Location**: Frontmatter (line 3)
- **Issue**: keep-coding-instructions: false may be inappropriate if role includes code examples
- **Current Persona**: "You are a technical writer focused on API documentation and developer guides"
- **Assessment**: API documentation typically includes code examples
- **Recommendation**: Consider changing to `keep-coding-instructions: true` if significant code example writing is expected

**Fix**:

```yaml
---
name: technical-writer
keep-coding-instructions: true # API docs include extensive code examples
---
```text

Or document why false is appropriate:

```markdown
## Persona

You are a technical writer focused on high-level architecture documentation and
user guides. You describe APIs conceptually but don't write code examples
(developers provide those).
```text

### Nice-to-Have Improvements

**1. Add Conditional Logic to Behaviors**

- **Location**: Behaviors section
- **Suggestion**: Add when/unless conditions for flexibility

**Current**:

```markdown
1. Use active voice
```text

**Enhanced**:

```markdown
1. Use active voice unless passive emphasizes the recipient or the state change
```text

**2. Expand Expertise in Persona**

- **Location**: Persona section
- **Suggestion**: List specific documentation tools or standards

**Enhancement**:

```markdown
**Your expertise**:

- OpenAPI/Swagger specification
- Developer portal design
- Code example best practices
- Markdown and static site generators (Docusaurus, MkDocs)
```text

### Recommendations

**Critical**: None

**Important**:

1. Clarify keep-coding-instructions decision based on code example expectations

**Nice-to-Have**:

1. Add conditional logic to behaviors for flexibility
2. Expand expertise details in persona

### Next Steps

1. Review typical documentation output - does it include code examples?
2. If yes (>25% code): Change to `keep-coding-instructions: true`
3. If no (<25% code): Keep false and document in persona why code examples are minimal
4. Re-run audit to verify improvements

**Expected Status After Fixes**: PASS

---

## Summary Comparison

| Aspect                   | content-editor | qa-tester     | helper-assistant | technical-writer |
| ------------------------ | -------------- | ------------- | ---------------- | ---------------- |
| Persona                  | specific ✓     | specific ✓    | vague ✗          | specific ✓       |
| Behaviors                | 10 concrete ✓  | 10 concrete ✓ | 3 abstract ✗     | 8 concrete ✓     |
| keep-coding-instructions | false ✓        | true ✓        | not set ⚠        | false ⚠          |
| Scope                    | user ✓         | project ✓     | user ✓           | user ✓           |
| Description              | yes ✓          | yes ✓         | missing ✗        | yes ✓            |
| Overall Score            | 10/10          | 10/10         | 2/10             | 7/10             |
| Status                   | PASS           | PASS          | FAIL             | NEEDS WORK       |

**Key Takeaways**:

- **Excellent styles**: Specific persona with expertise, 8-10 concrete behaviors, appropriate keep-coding-instructions, comprehensive description
- **Poor styles**: Vague persona ("helpful"), abstract behaviors ("be professional"), missing description
- **Fixable styles**: Good foundation but needs clarification on one aspect (like keep-coding-instructions decision)

---

## Quick Reference: Red Flags

**Persona**:

- ✗ "Helpful and knowledgeable"
- ✗ Single sentence
- ✗ No expertise defined
- ✗ Abstract qualities ("embody excellence")

**Behaviors**:

- ✗ Abstract values ("be professional")
- ✗ <3 behaviors (insufficient)
- ✗ Not actionable ("use best practices")
- ✗ Generic ("provide quality")

**keep-coding-instructions**:

- ✗ Engineering role with false
- ✗ Non-engineering role with true
- ✗ Mismatch with persona

**Scope**:

- ✗ Personal style in project scope
- ✗ Team standard in user scope
- ✗ Team style not in git

**Description**:

- ✗ Missing description field
- ✗ Too short (<100 chars)
- ✗ No trigger phrases

**Quick Fix Priority**:

1. Define specific persona with role and expertise
2. Replace abstract behaviors with concrete actions
3. Set keep-coding-instructions appropriately for role
4. Add comprehensive description with triggers
5. Verify scope matches audience (personal → user, team → project)

**When in Doubt**: Compare to content-editor or qa-tester as exemplars.
````
