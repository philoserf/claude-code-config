---
argument-hint: "[scope or focus]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
description: Builds a Naur-style theory of a codebase — the understanding needed to change it without damaging its conceptual integrity. Use when inheriting an unfamiliar system, capturing design rationale, or recovering lost design intent. Writes `THEORY.md` plus any drift and contradictions it finds to `.issues/`.
---

Build and express a theory of this codebase in the sense Peter Naur meant in "Programming as Theory Building": not a summary of what files exist, but an account of the understanding a competent maintainer would need to hold in mind to modify this system without damaging its conceptual integrity.

Scope the investigation to `$ARGUMENTS` if provided, otherwise treat the whole repository as in scope. Examples: `the scheduler`, `src/billing/`, `the plugin system`.

Skip vendored dependencies, build output, generated code, and lockfiles (`node_modules/`, `dist/`, `vendor/`, `*.min.js`, `go.sum`).

## Phase one — investigation

Read widely before you read deeply.

1. **Orient.** Entry points, build configuration, top-level module structure. Enough to know what runs and in what order.
2. **Follow the grain.** Trace a few representative flows end-to-end. A flow you can follow from input to durable effect teaches more than ten files skimmed.
3. **Read the tests.** They record which behaviors the authors considered load-bearing. A behavior with an exhaustive test suite and a behavior with none are telling you different things.
4. **Read the history.** Recent commits, design notes, ADRs, long comments. These are the decisions the authors thought worth recording — and the ones they kept revisiting.

Then hunt specifically for the places where the code **resists easy explanation**. This is where the theory lives:

- Unusual abstractions — an indirection that seems to buy nothing until you find the case it exists for
- Apparent duplication that isn't quite duplication — two things that look copy-pasted but diverge in one detail, which is the detail that matters
- Defensive checks whose triggering conditions aren't obvious — someone was burned; find out by what
- Naming that hints at a vocabulary you don't yet share — domain words used as if their meaning were settled

**Do not stop at the first coherent story you can tell.** Once you have a working theory, actively look for evidence that would complicate it. A theory that survived no contact with contradicting evidence is a guess.

## Phase two — expression

Write continuous prose addressed to a hypothetical engineer who will inherit this system next month. Technically competent, short on time. Plain prose, name things once.

Cover these, in whatever order serves clarity:

- **What the system is for**, stated in terms of the world it models rather than the technologies it uses. What are the core entities and relationships in the problem domain, and how does the code's vocabulary map onto them?
- **The organizing ideas** — the load-bearing abstractions, the invariants that must hold, the separations of concern that matter and the ones that are merely conventional. Distinguish what is essential to the design from what is incidental.
- **The seams** — where the system meets the outside world, where subsystems meet each other, and where the theory is thinnest or most contested. Which boundaries are principled and which are historical accidents?
- **What the system is shaped to accommodate**, and what would require rethinking something fundamental. If a new requirement arrived tomorrow, where would a maintainer who understood the theory look first — and where would a maintainer who didn't be likely to cause damage?
- **Your uncertainties.** Mark clearly where you are inferring intent from code alone and could be wrong, and where the code itself seems in tension with any coherent theory you can construct — possible drift, incomplete refactors, or theories that were never fully shared among the original authors.

Do not drop the uncertainties section. It is what separates a theory from a design doc, and the inheriting engineer needs to know which of your claims to trust.

## Two failure modes to avoid

**A file-by-file tour.** Restating the directory structure is documentation of the text, not theory. If a section could be replaced by `ls -R` plus one sentence per entry, cut it.

**Confident generalities.** A theory is specific to this system and should contain claims that would be false of a sibling project solving the same problem differently. **If your account could survive a global find-and-replace of the domain terms, it is not yet a theory.** Apply that test to every paragraph before you ship.

## Output

Two artifacts, and the split matters: **the theory is not a findings list, and a finding is
not the theory.**

**`THEORY.md` in the repository root** holds the theory itself. If the file already exists,
ask the user whether to overwrite it or extend it before writing anything.

**`.issues/`** holds the discrete, actionable things the investigation turned up — follow
[issues-protocol.md](../code-audit/references/issues-protocol.md), the canonical copy shared
with `code-audit` and `code-reduction`, for the file layout, finding format, dedup checks,
and re-run rules. File each with `**Source:** code-theory`. What qualifies:

- Code in tension with any coherent theory you could construct — drift, an incomplete
  refactor, two subsystems built on premises that contradict each other
- Documentation, comments, or an existing `THEORY.md`/`walkthrough.md` that state things the
  code no longer does. Verify each claim against the code and cite both sides
- An invariant the theory depends on that nothing actually enforces
- A boundary that is a historical accident being load-bearing as though it were principled

Uncertainty about intent is **not** a finding — it belongs in the theory's uncertainties
section. File something only when you can name what is wrong and what would resolve it.

You run inline, so unlike the other two skills you can ask. Still write findings to disk
rather than only reporting them; they are what the next pass dedups against.

End `THEORY.md` with the protocol's index table covering the findings you filed, so the
theory points at its own loose ends. Report to the user in the conversation only if they
asked a narrow question the document answers directly; otherwise point them at the file and
the index.

## Do not use when

- The user wants a linear code tour or an "explain how this works" narrative — use `walkthrough`, which follows the call chain and produces verifiable executable snippets. This skill answers a different question: what must I understand to change this safely?
- Reviewing code for bugs, security issues, or cleanliness — use `code-audit` or `/code-review`
- The user just wants a quick answer in conversation — this skill produces a document
- The user already understands the system and wants to know how to restructure it — use `code-refactor`, which consumes the theory this skill produces
