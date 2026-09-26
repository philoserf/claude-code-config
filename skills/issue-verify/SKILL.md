---
description: Re-reads open issues against the current tree and posts a verification comment on each, flagging anything already fixed, partly stale, or wrong to do. Use before acting on a backlog, triaging a milestone, or when asked whether filed issues are still real.
allowed-tools:
  - Bash
  - Read
  - Grep
---

# Issue verification

An issue is a claim about a tree that has since moved. This skill re-reads each one against
current `HEAD`, decides whether the claim still holds, and writes that decision down where
the next reader will find it — on the issue.

Verification is not agreement. The output is a disposition for every issue looked at, and
"this was fixed three commits ago" is as useful a result as "still stands".

## Gather the facts first

```bash
~/.claude/skills/issue-verify/scripts/issue-facts.sh <N> [N...]
```

Per issue it prints the metadata, then rows you can grep:

```text
FILE   present|MISSING   <path>      every source path the body names
SYMBOL present|MISSING   <name>      every backticked identifier
SINCE  filed at <sha>; <n> commit(s) touched its files since
DEP    blocked_by #N [in-milestone|OUTSIDE|CLOSED]
```

**`SINCE` is the row that earns this script.** It lists the commits that have touched the
issue's own files since it was filed, which is the difference between an issue nobody has
been near and one whose ground has shifted under it.

**A `MISSING` row is a prompt, not a verdict.** An issue may correctly name a file it is
asking you to create, or a symbol it is asking you to delete. Read before concluding.

## Then read the issue

The script cannot tell you whether a finding is _right_, only whether its references still
resolve. Open the body and check its claims against the code — the counts, the greps, the
line it quotes. Findings written by the `code-*` skills state how they were verified; redo
that, do not take it on trust.

Four dispositions, and every issue gets exactly one:

- **Stands.** The claim is still true. Say what you re-checked.
- **Already fixed.** Name the commit that did it and close.
- **Partly stale.** The most common and the easiest to miss: half the finding has been
  overtaken and the rest is live. Say which half is gone, narrow the scope, keep the issue.
- **Wrong to do.** The suggested change would make things worse, or the premise has been
  invalidated. Argue it on the issue rather than closing quietly.

## Verify the claims the issue could not

The highest-value finding in a verification pass is usually a claim the author marked
unverifiable. `code-*` findings are written offline and say so — _"I cannot verify what
USNO publishes for that date"_, _"I could not check this against the upstream"_.

**Try.** Fetch the reference, run the command, query the API. The answer can change the
correct fix rather than confirm it — published data may show the value right and the
_comment_ wrong, which calls for a tighter test rather than a weaker label.

If it stays unverifiable, say that in the comment, with what you tried.

## Watch for

- **Issues overtaken by a deletion.** A correctness finding inside code another issue
  proposes to delete does not need fixing; it needs closing with the deletion. Check
  whether a sibling issue removes the ground this one stands on.
- **`duplicate` labels.** GitHub records the relation as `blocked_by`; the script prints
  it. A duplicate closes on the other issue's PR, not by itself. Where the relation is
  described in prose but was never recorded, `issue-triage` is what records it.
- **Half-stale infrastructure findings.** An issue naming two files where one has since
  been deleted is still a real finding about the survivor. Narrow it; do not close it.
- **A body that references a file the repo hides.** `.issues/` is excluded by a global
  ignore in some repos, so its paths report MISSING by design. The script already drops
  the `Filed from` footer's own path.

## Post one comment per issue

Say what you re-checked, what you found, and the disposition. Quote the evidence — a grep
count, a commit sha, a line that no longer exists. A verification comment that says only
"still valid" has not recorded anything the next reader could not have guessed.

Where the disposition changes the scope, say so explicitly, because the issue title will
keep claiming the original scope forever.

## Do not use when

- You are about to fix the issue in the same pass — use `issue-pr`, which verifies as its
  first step and does not need a separate comment.
- The whole milestone is being worked autonomously — `release-captain` runs this as its
  first phase.
- Nothing has landed since the issues were filed. `SINCE` will say so, and a pass that
  re-confirms untouched findings is noise on every issue.
- The issues are fine but unsorted — no milestone, no relations, not on the board. That is
  placement rather than truth: use `issue-triage`.
