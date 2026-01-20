# Focus Area Quality

Guide for assessing the quality and specificity of agent focus areas.

## Core Principle

**Focus areas define agent expertise - they must be specific, concrete, and comprehensive.**

Vague focus areas = unclear capabilities
Specific focus areas = clear expertise

## What Are Focus Areas

Focus areas are the specific domains where an agent has expertise. They tell users and Claude:

- What the agent knows about
- What technologies it's expert in
- What problems it can solve
- What patterns it follows

**Example from code-generator**:

```markdown
## Focus Areas

- Defensive programming with strict error handling
- POSIX compliance and cross-platform portability
- Safe argument parsing and input validation
- Robust file operations and temporary resource management
- Production-grade logging and error reporting
```

Each focus area is **specific** (not generic) and **concrete** (not vague).

## Quality Criteria

### Criterion 1: Specificity

**Specific vs Generic**:

✗ **Generic** (too broad):

- "Programming"
- "Best practices"
- "Good code"
- "Quality standards"

✓ **Specific** (clear domain):

- "FastAPI REST APIs with SQLAlchemy ORM"
- "Defensive programming with strict error handling"
- "Test-driven development with Jest"
- "SOLID principles in TypeScript applications"

**Test**: Can you replace "programming" with a specific technology/framework?

### Criterion 2: Concreteness

**Concrete vs Vague**:

✗ **Vague** (abstract):

- "Do things well"
- "Follow standards"
- "Use good patterns"
- "Write quality code"

✓ **Concrete** (actionable):

- "Set -euo pipefail in all Bash scripts"
- "Validate all user input with Joi schemas"
- "Use factory pattern for object creation"
- "Document all public APIs with JSDoc"

**Test**: Can someone implement this guidance?

### Criterion 3: Comprehensiveness

**Target**: 5-15 focus areas

**Too few** (<5):

- Expertise unclear
- Scope too narrow
- Missing important areas

**Sweet spot** (5-15):

- Comprehensive coverage
- Clear boundaries
- Focused expertise

**Too many** (>15):

- Trying to do everything
- Unfocused
- Diluted expertise

### Criterion 4: Non-Overlap

Each focus area should be distinct:

✗ **Overlapping**:

- "Error handling patterns"
- "Exception management"
- "Failure recovery strategies"

(All about error handling)

✓ **Distinct**:

- "Error handling and exception management"
- "Logging and observability"
- "Resource cleanup and lifecycle management"

(Different concerns)

### Criterion 5: Technology Specificity

Name frameworks, libraries, tools:

✗ **Generic**:

- "Database usage"
- "Testing approaches"
- "API design"

✓ **Technology-Specific**:

- "PostgreSQL with Sequelize ORM"
- "pytest with fixtures and parameterization"
- "RESTful APIs with OpenAPI specification"

## Scoring Methodology

### Score Calculation (1-10)

**Score = (Specificity + Concreteness + Coverage) / 3**

Each component scored 1-10:

**Specificity**:

- 10: All areas name specific technologies/frameworks
- 7-9: Most areas specific, some generic
- 4-6: Mix of specific and generic
- 1-3: Mostly generic

**Concreteness**:

- 10: All areas actionable, concrete guidance
- 7-9: Most areas concrete, some vague
- 4-6: Mix of concrete and vague
- 1-3: Mostly vague

**Coverage**:

- 10: 10-15 areas, comprehensive
- 7-9: 7-9 areas, good coverage
- 4-6: 5-6 areas, adequate
- 1-3: <5 areas, insufficient

### Example Scoring

**Agent 1: code-generator**

Focus areas:

- Defensive programming with strict error handling (specific ✓, concrete ✓)
- POSIX compliance and cross-platform portability (specific ✓, concrete ✓)
- Safe argument parsing and input validation (specific ✓, concrete ✓)
- Robust file operations and temporary resource management (specific ✓, concrete ✓)
- Production-grade logging and error reporting (specific ✓, concrete ✓)

Count: 5 areas

Scores:

- Specificity: 10/10 (all specific)
- Concreteness: 10/10 (all concrete)
- Coverage: 6/10 (only 5 areas, could expand to 8-10)

**Overall**: (10+10+6)/3 = 8.7/10 (Good)

**Agent 2: Hypothetical Poor Agent**

Focus areas:

- Best practices
- Code quality
- Good patterns

Scores:

- Specificity: 1/10 (all generic)
- Concreteness: 1/10 (all vague)
- Coverage: 2/10 (only 3 areas)

**Overall**: (1+1+2)/3 = 1.3/10 (Poor)

## Common Anti-Patterns

### Anti-Pattern 1: Too Generic

**Problem**:

```markdown
## Focus Areas

- Programming best practices
- Code quality standards
- Software engineering principles
```

**Why bad**: No specific guidance, could apply to anything

**Fix**:

```markdown
## Focus Areas

- Defensive programming with explicit error handling (Go idioms)
- Table-driven tests with testing package
- Clean architecture with dependency injection
- Idiomatic Go code following Effective Go guidelines
- Concurrent programming with goroutines and channels
```

### Anti-Pattern 2: Too Few Areas

**Problem**:

```markdown
## Focus Areas

- Python programming
- Web development
```

**Why bad**: Expertise too broad and vague

**Fix**: Expand to 8-10 specific areas:

```markdown
## Focus Areas

- FastAPI REST APIs with Pydantic models
- SQLAlchemy ORM with async support
- pytest testing with fixtures and mocking
- Python type hints with mypy validation
- Async/await patterns with asyncio
- Dependency injection with FastAPI dependencies
- API documentation with OpenAPI/Swagger
- Error handling with structured exceptions
```

### Anti-Pattern 3: Too Many Areas

**Problem**: 25 focus areas covering everything

**Why bad**: Unfocused, trying to be expert in everything

**Fix**: Consolidate to 10-12 core areas, group related items

### Anti-Pattern 4: Overlapping Areas

**Problem**:

```markdown
## Focus Areas

- Error handling
- Exception management
- Failure recovery
- Error reporting
- Fault tolerance
```

**Why bad**: All about errors, redundant

**Fix**:

```markdown
## Focus Areas

- Error handling and exception management with structured errors
- Fault tolerance with retry policies and circuit breakers
- Observability with structured logging and metrics
```

### Anti-Pattern 5: No Technology Names

**Problem**:

```markdown
## Focus Areas

- Database design
- Testing strategies
- API architecture
```

**Why bad**: No indication of which technologies

**Fix**:

```markdown
## Focus Areas

- PostgreSQL schema design with normalized tables
- pytest testing with pytest-asyncio and factories
- RESTful API design with OpenAPI 3.0 specification
```

## Assessment Process

### Step 1: Extract Focus Areas

Read agent file and find focus areas section:

```bash
# Find focus areas
grep -A 20 "## Focus Areas" agent-file.md
```

### Step 2: Count Areas

Count individual bullet points:

```bash
# Count focus areas
grep -A 20 "## Focus Areas" agent-file.md | grep "^-" | wc -l
```

Target: 5-15 areas

### Step 3: Analyze Specificity

For each area, check:

- [ ] Names specific technology/framework
- [ ] Mentions concrete patterns/practices
- [ ] Provides actionable guidance
- [ ] Not generic ("best practices", "good code")

### Step 4: Check Coverage

Does the set of focus areas cover:

- [ ] Core responsibilities
- [ ] Common scenarios
- [ ] Edge cases
- [ ] Quality standards
- [ ] Integration patterns

### Step 5: Calculate Score

Use scoring methodology above to get 1-10 score.

## Examples by Score Range

### 9-10/10 (Excellent)

**Characteristics**:

- 10-15 focus areas
- All specific with technology names
- All concrete with actionable guidance
- Comprehensive coverage
- No overlap

**Example**:

```markdown
## Focus Areas

- Defensive programming with set -euo pipefail and trap handlers
- POSIX compliance validated with shellcheck --shell=sh
- Safe argument parsing with getopts and input validation
- Robust file operations with mktemp and automatic cleanup
- Production logging to stderr with ISO 8601 timestamps
- Cross-platform portability (Linux, macOS, BSD)
- Safe command composition with proper quoting
- Error handling with meaningful exit codes (0-255)
- Idempotent operations with state validation
- Integration with CI/CD pipelines (GitHub Actions, GitLab CI)
```

### 7-8/10 (Good)

**Characteristics**:

- 7-9 focus areas
- Most specific, few generic
- Most concrete, few vague
- Good coverage with minor gaps

**Example**:

```markdown
## Focus Areas

- React component development with hooks
- State management with Redux Toolkit
- TypeScript types and interfaces
- Jest testing with React Testing Library
- CSS-in-JS with styled-components
- API integration with axios
- Form handling with React Hook Form
```

### 5-6/10 (Adequate)

**Characteristics**:

- 5-6 focus areas
- Mix of specific and generic
- Some vague statements
- Basic coverage, noticeable gaps

**Example**:

```markdown
## Focus Areas

- Python programming
- Web API development with FastAPI
- Database usage
- Testing best practices
- Code quality standards
```

### 3-4/10 (Poor)

**Characteristics**:

- 3-4 focus areas
- Mostly generic
- Many vague statements
- Incomplete coverage

**Example**:

```markdown
## Focus Areas

- Best practices
- Clean code principles
- Software design
```

### 1-2/10 (Very Poor)

**Characteristics**:

- <3 focus areas
- All generic
- All vague
- No real guidance

**Example**:

```markdown
## Focus Areas

- Programming
- Quality
```

## Improvement Strategies

### Strategy 1: Add Technology Names

**Before**:

```markdown
- Database design
```

**After**:

```markdown
- PostgreSQL schema design with normalized tables and foreign keys
- MongoDB document modeling with embedded vs referenced patterns
```

### Strategy 2: Make Concrete

**Before**:

```markdown
- Testing approaches
```

**After**:

```markdown
- pytest unit testing with fixtures and parameterization
- Integration testing with testcontainers
- Property-based testing with Hypothesis
```

### Strategy 3: Expand Coverage

**Before** (3 areas):

```markdown
- API development
- Testing
- Documentation
```

**After** (9 areas):

```markdown
- RESTful API design with OpenAPI 3.0 specification
- Request validation with Pydantic models
- Response serialization with JSON schemas
- pytest unit testing with fixtures
- Integration testing with TestClient
- API documentation with FastAPI automatic docs
- Error handling with HTTP exceptions
- Authentication with JWT tokens
- Rate limiting and throttling
```

### Strategy 4: Split Overlapping Areas

**Before**:

```markdown
- Error handling
- Exception management
- Failure recovery
```

**After**:

```markdown
- Structured error handling with custom exception hierarchies
- Fault tolerance with retry policies and circuit breakers
```

### Strategy 5: Remove Vague Statements

**Before**:

```markdown
- Best practices
- Good patterns
- Quality standards
```

**After**:

```markdown
- SOLID principles (Single Responsibility, Open/Closed, etc.)
- Factory and Builder patterns for object creation
- Clean architecture with dependency inversion
```

## Validation Checklist

When auditing focus areas:

- [ ] **Count appropriate**: 5-15 areas
- [ ] **All specific**: Technology/framework names present
- [ ] **All concrete**: Actionable, not vague
- [ ] **No overlap**: Each area distinct
- [ ] **Comprehensive**: Covers main responsibilities
- [ ] **Accurate**: Matches actual agent capabilities
- [ ] **Realistic**: Agent can deliver on claims

## Examples from Existing Agents

### Example 1: evaluator

**Focus areas** (12 total):

- YAML frontmatter validation
- Markdown structure and formatting
- Tool permission analysis
- Description quality assessment
- Progressive disclosure validation
- File organization checking
- Naming convention enforcement
- Reference file validation
- Integration pattern analysis
- Context economy assessment
- Security implication review
- Cross-cutting concern detection

**Analysis**:

- Specificity: 10/10 (all specific to evaluation)
- Concreteness: 10/10 (all actionable)
- Coverage: 10/10 (12 areas, comprehensive)

**Score**: 10/10 (Excellent)

### Example 2: Hypothetical Weak Agent

**Focus areas** (3 total):

- Programming
- Code quality
- Best practices

**Analysis**:

- Specificity: 1/10 (all generic)
- Concreteness: 1/10 (all vague)
- Coverage: 2/10 (only 3 areas)

**Score**: 1.3/10 (Very Poor)

## Focus Area Specificity Assessment

Detailed criteria for assessing the specificity and quality of focus areas.

### Assessment Criteria

1. **Technology specificity**: Mentions frameworks/tools by name
   - ✓ Good: "FastAPI REST APIs with SQLAlchemy ORM"
   - ✗ Bad: "Python programming"

2. **Domain clarity**: Clear area of expertise
   - ✓ Good: "OAuth 2.0 authentication with JWT tokens"
   - ✗ Bad: "Security"

3. **Actionability**: Concrete guidance possible
   - ✓ Good: "React hooks (useState, useEffect, useContext)"
   - ✗ Bad: "Frontend development"

4. **Coverage**: Spans full expertise area
   - Check if all major responsibilities are covered
   - No significant gaps in agent's domain

5. **Non-overlap**: Each area distinct
   - Focus areas shouldn't duplicate each other
   - Each should cover a unique aspect

### Specificity Scoring (1-10 Scale)

- **9-10**: All specific, concrete, comprehensive
  - Every area names technologies/frameworks
  - Clear, actionable expertise
  - Full coverage of domain

- **7-8**: Mostly specific, minor generic statements
  - Most areas have specificity
  - 1-2 areas could be more concrete
  - Good overall quality

- **5-6**: Mix of specific and generic
  - Some areas specific, some vague
  - Needs improvement
  - Partial coverage

- **3-4**: Mostly generic, little specificity
  - Few specific areas
  - Many vague statements
  - Poor quality

- **1-2**: All generic, no concrete focus
  - No technology names
  - All abstract/vague
  - Unacceptable quality

### Evaluation Process

1. Count total focus areas (target: 5-15)
2. Score each area for specificity (1-10)
3. Calculate average specificity score
4. Check for overlap/duplication
5. Assess coverage completeness
6. Generate overall quality score

## Summary

**Key Principles**:

1. **5-15 areas**: Not too few, not too many
2. **Name technologies**: Specific frameworks/libraries
3. **Be concrete**: Actionable guidance
4. **Avoid overlap**: Each area distinct
5. **Comprehensive coverage**: All major responsibilities

**Quality indicators**:

- Good: "pytest testing with fixtures and mocking"
- Bad: "Testing best practices"

**When in doubt**: Add specificity and technology names.
