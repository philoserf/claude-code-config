---
argument-hint: "[milestone]"
description: Organizes filed issues into milestones and repairs their metadata — severity labels and blocked-by relations. Use when sorting a backlog, planning a release's scope, recording what blocks what, or when issues have been filed but not placed.
allowed-tools:
  - Bash
  - Read
  - Grep
  - AskUserQuestion
---

# Issue triage

The step between filing issues and working them. A finding written to `.issues/` and pushed
to GitHub arrives with a title, a body and a label; it does not arrive knowing which release
it belongs to, what it waits on, or how severe it really is. This skill supplies that.

Triage is about **placement**, not truth. Whether a finding is still correct is
`issue-verify`'s question, and a freshly filed issue usually has not had time to go stale.

## Start with the audit

```bash
~/.claude/skills/issue-triage/scripts/issue-meta.sh audit [milestone]
```

One row per open issue, then a `GAP` line for every missing piece. Exit `2` means gaps were
found. With no argument it audits the whole open backlog, which is the right way to catch an
issue that was filed and then forgotten because it belonged to no milestone.

## Deciding the milestone

The question is not "is this important" but **"what breaks if this ships in the same release
as everything else in that milestone"**.

- **A behaviour change belongs in a minor**, not a patch — including a bug fix that moves
  values callers may have pinned.
- **Anything that changes an exported signature, removes a field, or alters an output
  contract belongs in the next major**, even when the change is small. A rendering change
  that breaks anyone parsing the output is a contract change.
- **Group by the seam they touch, not by size.** Five issues about one boundary are worth
  one release that fixes the boundary; spread across three releases they are three partial
  rewrites of the same code.
- **Leave it unmilestoned rather than guess.** An issue with no milestone is visible in the
  audit. One in the wrong milestone silently widens a release's scope.

```bash
issue-meta.sh milestone v5.0.0 96 104
```

Where the call is genuinely the maintainer's — an accuracy fix that could be a minor or
could wait for the major already in flight — ask, with the two framings. Do not decide it by
what is convenient to do next.

## Recording what blocks what

```bash
issue-meta.sh block <blocked> <blocker>
issue-meta.sh unblock <blocked> <blocker>
```

**The API takes the blocking issue's database id, not its number** — `{"id":5406149848,
"number":71}`. The script resolves it; a hand-rolled `gh api` call passing the number is
rejected. It also needs `-F` rather than `-f`, because the field is typed as an integer and
a string is refused.

Record a relation when **one issue's work cannot start, or cannot be correct, until the
other lands**. That is narrower than "related":

- A deletion that removes the code another issue is about — the deletion blocks it, and
  frequently _closes_ it.
- A duplicate: it is blocked by the issue that supersedes it, and closes on that PR.
- A fix that re-pins values a second fix will move again — the first blocks the second, so
  the values are recorded once.

Do **not** record a relation for issues that merely touch the same file. That is ordering
information, and it belongs in the plan `release-captain` writes, not in the graph. Over-
recording turns a useful constraint into a chain that forbids parallel work.

**Sequencing stated only in prose is invisible to every tool.** When a body says _"sequence
this before #69"_ and no relation exists, this is the moment to create it — otherwise the
next reader gets an order that looks unconstrained and is not.

## Severity

The severity label is the priority; nothing else carries it. A missing label is a `GAP` in the
audit, so set one on every issue you place.

**Promote `severity:high` to `severity:critical` when the finding is silent data loss or
corruption** — the user loses work, or gets a wrong answer, without being told. The audit
cannot judge "silent"; the promotion is made by hand, here. If the repo has no
`severity:critical` label yet, create it rather than leaving the issue at high.

## Every issue gets a disposition

A triage pass that leaves issues untouched has not triaged them. For each one: placed in a
milestone, deliberately left unmilestoned with a reason, or closed. **List anything parked,
explicitly, at the end** — a backlog's real cost is the issues nobody decided about.

## Do not use when

- The issues need checking against the code rather than sorting — use `issue-verify`.
- A milestone is already well-formed and the work is what remains — use `release-captain`,
  whose first phase is verification, not placement.
