---
argument-hint: "[repo...]"
description: Runs verify, triage, next-milestone, fix and release-gate across every philoserf repo, one background agent per repo in its own worktree, and stops before shipping. Use when asked to sweep, groom or get the philoserf repos release-ready. Holds every decision for one batch at the end.
allowed-tools:
  - Agent
  - Bash
  - Read
  - Edit
  - AskUserQuestion
---

# Milestone sweep

One agent per repo under `~/source/philoserf/`, each working its repo end to end in a linked
worktree: verify, triage, pick the next milestone, ship it with `issue-pr`, gate it with
`release-gate`, stop before tagging. You orchestrate and do not touch the repos yourself
while their agents run.

**Run it on `almanac`, from a session started in `~/source/philoserf`.** `almanac` is the
always-on host. Twenty agents report back over an hour or more, and nothing here needs
`sextant`. Starting anywhere else, such as `~/notes`, roots the language server outside the
repos. It then sends a stream of false "module not in workspace" and `undefined:` errors
about files that compile.

## 1. Sync, then list the repos

```bash
cd ~/source/philoserf && task sync
```

Stop if `sync` reports a repo as diverged or errored. Don't sweep a clone that doesn't match
its remote.

The repos are the child directories with a `.git`. With arguments, sweep only those.
Leave out:

- `obsidian-vault-changelog`, excluded from all workspace work (`CLAUDE.md`)
- any repo whose `gh repo view` fails, because there is nothing to triage or open PRs against

**Note any repo with issues disabled** (`gh repo view --json hasIssuesEnabled`). Its agent
runs only step 5, the gate, and lands any fix as a PR with no issue.

## 2. Launch

One `Agent` call per repo, all in one message, with `subagent_type: "repo-sweeper"` and
`run_in_background: true`. The agent definition (`~/.claude/agents/repo-sweeper.md`) carries
the whole brief. The prompt only names `REPO` and `SCRATCH`, where `SCRATCH` is your
scratchpad directory, plus anything repo-specific you know: that it is one of the
unversioned sites, that issues are disabled, or that a milestone already exists.

Tell the user how many agents went out, which repos you skipped, and why.

## 3. While agents report

Relay each report as it lands, briefly. **Assume the user is not watching.** A relay is a
heads-up, not a question that blocks anything. Nothing waits on an answer: agents keep
working, and every item the user hasn't answered carries into step 4. Do not act on a
report's requests yourself:

- An agent blocked by a permission prompt reports the command it needed. That command goes to
  the user. You don't run it.
- A pending decision is not answered until the user answers it. If they answer mid-run, act
  on it. If not, it waits for the batch.

**Do act on a fleet-wide hazard.** If one agent reports a mistake the others are about to
repeat, send the running agents a warning with `SendMessage`.

## 4. Decisions, in one batch

Once every agent has reported, collect every decision they held back and every blocked
command, leaving out what the user already answered mid-run. Present them together, with
`AskUserQuestion` where the choices are discrete. If the user is still away, the final
report lists them as open, and the run is complete without them. Typical ones:

- a PR held because its merge would deploy
- a `kind:decision` issue
- whether a repo is versioned at all

Act on the answers.

## 5. Report

Per repo:

- the milestone and its proposed version
- what was fixed, what is blocked, and what needs a decision
- what was deferred, and why
- the gate result

Then list the toolchain migrations that apply across all repos.

**Gate results:** exit 3 with 0 FAIL and 0 WARN means nothing is ready to release, and counts
as clean. Report it apart from a true exit 0.

Then offer two follow-ups:

- **`NEXT.md` rows.** A row is an action, never a status. Follow `~/source/philoserf/CLAUDE.md`.
- **A co-log line in today's daily note.** `~/source/philoserf/NEXT.md` is tracked in the
  dotfiles repo; commit it with `dot` only when asked.
