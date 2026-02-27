# Analysis Rubric

## Code Smell Detection

Concrete thresholds for identifying structural problems. Flag any violation with its location and measured value.

### Size and Complexity

| Smell                | Threshold       | What to look for                               |
| -------------------- | --------------- | ---------------------------------------------- |
| Long function/method | > 20 lines      | Functions doing multiple things                |
| Large class/module   | > 200 lines     | Classes with too many responsibilities         |
| High complexity      | Cyclomatic > 10 | Deep branching, many code paths                |
| Too many parameters  | > 3 params      | Functions requiring excessive context          |
| Deep nesting         | > 2 levels      | Nested loops/conditionals that obscure intent  |
| Long parameter list  | > 3 params      | Consider parameter objects or builder patterns |

### Duplication and Dead Code

- **Duplicate blocks** — Identical or near-identical logic in multiple locations
- **Dead code** — Unreachable branches, unused variables, commented-out code
- **Copy-paste patterns** — Similar structures that differ only in names or values

### Naming and Clarity

- **Magic numbers** — Unnamed numeric literals with domain meaning
- **Cryptic names** — Single-letter variables (outside loops), abbreviations, misleading names
- **Inconsistent conventions** — Mixed naming styles within the same scope
- **Misleading names** — Names that suggest different behavior than what the code does

### Coupling and Cohesion

- **Tight coupling** — Direct dependencies on concrete implementations
- **Feature envy** — Methods that use another class's data more than their own
- **Shotgun surgery** — A single change requires edits across many files
- **God object** — One class that knows/does too much

## SOLID Violation Indicators

What to look for — not textbook definitions.

| Principle             | Red flags                                                                |
| --------------------- | ------------------------------------------------------------------------ |
| Single Responsibility | Class has multiple reasons to change; methods grouped by unrelated tasks |
| Open/Closed           | Adding behavior requires modifying existing code instead of extending    |
| Liskov Substitution   | Subclasses override methods to throw or no-op; type checks in consumers  |
| Interface Segregation | Clients forced to depend on methods they don't use; fat interfaces       |
| Dependency Inversion  | High-level modules import low-level modules directly; no abstractions    |

## Performance Smell Indicators

- **Quadratic or worse algorithms** — Nested iterations over the same collection
- **Unnecessary object creation** — Allocations inside tight loops
- **Missing caching** — Repeated expensive computations with same inputs
- **Blocking operations** — Synchronous I/O in hot paths
- **Memory accumulation** — Collections that grow without bounds

## Severity Classification

| Severity     | Criteria                                                       | Examples                                                    |
| ------------ | -------------------------------------------------------------- | ----------------------------------------------------------- |
| **Critical** | Security risk, data corruption, resource leaks                 | SQL injection, unbounded memory growth, race conditions     |
| **High**     | Performance bottleneck, maintainability blocker, missing tests | O(n^2) on large data, 500-line function, zero test coverage |
| **Medium**   | Code smell, minor perf issue, incomplete docs                  | Duplicate blocks, magic numbers, missing type annotations   |
| **Low**      | Style inconsistency, minor naming, cosmetic                    | Inconsistent formatting, slightly unclear variable name     |

## Prioritization Matrix

Combine severity with estimated effort to determine action order:

```text
              Low Effort    High Effort
High Impact   P1 (do first) P2 (plan next)
Low Impact    P3 (quick win) P4 (skip)
```

- **P1**: Rename variables, extract constants, remove dead code, simplify booleans
- **P2**: Decompose god classes, introduce interfaces, restructure modules
- **P3**: Fix minor naming, add type annotations, improve formatting
- **P4**: Large-scale rewrites with marginal benefit — defer or skip
