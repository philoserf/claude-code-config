# The `.issues/` protocol

Shared by `code-theory` and `code-walkthrough`, which reference it by path. This file is
the canonical copy. Change it here.

The two skills answer different questions about the same codebase and will keep meeting
each other in the same files. The point of a shared protocol is that a second pass can
see what the first one already said, and disagree with it explicitly rather than silently
re-filing it.

## Layout

`.issues/` lives at the repository root. Create it if absent. Nothing written there ships,
which is what makes it the right home for anything that expires — but that property comes
from an ignore rule outside the repository being reviewed, so it is verified rather than
assumed. See the first check under [Before filing anything](#before-filing-anything).

Two tiers, and the line between them is **does this ship**:

**Standing documents** — `UPPERCASE.md` at the repository root, tracked. Each is the
project's single canonical answer to a question that stays answered, addressed to someone
arriving cold. They sit alongside `README.md` and `CLAUDE.md`, which is why they take the
same case.

| File             | Written by         | Contents                                  |
| ---------------- | ------------------ | ----------------------------------------- |
| `THEORY.md`      | `code-theory`      | The theory; no findings index             |
| `WALKTHROUGH.md` | `code-walkthrough` | The linear walkthrough; no findings index |

Standing documents carry no findings index; the findings live in `.issues/`.

**A standing document cites only durable references.** A GitHub issue link, a commit sha, or
a plain "corrected in place" — never an `.issues/` path or a bare finding slug. This is the
**does this ship** test applied to the reference rather than only to the document: a tracked
file that points into an ignored, expiring directory is a dangling reference by construction,
and it dangles silently, because nothing resolves it. Cite the event, not the file it was
written in.

**Working state** — inside `.issues/`, ignored. Findings: things that accumulate, go stale,
and expire once acted on. One finding, one file, named `<descriptive-kebab-case>.md`.

A new document goes in the first tier only if it would still be correct a year from now
without being rewritten. A plan fails that test; a theory passes it.

Finding filenames carry no number prefix — they are named for the problem
(`slug-invariant-unenforced-at-build.md`), which is what makes them greppable and what
makes a duplicate obvious on sight.

## Finding format

```text
# One-sentence statement of the problem, as a title

**Severity:** critical | high | medium | low
**Source:** code-theory | code-walkthrough
**Date:** YYYY-MM-DD
**Location:** `file:line`, or several, comma-separated

## Description

What's wrong and why it matters. Cite what you verified and how.

## Suggested fix

Concrete recommendation. Where a build or test command would confirm the fix, say which.
```

Severity is the shared scale, so an index built from mixed sources sorts coherently:

| Severity     | Meaning                                                                  |
| ------------ | ------------------------------------------------------------------------ |
| **Critical** | Security vulnerabilities, data loss, crashes                             |
| **High**     | Correctness bugs, missing error handling, race conditions                |
| **Medium**   | Design issues, code smells, missing validation, misleading documentation |
| **Low**      | Style inconsistencies, naming, minor cleanup                             |

## Before filing anything

Run all four checks, then decide:

1. **Confirm `.issues/` is ignored.** `git check-ignore -q .issues` must exit `0`. If it does
   not, stop and report that instead of filing anything.

   The rule normally comes from git's global ignore file, `~/.config/git/ignore` — outside
   whatever repository you are reviewing, and not tracked by it. A fresh machine that cloned
   the skills without the global ignore, or a git config rewritten by a dotfile manager,
   removes it with no error and no visible symptom. Without it these skills add untracked
   files to someone else's working tree, and the obvious next step there — `git add -A` —
   commits a directory of AI-authored findings into their history.

   Ask: report that the ignore rule is missing and let the user choose between filing anyway and stopping. Do not
   file on your own judgment. The danger is in someone else's repository, which makes it
   theirs to accept.

2. **Read `.issues/`.** Every existing `*.md`, including the other skill's findings. You need
   the `**Location:**` and `**Source:**` lines before you can tell a duplicate from a
   disagreement.
3. **Search GitHub issues** — `gh issue list --search "<path>"`. GitHub issues carry no
   structured `file:line`, so search titles and bodies for the path. If `gh` is missing,
   unauthenticated, or errors (non-GitHub remote, offline, unconfigured), skip this step
   and say so in your report instead of failing.
4. **Decide per finding:**

   - **Duplicate** — same location, same category, same `Source:`. Skip it. Do not re-file
     and do not rewrite the existing file.
   - **Related** — same location, _different_ `Source:`. This is the interesting case and
     must not be silenced. File yours, and add a `Related:` line under `## Description`
     linking the other finding by filename and naming its source, so a reader lands on both
     angles on the same code. Where the two disagree, say which you think wins and why. Naming the conflict is the deliverable; resolving it may not be yours to do.
   - **Already tracked on GitHub** — do not duplicate it into `.issues/`. Mention it in your
     report with its issue number.
   - **New** — file it.

## Re-running

These are defaults you may depart from — by asking first, never by deciding
alone. Each one protects work that is not yours, which is what makes the user the right
person to release it:

- **An existing finding file is not overwritten.** If a finding is genuinely new but collides
  on filename, extend the filename to distinguish it. If it is the same finding, it is a
  duplicate — skip it. Ask before replacing one: you are proposing that another pass's
  reading was wrong, and saying so is more useful than quietly writing over it.
- **Nothing in `.issues/` is deleted on your initiative.** Not stale entries, not fixed ones,
  not another skill's. If a finding looks already fixed, say so in your report as
  possibly resolved and leave the file alone; if it should go, ask. The asymmetry is
  worth remembering: `.issues/` is ignored, so a deletion here is not recoverable from git
  the way everything else in the tree is.

The user is not bound by any of this. When they tell you to overwrite or delete something
here, that is not the protocol being violated — it is the owner acting outside a rule aimed
at the passes.

## Scope discipline

For a large codebase, prioritize Critical and High and traverse deliberately — entry points
and core modules first, then remaining directories one at a time — so that partial coverage
is systematic rather than a random sample. Say in your report where you stopped.
