---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Issue-tracker operations and labels are in `~/.claude/references/github-tracker.md`. If the user passes a ticket reference, fetch it and state its title before starting. If the reference is ambiguous, ask.

Never commit to `main`. Unless you're already on a feature branch, start one with `~/.claude/bin/pr-cycle start <branch>`.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Commit your work to the branch. Then call the Skill tool with "spec-review" to review it, commit the fixes for what it finds, and record the review with `~/.claude/bin/pr-cycle reviewed <branch>`.

Stop there. Shipping is the user's call: report the branch, and draft the PR body with the `pr` skill (`Closes #<n>` for each ticket) so `pr-cycle ship` is one command away.
