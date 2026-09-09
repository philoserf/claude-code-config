# The `.issues/` protocol

Shared by `code-audit`, `code-reduction`, and `code-theory`. This file is the canonical
copy; the other two skills reference it by path. Change it here.

The three skills answer different questions about the same codebase and will keep meeting
each other in the same files. The point of a shared protocol is that a second pass can
see what the first one already said, and disagree with it explicitly rather than silently
re-filing it.

## Layout

`.issues/` lives at the repository root. Create it if absent.

| File                                           | Written by       | Contents                                                |
| ---------------------------------------------- | ---------------- | ------------------------------------------------------- |
| `000-audit.md`                                 | `code-audit`     | Narrative overview + index of that pass's findings      |
| `000-reduction.md`                             | `code-reduction` | Narrative overview + index of that pass's findings      |
| `THEORY.md` (repo root, **not** in `.issues/`) | `code-theory`    | The theory; ends with an index of the findings it filed |
| `<descriptive-kebab-case>.md`                  | any              | One finding, one file                                   |

Overview files sort above findings, so `ls .issues/` opens on the summaries. Finding
filenames carry no number prefix — they are named for the problem
(`slug-invariant-unenforced-at-build.md`), which is what makes them greppable and what
makes a duplicate obvious on sight.

## Finding format

```text
# One-sentence statement of the problem, as a title

**Severity:** critical | high | medium | low
**Source:** code-audit | code-reduction | code-theory
**Date:** YYYY-MM-DD
**Location:** `file:line`, or several, comma-separated

## Description

What's wrong and why it matters. Cite what you verified and how.

## Suggested fix

Concrete recommendation. Where a build or test command would confirm the fix, say which.
```

`code-reduction` adds a `**Payoff:**` line after `**Severity:**` — approximate lines
removed and the risk of removing them.

Severity is the shared scale, so an index built from mixed sources sorts coherently:

| Severity     | Meaning                                                                  |
| ------------ | ------------------------------------------------------------------------ |
| **Critical** | Security vulnerabilities, data loss, crashes                             |
| **High**     | Correctness bugs, missing error handling, race conditions                |
| **Medium**   | Design issues, code smells, missing validation, misleading documentation |
| **Low**      | Style inconsistencies, naming, minor cleanup                             |

## The overview report

Narrative prose: what you looked at, how, what you actually ran, and what the findings add
up to. Say plainly when a severity band is empty rather than manufacturing entries to fill
it. End with an index:

```markdown
## Index

| # | Severity | Issue | Primary location |
| --- | --- | --- | --- |
| 1 | high | `slug-invariant-unenforced-at-build` | three `single.html` templates |

**Total: N issues (C critical, H high, M medium, L low)**
```

Index only the findings from this pass. Pre-existing findings from another skill belong in
the prose, under **Related existing findings**, not in the count.

## Before filing anything

Run all three checks, then decide:

1. **Read `.issues/`.** Every existing `*.md`, including other skills' overviews. You need
   the `**Location:**` and `**Source:**` lines before you can tell a duplicate from a
   disagreement.
2. **Search GitHub issues** — `gh issue list --search "<path>"`. GitHub issues carry no
   structured `file:line`, so search titles and bodies for the path. If `gh` is missing,
   unauthenticated, or errors (non-GitHub remote, offline, unconfigured), skip this step
   and note it in the overview instead of failing.
3. **Decide per finding:**

   - **Duplicate** — same location, same category, same `Source:`. Skip it. Do not re-file
     and do not rewrite the existing file.
   - **Related** — same location, _different_ `Source:`. This is the interesting case and
     must not be silenced. File yours, and add a `Related:` line under `## Description`
     linking the other finding by filename and naming its source, so a reader lands on both
     angles on the same code. Where the two disagree — a reduction pass proposing deletion
     of something an audit pass flagged as a bug worth fixing — say which you think wins
     and why. Naming the conflict is the deliverable; resolving it may not be yours to do.
   - **Already tracked on GitHub** — do not duplicate it into `.issues/`. Mention it in the
     overview's prose with its issue number.
   - **New** — file it.

## Re-running

`code-audit` and `code-reduction` run forked and cannot ask a question mid-run. The rules
are therefore fixed, not negotiated:

- **The overview is regenerated in place.** It describes one pass; overwrite it.
- **An existing finding file is never overwritten.** If a finding is genuinely new but
  collides on filename, extend the filename to distinguish it. If it is the same finding,
  it is a duplicate — skip it.
- **Nothing in `.issues/` is deleted.** Not stale entries, not fixed ones, not another
  skill's. If a finding looks already fixed, say so in the overview under **Possibly
  resolved** and leave the file alone.

## Scope discipline

For a large codebase, prioritize Critical and High and traverse deliberately — entry points
and core modules first, then remaining directories one at a time — so that partial coverage
is systematic rather than a random sample. Say in the overview where you stopped.
