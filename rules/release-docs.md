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
- Write and edit them with `Write` and `Edit`: the markdown format hook fires only on those tools, not on shell writes.
- Label a snippet `` `path` — `symbol` `` (`src/config.py` — `load_config`), never by line range: a line range still looks plausible after the code moves. That label is what `release-gate` check 8 reads; it requires the snippet verbatim in the named file, allowing an elided middle marked `...`. Check 8 reads content, not history, and **nothing checks the prose** — no re-execution, no diff, no gate. Against silent drift in the prose, the only thing standing is the care taken while writing.
- Getting the snippets right is not the whole job. After a rename or a deletion, grep the prose for the old identifier — the sentence around a snippet goes stale as readily as the snippet does, and it is harder to notice.
- Checking them belongs in the release pass, by hand or via check 8 — never in the per-PR gate (`task check`, or whatever `pr-cycle.sh` runs), which would turn each code PR red until the docs catch up and force exactly the practice this rule exists to avoid.
- Releasing is `release-gate` first, then `release-ship`. The gate reports; it does not prepare. Ship's Phases 3 and 4 are where this whole set comes current — `CHANGELOG.md` in Phase 3, the walkthrough and the rest in Phase 4 — whether the user runs `/release-ship` or a `repo-releaser` agent works through it for `/release-sweep`.
- The unversioned sites (the list in `~/source/philoserf/CLAUDE.md`) never release, so there is no pass to wait for. There the documents are regenerated with `code-walkthrough` and `code-theory` when they are wrong enough to matter, and are not patched in between. A repo's own `CLAUDE.md` wins where it says more.
- Every repo with one of `THEORY.md` and `WALKTHROUGH.md` has both. Ask whether to extend or overwrite before writing either.
