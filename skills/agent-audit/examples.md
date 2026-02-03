# Examples

Comprehensive examples of good vs poor agents, full audit reports, and common mistakes with fixes.

## Good Agent Example 1: evaluator

**File**: `agents/evaluator.md`

### Frontmatter

```yaml
---
name: evaluator
model: sonnet
allowed_tools:
  - Read
  - Grep
  - Glob
  - Bash
---
```

### Focus Areas (12 total)

```markdown
## Focus Areas

- YAML frontmatter validation and syntax checking
- Markdown structure and formatting compliance
- Tool permission analysis and security implications
- Description quality assessment for discoverability
- Progressive disclosure validation (main file + references)
- File organization checking (naming, structure)
- Naming convention enforcement (kebab-case, verb-noun)
- Reference file validation (links, completeness)
- Integration pattern analysis (agents, skills, commands)
- Context economy assessment (file size, conciseness)
- Security implication review (tool restrictions)
- Cross-cutting concern detection (DRY violations)
```

**Analysis**:

- ✓ Count: 12 focus areas (sweet spot: 10-15)
- ✓ Specific: All mention concrete technologies/patterns
- ✓ Concrete: Actionable expertise (YAML validation, not "best practices")
- ✓ Non-overlapping: Each area distinct
- ✓ Technology-specific: References YAML, Markdown, tool names

**Score**: 10/10 (Excellent)

### Approach Section

```markdown
## Approach

1. Read customization file (agent, skill, command, hook, output-style)
2. Validate YAML frontmatter (syntax, required fields)
3. Check markdown structure (headers, formatting)
4. Analyze tool permissions (security implications)
5. Assess description quality (length, keywords, use cases)
6. Verify progressive disclosure (file size, references)
7. Check file organization (naming, location)
8. Generate evaluation report

Output: Markdown evaluation report with:

- Summary (1-2 sentences)
- Compliance status (PASS/NEEDS WORK/FAIL)
- Critical issues (YAML errors, missing required fields)
- Important issues (description quality, structure)
- Nice-to-have improvements (polish, optimization)
- Prioritized recommendations
```

**Analysis**:

- ✓ Process: Clear 8-step methodology
- ✓ Output: Specific deliverable format
- ✓ Quality: Report structure defined
- ✓ Integration: Uses focus area expertise (YAML, markdown, tools)

**Score**: 10/10 (Excellent)

### Model Selection

**Model**: sonnet

**Justification**:

- Complex multi-file analysis required
- Pattern detection and reasoning needed
- Not simple enough for Haiku (needs reasoning)
- Not complex enough for Opus (Sonnet handles well)

**Verdict**: ✓ Appropriate choice

### Tool Restrictions

**Tools**: [Read, Grep, Glob, Bash]

**Pattern**: Read-only analyzer

**Security analysis**:

- ✓ No Write/Edit (doesn't modify files)
- ✓ Bash for safe commands only (ls, wc, grep)
- ✓ No permission amplification (no Task/Skill)
- ✓ Appropriate for evaluation role

**Verdict**: ✓ Secure and appropriate

### Overall Audit

**Status**: PASS

**Summary**: Excellent agent design with comprehensive focus areas, clear methodology, appropriate model, and secure tool restrictions.

**Scores**:

- Model Selection: 10/10
- Tool Restrictions: 10/10
- Focus Areas: 10/10
- Approach: 10/10

**Overall**: 10/10 (Excellent)

---

## Good Agent Example 2: test-runner

**File**: `agents/test-runner.md`

### Frontmatter

```yaml
---
name: test-runner
model: sonnet
allowed_tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - Skill
skills:
  - audit-coordinator
---
```

### Focus Areas (6 total)

```markdown
## Focus Areas

- Sample Query Generation - Creating realistic test queries based on descriptions
- Expected Behavior Validation - Verifying outputs match specifications
- Regression Testing - Ensuring changes don't break existing functionality
- Edge Case Identification - Finding unusual scenarios and boundary conditions
- Integration Testing - Validating customizations work together
- Performance Assessment - Analyzing context usage and efficiency
```

**Analysis**:

- ✓ Count: 6 focus areas (good coverage for testing domain)
- ✓ Specific: Each area clearly defined with concrete purpose
- ✓ Concrete: Actionable testing types (query generation, validation, regression)
- ✓ Comprehensive: Covers functional, integration, and performance testing

**Score**: 9/10 (Excellent focus area coverage)

### Approach Section

```markdown
## Test Framework

### Test Types

- Functional Tests: Verify core functionality works as specified
- Integration Tests: Ensure customizations work together
- Usability Tests: Assess user experience quality

### Test Process

1. Identify customization type (agent/skill/command/hook)
2. Read documentation and configuration
3. Generate test cases based on description
4. Execute tests (read-only or active mode)
5. Compare results to expected behavior
6. Generate structured test report

Output: Test report with pass/fail counts, edge cases, and recommendations
```

**Analysis**:

- ✓ Process: Clear 6-step testing methodology
- ✓ Output: Structured test report format specified
- ✓ Quality: Test types clearly categorized
- ✓ Integration: Comprehensive testing framework

**Score**: 10/10 (Excellent)

### Model Selection

**Model**: sonnet

**Justification**:

- Test generation requires reasoning about expected behavior
- Query synthesis needs creativity and understanding
- Report generation requires structured thinking
- Sonnet provides good balance for testing complexity

**Verdict**: ✓ Appropriate choice

### Tool Restrictions

**Tools**: [Read, Write, Glob, Grep, Bash, Skill]

**Pattern**: Test runner with reporting

**Security analysis**:

- ✓ Read for examining customizations (required)
- ✓ Write for test reports (required for output)
- ✓ Glob/Grep for file discovery (required)
- ✓ Bash for file analysis (read-only commands)
- ✓ Skill for active testing (optional, controlled)
- ✓ All tools justified by testing role

**Verdict**: ✓ Appropriate permissions

### Overall Audit

**Status**: PASS

**Summary**: Excellent agent design with comprehensive focus areas, clear testing methodology, appropriate model selection, and justified tool permissions for test execution and reporting.

**Scores**:

- Model Selection: 10/10
- Tool Restrictions: 10/10
- Focus Areas: 9/10 (comprehensive coverage)
- Approach: 10/10

**Overall**: 9.5/10 (Excellent)

**Recommendation**: Well-structured testing agent. Consider adding performance benchmarking focus area for timing analysis.

---

## Good Agent Example 3: test-runner (Resource Organization)

**File**: `agents/test-runner/test-runner.md`

**Focus**: Resource organization and progressive disclosure

### Structure

```text
test-runner/
├── test-runner.md  (328 lines)
└── references/
    ├── examples.md             (test case examples)
    └── common-failures.md      (failure patterns)
```

### Resource Organization Analysis

**Main file size**: 328 lines

✓ Under 500 line target
✓ Focused on core workflow and methodology
✓ Delegates details to reference files

**References directory**:

✓ Located in `references/` subdirectory (correct for agents)
✓ Contains 2 reference files (optimal count: 2-6)
✓ Flat structure (no nesting)

**Reference section** (from main file):

```markdown
## Reference Files

This agent uses reference materials in the `references/` directory:

- [examples.md](references/examples.md) - Concrete test case examples for different customization types
- [common-failures.md](references/common-failures.md) - Catalog of common failure patterns when testing
```

**Linking quality**:

✓ Clear "Reference Files" section header
✓ Both references linked with descriptions
✓ Descriptive link text explains content
✓ Relative paths work correctly (references/file.md)
✓ No orphaned files

### Resource Organization Scoring

**Evaluation**:

- Main file size: 10/10 (328 lines, well under 500)
- References structure: 10/10 (in references/ subdirectory, flat)
- Reference linking: 10/10 (all linked with clear descriptions)
- Navigation quality: 10/10 (clear section, descriptive links)
- Flat structure: 10/10 (no nesting)

**Resource Organization Score**: 10/10 (Excellent)

**Assessment**: Perfect example of progressive disclosure in agents. Main file stays lean and focused while reference files provide detailed examples and troubleshooting guidance when needed.

---

## Poor Agent Example: hypothetical-poor-agent

**File**: `agents/code-helper.md`

### Frontmatter

```yaml
---
name: code-helper
model: opus
# No allowed_tools specified
---
```

### Focus Areas (3 total)

```markdown
## Focus Areas

- Programming best practices
- Code quality standards
- Good design patterns
```

### Approach Section

```markdown
## Approach

Write good code following best practices and industry standards.
```

### Audit Report

**Status**: FAIL

**Critical Issues**:

1. **Missing Tool Restrictions**
   - **Severity**: CRITICAL
   - **Location**: Frontmatter (line 3)
   - **Issue**: No `allowed_tools` field specified
   - **Impact**: Agent has unrestricted access (security risk)
   - **Fix**: Add `allowed_tools: [Read, Write, Edit, Grep, Glob, Bash]`

2. **Inappropriate Model Selection**
   - **Severity**: CRITICAL
   - **Location**: Frontmatter (line 2)
   - **Issue**: Using Opus for generic code task
   - **Impact**: 5-10x cost with no justification
   - **Fix**: Change to `model: sonnet` (default for code generation)

3. **Generic Focus Areas**
   - **Severity**: CRITICAL
   - **Location**: Focus Areas section (lines 8-12)
   - **Issue**: All focus areas vague and generic
   - **Impact**: Unclear expertise, poor discoverability
   - **Fix**: Replace with specific areas:

     ```markdown
     ## Focus Areas

     - Python type hints with mypy validation
     - pytest testing with fixtures and parameterization
     - FastAPI REST APIs with Pydantic models
     - SQLAlchemy ORM with async support
     - Dependency injection with FastAPI dependencies
     - API documentation with OpenAPI/Swagger
     - Error handling with structured exceptions
     - Async/await patterns with asyncio
     ```

4. **Incomplete Approach**
   - **Severity**: CRITICAL
   - **Location**: Approach section (line 16)
   - **Issue**: Vague single-line approach with no methodology
   - **Impact**: Unclear how agent works, no process
   - **Fix**: Add step-by-step process with output format

**Important Issues**:

1. **Insufficient Focus Area Count**
   - **Location**: Focus Areas section
   - **Issue**: Only 3 focus areas (target: 5-15)
   - **Recommendation**: Expand to 8-10 specific areas

2. **Name Too Generic**
   - **Location**: Frontmatter (line 1)
   - **Issue**: "code-helper" doesn't indicate specialization
   - **Recommendation**: Use specific name like "fastapi-generator" or "python-api-builder"

**Scores**:

- Model Selection: 1/10 (Opus unjustified)
- Tool Restrictions: 0/10 (Missing)
- Focus Areas: 1/10 (All generic)
- Approach: 1/10 (No methodology)

**Overall**: 1/10 (Very Poor - Requires complete rewrite)

**Priority Fixes**:

1. Add `allowed_tools` field immediately
2. Change model from opus to sonnet
3. Replace all generic focus areas with specific ones
4. Add complete approach section with steps

---

## Common Mistake 1: Opus Overuse

### Before (Incorrect)

```yaml
---
name: json-validator
model: opus
allowed_tools: [Read]
---
```

**Agent task**: Validate JSON file syntax

**Issue**: Using Opus (expensive) for simple read-only validation

### After (Correct)

```yaml
---
name: json-validator
model: haiku
allowed_tools: [Read]
---
```

**Justification**:

- Simple read-only task (try parse, return yes/no)
- High frequency (100+ checks/day)
- Haiku sufficient for pattern matching
- Significant cost savings ($30/month vs $500+/month)

---

## Common Mistake 2: Missing Tool Restrictions

### Before (Incorrect)

```yaml
---
name: file-analyzer
model: sonnet
# No allowed_tools
---
```

**Issue**: Unrestricted tool access (security risk)

### After (Correct)

```yaml
---
name: file-analyzer
model: sonnet
allowed_tools:
  - Read
  - Grep
  - Glob
  - Bash
---
```

**Justification**:

- Read-only analyzer pattern
- No Write/Edit needed (doesn't modify files)
- Bash for safe commands (ls, wc, file)
- Security boundaries clear

---

## Common Mistake 3: Generic Focus Areas

### Before (Incorrect)

```markdown
## Focus Areas

- Best practices
- Code quality
- Good design
- Testing approaches
```

**Issue**: All vague and generic, no technology specificity

### After (Correct)

```markdown
## Focus Areas

- React component development with hooks (useState, useEffect, useContext)
- State management with Redux Toolkit and createSlice
- TypeScript types and interfaces for props and state
- Jest testing with React Testing Library and user events
- CSS-in-JS with styled-components and theming
- API integration with axios and React Query
- Form handling with React Hook Form and validation schemas
- Performance optimization with useMemo and useCallback
```

**Improvements**:

- Specific: Names React, Redux, TypeScript, Jest, etc.
- Concrete: Mentions specific hooks and patterns
- Count: 8 focus areas (sweet spot)
- Technology-specific: Calls out exact libraries

---

## Common Mistake 4: Vague Approach

### Before (Incorrect)

```markdown
## Approach

Follow industry best practices to produce quality code.
```

**Issue**: No process, no output specification, no quality standards

### After (Correct)

```markdown
## Approach

1. Analyze existing React components in codebase
2. Design new component using React hooks
3. Implement with TypeScript type definitions
4. Add Jest tests with React Testing Library
5. Style with styled-components following theme
6. Validate with ESLint and TypeScript compiler
7. Document with JSDoc and usage examples

Output: React component with:

- TypeScript types for all props and state
- Jest tests with >80% coverage
- styled-components styling with theme support
- JSDoc documentation with examples
- ESLint clean (no errors or warnings)
```

**Improvements**:

- Process: Clear 7-step methodology
- Output: Specific deliverable format
- Quality: Standards defined (>80% coverage, ESLint clean)
- Integration: Uses focus area expertise

---

## Common Mistake 5: Tools Too Permissive

### Before (Incorrect)

```yaml
---
name: code-reviewer
model: sonnet
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
  - Task
  - Skill
---
```

**Agent task**: Review code and provide feedback (read-only)

**Issue**: Has Write, Edit, Task, Skill but only needs Read

### After (Correct)

```yaml
---
name: code-reviewer
model: sonnet
allowed_tools:
  - Read
  - Grep
  - Glob
  - Bash
---
```

**Justification**:

- Read-only task (analysis, no modifications)
- Removed Write/Edit (doesn't create/modify files)
- Removed Task/Skill (doesn't invoke other components)
- Minimal permissions for security

---

## Full Audit Report Example

### Agent: fastapi-generator

**File**: `agents/fastapi-generator.md`

**Audited**: 2025-01-15 14:23

**Summary**: Agent generates FastAPI applications with appropriate model (Sonnet), good tool restrictions, but focus areas need expansion and approach needs more detail.

**Compliance Status**: NEEDS WORK

- **Model Selection**: ✓ sonnet - appropriate for code generation
- **Tool Restrictions**: ✓ 6 tools - code generator pattern, secure
- **Focus Areas**: ⚠ 4 areas - insufficient count, needs expansion to 8-10
- **Approach**: ⚠ incomplete - missing decision logic and quality standards
- **Context Economy**: ✓ 342 lines - good size

### Critical Issues

None

### Important Issues

**1. Insufficient Focus Areas**

- **Severity**: IMPORTANT
- **Location**: Focus Areas section (lines 12-16)
- **Issue**: Only 4 focus areas (target: 5-15)
- **Impact**: Expertise scope unclear, discoverability reduced
- **Fix**: Expand to 8-10 areas:

```markdown
## Focus Areas

- FastAPI REST APIs with Pydantic request/response models
- SQLAlchemy async ORM with relationship patterns
- Alembic database migrations with version control
- pytest testing with TestClient and async fixtures
- Python type hints with mypy strict mode validation
- API documentation with OpenAPI/Swagger automatic generation
- JWT authentication with python-jose
- Error handling with HTTPException and custom handlers
- Dependency injection with FastAPI Depends
- CORS and middleware configuration
```

**2. Incomplete Approach Methodology**

- **Severity**: IMPORTANT
- **Location**: Approach section (lines 24-30)
- **Issue**: Missing decision logic and quality standards
- **Current**:

  ```markdown
  ## Approach

  1. Analyze API requirements
  2. Generate FastAPI routes and models
  3. Add database integration
  4. Create tests
  5. Document endpoints

  Output: FastAPI application
  ```

- **Fix**: Add decision logic and quality:

  ```markdown
  ## Approach

  **Decision logic**:

  - If authentication needed → Add JWT with python-jose
  - If database required → Use SQLAlchemy async ORM
  - If complex validation → Use Pydantic validators

  1. Parse OpenAPI spec or requirements
  2. Generate FastAPI routes with Pydantic models
  3. Implement SQLAlchemy models and relationships
  4. Add Alembic migrations for schema
  5. Create pytest tests with TestClient
  6. Validate with mypy strict mode
  7. Generate OpenAPI documentation

  Output: FastAPI application with:

  - Pydantic models for all endpoints
  - SQLAlchemy async ORM integration
  - pytest tests with >80% coverage
  - Alembic migrations
  - OpenAPI documentation
  - mypy strict mode compliance

  **Quality standards**:

  - All tests pass
  - mypy shows no errors
  - API documentation complete
  - Migration scripts reversible
  ```

### Nice-to-Have Improvements

**1. Add Technology Version Specificity**

- **Location**: Focus Areas
- **Suggestion**: Mention FastAPI 0.100+, SQLAlchemy 2.0+, Pydantic 2.0+
- **Benefit**: Clearer technology stack

**2. Add Example Decision Scenarios**

- **Location**: Approach section
- **Suggestion**: Add more if/then patterns for common variations
- **Benefit**: Better handling of edge cases

### Recommendations

**Critical**: None

**Important**:

1. Expand focus areas from 4 to 8-10 specific items
2. Enhance approach with decision logic and quality standards

**Nice-to-Have**:

1. Add technology version specificity to focus areas
2. Include more decision scenarios in approach

### Next Steps

1. Add 4-6 focus areas covering authentication, validation, middleware, error handling
2. Update approach section with decision logic and quality standards
3. Re-run audit to verify improvements

**Expected Status After Fixes**: PASS

---

## Poor Agent Example 2: Oversized Single File

**File**: `agents/comprehensive-analyzer.md` (fictional example)

**Focus**: Resource organization problems

### Structure

```text
agents/
└── comprehensive-analyzer.md  (850 lines, single file)
```

### Issues

**Resource Organization Problems**:

✗ File too large (850 lines, target <500)
✗ No references/ directory
✗ Includes extensive examples inline (could be references/examples.md)
✗ Contains detailed reference tables (could be references/tables.md)
✗ Multiple complete workflows embedded (could be references/workflows.md)

**Impact**:

- Slow to load (high context usage)
- Hard to navigate and find information
- Difficult to maintain and update
- Poor user experience
- No progressive disclosure

**Resource Organization Score**: 2/10 (Poor)

### Recommended Fix

Refactor into directory structure:

```text
comprehensive-analyzer/
├── comprehensive-analyzer.md  # <400 lines, core methodology
└── references/
    ├── examples.md           # Extracted examples (150 lines)
    ├── reference-tables.md   # Extracted tables (120 lines)
    └── workflows.md          # Extracted detailed workflows (180 lines)
```

**After refactoring**:

- Main file: ~350 lines (core methodology only)
- References: 3 focused files in references/
- Clear navigation with "Reference Files" section
- Progressive disclosure: load details as needed

**New Resource Organization Score**: 9/10 (Excellent)

**Assessment**: Demonstrates importance of progressive disclosure. Single oversized file becomes well-organized agent with proper reference structure.

---

## Summary Comparison

| Aspect        | evaluator  | test-runner | poor-agent  | fastapi-generator |
| ------------- | ---------- | ----------- | ----------- | ----------------- |
| Model         | sonnet ✓   | sonnet ✓    | opus ✗      | sonnet ✓          |
| Tools         | 4 tools ✓  | 6 tools ✓   | missing ✗   | 6 tools ✓         |
| Focus Areas   | 12 areas ✓ | 6 areas ✓   | 3 generic ✗ | 4 areas ⚠         |
| Approach      | Complete ✓ | Complete ✓  | vague ✗     | incomplete ⚠      |
| Overall Score | 10/10      | 9.5/10      | 1/10        | 6.5/10            |
| Status        | PASS       | PASS        | FAIL        | NEEDS WORK        |

**Key Takeaways**:

- **Excellent agents**: Specific focus areas (12), complete approach, appropriate model, secure tools
- **Good agents**: Adequate focus areas (5+), clear methodology, justified permissions
- **Poor agents**: Generic focus areas (<5), vague approach, inappropriate model, missing tools
- **Fixable agents**: Good foundation but needs expansion/detail

---

## Quick Reference: Red Flags

**Model Selection**:

- ✗ Opus for simple tasks
- ✗ Haiku for code generation
- ✗ No justification for non-Sonnet

**Tool Restrictions**:

- ✗ No `allowed_tools` field
- ✗ Write + Bash unrestricted
- ✗ Tools don't match usage

**Focus Areas**:

- ✗ <5 areas
- ✗ Generic statements ("best practices")
- ✗ No technology names

**Approach**:

- ✗ Missing approach section
- ✗ Single vague sentence
- ✗ No output specification
- ✗ No quality standards

**Quick Fix Priority**:

1. Add `allowed_tools` if missing
2. Change Opus→Sonnet if unjustified
3. Expand focus areas to 5+ specific items
4. Add complete approach with steps + output

**When in Doubt**: Compare to evaluator or test-runner as exemplars.
