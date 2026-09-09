# Review dimensions

The checklists behind the review. Not a form to fill in — a prompt for attention. A
dimension with nothing to report gets no section in the output.

## The problem domain

Before judging the implementation, determine what the software is actually trying to do.

- The core problem being solved
- The principal domain concepts
- The important invariants
- The main inputs and outputs
- The expected users or callers
- Persistent state, if any
- External systems or protocols
- Likely performance or reliability requirements
- Places where domain terminology is represented clearly
- Places where implementation concepts obscure the domain

Distinguish accidental complexity from complexity inherent in the problem. Infer the
intended design from the code, tests, documentation, command-line interface, APIs,
configuration, commit structure, and other available evidence. **Do not invent requirements
that the repository does not support.**

## The repository

Inspect broadly enough to understand: directory and package/module structure, entry points,
major execution paths, public APIs, important internal APIs, data models, dependencies,
configuration, tests, build and release machinery, generated code, scripts and tooling, and
documentation.

Trace several representative operations end to end.

Pay particular attention to boundaries between components. Many important design problems
occur at boundaries rather than inside individual functions.

## Language and ecosystem

Evaluate the code according to the conventions of the language and its contemporary
community. Prefer normal, recognizable idioms over patterns imported from other languages
or ecosystems.

- Standard-library solutions before third-party abstractions
- Conventional package/module organization
- Normal naming practices
- Customary error-handling patterns
- Accepted interface and abstraction styles
- Ecosystem expectations for testing
- Normal concurrency models
- Normal resource-lifetime patterns
- Standard tooling
- Current compiler/runtime capabilities

Call out code that is technically valid but culturally unusual enough to increase
maintenance cost. Also identify cases where conventional wisdom should **not** be followed
because the domain or repository has a legitimate reason to differ.

## Correctness

- Violated or unenforced invariants
- Unexpected zero, null, nil, empty, or missing values
- Integer and other numeric issues
- Ordering assumptions
- State-transition errors and stale state
- Partial failure, and cleanup that does not run
- Error swallowing and error misclassification
- Races, deadlocks, and unsafe shared state
- Cancellation, retry, and idempotency problems
- File and network lifecycle errors
- Malformed input handling
- Serialization and deserialization mismatches
- Time and timezone assumptions
- Security-sensitive trust mistakes

Distinguish demonstrated defects from plausible risks. **Do not label something a bug merely
because it could be written differently.**

## Architecture and design

Determine whether the current decomposition matches the actual structure of the problem.

- Responsibilities grouped incorrectly
- Packages/modules with weak cohesion
- Excessive coupling and circular conceptual dependencies
- Inappropriate global state
- Abstractions that leak implementation details
- Interfaces that exist without meaningful substitution
- Overly generic mechanisms serving only one concrete use
- Abstractions created prematurely
- Duplicated domain logic
- Domain logic mixed with transport, storage, UI, or infrastructure concerns
- Infrastructure abstractions contaminating the domain model
- Control flow spread across too many layers
- Giant functions or types that genuinely contain multiple responsibilities
- Tiny functions or types that fragment otherwise simple logic
- Configuration threaded through inappropriate layers
- Important invariants that have no obvious owner

Do not apply rules such as "functions must be short" or "files must be small"
mechanically. Judge structure by comprehension, cohesion, coupling, and changeability.

## Readability and maintainability

Evaluate whether a competent maintainer unfamiliar with the project could reconstruct the
system's behavior.

- Naming and vocabulary consistency
- Local reasoning
- Control-flow and data-flow clarity
- Mutation and hidden side effects
- Implicit contracts and surprising behavior
- Comments and documentation
- Unnecessary indirection
- Excessive cleverness

Identify places where the code can become more obvious rather than merely more elegant.
Prefer explicit code when it substantially reduces the amount of context a reader must hold
in mind.

## Efficiency

Review efficiency in proportion to its likely importance.

- Algorithmic complexity
- Repeated work, including redundant parsing and transformation
- Excessive allocation and copying
- Unnecessary synchronization or inappropriate concurrency
- Blocking operations
- Inefficient I/O: repeated network or filesystem access, poor batching
- Inappropriate caching
- Unbounded data structures
- Avoidable startup cost
- Hot-path abstraction overhead

Do not recommend micro-optimization without evidence that it matters. Where performance
concerns are speculative, identify what should be benchmarked or measured before changing
the implementation.

## Tests

Evaluate the tests as part of the design.

- What behavior is actually protected
- Which important invariants are untested
- Whether tests are coupled to implementation details
- Whether tests make refactoring unnecessarily difficult
- Whether integration tests cover meaningful boundaries
- Whether unit tests are used where broader behavioral tests would be better
- Whether important failure modes are tested
- Whether concurrency behavior is exercised
- Whether benchmarks would be useful
- Whether fuzzing, property-based testing, static analysis, or race detection would
  materially improve confidence

Do not equate test count or coverage percentage with test quality.

## Dependencies

Review dependencies individually where important.

- Does this dependency provide enough value to justify its cost?
- Is it being used for something the standard library or existing code already handles
  adequately?
- Does it impose an architecture on the project?
- Does it significantly increase API surface, build complexity, security exposure, or
  maintenance burden?
- Is the project reimplementing something a well-established dependency should provide?
- Is the dependency current and appropriate for this language ecosystem?

Do not recommend replacing dependencies merely for the sake of reducing their number.
