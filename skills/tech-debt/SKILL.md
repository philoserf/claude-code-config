---
name: tech-debt
description: >-
  Identify, classify, and prioritize technical debt with a remediation roadmap.
  Use when auditing technical debt, assessing code quality, analyzing maintenance
  burden, inventorying legacy code, or asking what's slowing us down.
---

# Technical Debt Analysis

Systematic methodology for identifying, classifying, and prioritizing technical debt across a codebase. This skill **diagnoses** — it produces an inventory and remediation roadmap but does not modify code.

## When to Use

- User asks about technical debt, maintenance burden, or "what's slowing us down"
- Starting a new engagement with an unfamiliar codebase
- Before a major refactor to scope and prioritize work
- Periodic health check on code quality

## When NOT to Use

- Actually fixing the debt (use `refactor-clean` instead)
- Pure dependency/security audit (use `deps-audit` instead)
- Performance profiling without structural concerns
- Single-file code review

## Relationship to refactor-clean

These skills form a diagnose/treat pair:

- **tech-debt** = diagnose (what's wrong, how bad, what to fix first)
- **refactor-clean** = treat (how to fix it, verify quality after)

Run `tech-debt` first to build the inventory, then hand prioritized items to `refactor-clean` for execution.

## Workflow

### 1. Scan

Walk the codebase and identify debt items using the [debt categories](#code-debt).

- Glob for project structure and file sizes
- Grep for known smell patterns (TODO/FIXME/HACK, deeply nested code, large files)
- Read representative files in hotspot areas
- Classify each finding into its debt category

### 2. Assess

Score each debt item using the [ROI framework](#impact-dimensions).

- Evaluate impact across velocity, quality, and risk dimensions
- Assign a risk level (Critical / High / Medium / Low)
- Estimate effort to remediate (T-shirt size: S / M / L / XL)
- Note recurring cost if left unaddressed

### 3. Prioritize

Rank items into action tiers:

| Tier        | Profile                  | Action                  |
| ----------- | ------------------------ | ----------------------- |
| Quick Wins  | High impact, low effort  | Address immediately     |
| Medium-Term | High impact, high effort | Plan for next cycle     |
| Long-Term   | Moderate impact, large   | Roadmap for future      |
| Skip        | Low impact, high effort  | Accept or revisit later |

### 4. Report

Deliver the analysis in structured format:

```text
## Tech Debt Inventory

### Summary
- Total items found: N
- Critical: N | High: N | Medium: N | Low: N

### Debt Items

| # | Category | Item | Location | Risk | Effort | Tier |
|---|----------|------|----------|------|--------|------|
| 1 | Code     | ...  | ...      | ...  | ...    | ...  |

### Prioritized Roadmap

#### Quick Wins
- [items with rationale]

#### Medium-Term
- [items with rationale]

#### Long-Term
- [items with rationale]

### Recommendations
- [key observations and suggested next steps]
```

## Output Format

1. **Debt Inventory** — Categorized list with locations, risk levels, and effort estimates
2. **Prioritized Roadmap** — Action tiers with rationale for ordering
3. **Recommendations** — Key observations and suggested next steps

## Debt Categories

Taxonomy of technical debt types with detection criteria and measurement thresholds. Use this as a checklist when scanning a codebase.

### Code Debt

Structural problems within individual files and functions.

#### Duplication

- **Exact duplicates** — Copy-pasted blocks across files
- **Similar logic patterns** — Same algorithm with superficial differences
- **Repeated business rules** — Validation or domain logic in multiple locations

Detection: Grep for identical multi-line blocks; look for files with suspiciously similar structure. Measure lines duplicated and number of locations.

#### Complexity

| Smell           | Threshold       | What to look for                            |
| --------------- | --------------- | ------------------------------------------- |
| High complexity | Cyclomatic > 10 | Deep branching, many code paths             |
| Deep nesting    | > 3 levels      | Nested conditionals/loops                   |
| Long methods    | > 50 lines      | Functions doing multiple things             |
| God classes     | > 500 lines     | Classes with > 20 methods or mixed concerns |
| Too many params | > 5 params      | Functions requiring excessive context       |

#### Poor Structure

- **Circular dependencies** — Modules importing each other
- **Feature envy** — Methods that primarily use another module's data
- **Shotgun surgery** — Single logical change requires edits across many files
- **Inappropriate intimacy** — Classes reaching into each other's internals

Detection: Trace import graphs; look for files that always change together. Measure coupling metrics and change frequency.

### Architecture Debt

Design-level problems that affect system organization.

#### Design Flaws

- **Missing abstractions** — Concrete implementations where interfaces should exist
- **Leaky abstractions** — Implementation details exposed through APIs
- **Violated boundaries** — Layers bypassing intended architecture (e.g., UI calling DB directly)
- **Monolithic components** — Single modules handling unrelated concerns

Detection: Map component boundaries; check for dependency direction violations. Measure component size and dependency counts.

#### Technology Lag

- **Outdated frameworks/libraries** — Major versions behind current
- **Deprecated API usage** — Calling APIs marked for removal
- **Legacy patterns** — Older idioms when better alternatives exist (e.g., callbacks vs async/await)
- **Unsupported dependencies** — Libraries no longer maintained

Detection: Check package manifests for version lag; grep for deprecated API calls. Measure version distance and known vulnerability count.

### Testing Debt

Gaps in test coverage and test quality.

#### Coverage Gaps

- **Untested code paths** — Functions or branches with no test coverage
- **Missing edge cases** — Happy path only, no error/boundary testing
- **No integration tests** — Unit tests exist but components untested together
- **Critical paths untested** — Payment flows, auth, data mutations without tests

Detection: Run coverage tools if available; inspect test directories for breadth. Measure coverage percentage and list critical untested paths.

#### Test Quality

- **Brittle tests** — Tests coupled to implementation details or environment
- **Slow test suites** — Tests that discourage frequent running
- **Flaky tests** — Non-deterministic failures
- **No assertions** — Tests that execute code but verify nothing meaningful

Detection: Check test run times; look for excessive mocking, sleep calls, or environment dependencies. Measure test runtime and failure rate.

### Documentation Debt

Missing or outdated documentation.

- **No API documentation** — Public interfaces without usage guidance
- **Undocumented complex logic** — Algorithms or business rules with no explanation
- **Stale documentation** — Docs that describe previous behavior
- **Missing setup/onboarding** — No instructions for getting started

Detection: Check for README, doc comments on public APIs, and architecture docs. Measure undocumented public API count.

### Infrastructure Debt

Operational and deployment problems.

- **Manual deployment steps** — Processes that should be automated
- **No rollback procedures** — Deployments without a recovery plan
- **Missing monitoring** — No alerting on errors, performance, or availability
- **No performance baselines** — No way to detect regressions
- **Missing CI/CD** — No automated build, test, or deploy pipeline

Detection: Check for CI config files, deployment scripts, monitoring setup. Measure deployment time and manual step count.

## ROI Framework

Impact assessment, risk classification, and prioritization for technical debt items. Use this to score and rank findings from the debt inventory.

### Impact Dimensions

Evaluate each debt item across three dimensions:

#### Velocity Impact

How much does this debt slow down development?

- **Time multiplier** — Extra hours per change due to workarounds, duplication, or complexity
- **Change frequency** — How often this area is touched (hot paths cost more)
- **Onboarding friction** — Time for new developers to understand the code
- **Scope of blast radius** — How many features/teams are affected

#### Quality Impact

How does this debt affect correctness and reliability?

- **Bug correlation** — Does this area produce more defects than average?
- **Regression risk** — How likely are changes to break existing behavior?
- **Error handling** — Are failure modes well-covered or silent?
- **Data integrity** — Could this debt lead to corrupted or lost data?

#### Risk Exposure

What's the worst-case scenario if this debt is left unaddressed?

- **Security surface** — Vulnerabilities, unpatched dependencies, exposed secrets
- **Operational fragility** — Single points of failure, missing monitoring
- **Compliance gaps** — Regulatory or policy requirements not met
- **Vendor lock-in** — Dependencies that constrain future decisions

### Risk Classification

| Level        | Criteria                                                       | Examples                                              |
| ------------ | -------------------------------------------------------------- | ----------------------------------------------------- |
| **Critical** | Security vulnerabilities, data loss risk, compliance violation | SQL injection, no backups, unencrypted PII            |
| **High**     | Performance degradation, frequent outages, high defect rate    | O(n^2) on large data, flaky deploys, no test coverage |
| **Medium**   | Reduced velocity, developer friction, growing complexity       | God classes, heavy duplication, stale docs            |
| **Low**      | Minor inefficiency, style issues, cosmetic                     | Naming inconsistencies, minor code smells             |

### Effort Estimation

T-shirt sizing for remediation effort:

| Size   | Scope                               | Typical range |
| ------ | ----------------------------------- | ------------- |
| **S**  | Single file, isolated change        | < 1 hour      |
| **M**  | Few files, one module               | 1–4 hours     |
| **L**  | Multiple modules, interface changes | 1–3 days      |
| **XL** | Cross-cutting, architectural        | 1+ weeks      |

### Prioritization Tiers

Combine risk level with effort to assign action tiers:

```text
              Low Effort (S/M)     High Effort (L/XL)
High Risk     Quick Win            Medium-Term
Low Risk      Quick Win / Skip     Long-Term / Skip
```

#### Quick Wins

High impact relative to effort. Address immediately.

- Critical/High risk items with S/M effort
- Items in frequently-changed code paths
- Fixes that unblock other improvements

#### Medium-Term

High impact but significant effort. Plan for next cycle.

- High risk items requiring L effort
- Architectural changes that affect multiple modules
- Dependency upgrades with breaking changes

#### Long-Term

Moderate impact with large effort. Roadmap for future.

- Systemic issues requiring XL effort
- Architecture redesigns
- Major technology migrations

#### Skip

Low impact relative to effort. Accept or revisit later.

- Low risk items with L/XL effort
- Areas rarely touched or scheduled for replacement
- Cosmetic issues with no measurable impact

### Per-Item Metrics

Capture these for each debt item in the inventory:

| Field          | Description                                        |
| -------------- | -------------------------------------------------- |
| Category       | Debt type from taxonomy (Code, Architecture, etc.) |
| Location       | File paths and line ranges                         |
| Risk level     | Critical / High / Medium / Low                     |
| Effort         | S / M / L / XL                                     |
| Tier           | Quick Win / Medium-Term / Long-Term / Skip         |
| Recurring cost | Ongoing impact if not addressed (qualitative)      |
| Dependencies   | Other debt items or systems affected               |

### Prevention Indicators

Signals that new debt is being created — flag these during analysis:

- Increasing file sizes or complexity over recent commits
- Growing TODO/FIXME/HACK count
- Declining test coverage trends
- Rising dependency vulnerability counts
- Lengthening build or deploy times
