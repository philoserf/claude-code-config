# Filing findings as GitHub issues

Shared by `code-theory` and `code-walkthrough`, which reference it by path. This file is
the canonical copy. Change it here.

The two skills answer different questions about the same codebase and will keep meeting
each other on the same code. Their side findings go where all other work is tracked: the
repository's GitHub issues, through `gh`, as `github-tracker.md` beside this file describes. A second pass can then see what the first one already said, and
disagree with it explicitly rather than silently re-filing it.

## Standing documents

`THEORY.md` and `WALKTHROUGH.md` are tracked in the repository's `docs/` directory, or at
the root in a repo without one. One that already exists stays where it is; a new one goes
in `docs/` when the repo has that directory. Never both: the release gate refuses a repo
with a copy in each place. Each is the project's single canonical answer to a question that stays
answered, addressed to someone arriving cold.

A standing document carries no findings index; the findings live in the issues. **It cites
only durable references**: an issue number or link, a commit sha, or a plain "corrected in
place".

## Issue format

Title: one sentence stating the problem. Body:

```text
**Severity:** critical | high | medium | low
**Source:** code-theory | code-walkthrough
**Location:** `file:line`, or several, comma-separated

## Description

What's wrong and why it matters. Cite what you verified and how.

## Suggested fix

Concrete recommendation. Where a build or test command would confirm the fix, say which.
```

Labels: `needs-triage`, `kind:theory` or `kind:walkthrough`, and `severity:<level>`. Apply
each only if `gh label list` shows the repo has it; never create labels.

| Severity     | Meaning                                                                  |
| ------------ | ------------------------------------------------------------------------ |
| **Critical** | Security vulnerabilities, data loss, crashes                             |
| **High**     | Correctness bugs, missing error handling, race conditions                |
| **Medium**   | Design issues, code smells, missing validation, misleading documentation |
| **Low**      | Style inconsistencies, naming, minor cleanup                             |

## Before filing anything

1. **Confirm `gh` reaches the repo.** `gh repo view --json nameWithOwner` must succeed. If
   `gh` is missing, unauthenticated, or the remote is not GitHub, file nothing: list the
   findings in your report, in the issue format above, and say why they were not filed.
2. **Search existing issues, open and closed**, for each finding's paths:
   `gh issue list --state all --search "<path>" --json number,title,state,labels`. Read the
   body of any hit before deciding.
3. **Decide per finding:**
   - **Duplicate**: an open issue on the same location and the same problem. Skip it, and
     name its number in your report.
   - **Related**: an issue on the same location from a different angle, often the other
     skill. File yours with a `Related: #<n>` line under `## Description`. Where the two
     disagree, say which you think wins and why. Naming the conflict is the deliverable;
     resolving it may not be yours to do.
   - **Recurred**: a closed issue whose problem is back. File a new one that cites it.
   - **New**: file it.

## Existing issues are not yours

Never comment on, edit, relabel, or close an existing issue on your own initiative. If one
looks already fixed, say so in your report as possibly resolved and leave it alone. When the
user tells you to act on one, that is the owner acting, not the protocol being broken.

## Scope discipline

For a large codebase, prioritize Critical and High and traverse deliberately: entry points
and core modules first, then remaining directories one at a time, so that partial coverage
is systematic rather than a random sample. Say in your report where you stopped, and list
the issues you filed by number.
