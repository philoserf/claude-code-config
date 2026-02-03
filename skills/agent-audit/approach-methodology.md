# Approach Methodology

Guide for assessing the completeness and quality of agent approach sections.

## Core Principle

**An approach section must define HOW the agent works, not just WHAT it does.**

Incomplete approach = unclear methodology
Complete approach = clear step-by-step process

## What Is an Approach Section

The approach section is the methodology blueprint that defines:

- **Process**: Step-by-step workflow the agent follows
- **Decisions**: How to handle variations and edge cases
- **Output**: What the agent produces
- **Quality**: Standards and validation criteria
- **Integration**: How approach uses focus area expertise

**Example from code-generator**:

```markdown
## Approach

1. Analyze requirements and constraints
2. Design solution using defensive programming principles
3. Implement with POSIX compliance
4. Add comprehensive error handling
5. Test on multiple platforms
6. Document with inline comments

Output: Production-ready Bash script with full error handling
```

Each step is **actionable** (not vague) and **ordered** (sequential process).

## Quality Criteria

### Criterion 1: Process Definition

**Complete vs Incomplete**:

✗ **Incomplete** (vague):

```markdown
## Approach

Write good code following best practices.
```

✓ **Complete** (step-by-step):

```markdown
## Approach

1. Read and analyze existing codebase
2. Identify patterns and conventions
3. Generate code following project style
4. Validate with linter/formatter
5. Add tests for new functionality
6. Document changes in comments
```

**Test**: Can someone follow these steps to reproduce the agent's work?

### Criterion 2: Decision Frameworks

**Explicit vs Implicit**:

✗ **Implicit** (no guidance):

```markdown
## Approach

Handle different file types appropriately.
```

✓ **Explicit** (if/then logic):

```markdown
## Approach

**File type handling**:

- If `.go` file → Use gofmt, apply Go idioms
- If `.js/.ts` file → Use prettier, apply ESLint rules
- If `.py` file → Use black, apply PEP 8
- If unknown → Skip formatting, report warning
```

**Test**: Does the approach explain how to handle variations?

### Criterion 3: Output Specification

**Vague vs Concrete**:

✗ **Vague** (unclear deliverable):

```markdown
## Approach

Produce good results.
```

✓ **Concrete** (specific output):

```markdown
## Approach

Output: Markdown audit report with:

- Summary (1-2 sentences)
- Compliance status (PASS/FAIL)
- Critical issues (must-fix)
- Important issues (should-fix)
- Recommendations (prioritized list)
```

**Test**: Can you identify the exact deliverable from the approach?

### Criterion 4: Quality Standards

**Implicit vs Explicit**:

✗ **Implicit** (no standards):

```markdown
## Approach

Write code and check it.
```

✓ **Explicit** (validation criteria):

```markdown
## Approach

**Quality validation**:

- All functions have test coverage
- No linter errors or warnings
- Documentation complete for public APIs
- Performance benchmarks pass
- Security scan shows no vulnerabilities
```

**Test**: Are quality standards measurable and verifiable?

### Criterion 5: Integration with Focus Areas

**Disconnected vs Integrated**:

✗ **Disconnected** (doesn't reference expertise):

```markdown
## Focus Areas

- React hooks and state management
- TypeScript type safety
- Testing with Jest

## Approach

1. Write code
2. Test code
3. Document code
```

✓ **Integrated** (uses focus areas):

```markdown
## Focus Areas

- React hooks and state management
- TypeScript type safety
- Testing with Jest

## Approach

1. Design component using React hooks (useState, useEffect)
2. Add TypeScript interfaces for all props and state
3. Write Jest tests with React Testing Library
4. Validate type safety with tsc --noEmit
5. Document component API with JSDoc
```

**Test**: Does the approach reference or use the declared focus areas?

## Completeness Assessment

### Required Components

**Minimum viable approach** (all must be present):

1. **Process**: Step-by-step methodology
2. **Output**: What the agent produces
3. **Quality**: How to validate results

**Enhanced approach** (adds value):

1. **Decisions**: How to handle variations
2. **Integration**: Uses focus area expertise
3. **Examples**: Concrete scenarios

### Component Scoring

**Process (1-10)**:

- 10: Clear numbered steps, logical flow, actionable
- 7-9: Steps present but some vague
- 4-6: High-level process, missing details
- 1-3: No clear process or very vague

**Output (1-10)**:

- 10: Specific deliverable with format/structure
- 7-9: General output described
- 4-6: Vague output mentioned
- 1-3: No output specification

**Quality (1-10)**:

- 10: Explicit validation criteria
- 7-9: Some quality standards mentioned
- 4-6: Implicit quality expectations
- 1-3: No quality standards

**Overall Score**: (Process + Output + Quality) / 3

### Score Interpretation

- **9-10**: Excellent - Complete methodology with all components
- **7-8**: Good - Clear process with minor gaps
- **5-6**: Adequate - Basic approach, needs enhancement
- **3-4**: Poor - Vague or incomplete
- **1-2**: Very Poor - No real methodology

## Common Anti-Patterns

### Anti-Pattern 1: Missing Approach Section

**Problem**: No approach section at all

**Impact**: Users don't know how the agent works

**Fix**: Add complete approach section with process, output, quality

### Anti-Pattern 2: Vague Single-Line Approach

**Problem**:

```markdown
## Approach

Follow best practices to produce quality results.
```

**Why bad**: No actionable steps, vague output, no quality criteria

**Fix**:

```markdown
## Approach

1. Analyze codebase for existing patterns
2. Apply SOLID principles to design
3. Implement with test-driven development
4. Review for security and performance
5. Document with inline comments and README

Output: Production-ready code with full test coverage

**Quality criteria**:

- All tests pass
- No linter errors
- Code review approved
```

### Anti-Pattern 3: Generic Template Approach

**Problem**:

```markdown
## Approach

1. Understand requirements
2. Design solution
3. Implement solution
4. Test solution
5. Deploy solution
```

**Why bad**: Could apply to any task, no specific methodology

**Fix**: Add technology-specific steps:

```markdown
## Approach

1. Parse OpenAPI specification for endpoints
2. Generate FastAPI route handlers with Pydantic models
3. Implement SQLAlchemy ORM queries
4. Add pytest tests with TestClient
5. Validate with mypy type checker

Output: FastAPI application with full type hints and test coverage
```

### Anti-Pattern 4: No Output Specification

**Problem**:

```markdown
## Approach

1. Read files
2. Analyze content
3. Report findings
```

**Why bad**: Unclear what "report findings" means

**Fix**: Specify exact output format:

```markdown
## Approach

1. Read agent configuration files
2. Analyze model selection, tools, focus areas
3. Generate audit report

Output: Markdown report with:

- Summary (1-2 sentences)
- Compliance status (PASS/NEEDS WORK/FAIL)
- Critical issues (must-fix with line numbers)
- Important issues (should-fix)
- Recommendations (prioritized action items)
```

### Anti-Pattern 5: Missing Decision Logic

**Problem**:

```markdown
## Approach

1. Choose appropriate testing strategy
2. Implement tests
3. Validate coverage
```

**Why bad**: Doesn't explain how to "choose appropriate testing strategy"

**Fix**: Add decision framework:

```markdown
## Approach

**Testing strategy selection**:

- If React components → React Testing Library with user events
- If API endpoints → pytest with TestClient
- If utilities → pytest with parametrize
- If integration → pytest with testcontainers

1. Select strategy based on code type
2. Implement tests following strategy
3. Validate coverage >80%
```

## Step-by-Step Methodology Patterns

### Pattern 1: Linear Workflow

**When to use**: Sequential processes with clear order

**Structure**:

```markdown
## Approach

1. {Initial analysis step}
2. {Design/planning step}
3. {Implementation step}
4. {Validation step}
5. {Finalization step}

Output: {Specific deliverable}
```

**Example**:

```markdown
## Approach

1. Read existing Bash scripts in codebase
2. Identify common patterns and conventions
3. Generate new script using defensive programming
4. Validate with shellcheck --shell=bash
5. Test on macOS and Linux

Output: Production-ready Bash script with POSIX compliance
```

### Pattern 2: Iterative Refinement

**When to use**: Processes with feedback loops

**Structure**:

```markdown
## Approach

1. {Initial draft/prototype}
2. {Analysis/review step}
3. {Refinement step}
4. Repeat steps 2-3 until {quality criteria met}
5. {Finalization}

Output: {Specific deliverable}
```

**Example**:

```markdown
## Approach

1. Generate initial component structure
2. Review for TypeScript errors and React best practices
3. Refine based on feedback
4. Repeat steps 2-3 until no linter errors
5. Add comprehensive JSDoc documentation

Output: React component with full TypeScript types and docs
```

### Pattern 3: Conditional Branching

**When to use**: Multiple paths based on input

**Structure**:

```markdown
## Approach

**Path selection**:

- If {condition A} → {approach A}
- If {condition B} → {approach B}
- If {condition C} → {approach C}

Common steps:

1. {Shared step}
2. {Shared step}

Output: {Deliverable varies by path}
```

**Example**:

```markdown
## Approach

**Agent type detection**:

- If read-only analyzer → Recommend Haiku (fast, cheap)
- If code generator → Recommend Sonnet (balanced)
- If complex reasoner → Recommend Opus (highest capability)

Validation steps:

1. Analyze tool permissions (Write/Edit = not Haiku)
2. Count focus areas (>10 complex = consider Opus)
3. Check frequency (high frequency = prefer Haiku if possible)

Output: Model recommendation with cost/capability justification
```

## Output Format Specifications

### Format 1: Markdown Report

**Use for**: Audit results, analysis summaries

**Template**:

```markdown
Output: Markdown report with:

- **Summary**: 1-2 sentence overview
- **Status**: PASS/NEEDS WORK/FAIL
- **Critical Issues**: Must-fix items with line numbers
- **Important Issues**: Should-fix items
- **Recommendations**: Prioritized action items
```

### Format 2: Code Files

**Use for**: Code generation agents

**Template**:

```markdown
Output: {Language} file with:

- File path: {location pattern}
- Structure: {modules/classes/functions}
- Documentation: {comment style}
- Tests: {test file location}
- Validation: {linter/formatter requirements}
```

### Format 3: Structured Data

**Use for**: Data processing agents

**Template**:

```markdown
Output: JSON file with schema:

\`\`\`json
{
"field1": "type and description",
"field2": "type and description",
"results": ["array of items"]
}
\`\`\`

Validation: Passes JSON schema validation
```

## Integration with Focus Areas

### Example 1: Tight Integration

**Focus areas**:

- FastAPI REST APIs with Pydantic models
- SQLAlchemy ORM with async support
- pytest testing with fixtures and mocking

**Approach** (integrated):

```markdown
## Approach

1. Design API endpoints using FastAPI decorators
2. Define Pydantic models for request/response validation
3. Implement SQLAlchemy async models and queries
4. Add pytest fixtures for database setup
5. Write tests using pytest-asyncio and mocking

Output: FastAPI application with full async support and test coverage
```

Each step references a focus area expertise.

### Example 2: Loose Integration

**Focus areas**:

- Defensive programming with strict error handling
- POSIX compliance and cross-platform portability

**Approach** (loosely integrated):

```markdown
## Approach

1. Write script using bash best practices
2. Test on multiple platforms
3. Add error handling

Output: Working Bash script
```

**Problem**: Doesn't explicitly use "defensive programming" or "POSIX compliance"

**Fix**:

```markdown
## Approach

1. Write script with defensive programming (set -euo pipefail, trap handlers)
2. Validate POSIX compliance with shellcheck --shell=sh
3. Test on macOS, Linux, BSD for portability
4. Add strict error handling with meaningful exit codes

Output: Production-ready POSIX-compliant Bash script
```

## Context Economy Considerations

### Keep Approach Sections Concise

**Target**: 50-150 lines for approach section

**Too short** (<30 lines):

- Likely missing components
- Insufficient detail

**Sweet spot** (50-150 lines):

- Complete methodology
- Clear steps
- Reasonable detail

**Too long** (>200 lines):

- Move details to references/
- Keep high-level process in main approach

### Use Progressive Disclosure

**Main SKILL.md**:

```markdown
## Approach

1. Validate model selection (see model-selection.md)
2. Check tool restrictions (see tool-restrictions.md)
3. Assess focus areas (see focus-area-quality.md)
4. Review approach completeness (see approach-methodology.md)
5. Generate audit report

Output: Comprehensive agent audit with prioritized recommendations
```

**References**:

- model-selection.md: 400 lines of decision matrix details
- tool-restrictions.md: 500 lines of security analysis
- focus-area-quality.md: 450 lines of scoring methodology
- approach-methodology.md: 350 lines of this guide

## Validation Checklist

When auditing an approach section:

- [ ] **Process defined**: Step-by-step methodology present
- [ ] **Steps actionable**: Each step is concrete, not vague
- [ ] **Logical order**: Steps flow sequentially
- [ ] **Decision frameworks**: Variation handling explained
- [ ] **Output specified**: Deliverable clearly defined
- [ ] **Quality standards**: Validation criteria present
- [ ] **Focus integration**: Uses declared expertise
- [ ] **Concise**: 50-150 lines or uses references
- [ ] **Examples provided** (optional): Concrete scenarios shown

## Examples by Quality

### Excellent Approach (9-10/10)

```markdown
## Approach

**Audit workflow**:

1. Read agent SKILL.md and extract frontmatter
2. Validate model selection against task complexity
3. Check tool restrictions match usage patterns
4. Assess focus area quality (specificity, count, concreteness)
5. Review approach completeness against this methodology
6. Generate standardized audit report

**Decision logic**:

- If model=opus but task is simple → Flag as cost inefficiency
- If model=haiku but Write/Edit in tools → Flag as capability mismatch
- If focus areas <5 → Flag as insufficient expertise definition
- If focus areas >15 → Flag as unfocused scope

Output: Markdown audit report with:

- Summary (1-2 sentences)
- Compliance status (PASS/NEEDS WORK/FAIL)
- Critical issues (must-fix with line numbers)
- Important issues (should-fix)
- Nice-to-have improvements
- Prioritized recommendations

**Quality validation**:

- All critical issues have specific fixes
- Line numbers provided for file references
- Recommendations prioritized by impact
```

### Good Approach (7-8/10)

```markdown
## Approach

1. Analyze agent configuration
2. Validate model choice
3. Check tool permissions
4. Assess focus areas
5. Generate report

Output: Audit report with findings and recommendations
```

**Missing**: Decision logic, quality validation, specific output format

### Poor Approach (3-4/10)

```markdown
## Approach

Review agent and provide feedback following best practices.
```

**Missing**: All components (process, output, quality, decisions)

## Approach Completeness Assessment

Detailed criteria for evaluating approach section completeness.

### Required Components

1. **Process**: Step-by-step methodology
   - Numbered or bulleted steps
   - Logical flow from start to finish
   - Clear progression
   - Actionable instructions

2. **Decisions**: How to handle variations
   - If/then logic for different scenarios
   - Edge case handling
   - Choice points and decision criteria
   - Adaptability to different inputs

3. **Output**: What the agent produces
   - Explicit statement of deliverable
   - Format specification
   - Quality characteristics
   - Examples if applicable

4. **Quality**: Standards and validation
   - Success criteria
   - Validation methods
   - Quality checks
   - Error handling

### Missing Components Impact

**No process**:

- Unclear how agent works
- User doesn't know what to expect
- Agent behavior unpredictable
- Hard to debug issues

**No decisions**:

- Can't handle variations
- Inflexible approach
- Edge cases fail
- Limited applicability

**No output**:

- Unclear deliverable
- User expectations unset
- Hard to validate success
- Ambiguous completion

**No quality**:

- No validation criteria
- Can't measure success
- Quality unpredictable
- No error detection

### Completeness Scoring

**10/10 - Excellent**:

- All 4 components present
- Detailed, specific, actionable
- Comprehensive decision logic
- Clear quality standards

**7-9/10 - Good**:

- All 4 components present
- Could be more detailed
- Basic decision logic
- Some quality criteria

**4-6/10 - Needs Work**:

- Missing 1-2 components
- Vague or incomplete
- Limited decisions
- Weak quality standards

**1-3/10 - Poor**:

- Missing 3+ components
- Very vague
- No decisions
- No quality criteria

## Summary

**Key Principles**:

1. **Define HOW, not just WHAT**: Step-by-step methodology
2. **Be specific, not vague**: Concrete steps and outputs
3. **Include decisions**: Handle variations explicitly
4. **Specify output**: Exact deliverable format
5. **Set quality standards**: Validation criteria
6. **Integrate focus areas**: Use declared expertise
7. **Stay concise**: 50-150 lines or use references

**Quality indicators**:

- Good: "1. Analyze with tool X, 2. Generate using pattern Y, Output: Format Z"
- Bad: "Do the task well following best practices"

**When in doubt**: Add numbered steps, specify output format, define quality criteria.
