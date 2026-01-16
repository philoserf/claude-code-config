---
name: map-codebase
description: Analyze codebase with parallel Explore agents to produce .planning/codebase/ documents. Use for brownfield project onboarding, refreshing codebase understanding after significant changes, before major refactoring, or when onboarding to unfamiliar codebases. Creates structured documentation of stack, architecture, structure, conventions, testing, integrations, and concerns.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - Task
# model: inherit
---

## Reference Files

Detailed workflow guidance and document templates:

- [workflow.md](workflow.md) — Detailed workflow guidance and orchestration patterns
- [templates/stack.md](templates/stack.md) — STACK.md template
- [templates/architecture.md](templates/architecture.md) — ARCHITECTURE.md template
- [templates/structure.md](templates/structure.md) — STRUCTURE.md template
- [templates/conventions.md](templates/conventions.md) — CONVENTIONS.md template
- [templates/testing.md](templates/testing.md) — TESTING.md template
- [templates/integrations.md](templates/integrations.md) — INTEGRATIONS.md template
- [templates/concerns.md](templates/concerns.md) — CONCERNS.md template

---

# Map Codebase

Analyzes existing codebases using parallel Explore agents to produce structured documentation in `.planning/codebase/`.

## Objective

This skill spawns multiple Explore agents to analyze different aspects of the codebase in parallel, each with fresh context. The result is 7 structured documents that provide a comprehensive map of the codebase state.

**Output:** `.planning/codebase/` folder with:

- `STACK.md` — Languages, frameworks, key dependencies
- `ARCHITECTURE.md` — System design, patterns, data flow
- `STRUCTURE.md` — Directory layout, module organization
- `CONVENTIONS.md` — Code style, naming, patterns
- `TESTING.md` — Test structure, coverage, practices
- `INTEGRATIONS.md` — APIs, databases, external services
- `CONCERNS.md` — Technical debt, risks, issues

## When to Use

**Use map-codebase for:**

- **Brownfield projects** before initialization — understand existing code first
- **Refreshing codebase map** after significant changes
- **Onboarding** to an unfamiliar codebase
- **Before major refactoring** — understand current state thoroughly
- **When STATE.md references outdated codebase info** — refresh understanding

**Skip map-codebase for:**

- **Greenfield projects** with no code yet — nothing to map
- **Trivial codebases** (<5 files) — not worth the overhead

## Process

### Step 1: Check Existing Documentation

Check if `.planning/codebase/` already exists:

- If yes: Offer to refresh (overwrite) or skip
- If no: Proceed with creation

### Step 2: Load Project Context

Check for `.planning/STATE.md` to load existing project context if available. This helps agents understand project-specific terminology and patterns.

### Step 3: Process Focus Area Argument

If user provided a focus area (e.g., "api" or "auth"), instruct agents to pay special attention to that subsystem while still providing holistic analysis.

### Step 4: Create Directory Structure

Create `.planning/codebase/` directory if it doesn't exist.

### Step 5: Spawn Parallel Explore Agents

Launch 4 Explore agents in parallel, each with "very thorough" exploration level:

**Agent 1: Technology Stack & Integrations**

- Focus: Languages, frameworks, dependencies, external services
- Outputs: Data for STACK.md and INTEGRATIONS.md

**Agent 2: Architecture & Structure**

- Focus: System design, patterns, directory organization
- Outputs: Data for ARCHITECTURE.md and STRUCTURE.md

**Agent 3: Conventions & Testing**

- Focus: Code style, naming patterns, test infrastructure
- Outputs: Data for CONVENTIONS.md and TESTING.md

**Agent 4: Concerns & Technical Debt**

- Focus: Issues, risks, technical debt, potential improvements
- Outputs: Data for CONCERNS.md

### Step 6: Collect Agent Findings

Wait for all 4 agents to complete. Collect and organize their findings by document type.

### Step 7: Write Structured Documents

Using the collected findings, write 7 markdown documents following the template structure:

1. **STACK.md**
   - Programming languages and versions
   - Frameworks and libraries
   - Build tools and package managers
   - Key dependencies and their purposes

2. **ARCHITECTURE.md**
   - System design overview
   - Architectural patterns used
   - Component relationships
   - Data flow and processing

3. **STRUCTURE.md**
   - Top-level directory layout
   - Module organization
   - File naming patterns
   - Code organization principles

4. **CONVENTIONS.md**
   - Code style guidelines
   - Naming conventions
   - Common patterns and idioms
   - Documentation practices

5. **TESTING.md**
   - Test framework(s) used
   - Test structure and organization
   - Coverage approach
   - Testing best practices

6. **INTEGRATIONS.md**
   - External APIs and services
   - Database systems
   - Third-party integrations
   - Configuration management

7. **CONCERNS.md**
   - Technical debt items
   - Known issues and limitations
   - Security concerns
   - Performance bottlenecks
   - Recommendations for improvement

### Step 8: Provide Next Steps

Inform user that codebase mapping is complete and suggest next steps:

- Review the generated documents in `.planning/codebase/`
- Use findings to inform refactoring or development plans
- Update `STATE.md` if needed with new insights

## Success Criteria

- [ ] `.planning/codebase/` directory created
- [ ] All 7 codebase documents written with substantive content
- [ ] Documents follow template structure
- [ ] Parallel agents completed without errors
- [ ] Findings are comprehensive and actionable
- [ ] User informed of completion and next steps

## Integration Notes

**Command Integration:**

- Invoked via `/map-codebase [optional: focus-area]` command
- Focus area argument is passed to agents for targeted analysis

**Project Lifecycle:**

- Can run **before** initial project setup on brownfield codebases
- Can run **after** initial project setup to refresh as code evolves
- Can run **anytime** to refresh codebase understanding
