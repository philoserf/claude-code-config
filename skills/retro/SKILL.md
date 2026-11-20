---
name: retro
description: "Conduct a retrospective on a coding session."
disable-model-invocation: true
---

The user has asked for a **retrospective**. You are suggesting improvements to the coding agent's **environment** to improve future runs.

## Steps

1. Call the Skill tool with `writing-for-agents` for the writing style guide.

2. Read the primary sources for the session the user specifies. This may mean searching through session logs on this machine. If the user doesn't specify a session, default to the current one.

3. Look for candidates for improvement in these categories.

- **Navigation**: how easy was it for the agent to find the right files? Are there hidden dependencies between files? Would a **navigation pointer** make it easier? _Use when_ the session took a long time to find a piece of information.
- **Automated checks**: are there automated checks that could catch errors the agent made? Linting, typing, tests, filesystem linters? The **guardrail** is the repo's `task` gate: every check runs locally through it. Read the repo's `Taskfile.yml` first, so the finding is a check that is missing from the gate, exists but isn't wired into it, or is silently broken, not a reinvention. A repo whose gate passes is guarded. _Use when_ the agent made a mistake an automated check could have caught.
- **Coding standards**: should the **reviewer agent** be given a new rule to enforce? Should an existing rule be removed or clarified? Classify the violation first. A **mechanical** one (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) gets a deterministic check, full stop: lint config or a script the repo's `task` gate runs. When the mistake is in the agent's behavior rather than the code (a command shape, a git habit), the check is a PreToolUse hook in `~/.claude/hooks/`, as the git-commit guard is. Default to building the check over writing the rule. Keep **judgement calls** (cross-file consistency, "matches the surrounding style," anything no check could ever substitute for) in the repo's `CLAUDE.md` or `docs/`, or in `~/.claude/rules/*.md` when they hold across repos. _Use when_ the reviewer agent failed to catch a mistake.
- **Global CLAUDE.md**: are there any steering instructions that should move to `rules/`, coding standards, or automated checks instead? _Use when_ a `CLAUDE.md` is particularly large: the repo's, or the global one at `~/.claude/CLAUDE.md`.
- **Tool economy**: did the agent make expensive tool calls that could be streamlined? Is there any custom tooling (CLI's, MCP's) that is particularly token-inefficient? _Use when_ the agent made an expensive tool call.
- **No-ops**: look for instructions in steering files that don't modify the agent's behavior. _Use when_ the steering files are large and unwieldy.
- **Information access**: look for opportunities to increase the agent's access to information. Teeing dev server logs, readonly access to third-party services. _Use when_ a crucial piece of information was not available to the agent.

4. Present these candidates to the user, in order of severity. Name where each one lands:
   - `philoserf/claude-code-config` (`~/.claude`) for global rules, hooks and user skills.
   - `philoserf/notes-tooling` for the vault's skills, agents and scripts.
   - The repo itself for its `task` gate, its `CLAUDE.md` and its `docs/`.

## Reference

### Implementation vs Review

Remember that all work goes through two stages: implementation and review. The implementation agent has the most **context pressure**. They are responsible for exploration, writing code, and debugging failures.

The review agent has the least context pressure - it receives a diff, so no exploration needed. It often does not need to write code or debug.

This means that the review agent should be responsible for imposing coding standards, not the implementation agent.

### Files

You have access to several files in the repo:

- `CLAUDE.md`: pushed to the context window of any agent working in the repo, and globally from `~/.claude/CLAUDE.md`. Use it incredibly sparingly, usually only for **navigation pointers** to other files.
- `rules/*.md`: standards that load only when their `paths:` match the files in play, so they cost nothing elsewhere. Global ones live in `~/.claude/rules/`. They are the standards review holds code to.
- Docs: use docs as references files, pointed to by other files. Look for existing docs before writing new ones.
- Skills: use skills for docs (since their description goes into the agent's context window), or for user-invoked commands. Follow the advice in the `writing-for-agents` skill.
