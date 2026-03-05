# Debt Categories

Taxonomy of technical debt types with detection criteria and measurement thresholds. Use this as a checklist when scanning a codebase.

## Contents

- Code Debt
  - Duplication
  - Complexity
  - Poor Structure
- Architecture Debt
- Testing Debt
- Documentation Debt
- Infrastructure Debt

## Code Debt

Structural problems within individual files and functions.

### Duplication

- **Exact duplicates** — Copy-pasted blocks across files
- **Similar logic patterns** — Same algorithm with superficial differences
- **Repeated business rules** — Validation or domain logic in multiple locations

Detection: Grep for identical multi-line blocks; look for files with suspiciously similar structure. Measure lines duplicated and number of locations.

### Complexity

| Smell           | Threshold       | What to look for                            |
| --------------- | --------------- | ------------------------------------------- |
| High complexity | Cyclomatic > 10 | Deep branching, many code paths             |
| Deep nesting    | > 3 levels      | Nested conditionals/loops                   |
| Long methods    | > 50 lines      | Functions doing multiple things             |
| God classes     | > 500 lines     | Classes with > 20 methods or mixed concerns |
| Too many params | > 5 params      | Functions requiring excessive context       |

### Poor Structure

- **Circular dependencies** — Modules importing each other
- **Feature envy** — Methods that primarily use another module's data
- **Shotgun surgery** — Single logical change requires edits across many files
- **Inappropriate intimacy** — Classes reaching into each other's internals

Detection: Trace import graphs; look for files that always change together. Measure coupling metrics and change frequency.

## Architecture Debt

Design-level problems that affect system organization.

### Design Flaws

- **Missing abstractions** — Concrete implementations where interfaces should exist
- **Leaky abstractions** — Implementation details exposed through APIs
- **Violated boundaries** — Layers bypassing intended architecture (e.g., UI calling DB directly)
- **Monolithic components** — Single modules handling unrelated concerns

Detection: Map component boundaries; check for dependency direction violations. Measure component size and dependency counts.

### Technology Lag

- **Outdated frameworks/libraries** — Major versions behind current
- **Deprecated API usage** — Calling APIs marked for removal
- **Legacy patterns** — Older idioms when better alternatives exist (e.g., callbacks vs async/await)
- **Unsupported dependencies** — Libraries no longer maintained

Detection: Check package manifests for version lag; grep for deprecated API calls. Measure version distance and known vulnerability count.

## Testing Debt

Gaps in test coverage and test quality.

### Coverage Gaps

- **Untested code paths** — Functions or branches with no test coverage
- **Missing edge cases** — Happy path only, no error/boundary testing
- **No integration tests** — Unit tests exist but components untested together
- **Critical paths untested** — Payment flows, auth, data mutations without tests

Detection: Run coverage tools if available; inspect test directories for breadth. Measure coverage percentage and list critical untested paths.

### Test Quality

- **Brittle tests** — Tests coupled to implementation details or environment
- **Slow test suites** — Tests that discourage frequent running
- **Flaky tests** — Non-deterministic failures
- **No assertions** — Tests that execute code but verify nothing meaningful

Detection: Check test run times; look for excessive mocking, sleep calls, or environment dependencies. Measure test runtime and failure rate.

## Documentation Debt

Missing or outdated documentation.

- **No API documentation** — Public interfaces without usage guidance
- **Undocumented complex logic** — Algorithms or business rules with no explanation
- **Stale documentation** — Docs that describe previous behavior
- **Missing setup/onboarding** — No instructions for getting started

Detection: Check for README, doc comments on public APIs, and architecture docs. Measure undocumented public API count.

## Infrastructure Debt

Operational and deployment problems.

- **Manual deployment steps** — Processes that should be automated
- **No rollback procedures** — Deployments without a recovery plan
- **Missing monitoring** — No alerting on errors, performance, or availability
- **No performance baselines** — No way to detect regressions
- **Missing CI/CD** — No automated build, test, or deploy pipeline

Detection: Check for CI config files, deployment scripts, monitoring setup. Measure deployment time and manual step count.
