---
argument-hint: "[repo[@version]...]"
description: Cuts the releases that are ready across the philoserf repos, one background agent per repo, after one up-front confirmation of the list. Use when asked to cut, ship or release what is ready, or after /milestone-sweep leaves repos ready to release. Tags and GitHub releases are public, so the list is confirmed once before anything ships.
allowed-tools:
  - Agent
  - Bash
  - Read
  - Edit
  - AskUserQuestion
---

# Release sweep

The shipping half of `/milestone-sweep`. Separate on purpose: the sweep stops before
shipping, and a release is a public step the user takes on purpose.

One `repo-releaser` agent per repo cuts its release with `release-ship`. You find what is
ready, get the list confirmed once, launch the agents, and clean up afterwards.

**Run it on `almanac`, from a session started in `~/source/philoserf`**, for the same reasons
as `/milestone-sweep`.

## 1. Find what is ready

```bash
cd ~/source/philoserf && task sync
```

Stop if `sync` reports a repo as diverged or errored. With arguments, consider only those
repos; `repo@version` fixes the version.

Otherwise, a repo is a candidate when:

- `release-check.sh` exits 3 with 0 FAIL and 0 WARN,
- its `Changes since last tag` row shows at least one commit, and
- it is not one of the unversioned sites (crbgc, neocities, sandbox, site), which release by
  deploying, not tagging.

Skip `obsidian-vault-changelog`, which `CLAUDE.md` excludes from all workspace work.

**Propose a version for each candidate.**

- **An open milestone named for a version:** use that.
- **No such milestone:** use the next semver step for what changed. A patch for tooling, docs
  and dependencies. A minor for a behavior change, including one that moves values callers
  may have pinned (`issue-triage`'s rules). A prerelease line continues its suffix:
  `-beta.3` becomes `-beta.4`.
- **A repo versioned only by tags** (obsidian-starter): pass the version explicitly.

Run `release-plan.sh <version>` for each candidate and note `prerelease` and `deploy_cmd`.

## 2. Confirm once

Present the list as a table: repo, current release, proposed version, prerelease or not,
deploys or not, and the commits since the last tag in one line. Ask with `AskUserQuestion`
whether to cut them all, and offer the chance to drop a repo or change a version.

**This is the only question before anything ships, and it is a real one: wait for it.**
Tags and releases are public and permanent. Everything after this answer is pre-approved,
and the agents will not ask again.

## 3. Launch

One `Agent` call per confirmed repo, all in one message, with
`subagent_type: "repo-releaser"` and `run_in_background: true`. The prompt names `REPO` and
`VERSION`, plus anything repo-specific:

- the tag prefix
- the version source
- that it deploys
- any exception the user granted, such as writing dusk's CHANGELOG
- evidence the CHANGELOG should record, such as a live check the user ran

## 4. While agents report

Relay each report as it lands, briefly. **Assume the user is not watching.** A relay is a
heads-up; nothing waits on an answer.

**Act on a fleet-wide hazard.** When one agent finds a gap the others are about to hit (a
beta about to be published as "Latest", say), warn the running agents with `SendMessage`.
Then fix the skill that caused it, so the next run doesn't need the warning.

**Never run a command an agent was blocked from running.** A blocked step goes to the user
as the exact commands that remain.

## 5. Close out

When every agent has reported:

- **List what didn't finish,** with each one's remaining commands, ready to paste. A release
  the user then finishes by hand still needs the cleanup below.
- **Verify each release,** whoever finished it:
  - **Release:** `gh release view <tag>` shows the right prerelease flag.
  - **Milestone:** deleted, if all of its issues are closed.
  - **Prep PR:** merged.
  - **Local branch:** none left behind.
  - **Checkout:** clean and level with origin.
- **`NEXT.md`:** a released repo's row is deleted, or becomes the deferred idea its work left
  behind, stated as an action (`~/source/philoserf/CLAUDE.md`). Commit and push it with
  `dot`, as part of the close-out.
- **Report** one line per repo: tag, release link, and deployed or not. Then offer a co-log
  line for today's daily note.
