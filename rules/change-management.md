# Change Management Rules

## Purpose

Specialist module for refactoring discipline and working with legacy code. Load alongside `core.md` when a task involves restructuring existing code, breaking dependencies in poorly tested systems, or preparing legacy code for safe modification.

This module governs how structural change happens — the mechanics, sequencing, safety techniques, and judgment calls that determine whether a codebase improves or just churns.

---

## Primary Directive

When modifying existing code, do not start by rewriting large areas. Start by making the next safe structural improvement that makes the desired change easier.

Default sequence:

1. establish a safety net
2. make a preparatory refactoring
3. make the functional change
4. refactor again if needed
5. stop when friction is removed

Reject changes that bundle large functional changes with unrelated structural churn.

---

## What Counts as Refactoring

Refactoring means: changing structure without changing external behavior, applying small composable transformations, removing code smells before or during feature work, making the next change easier.

Refactoring does not mean: large rewrites, unverified cleanup, "modernization" with unclear behavioral impact, or mixing architecture migration, feature work, and cleanup in one patch. Do not call a change a refactor when it changes behavior.

---

## Behavior Preservation

- Refactorings must preserve observable behavior.
- If behavior must change, isolate the behavior change from structural refactoring.
- Never disguise a feature change as a refactoring.
- Keep the system runnable and buildable at every intermediate step where practical.

---

## Small Steps

Prefer many small safe edits over one large transformation. Each step should be understandable and reversible. If a patch feels too large to reason about locally, split it.

---

## Preparatory Refactoring

Before implementing a feature, ask:

- What makes this change awkward?
- What local structural change would make it straightforward?
- Can I rename, extract, move, split, or inline first?

Do the preparatory refactoring before the feature change. After the feature lands, clean remaining structural debt the change introduced.

---

## Stopping Rules

Stop refactoring when:

- the requested change is easy to implement
- the main friction blocking change is removed
- further cleanup would be speculative
- the next abstraction is not yet justified by a second real need
- readability and local changeability are clearly improved

---

## Code Smells

Actively look for these when modifying code:

- **Duplicated logic** — extract shared behavior, but do not abstract coincidental similarity.
- **Long functions** — split when they mix responsibilities, abstraction levels, or phases.
- **Long parameter lists** — replace clumps with parameter objects; remove boolean flags that switch behavior.
- **Global data** — reduce reliance on globals, singletons, and ambient context; make dependencies explicit.
- **Divergent change** — if one class changes for many different reasons, split responsibilities.
- **Shotgun surgery** — if one change forces edits across many files, centralize the knowledge.
- **Feature envy** — if a method mostly manipulates another object's data, move it or reshape the model.
- **Data clumps** — replace repeated primitive bundles with meaningful types.
- **Primitive obsession** — give recurring business concepts names and validation.
- **Switch/type conditionals** — reduce repeated branching on type or mode when polymorphism, tables, or strategies fit. Do not replace a single honest conditional with needless indirection.
- **Temporary fields** — remove fields that exist only for unusual code paths; prefer explicit state modeling.
- **Middle man** — remove forwarding layers that add no value.
- **Speculative generality** — delete abstractions created "just in case" that are not earning their keep.

---

## Preferred Refactoring Moves

- **Rename** variables, functions, types, and modules to reveal intent. Rename before deeper refactoring when bad names block understanding.
- **Extract function** when a block has a coherent purpose.
- **Extract variable** when an expression hides meaning.
- **Extract class or module** when one unit has multiple reasons to change.
- **Move behavior** to the module or type where the data or concept lives.
- **Inline** accidental abstractions and unnecessary layers.
- **Guard clauses** to replace nested conditionals where it improves clarity.
- **Encapsulate state** behind intention-revealing operations.
- **Parameter objects** for repeated argument groups.

Avoid creating micro-method noise with no explanatory value.

---

## Legacy Code Definition

Legacy code is code that is expensive to change safely. The default assumption:

**If code lacks trustworthy tests, treat it as legacy code.**

Do not begin with a rewrite unless explicitly required.

---

## Legacy Workflow

1. Identify the exact area affected.
2. Determine whether trusted tests already protect the behavior.
3. If not, add characterization tests around current behavior where feasible.
4. Identify the dependency that makes change difficult.
5. Find or create a seam.
6. Break the blocking dependency.
7. Make the requested change.
8. Refactor locally for clarity and testability.

Do not start by cleaning the whole module.

---

## Characterization Tests

Use characterization tests when current behavior is uncertain. Capture what the code does today, even if the behavior is ugly.

- Test externally visible behavior first.
- Prefer narrow tests around the slice being modified.
- Capture ugly behavior if real consumers rely on it.
- Once behavior is protected, improve structure safely.

---

## Seams

A seam is a place where behavior can be changed without editing surrounding code directly. Use seams to inject doubles, isolate dependencies, and observe behavior.

Useful seam types: constructor injection, parameter injection, extracted method, wrapper around static or global access, adapter around framework objects, factory indirection, module boundary, import seam, subclass seam (only when forced by language constraints).

- Use the smallest seam that unlocks the change.
- Prefer explicit seams over magical test hooks.
- Prefer seams that remain useful after the current task.
- Create seams near hard dependencies, not randomly in the code.

---

## Dependency Breaking

When legacy code is hard to test, look for these dependency types:

**Hidden inputs** — current time, random values, environment variables, thread-local state, static singletons, global configuration, implicit current user or request.

**Hard outputs** — direct file writes, direct network calls, process exits, direct database writes, direct message publication.

**Construction problems** — constructors that do real work, complex collaborator allocation buried inside methods, factory calls hidden deep in behavior.

Required moves: wrap static and global access, inject clocks/RNGs/gateways/repositories, split construction from use, extract side effects behind explicit collaborators, narrow the code under test to a manageable slice.

---

## Legacy Techniques

- **Sprout method** — extract new behavior into a new method; keep old code mostly untouched.
- **Sprout class** — add a focused new collaborator when the old class is too risky to reshape.
- **Wrap method** — add pre/post behavior or observability around a risky method.
- **Wrap class** — mediate behavior when the original class is too hard to test directly.
- **Extract and override** — last resort when language constraints leave few better options.

Every legacy change should leave the area more observable, testable, or modular.

---

## Commit Discipline

- Separate structural edits from behavior changes whenever practical.
- Group related refactorings together.
- Avoid giant mixed commits that rename, move, redesign, and change logic all at once.
- Prefer reviewable sequences of transformations.

---

## Testing

- Add characterization tests before risky edits when behavior is unclear.
- Add focused tests for new behavior.
- Keep old behavior tests unless the behavior change is intentional.
- Never delete a failing test just to complete a refactoring.
- Refactor tests too when they become noisy, duplicative, or misleading.
- If tests are absent and cannot be added quickly, keep changes smaller and improve testability first.

---

## Review Checklist

Before finalizing any change involving refactoring or legacy modification, verify:

- Did we preserve observable behavior during structural changes?
- Did we separate structural edits from behavior changes where practical?
- Did we treat untested code as risky legacy code?
- Did we capture current behavior where it was unclear?
- Did we create or exploit a seam where dependencies blocked testing?
- Did we reduce at least one real source of friction or hard dependency?
- Is the changed area easier to test than before?
- Did we avoid a rewrite as the first move?
- Did we keep edits local to the requested change?
- Did we avoid speculative abstraction?
- Did we avoid a giant mixed patch?

If any answer is no, revise before shipping.

---

## Forbidden Patterns

- **Big-bang rewrite** — replacing a working subsystem wholesale before understanding current behavior.
- **Mixed-intent patches** — behavior changes hidden inside cleanup; code motion that makes review impossible.
- **Abstracting too early** — introducing interfaces or hierarchies before a second real need; replacing understandable duplication with unclear shared code.
- **Refactoring theater** — renaming things while deeper design problems remain; introducing patterns instead of removing complexity.
- **Untested structural surgery** — large refactors without any safety net; "cleanup" on fragile code with no verification strategy.
- **No-safety change** — changing legacy code with no tests or observation strategy; relying on manual reasoning alone for risky behavior.
- **Hidden dependency expansion** — adding more globals, statics, or framework reach-through in already hard-to-test code.
- **Cosmetic-only refactoring** — renaming and formatting while leaving real dependency knots intact.

---

## Output Expectations

When modifying legacy or refactoring-heavy code, Claude must:

- State how behavior was protected (characterization tests, existing coverage, type system, or explicit scope limitation).
- State which seams or dependency breaks were introduced.
- Call out areas that remain risky or untested after the change.

---

## Final Instruction

When uncertain, choose the smallest change that increases understanding, increases testability, breaks one hard dependency, preserves current behavior, and makes the next change cheaper. Reject big rewrites and heroic cleanup when a seam and a test would do.
