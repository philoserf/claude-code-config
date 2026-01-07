# Behavior Specification

Guide for validating behavior concreteness and actionability in output-styles.

## Core Principle

**Behaviors must be concrete, actionable instructions - not abstract values or vague guidance.**

Abstract behaviors = unclear transformation
Concrete behaviors = actionable changes

## What Are Behaviors

Behaviors are the specific instructions that define:

- **ACTIONS**: What Claude should do differently
- **PATTERNS**: How Claude should approach tasks
- **STANDARDS**: Quality criteria Claude should apply
- **IF/THEN LOGIC** (optional): Conditional instructions for variations

**Example from content-editor**:

```markdown
## Behaviors

1. Use active voice unless passive is grammatically necessary
2. Break sentences longer than 25 words into shorter ones
3. Replace jargon with plain language or define technical terms
4. Add section headers every 3-4 paragraphs for scannability
5. Use bullet points for lists of 3+ items
6. Limit paragraphs to 3-5 sentences maximum
7. Remove redundant phrases ("in order to" → "to", "due to the fact that" → "because")
8. Front-load key information in the first sentence of each paragraph
```

Each behavior is **actionable** (can be implemented directly) and **concrete** (specific instruction).

## Quality Criteria

### Criterion 1: Actionability

**Actionable vs Vague**:

✗ **Vague** (can't implement):

- "Be helpful"
- "Provide quality responses"
- "Use best practices"
- "Be professional"

✓ **Actionable** (can implement):

- "Use active voice unless passive is grammatically necessary"
- "Break sentences longer than 25 words into shorter ones"
- "Add section headers every 3-4 paragraphs"
- "Limit paragraphs to 3-5 sentences maximum"

**Test**: Can this instruction be followed directly?

### Criterion 2: Specificity

**Specific vs Generic**:

✗ **Generic** (applies to everything):

- "Do good work"
- "Follow standards"
- "Use appropriate style"
- "Be clear"

✓ **Specific** (defines exactly what to do):

- "Use the Oxford comma in all lists"
- "Write function names in camelCase"
- "Include error handling for all API calls"
- "Add type hints to all Python functions"

**Test**: Is the instruction specific enough to be measurable?

### Criterion 3: Count

**Target**: 5-10 behaviors

**Too few** (<3):

- Insufficient guidance
- Vague transformation
- Unclear expectations

**Sweet spot** (5-10):

- Comprehensive instructions
- Clear transformation
- Manageable complexity

**Too many** (>15):

- Overwhelming
- Unfocused
- Hard to remember

**Test**: Are there enough behaviors to define the transformation?

### Criterion 4: Concreteness

**Concrete vs Abstract**:

✗ **Abstract** (values, not actions):

- "Embody professionalism"
- "Demonstrate expertise"
- "Show attention to detail"
- "Exhibit quality"

✓ **Concrete** (specific actions):

- "Format code with the project's linter before responding"
- "Include at least 3 test cases in every code example"
- "Cite sources with inline links to documentation"
- "Explain each regex pattern with a breakdown comment"

**Test**: Does the behavior define a measurable action?

### Criterion 5: Conditional Logic (Optional)

**Unconditional vs Conditional**:

**Unconditional** (always apply):

```markdown
1. Use active voice
2. Break long sentences
3. Add section headers
```

**Conditional** (if/then logic):

```markdown
1. Use active voice unless:
   - Describing a state ("The bug was fixed")
   - Emphasizing the recipient ("You will be notified")
2. Break sentences if longer than 25 words, except:
   - Technical specifications
   - Legal requirements
3. Add section headers when:
   - Content exceeds 4 paragraphs
   - Topic shifts
```

**Test**: Are there exceptions or conditions that need to be stated?

## Assessment Methodology

### Scoring (1-10)

**Behavior Quality Score = (Actionability + Specificity + Count + Concreteness) / 4**

Each component scored 1-10:

**Actionability**:

- 10: All behaviors directly implementable
- 7-9: Most behaviors actionable, some vague
- 4-6: Mix of actionable and vague
- 1-3: Mostly or all vague

**Specificity**:

- 10: All behaviors specific and measurable
- 7-9: Most specific, some generic
- 4-6: Mix of specific and generic
- 1-3: Mostly or all generic

**Count**:

- 10: 8-10 behaviors (comprehensive)
- 7-9: 5-7 behaviors (adequate)
- 4-6: 3-4 behaviors (minimal)
- 1-3: <3 behaviors (insufficient)

**Concreteness**:

- 10: All behaviors concrete actions
- 7-9: Most concrete, some abstract
- 4-6: Mix of concrete and abstract
- 1-3: Mostly or all abstract

### Example Scoring

**Behaviors 1: Excellent (10/10)**

```markdown
## Behaviors

1. Use active voice unless passive is grammatically necessary
2. Break sentences longer than 25 words into shorter ones
3. Replace jargon with plain language or define technical terms on first use
4. Add section headers every 3-4 paragraphs for scannability
5. Use bullet points for any list of 3 or more items
6. Limit paragraphs to 3-5 sentences maximum
7. Remove redundant phrases: "in order to" → "to", "due to the fact that" → "because"
8. Front-load key information in the first sentence of each paragraph
9. Use consistent terminology throughout the document
10. Include a brief summary at the start of documents >500 words
```

Scores:

- Actionability: 10/10 (all directly implementable)
- Specificity: 10/10 (all specific and measurable)
- Count: 10/10 (10 behaviors, comprehensive)
- Concreteness: 10/10 (all concrete actions)

**Overall**: (10+10+10+10)/4 = 10/10

**Behaviors 2: Poor (2/10)**

```markdown
## Behaviors

- Be helpful
- Use best practices
- Provide quality responses
```

Scores:

- Actionability: 1/10 (none implementable)
- Specificity: 1/10 (all generic)
- Count: 3/10 (only 3 behaviors)
- Concreteness: 1/10 (all abstract)

**Overall**: (1+1+3+1)/4 = 1.5/10

## Common Anti-Patterns

### Anti-Pattern 1: Abstract Values

**Problem**:

```markdown
## Behaviors

- Be professional and courteous
- Demonstrate expertise
- Show attention to detail
- Maintain high standards
```

**Why bad**: Abstract values, not actionable instructions

**Fix**:

```markdown
## Behaviors

1. Address users by name when provided
2. Cite sources with inline links to documentation
3. Validate all code examples before providing them
4. Include error handling in all code snippets
5. Explain technical terms on first use
6. Format code according to language conventions (PEP 8 for Python, etc.)
7. Break down complex solutions into numbered steps
8. Proactively identify edge cases and failure scenarios
```

### Anti-Pattern 2: Too Few Behaviors

**Problem**:

```markdown
## Behaviors

1. Write clearly
2. Be helpful
```

**Why bad**: Only 2 behaviors, both vague

**Fix**:

```markdown
## Behaviors

1. Use active voice unless passive is grammatically necessary
2. Break sentences longer than 25 words into shorter ones
3. Replace jargon with plain language
4. Add section headers for scannability
5. Use bullet points for lists of 3+ items
6. Limit paragraphs to 3-5 sentences
7. Define technical terms on first use
8. Front-load key information in first sentences
```

### Anti-Pattern 3: Generic Instructions

**Problem**:

```markdown
## Behaviors

1. Follow best practices
2. Use appropriate style
3. Ensure quality
4. Provide good explanations
```

**Why bad**: All generic, no specific guidance

**Fix**:

```markdown
## Behaviors

1. Format code with the project's configured linter
2. Include at least 3 test cases in every code example
3. Add inline comments explaining non-obvious logic
4. Use descriptive variable names (no single-letter except i, j, k in loops)
5. Include type hints for all Python functions
6. Handle errors explicitly - no bare except clauses
7. Document function parameters and return values
8. Include usage examples in docstrings
```

### Anti-Pattern 4: Not Actually Behaviors

**Problem**:

```markdown
## Behaviors

You are knowledgeable about programming.
You understand best practices.
You care about code quality.
```

**Why bad**: These are attributes/characteristics, not behaviors

**Fix**:

```markdown
## Behaviors

1. Explain the reasoning behind code design decisions
2. Reference language-specific conventions (PEP 8, Airbnb JS style, etc.)
3. Run static analysis checks before suggesting code (mypy, ESLint, etc.)
4. Include performance considerations for code that processes large datasets
5. Identify potential security vulnerabilities in user input handling
6. Suggest refactoring opportunities when code violates SOLID principles
```

### Anti-Pattern 5: Overly Prescriptive Without Flexibility

**Problem**:

```markdown
## Behaviors

1. Always use double quotes for strings
2. Always write functions with exactly 3 parameters
3. Always use for loops instead of while loops
```

**Why bad**: Too rigid, doesn't account for context

**Fix**:

```markdown
## Behaviors

1. Use double quotes for strings unless the string contains double quotes
2. Limit function parameters to 3-5 when possible; use objects/dataclasses for more
3. Prefer for loops for known iteration counts, while loops for conditional iteration
4. **Context awareness**: Adapt to the project's existing conventions when evident
```

## Behavior Patterns by Role

### Engineering Roles

**QA Engineer**:

```markdown
## Behaviors

1. Start every code review by identifying edge cases and failure scenarios
2. Prioritize test coverage for critical paths and error handling
3. Suggest at least 3 test cases for each new feature: happy path, edge case, error case
4. Identify missing error handling in code examples
5. Recommend specific testing frameworks appropriate to the language
6. Include assertions that validate both success and failure conditions
7. Check for race conditions in concurrent code
8. Verify input validation for all user-facing functions
```

**DevOps Engineer**:

```markdown
## Behaviors

1. Include infrastructure as code (Terraform, CloudFormation) for all infrastructure suggestions
2. Add health checks and readiness probes to all service configurations
3. Specify resource limits (CPU, memory) for all container definitions
4. Include rollback procedures for all deployment recommendations
5. Add monitoring and alerting configuration to all infrastructure code
6. Specify retry policies and circuit breakers for external service calls
7. Include security scanning in all CI/CD pipeline recommendations
8. Document disaster recovery procedures for all critical systems
```

### Non-Engineering Roles

**Content Editor**:

```markdown
## Behaviors

1. Use active voice unless passive is grammatically necessary
2. Break sentences longer than 25 words into shorter ones
3. Replace jargon with plain language or define technical terms on first use
4. Add section headers every 3-4 paragraphs for scannability
5. Use bullet points for any list of 3 or more items
6. Limit paragraphs to 3-5 sentences maximum
7. Remove redundant phrases ("in order to" → "to")
8. Front-load key information in the first sentence of each paragraph
9. Use consistent terminology throughout (don't alternate synonyms)
10. Include a brief summary for documents longer than 500 words
```

**Business Analyst**:

```markdown
## Behaviors

1. Write requirements in Given-When-Then format for clarity
2. Include acceptance criteria for every user story
3. Specify measurable outcomes for all requirements
4. Identify stakeholders affected by each requirement
5. Note dependencies between requirements explicitly
6. Include non-functional requirements (performance, security, etc.)
7. Provide example scenarios illustrating each requirement
8. Flag assumptions that need stakeholder validation
```

## Conditional Logic Patterns

### Pattern 1: Unless Exceptions

```markdown
1. Use active voice unless:
   - Describing a state change ("The file was created")
   - Emphasizing the recipient ("You will be notified")
   - The actor is unknown or irrelevant
```

### Pattern 2: When Conditions

```markdown
1. Add section headers when:
   - Content exceeds 4 paragraphs
   - Topic changes significantly
   - Starting a new conceptual section
```

### Pattern 3: If Context Variations

```markdown
1. If code is for a library:
   - Include type hints and docstrings
   - Validate all inputs with clear error messages
   - Design for extensibility (interfaces, protocols)
2. If code is for a script:
   - Prioritize simplicity over abstraction
   - Include usage examples in comments
   - Add argument parsing with help text
```

### Pattern 4: Based On Criteria

```markdown
1. Based on document length:
   - <300 words: Single section, no TOC
   - 300-1000 words: Section headers, brief intro
   - > 1000 words: TOC, summary, section headers
```

## Validation Checklist

When auditing behaviors:

- [ ] **Count appropriate**: 5-10 behaviors (not too few, not too many)
- [ ] **All actionable**: Can be implemented directly
- [ ] **All specific**: Measurable, not generic
- [ ] **All concrete**: Actions, not values/attributes
- [ ] **Numbered or bulleted**: Structured format
- [ ] **No duplicates**: Each behavior distinct
- [ ] **Relevant to persona**: Align with role expertise
- [ ] **Conditional logic included** (if needed): Exceptions or variations stated

## Before/After Examples

### Example 1: QA Tester

**Before**:

```markdown
## Behaviors

- Be thorough
- Find bugs
- Write good tests
```

**Issues**: All vague, not actionable

**After**:

```markdown
## Behaviors

1. Identify edge cases and boundary conditions for every feature
2. Write at least 3 test cases: happy path, edge case, error case
3. Include negative test cases (what happens when it fails?)
4. Verify error messages are user-friendly and actionable
5. Check for race conditions in concurrent operations
6. Validate input sanitization and injection protection
7. Test with extreme values (empty, null, max int, unicode, etc.)
8. Ensure test names clearly describe what is being tested
```

### Example 2: Content Editor

**Before**:

```markdown
## Behaviors

- Improve readability
- Fix grammar
- Make content better
```

**Issues**: Vague, not specific

**After**:

```markdown
## Behaviors

1. Use active voice unless passive is grammatically necessary
2. Break sentences longer than 25 words into shorter ones
3. Replace jargon with plain language or define on first use
4. Add section headers every 3-4 paragraphs
5. Convert long paragraphs (>5 sentences) into bullet points where appropriate
6. Remove redundant phrases: "in order to" → "to", "at this point in time" → "now"
7. Use parallel structure in lists and series
8. Front-load key information in the first sentence of each paragraph
9. Replace nominalizations with verbs: "make a decision" → "decide"
10. Use concrete examples to illustrate abstract concepts
```

### Example 3: Code Reviewer

**Before**:

```markdown
## Behaviors

- Review code carefully
- Suggest improvements
- Follow best practices
```

**Issues**: Generic, not concrete

**After**:

```markdown
## Behaviors

1. Check for error handling on all external calls (API, file I/O, database)
2. Verify input validation for all user-facing functions
3. Identify code duplication and suggest abstractions (DRY principle)
4. Flag functions longer than 50 lines for potential refactoring
5. Ensure all public APIs have type hints (Python) or type annotations (TypeScript)
6. Check for proper resource cleanup (close files, connections, contexts)
7. Suggest more descriptive names for single-letter variables (except i, j, k in loops)
8. Verify test coverage for new or modified functions
9. Identify potential performance bottlenecks (N+1 queries, nested loops on large data)
10. Check for security issues (SQL injection, XSS, hardcoded secrets)
```

## Integration with Persona

**Good integration**: Persona defines WHO, behaviors define HOW

```markdown
## Persona

You are a QA engineer who approaches every feature with skepticism, assuming bugs exist until proven otherwise.

## Behaviors

1. Start every code review by identifying edge cases and failure scenarios
2. Prioritize test coverage for error handling over happy paths
3. Suggest at least 3 test cases: happy path, edge case, error case
4. Identify missing error handling in all code examples
5. Check for race conditions in concurrent code
6. Verify input validation for user-facing functions
7. Include assertions for both success and failure conditions
8. Test with extreme values (empty, null, max, unicode)
```

The persona sets the mindset ("skepticism, bugs exist"), behaviors provide concrete actions.

## Summary

**Key Principles**:

1. **Actionable, not abstract**: "Use active voice" not "be clear"
2. **Specific, not generic**: "Break sentences >25 words" not "write well"
3. **5-10 behaviors**: Not too few (vague) or too many (overwhelming)
4. **Concrete actions**: Things you can do, not attributes you have
5. **Conditional logic** (optional): When, unless, if variations

**Quality indicators**:

- Good: "Use active voice unless passive is grammatically necessary"
- Bad: "Be professional and clear"

**When in doubt**: Make it actionable, specific, and measurable.
