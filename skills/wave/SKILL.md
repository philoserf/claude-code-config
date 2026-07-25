---
disable-model-invocation: true
description: Runs a batched bug-fix wave end to end — plan, human approval, parallel execution, /simplify, /code-review --fix, PR, merge. Use when shipping a batch of issues together, working a backlog in waves, or when asked to "plan and ship these issues".
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Agent
  - Skill
  - Workflow
  - ExitPlanMode
  - AskUserQuestion
---

# Wave

Ship a batch of related issues as one reviewed, merged change.

The value is not the step list — it is the failure modes each step exists to catch. Every
"Do not" below is something that actually went wrong and cost real time. Read them as
findings, not etiquette.

## Phase 0 — Select the batch

Pick issues that are **file-disjoint** where possible, and group ones that touch the same
hunk into a single branch. Two agents editing the same three lines will conflict; two
agents fixing the same function in different ways will produce a merge that satisfies
neither issue.

**Shared fixtures bind harder than shared files.** Two issues in different packages that
move the same golden/snapshot cannot be parallelized at all: each agent re-derives the
fixture against its own change, and the results are unmergeable by inspection — you
cannot diff two hand-traced expected values into a third. Check what each candidate
would force to be re-derived, not just what it edits. When several issues share one
fixture, the wave is sequential and re-derives it **once**, at the end.

Hold back issues that:

- **rewrite the same expression or re-trace the same fixture** as another issue — those
  belong together in their own wave, or they get done twice
- **depend on a decision, not code** — an unresolved ambiguity is not a bug fix. Surface it
  for a ruling and leave it filed.
- **another in-flight issue is about to change** — sequence them, don't parallelize them.

### Verify every issue still reproduces before assigning it

Non-negotiable. Stale issues are common: a bug gets fixed as a side effect, or drifts into a
different bug, and nobody closes the ticket. Confirm the described defect exists **in the
current tree** before writing a brief for it. Issues that no longer reproduce get closed
with an explanation, not assigned.

Related: **issue bodies carry stale `Location:` lines.** Locate code by symbol name, never
by the line number in the ticket.

## Phase 1 — Plan, then stop for human review

Produce a plan that names, per group: the issues, the files, the expected test movement,
and the decisions to settle **in the brief rather than mid-edit**. A design question
discovered halfway through an edit gets answered badly.

Call `ExitPlanMode` and wait. Do not begin work on an unapproved plan. The plan review is
where a wrong grouping gets caught for free — after execution it costs a rebase.

State explicitly in the plan:

- which issues are held back and why
- any file overlap between groups that needs sequencing
- which goldens/fixtures are expected to move, with the reason

## Phase 2 — Execute in parallel

One agent per group, launched in a single message so they run concurrently. Prefer
`isolation: "worktree"` when agents write to the tree.

Every agent brief carries these constraints:

- **Verify the issue reproduces before fixing it.**
- **Do not `git checkout`.** In a shared checkout an agent switching branches silently moves
  everyone else's ground. Check `git branch --show-current` after each agent returns.
- **Fixtures/goldens pass untouched** unless the agent's own analysis predicted the move,
  with the new value re-derived and shown. A changed expected-value with no derivation is a
  defect, not a fix.
- **State the blast radius**: for deterministic generators, whether the change alters the
  random-draw sequence.
- Report what was _not_ fixed and why.

### Do not broad-`git add` while agents are writing

`git add internal/` will sweep in an agent's scratch file. Stage explicit paths, and read
`git status --short` before every commit. Recovering from a committed scratch file is
`--amend` at best and a revert at worst.

## Phase 3 — /simplify, then /code-review --fix, in that order

Both. In that order. This is the step most worth keeping.

Each pass finds what the other cannot, **because the second runs against the first's
output**. Chains of incomplete fixes terminate here: a fix that validates only the endpoints
of a range, a predicate that over-generalizes and silently drops data, a guard deleted along
with the dead branch beside it.

`/simplify` is not safe-by-construction. It can introduce regressions — collapsing two
things that looked alike when only one was dead. That is precisely why `/code-review` runs
after it and not before.

Apply findings, but **skip with a note** rather than argue: a finding whose fix would change
intended behavior, reach well outside the diff, or undo a deliberate design. Say which and
why in the commit.

### Verification must be non-vacuous

A green suite after a fix proves nothing on its own. For any behavioral fix, **show the new
test failing without it**:

```sh
git stash push -q <file-with-the-fix>
grep -c '<the new guard>' <file>     # assert it is actually gone: expect 0
go test ./pkg/ -run TheNewCase       # expect FAIL, and read the message
git stash pop -q
```

**Scrutinise every assertion of a negative.** A check for the ABSENCE of something —
no output, no seed line, an expected panic, a skipped row — passes when the mechanism it
depends on is missing. Ask what *else* produces that same absence: an expected-panic test
whose helper panics at construction passes with no guard under test; an exit-code check
passes on a crash if the crash exits with the same code. Assert the reason, not the
symptom — match the panic message, not that it panicked. And never add a sentinel that
opts a row out of a check; delete the row or assert it.

Three separate vacuous comparisons happened in one session — a `cd` that broke module
lookup, an unquoted variable that didn't word-split, and a `git stash` that left both runs
on the same code. Two more followed: a `git merge` piped through `head`, which masks git's
exit code and reported four failed merges as "ok", and an unconditional `echo "suite
green"` printed after a grep that had output. Each produced a confident, wrong "verified". If a check _can_ pass for the
wrong reason, make it assert the precondition too.

## Phase 4 — PR

Body names what changed and why, the findings from both passes, and what was deliberately
**not** fixed (with issue numbers for anything filed instead).

Closing keywords:

- **Derive the list from the wave's COMMITS, not from a count of its issues.** An issue
  once shipped fixed — by a commit naming it in the subject — and stayed open for two
  waves, because the list was written from "this wave is 14 issues" instead of from
  `git log`. Walk the commits, collect the numbers, then check each one's state.
- **One `Closes #N` per line.** `Closes #1, #2` closes only the first.
- **Never put a closing keyword near an issue number that must stay open.** A squash can
  collapse "not fixed: #299" into text that auto-closes a live bug. Write those as bare
  references, well away from any keyword.
- **Verify each number's title and state before writing its line.** Confirm it is the issue
  you think it is and that it is still open.

After merge, re-check that the deferred issues are still `OPEN`. A wrongly-closed live bug
is invisible until someone hits it again.

## Phase 5 — Merge

Confirm CI is green, then merge. Respect the repo's merge policy (a ff-only repo needs
`--no-ff` passed explicitly; squash-merge repos need it too).

Report: the merge SHA, issues closed, issues filed, and the backlog delta.

## Branch hygiene

Squash-merged branches will **not** show as `--merged`, because their commits never appear
in the target. Neither `--merged` nor reverse-applying the patch reliably proves the work
shipped — the latter fails for any branch a later wave then edited.

So before deleting local branches, check whether they exist on the remote. If they do not,
there is no copy to recover from:

```sh
git bundle create ~/<repo>-branches-$(date +%Y%m%d).bundle --branches
git bundle verify ~/<repo>-branches-$(date +%Y%m%d).bundle
# confirm every tip is captured, THEN delete
```

Say plainly that the evidence a branch shipped is the PR/issue record, not a content check.
Do not claim a mechanical check proved something it cannot prove.
