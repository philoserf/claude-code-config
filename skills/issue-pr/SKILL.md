---
argument-hint: "<issue-number> [issue-number...]"
description: Fixes one issue and lands it as a merged pull request — branch, implement, run the repo's own gate, open a PR that closes the issue, wait for CI, merge. Use when asked to fix, do, or ship a specific issue.
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
---

# Ship one issue

One issue in, one merged PR out. The mechanics — push, open, wait, merge — are a script,
because the waiting has a trap in it. Everything else is judgment.

## 1. Read the issue before touching anything

Re-check its claims against `HEAD`. A filed issue describes a tree that has moved; fixing
what it says rather than what is there is how a PR ends up reverting someone's work.

`~/.claude/skills/issue-verify/scripts/issue-facts.sh <N>` prints the file and symbol rows
and the commits that have touched them since filing. If the finding is already fixed, say
so and close the issue — do not manufacture a change.

**Read the whole body, not the Suggested fix.** These findings routinely state a sequencing
constraint, a pinned value that will move, or a reason the obvious repair is wrong, and the
Suggested fix section is where the *last* of that appears, not all of it.

## 2. Branch

```bash
~/.claude/skills/issue-pr/scripts/pr-cycle.sh start <branch>
```

Refuses on a dirty tree, syncs the default branch, and cuts from it. Name the branch for
the change, not the issue number.

## 3. Implement, then run the repo's own gate

Not `go test`, not the one target you think is affected — **the gate CI runs**. Find it in
`CLAUDE.md`; in these repos it is usually bare `task`. Half of a typical milestone's changes
move a coverage ratchet, a formatter, or a lint rule that a test run alone never reaches.

Where the repo formats with a hook on file writes, remember it does not fire for writes made
through shell redirection. Run the formatter explicitly before the gate, or the gate catches
it and you have spent a CI cycle learning that.

## 4. Open the PR

```bash
~/.claude/skills/issue-pr/scripts/pr-cycle.sh ship <branch> "<title>" <body-file>
```

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

## 5. The wait is the part that bites

`ship` blocks until at least one check row **registers**, then until every row concludes.
Both halves matter:

- `gh pr checks` exits 1 for *"no checks reported"* and for *"a check failed"* alike, so the
  exit code alone cannot tell "CI has not started" from "CI said no".
- A PR created seconds ago normally has **zero** rows. Watching immediately reports a green
  PR that CI never looked at.

The script's exit codes distinguish the outcomes: `2` nothing ever registered, `3` checks
failed, `4` still pending at the deadline. None of them merge. `merge` separately refuses a
PR with an empty check list, so skipping the wait cannot produce a quiet green merge.

On a failure, read the run, fix on the same branch, push. **Twice failing the same way on
one PR is where to stop and ask** rather than trying a third repair.

## Issues that cannot be their own PR

Some pairs are not separable, and the graph will not tell you — the constraint is in prose.

The signature: one issue forbids an action the other requires. *"Do not re-pin the expected
output after this step; record it once, after #69"* means that issue, shipped alone, leaves
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
- A whole milestone is being worked in order — `release-captain` drives this per issue and
  handles the sequencing this skill deliberately does not.
