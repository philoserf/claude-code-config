---
# THEORY.md and WALKTHROUGH.md only, and both spellings because it is not
# documented whether these patterns match repo-relative or absolute paths.
#
# Deliberately not "README.md": every repo has one, so this rule would fire
# everywhere — including the Obsidian repos where rules/obsidian-plugin.md
# already owns the release process, and two rules instructing the same file is
# the failure mode. Deliberately not "CHANGELOG.md" for the same reason: that
# rule claims it. Both files are named in the body instead. These two are the
# marker that a repo keeps narrative documents at all.
paths:
  - "THEORY.md"
  - "**/THEORY.md"
  - "WALKTHROUGH.md"
  - "**/WALKTHROUGH.md"
---

These are narrative documents — prose describing the state of the code rather than the code itself. With `README.md`, `CLAUDE.md` and `CHANGELOG.md` they are one set, and the set is brought current **at release time, in one pass, once the code has settled**.

- Do not update them as work proceeds. Code, issues and board metadata are fair game during a session; prose about them waits for the release.
- The reason is cascade, not churn. These documents cross-reference each other, so fixing one mid-stream leaves the others asserting that the first is wrong — the fix manufactures the next pass. Consistency is only reachable from a settled state, all at once.
- Once a documentation pass is deferred, it leaves the conversation until the user raises it. Do not offer it, list it as a next step, flag it as worth knowing before stopping, or name it in a wrap-up. A deferral is a decision already made, and re-raising it reverses it.
- Both are ordinary markdown, written and edited with `Write` and `Edit` like any other document, and prettier formats them like any other document.
- Identify a snippet by file and symbol (`src/config.py` — `load_config`), never by line range. A line range still looks plausible after the code moves, and **nothing in the repo checks either document** — no re-execution, no diff, no gate. Silent drift is the failure these documents exist to prevent, and the only thing standing against it is the care taken while writing.
- Getting the snippets right is not the whole job. After a rename or a deletion, grep the prose for the old identifier — the sentence around a snippet goes stale as readily as the snippet does, and it is harder to notice.
- Checking them belongs in the release pass, by hand or via `release-gate` check 8 — never as a CI gate on every push, which turns each code PR red until the docs catch up and forces exactly the practice this rule exists to avoid. Note what check 8 can and cannot see: it reports whether code has been committed since the walkthrough was last touched, which is a staleness signal, not a correctness one.
- Releasing is `release-gate` first, then `release-ship`, which is user-invoked. The gate reports; it does not prepare. Phase 4 of ship is where this whole set comes current.
- `THEORY.md` and `WALKTHROUGH.md` already exist in most repos that have them at all. Ask whether to extend or overwrite before writing either.
