---
disable-model-invocation: true
argument-hint: "<milestone>"
description: "Works an entire milestone unattended: verifies every open issue, sequences them by dependency, ships each as a merged PR, then brings the release to the point of tagging and stops. User-invoked only — it merges pull requests."
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

Takes a milestone from filed issues to a tagged-ready release, unattended. It merges pull
requests, which is why it is user-invoked only.

Five phases in order. Phases 1–3 are this skill's work; phases 4–5 hand off to the two
release skills rather than reimplementing them.

**0. Plan** → 1. Verify → 2. Sequence → 3. Execute → 4. Prep → 5. Stop at the tag

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
severity label and whatever relations are real. It does not assume they are *correct* — that
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

- **Prose sequencing.** *"Sequence this before #69"* in a body that nobody entered as a
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

**A regression you introduce is yours to fix**, in its own PR, before the prep PR — so the
documents that get regenerated describe settled code. It does not matter that it was not in
the milestone.

## Phase 4: Prep

When the milestone is empty, run `release-gate` for the target version. Two FAIL rows are
expected and are what prep exists to clear: the CHANGELOG section that does not exist yet,
and the walkthrough that code has landed after.

Then the prep PR — **one branch, one commit**: the version bump, the CHANGELOG section, and
the standing documents regenerated together.

**It has to be one PR.** The gate counts code commits made *after* the walkthrough and
`CLAUDE.md` were last committed. Split them and whichever lands second dates the other, so
the walkthrough row fails by construction. This is also why the documents are release-time
work: four that cross-reference each other can only be made consistent from a settled state,
all at once.

`release-ship` owns this pattern in detail, including repos where the version lives in a file.
Follow its phases 1–5 rather than inventing a second procedure. Where the repo has no version
source, the CHANGELOG section *is* the bump, and the gate must be given the version as an
argument.

**Verify every quoted snippet after the formatter runs, not before.** Prose reflows and
fenced blocks may be rewritten; a snippet checked pre-format is a snippet unchecked. Extract
them programmatically from the source and assert each is a verbatim substring.

## Phase 5: Stop at the tag

Re-run `release-gate` against the merged commit and require **exit 0**.

Then stop. Do not tag, do not create the release, and do not work through `release-ship`'s
later phases by hand — it is user-invoked by design, and the user runs it.

Report:

```text
Parked:         <loudly, first, with reasons — or "nothing">
Issues closed:  <n>/<n>
PRs merged:     <list>
Tests:          <gate state, CI state, anything that does not run in CI>
Docs drift:     <how the snippets were verified>
Gate:           exit 0 on <sha>
Release:        none — <version> is ready to tag; /release-ship is yours to run
```

Then say what the deviations from the plan were and why, including any PR that was not in it.

## Do not use when

- One issue is in scope — use `issue-pr`.
- You want the issues checked without the work — use `issue-verify`.
- The issues are not sorted into milestones yet — use `issue-triage` first.
- The milestone is already empty and the release is what remains — start at `release-gate`.
