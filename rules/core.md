# Core Engineering Rules

## Purpose

Mandatory construction-quality rules for all code generation, edits, and reviews.
Load this file for every task. Load specialist modules alongside it when the task involves architecture, domain modeling, data systems, production operations, or legacy/refactoring work.

---

## Primary Directive

When uncertain, choose the option that:

1. reduces the number of facts a reader must hold at once
2. puts each business rule in one authoritative place
3. keeps volatile details behind stable boundaries
4. makes intent clearer to future maintainers
5. preserves behavior during structural change

Reject designs that merely appear simpler by hiding complexity in callers, frameworks, databases, global state, or operational assumptions.

---

## Conflict Resolution

Apply these rules when principles appear to disagree.

### Small Functions vs Deep Modules

- Prefer small units when they clarify intent, isolate responsibility, or simplify testing.
- Avoid chains of tiny pass-through functions that force readers to jump constantly.
- A module may contain internal complexity when its public interface is small, meaningful, and stable.

### DRY vs Premature Abstraction

- Remove duplicated knowledge, not merely duplicated text.
- Centralize business rules, validation semantics, mappings, and calculations.
- Keep similar code separate when the similarity is coincidental or the shared abstraction would be vague.

### Boundaries vs Overengineering

- Introduce boundaries around volatility, external systems, and cross-context translation.
- Do not add layers that only forward calls.
- Every abstraction must reduce coupling, hide complexity, clarify ownership, or protect a contract.

### Comments vs Self-Documenting Code

- Improve names and structure before adding comments.
- Use comments for contracts, invariants, rationale, non-obvious constraints, and external protocol assumptions.
- Delete comments that narrate obvious code or describe obsolete behavior.

---

## Naming Rules

- Use intention-revealing names that describe purpose, role, or domain meaning.
- One term for one concept inside a boundary. One term must not carry multiple meanings.
- Avoid misleading, vague, abbreviated, or visually confusable identifiers.
- Avoid type prefixes, Hungarian notation, and implementation encodings.
- Class and module names: nouns or noun phrases. Function names: verbs or verb phrases.
- Use problem-domain names for domain concepts, solution-domain names for technical concepts.
- Rename when understanding improves.

Avoid: `Manager`, `Processor`, `Handler`, `Helper`, `Util`, `Common`, `Data`, `Info`, and `Service` when a more precise term exists.

---

## Function and Routine Rules

- Each routine should have one coherent purpose at one level of abstraction.
- Keep interfaces small and hard to misuse.
- Minimize parameters. Replace repeated parameter groups with meaningful objects.
- Avoid boolean flag parameters; split behavior or model the mode explicitly.
- Separate commands from queries. A function that answers a question should not mutate state.
- Eliminate hidden side effects.
- Isolate error handling from the main path.
- Prefer guard clauses when they clarify the happy path.
- Split parsing, validation, computation, I/O, and formatting when they are conceptually different.
- Delete dead code instead of commenting it out.

---

## Variable and Data Rules

- Keep scope as small as practical.
- Initialize deliberately.
- Prefer immutability when mutation adds no value.
- Use constants, enums, value objects, or richer types instead of magic values and unexplained sentinels.
- Expose units, meaning, and lifecycle in names.
- Encapsulate mutable state behind intention-revealing operations.

---

## Control Flow Rules

- Prefer straightforward control flow over clever control flow.
- Keep nesting shallow.
- Replace complicated boolean logic with named predicates or clearer structure.
- Use table-driven or data-driven logic for stable explicit mappings.
- Remove impossible paths and dead branches.
- Use polymorphism, strategies, or tables only when they reduce real repeated branching.

---

## Defensive Programming and Error Handling

- Validate input at trust boundaries.
- Use assertions for programmer assumptions, validation for external input, domain errors for expected business failures.
- Distinguish recoverable conditions, permanent failures, and programming errors.
- Do not silently continue from corrupted or impossible state.
- Provide enough error context for diagnosis.
- Keep cleanup and shutdown paths correct and visible.
- Do not return or pass null-like sentinels when a safer model exists.

---

## Module and Interface Design

- Treat complexity as a defect risk.
- Watch for change amplification, cognitive load, unknown unknowns, and hidden dependencies.
- Put complexity in one place rather than many.
- Hide volatile decisions behind stable interfaces.
- Prefer a slightly more complex implementation when it makes many callers simpler.
- Eliminate special cases by improving interfaces or invariants where possible.

### Deep Modules

- Prefer deep modules: simple public interface, substantial hidden value.
- Avoid shallow modules that only rename or forward calls.
- Design interfaces around what clients need, not how the implementation works.
- Keep public APIs small, semantic, and hard to misuse.
- Avoid call-order traps, half-initialized objects, and mode parameters that expose internals.

### Cohesion and Coupling

- Each module should have a focused reason to change.
- Keep related concepts close. Split modules that accumulate unrelated behavior.
- Prefer composition over complex inheritance unless inheritance is clearly simpler.
- Minimize global state, ambient context, and shared mutable state.

---

## Testing Rules

- Treat tests as production-quality code.
- Tests must be readable, deterministic, maintainable, and self-checking.
- Each test should communicate one main idea.
- Prefer simple setup and clear assertions.
- Avoid brittle tests coupled to irrelevant implementation details.
- Tests should be isolated and order-independent.
- Add or update tests for behavior changes, bug fixes, and significant contracts.
- When fixing a bug, add a test that would have caught it when feasible.
- Run relevant validation before finishing.

---

## Change Workflow

For every non-trivial task:

1. Understand the requested behavior and the affected area.
2. Identify the safety net: tests, types, assertions, or manual checks.
3. Identify the simplest change that preserves or improves structure.
4. Make preparatory refactors only when they make the change safer or clearer.
5. Implement the change in small reviewable steps.
6. Add or update proportionate tests.
7. Review the diff for duplication, naming, boundary leaks, and hidden assumptions.
8. Stop when the change is done and further cleanup would be speculative.

Do not silently broaden scope beyond the task.

---

## Forbidden Patterns

- Clever code that is hard to inspect.
- Shallow pass-through layers and wrappers that add names but no simplification.
- One more flag, callback, or conditional instead of a better abstraction.
- Speculative frameworks, interfaces, or hierarchies before a real need exists.
- Generic `utils`, `helpers`, `common`, or `shared` packages as design escape hatches.
- God classes and god services.
- Duplicated business rules across UI, API, services, database, and jobs.
- Comments compensating for bad names, poor decomposition, or confusing control flow.

---

## Output Expectations

When making changes:

- Briefly state what changed.
- State what tests or checks were run.
- Call out unresolved risks, assumptions, or trade-offs.
- If a requested change conflicts with these rules, follow the user request but mention the conflict explicitly.
