---
argument-hint: "<issue-number> [issue-number...]"
description: Fixes one issue and lands it as a merged pull request — branch, implement, run the repo's own gate, open a PR that closes the issue, merge. Use when asked to fix, do, or ship a specific issue.
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
---

# Ship one issue

One issue in, one merged PR out. The mechanics — gate, push, open, merge — are a script, so
nothing reaches the remote without passing the gate. Everything else is judgment.

## 1. Read the issue before touching anything

Re-check its claims against `HEAD`. A filed issue describes a tree that has moved; fixing
what it says rather than what is there is how a PR ends up reverting someone's work.

`~/.claude/skills/issue-verify/scripts/issue-facts.sh <N>` prints the file and symbol rows
and the commits that have touched them since filing. If the finding is already fixed, say
so and close the issue — do not manufacture a change.

**Read the whole body, not the Suggested fix.** These findings routinely state a sequencing
constraint, a pinned value that will move, or a reason the obvious repair is wrong, and the
Suggested fix section is where the _last_ of that appears, not all of it.

**State a done-check and watch it fail.** One objective test of the fix — a test, a lint rule,
a `task` assertion, or a grep that must return empty — run against `HEAD` before any change.
If it already passes, the finding is stale: say so and close the issue. If no check can be
written, the issue needs a decision, not a PR — comment what is undecided and stop. Name the
check in the PR body.

## 2. Branch

```bash
~/.claude/skills/issue-pr/scripts/pr-cycle.sh start <branch>
```

Refuses on a dirty tree, syncs the default branch, and cuts from it. Name the branch for
the change, not the issue number.

**If the fix depends on a PR that has not merged, land that PR first**, then `start` from the
updated default branch. A branch cut from the unmerged parent is orphaned when the parent
squash-merges, and its rebase replays commits the trunk already has. If the two cannot land
apart, they are one PR — see below.

## 3. Implement, then run the repo's own gate

Not `go test`, not the one target you think is affected — **the repo's own gate**. It is
the only check: nothing on the PR is waited on. Do not look it up: `pr-cycle.sh` resolves it
from the release gate's profile, so a PR and a release run the same command. Half of a
typical milestone's changes move a coverage ratchet, a formatter, or a lint rule that a test
run alone never reaches. To run it before shipping, `pr-cycle.sh gate` with no argument.

Where the repo formats with a hook on file writes, remember it does not fire for writes made
through shell redirection. Run the formatter explicitly before the gate, or the gate catches
it and you have spent a gate run learning that.

Run the done-check again before the gate. It must pass now; the gate proves nothing broke,
not that this issue is fixed.

## 4. Open the PR

```bash
~/.claude/skills/issue-pr/scripts/pr-cycle.sh ship <branch> "<title>" <body-file>
```

`ship` runs the gate on the committed tree before it pushes anything. It refuses with exit `1`
when the repo has no gate. That is a gap in the profile, fixed by setting `GATE_CMD` in a
`.release-gate`, not by guessing a command. Never substitute bare `task`: in some repos the
default target commits and pushes.

**`Closes #N` goes on its own line, literally.** GitHub does not parse it inside a sentence,
and a PR whose body says "this closes the parallax issue (#69)" merges with the issue still
open. One line per issue, nothing else on it:

```text
Closes #67
Closes #69
```

**The title becomes the commit subject** wherever the repo squash-merges, which is where the
CHANGELOG gets drafted from. Write it as the line you want to read in the release notes —
declarative, no `fix:` prefix unless the repo uses one in PR titles, no issue number.

**The body is the argument, not a summary of the diff.** The diff is already in the PR. What
is not is why this repair and not the obvious one, what moved that a reviewer will not expect,
and what you measured. Where a pinned value changed, give the before and after.

## 5. The gate is the check

GitHub is a remote with PRs and issues, nothing more: no status check is required, and the
script waits on none. A workflow that still fires on the PR is not consulted. What stands
between a change and `main` is the local gate, so `ship` refuses in three cases, all exit `3`
with nothing pushed:

- The tree is dirty before the gate — it would test work the PR does not carry.
- The gate fails.
- The gate leaves the tree dirty — a formatter rewrote files the PR would ship without.

On a failure, fix on the same branch, commit, and run `ship` again. **Twice failing the same
way on one PR is where to stop and ask** rather than trying a third repair.

## Issues that cannot be their own PR

Some pairs are not separable, and the graph will not tell you — the constraint is in prose.

The signature: one issue forbids an action the other requires. _"Do not re-pin the expected
output after this step; record it once, after #69"_ means that issue, shipped alone, leaves
its own repository red. Its PR cannot pass. Ship the pair in one PR with a `Closes` line each,
and say in the body why the boundary moved.

The same applies to an issue whose resolution is another's deletion: a `duplicate`, or a
correctness finding inside code a sibling issue removes. One PR, both `Closes`.

## After it merges

Grep for what you deleted. Removing the last production call site of a helper leaves it
reachable only from its own test, and `unused` will not report that — it counts the test
call and is satisfied. If a fix orphans something,
that is a defect the fix introduced; open a follow-up rather than leaving it.

## Do not use when

- The change is not tied to an issue — just make it.
- Several issues need ordering first — this skill ships one issue and does not sequence.
  Take them one at a time, in the order their blocked-by relations allow.
