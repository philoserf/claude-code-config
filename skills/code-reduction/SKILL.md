---
argument-hint: "[path or scope]"
context: fork
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
description: Reviews a codebase for what to delete, inline, and flatten — abstractions that don't earn their keep, ceremonial types, obscuring indirection, tests of language features. Use when code has accreted structure and needs shrinking. Advisory only.
---

Review this codebase and advise on refactoring to reduce, simplify, remove, and reorganize. The goal is less code and fewer concepts, not tidier code.

Scope the review to `$ARGUMENTS` if provided, otherwise review the whole project. Examples: `src/api/`, `the test suite`, `lib/parsers/`.

Skip vendored dependencies, build output, generated code, and lockfiles (`node_modules/`, `dist/`, `vendor/`, `*.min.js`, `go.sum`).

## First, establish the license to delete

This skill assumes **sole-owner code with no backward-compatibility constraints**. That assumption is what makes aggressive deletion the right call, so check it before leaning on it: look for a published package name, semver tags, a CHANGELOG, a documented public API, or `deprecated` markers that imply someone downstream. If you find signs of external consumers, say so explicitly and mark which recommendations the constraint blocks — don't silently soften the whole review.

## What to look for

**Abstractions that don't earn their keep.** An interface with one implementation. A factory that constructs one thing. A base class extended once. A strategy pattern over two branches that never grew to three. A config object for parameters that are always the same. Count the call sites — an abstraction with one caller is a function with extra steps.

**Types that add ceremony without safety.** Wrappers whose only behavior is to hold a value of the type they wrap. Enums that mirror a set of strings without constraining anything. Type gymnastics that encode a rule the runtime doesn't enforce anyway. Ask what invalid program the type actually rejects — if the answer is "none," it's documentation with a compile step.

**Indirection that obscures rather than clarifies.** Chains of thin delegating methods. Event buses and callback registries where a direct call would do. Dependency injection for dependencies that are never substituted. Files that exist only to re-export. Trace a real request end-to-end and count the hops that make a decision versus the ones that pass a value along.

**Tests that test the language, not the business.** Asserting that a constructor assigns its arguments. Asserting a getter returns the field. Round-tripping a serializer through itself. Testing that a mock was called with what the test just told it to call. These cost maintenance and pin down nothing. Delete them; they're worse than no coverage because they inflate the number.

Look also for **near-duplication that should collapse** and **shared helpers that should split**: two call sites diverging through a flag parameter usually want to be two functions, and one helper with a mode switch usually wants to be inlined into both.

## Priority order

When two fixes compete, prefer:

1. **Deletion over renaming.** Dead code, unused exports, commented-out blocks, and abandoned feature flags go first. A better name for code that shouldn't exist is wasted work.
2. **Inlining over extracting.** Collapse single-use helpers into their caller. Extraction is the reflex that created the problem.
3. **Flattening over restructuring.** Fewer layers beats better-organized layers. Moving files between directories rearranges the problem; removing a layer solves it.

Reorganization comes last, but do recommend it where it removes a concept or shortens the path through the code — not for tidiness. It is often most obvious after a deletion, when removing a layer leaves two files that plainly belong together.

## Before recommending a deletion

Verify it's actually unused, don't infer it from a quick grep. Check for dynamic dispatch, reflection, string-keyed lookup tables, config-driven wiring, framework conventions that call by name, and entry points invoked by CI or scripts rather than by code. Say which check you ran. A confident wrong deletion costs more than the code it removed.

Where a build or test command exists, note whether the change is verifiable — "removing this is covered by `task test`" is a materially stronger recommendation than one nothing checks.

## Output

Report in the conversation, ordered by payoff — most lines removed for least risk first. For each item: the location, what it is, why it doesn't earn its place, and the concrete move (delete / inline into X / flatten Y and Z). Give an approximate line count for the whole set so the user can judge scale.

This skill is advisory and does not apply changes. It runs forked, so it cannot ask a follow-up question mid-run: when the list is long enough to work through over multiple sessions, write it to `.issues/reductions.md` and say so in the report rather than offering.

## Do not use when

- Reviewing a staged diff or recent changes rather than a whole codebase — use `/simplify`, which reviews changed code and applies the fixes
- Hunting for bugs, security issues, or missing error handling — use `code-audit` or `/code-review`
- Trying to understand why the system is shaped as it is before changing it — use `code-theory`; run it first if the design rationale is unclear, since an abstraction that looks unearned may be load-bearing for a reason the code doesn't state
