---
disable-model-invocation: true
argument-hint: "<milestone>"
description: "Works an entire milestone unattended: verifies every open issue, sequences them by dependency, ships each as a merged PR, then stops when the milestone is empty, before release prep. User-invoked only — it merges pull requests."
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Skill
  - AskUserQuestion
---

# Release captain

Takes a milestone from filed issues to an empty milestone ready for release prep, unattended.
It merges pull requests, which is why it is user-invoked only.

Five phases in order. The release itself — version bump, CHANGELOG, regenerated documents,
tag — belongs to `release-ship`, and the user runs it.

**0. Plan** → 1. Verify → 2. Sequence → 3. Execute → 4. Stop before prep

It starts from a milestone that already exists. Producing one — sorting loose issues into
releases, recording what blocks what — is `issue-triage`, and Phase 0 checks its work rather
than repeating it.

## The autonomy contract

Decide and proceed by default. **Stop and ask only for:**

- an issue whose correct disposition is genuinely ambiguous — not merely unstated, but one
  where two readings lead to materially different work and nothing in the repo settles it;
- a fix that would change the public API;
- **CI failing twice the same way on one PR.**

Everything else is yours: which of two offered repairs to take, how to word a comment, where
a PR boundary falls, what to name a branch.

**Never park silently.** Anything left undone goes at the very top of the final report with
the reason, whether it was parked by choice, by a blocker, or because it turned out to be
someone else's decision.

## Phase 0: Plan

This skill assumes a **well-formed milestone**: every issue in it placed deliberately, with a
severity label and whatever relations are real. It does not assume they are _correct_ — that
is Phase 1.

Check that assumption first, because a milestone with gaps produces a plan with gaps:

```bash
~/.claude/skills/issue-triage/scripts/issue-meta.sh audit <milestone>
```

Exit `2` means gaps. Stop and run `issue-triage` rather than working around them — an issue
filed and never placed will not appear in this milestone at all, and nothing downstream will
notice it is missing.

Then the graph:

```bash
~/.claude/skills/release-captain/scripts/milestone-graph.sh <milestone>
```

Prints `ISSUE`, `DEP`, `ORDER` and `WARN` rows. Exit `2` means a cycle, or a blocker outside
the milestone — read the `WARN` rows before going on.

Confirm the milestone is the one meant, and that the repo is clean and on its default branch.

## Phase 1: Verify

Run the `issue-verify` skill across every open issue in the milestone. Post one comment each,
with a disposition.

This phase pays for itself on the issues that have gone stale. Expect one or two: a finding
naming two files where one has since been deleted, or a claim its author marked unverifiable
that you can now check. Both change what gets built.

## Phase 2: Sequence

Write the ordered plan to `.planning/milestone-<version>.md` **before touching code**.

The `ORDER` rows are a starting point, not the plan. They know only what GitHub records.
Add what they cannot see:

- **Prose sequencing.** _"Sequence this before #69"_ in a body that nobody entered as a
  relation. Read every body for ordering language.
- **Pairs that cannot be separate PRs** — see `issue-pr`. One issue forbidding an action
  another requires means one PR, and the plan should say so and why.
- **Shared files.** Two issues rewriting the same paragraph should be adjacent and ordered,
  so the line is edited once.
- **Deletions before the things that depend on them.** An issue about how a file is organised
  reads differently once a sibling issue has removed half its contents.

The plan names, per entry: the branch, the issues it closes, and why it sits there. Note that
`.planning/` is commonly ignored, so the file is a working artifact rather than a commit —
check `git check-ignore` rather than assuming either way.

## Phase 3: Execute

Drive `issue-pr` through the plan, one entry at a time, each branch cut fresh from the
default branch after the previous merge.

Do not batch. A merged PR per entry keeps the history readable, keeps CI honest about which
change broke what, and means an interruption leaves a coherent repository.

**A regression you introduce is yours to fix**, in its own PR, before you stop — so the
documents `release-ship` regenerates describe settled code. It does not matter that it was not in
the milestone.

## Phase 4: Stop before prep

When the milestone is empty, run `release-gate` for the target version. Expect FAIL rows
for exactly what prep clears: version consistency (the version files still hold the
released version), the missing CHANGELOG section, and the walkthrough and `CLAUDE.md` rows
once code has landed after them. Any other FAIL is real — fix it in its own PR, then re-run
the gate.

Then stop. Do not bump the version, write the CHANGELOG, regenerate documents, tag, or
create the release, and do not work through `release-ship`'s phases by hand — it is
user-invoked by design, and the user runs it.

Report:

```text
Parked:         <loudly, first, with reasons — or "nothing">
Issues closed:  <n>/<n>
PRs merged:     <list>
Tests:          <gate state, CI state, anything that does not run in CI>
Gate:           only the expected prep FAILs on <sha>
Release:        none — <version> is ready for /release-ship
```

Then say what the deviations from the plan were and why, including any PR that was not in it.

## Do not use when

- One issue is in scope — use `issue-pr`.
- You want the issues checked without the work — use `issue-verify`.
- The issues are not sorted into milestones yet — use `issue-triage` first.
- The milestone is already empty and the release is what remains — start at `release-gate`.
