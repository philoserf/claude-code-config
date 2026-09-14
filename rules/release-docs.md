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
- `WALKTHROUGH.md` is showboat's file. Never write it with `Edit` or `Write` — build it with `showboat note` / `exec`, and repair it with `pop` (last entry) or `verify --output` (mid-document). Editing it directly also bypasses the auto-format hook that exists to keep prettier off it.
- Anchor showboat snippets to content (`sed -n '/^func Parse/,/^}/p'`), never to line numbers. A line range keeps producing _some_ output after the code moves, and `verify` only checks that output matches the command — never that the command still matches the prose. That is silent drift, and it is the failure the document exists to prevent.
- Regenerating the blocks is not the whole job: `verify` never reads the commentary. After a rename or deletion, grep the prose for the old identifier.
- Verification belongs in the release pass, run by hand or by `release-gate` check 8 — never as a CI gate on every push, which turns each code PR red until the docs catch up and forces exactly the practice this rule exists to avoid.
- Releasing is `release-gate` first, then `release-ship`, which is user-invoked. The gate reports; it does not prepare. Phase 4 of ship is where this whole set comes current.
- `THEORY.md` and `WALKTHROUGH.md` already exist in most repos that have them at all. Ask whether to extend or overwrite before writing either.
