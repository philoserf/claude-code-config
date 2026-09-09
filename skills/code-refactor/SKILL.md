---
argument-hint: "[scope or focus]"
effort: high
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
description: Produces a target design and an incremental migration sequence for a codebase, backed by an architectural review. Use when asked how a system should be refactored, restructured, or reorganized, or what it should look like afterward. Writes its findings and plan to `.issues/`; recommends changes but does not apply them.
---

Conduct a deep technical review of this codebase with the goal of determining how it should
be refactored.

**Do not begin by changing code.** First understand the system as it exists: what problem it
solves, how it is organized, what constraints appear to have shaped it, and where its
current design helps or hinders future work. This is an architectural and implementation
review, not a linting exercise.

Do not assume that more abstraction, more layering, more interfaces, more files, or more
design patterns constitute improvement. Prefer the simplest design that accurately expresses
the domain and satisfies the real requirements.

Scope the review to `$ARGUMENTS` if provided, otherwise treat the whole repository as in
scope. Examples: `the storage layer`, `cmd/`, `the plugin system`.

Skip vendored dependencies, build output, generated code, and lockfiles (`node_modules/`,
`dist/`, `vendor/`, `*.min.js`, `go.sum`).

## Phase one — understand before recommending

Read [review-dimensions.md](references/review-dimensions.md). It carries the checklists for
the problem domain, the repository survey, ecosystem conventions, correctness, architecture,
readability, efficiency, tests, and dependencies. Work the dimensions that this codebase
actually raises; a dimension with nothing to report gets no section in the output.

**Start with what the repository already knows about itself.** `THEORY.md`, `.issues/`, an
existing `WALKTHROUGH.md`, ADRs and design notes are evidence, and prior passes by sibling
skills are the cheapest context available:

- If `THEORY.md` exists, read it first and treat it as a hypothesis, not a fact. Verify its
  central claims against the code. Where it is right, build on it instead of re-deriving the
  domain. Where it is wrong, that is a finding.
- If `.issues/` exists, read all of it. Known correctness bugs are input to the target
  design — a module you are proposing to delete makes its open bugs moot, and that is worth
  saying.

Only where neither exists do the domain and repository survey yourself, and do them as input
to the target design rather than as a deliverable. This skill does not write `THEORY.md`.

Trace several representative operations end to end. Pay particular attention to boundaries
between components — many important design problems occur at boundaries rather than inside
individual functions.

## Phase two — judge

Identify what the codebase does well before considering major changes. **Preserve good
decisions unless there is a concrete reason to replace them.**

Distinguish demonstrated defects from plausible risks. Do not label something a bug merely
because it could be written differently.

### Refactoring philosophy

The desired outcome is not a theoretically perfect architecture. It is a smaller, clearer,
more correct, more idiomatic system whose structure reflects the actual problem.

Favor refactorings that reduce concepts, reduce indirection, clarify ownership, make
invariants explicit, make state transitions easier to understand, improve locality, expose
important behavior through clearer APIs, remove duplication of knowledge, separate genuinely
independent concerns, consolidate things that should never have been separated, make tests
easier to write at meaningful boundaries, and reduce the number of ways the same task can be
accomplished.

**Be suspicious of refactorings that merely move complexity around.**

## Phase three — write it up

Two artifacts, and the split is the thing most easily gotten wrong: **a finding is a defect
at a location; the design is what the system should become.**

Both live under `.issues/`: the findings as their own files, everything else as the overview
at `.issues/000-refactor.md`. Nothing goes to the repository root. A refactoring plan is
working state that expires the moment it is executed — it does not belong beside the
standing documents (`README.md`, `CLAUDE.md`, `THEORY.md`, `WALKTHROUGH.md`), which answer
questions that stay answered.

### Findings → `.issues/`

Follow [issues-protocol.md](../code-audit/references/issues-protocol.md), the canonical copy
shared across the `code-*` review skills, for the file layout, finding
format, dedup checks against `.issues/` and GitHub, and re-run rules. File each with
`**Source:** code-refactor`.

A finding is a specific problem at a specific location — a correctness risk, a cohesion or
coupling failure, an abstraction that leaks, a dependency that does not earn its cost. The
severity bands below map onto the protocol's scale: Critical → `critical`, High value →
`high`, Medium value → `medium`, Low value → `low`.

For every significant finding, cover:

1. What you observed
2. Where it appears in the code
3. Why it matters
4. Whether it is a correctness, design, maintainability, performance, ecosystem-convention,
   or operational issue — or some combination
5. The proposed direction of change
6. The likely benefit
7. The cost, risk, or trade-off of making the change
8. Your confidence in the recommendation

Use specific files, packages/modules, types, functions, and execution paths as evidence.
Avoid generic advice that could apply to any repository.

Classify roughly as **Critical** (probable correctness, security, data-loss, or serious
reliability problems), **High value** (architectural or design changes likely to
substantially improve the system), **Medium value** (worthwhile simplifications or
maintainability improvements), or **Low value** (cleanup, polish, minor idiomatic
improvements, speculative optimization).

**Do not inflate severity.** A long list of minor style observations should not obscure a
small number of consequential design problems.

### The overview → `.issues/000-refactor.md`

Regenerated in place on each pass, per the protocol. Cover, in this order:

**The system as you understand it.** Concise, in terms of the problem it solves rather than
the technologies it uses. Then the current architecture, explained against that problem.

**What the codebase does well.** Before the changes. Specific, not courtesy.

**The target design.** Not a list of local fixes — what the codebase should look like after
refactoring: the proposed conceptual model, major packages/modules/components, ownership of
important state, principal interfaces and boundaries, dependency direction, major data
flows, error propagation, concurrency model if relevant, configuration model, where domain
logic should live, where infrastructure concerns should live, which existing abstractions
remain, which disappear, and which new ones are justified.

Prefer an evolutionary target that can realistically be reached from the current repository.
**If the existing architecture is already fundamentally sound, say so** and recommend
localized improvement rather than redesign.

**The refactoring sequence.** The target design as an incremental migration plan that keeps
the codebase working throughout wherever reasonably possible. Per stage: the objective,
affected areas, prerequisites, tests or safeguards required first, specific changes, expected
simplification, risks, and how to tell the stage is complete.

Order the work so early changes reduce uncertainty or make later changes safer. Separate
behavior-preserving refactoring from intentional behavioral changes. Where possible,
establish tests around existing behavior before restructuring it.

**What not to change.** Explicitly identify areas that may look imperfect but should probably
remain as they are, and why. A useful review protects good existing decisions as well as
identifying bad ones.

**Unresolved questions.** Questions that materially affect the recommended architecture but
cannot be answered from the repository alone. **Do not use unresolved questions as an excuse
to avoid conclusions the available evidence supports.**

End with the protocol's index table covering the findings you filed.

## What to optimize for

Be concrete, skeptical, and evidence-driven. Do not perform a wholesale rewrite merely
because a cleaner design can be imagined. Do not optimize for novelty.

Optimize for correctness, simplicity, idiomatic use of the language, clarity of the domain
model, ease of reasoning, and reduced long-term maintenance cost.

This skill is advisory and does not apply changes. You run inline, so ask when a question
would change the recommendation — but write both artifacts to disk rather than only
reporting them.

## Do not use when

- The user needs to understand the system before changing it — use `code-theory`, which
  builds the theory this skill consumes. Run it first when no `THEORY.md` exists and the
  design rationale is unclear
- The ask is how the system runs today, told linearly — use `code-walkthrough`
- The ask is a bug and security sweep rather than a design — use `code-audit` or
  `/code-review`
- The ask is deletion — what to remove, inline, and flatten, with no target architecture
  behind it — use `code-reduction`
- Reviewing a staged diff or recent changes — use `/code-review` for defects, `/simplify` to
  apply cleanups
- The architecture is already sound and the user wants it changed anyway. Say it is sound
  and stop; that is the finding
