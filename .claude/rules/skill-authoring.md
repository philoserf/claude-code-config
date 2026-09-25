---
# Skill- and agent-authoring conventions for this repo (~/.claude) only: the body
# names this repo's own skills and commit SHAs, so it must not fire elsewhere.
# Both the bare and "**/"-prefixed forms are listed because it is not documented
# whether these patterns match repo-relative or absolute paths.
paths:
  - "skills/**/SKILL.md"
  - "**/skills/**/SKILL.md"
  - ".claude/skills/**/SKILL.md"
  - "**/.claude/skills/**/SKILL.md"
  - "agents/*.md"
  - "**/agents/*.md"
---

# Writing skills

- Every skill under `skills/` ends with a single `## Do not use when` section at the bottom of
  the file — one place, never scattered inline. Skills under `.claude/skills/` follow the same
  convention where it applies.
- Skills that need real logic put it in `scripts/*.sh` next to `SKILL.md` rather than inlining
  long shell in prose, so it can be tested and run directly. Keep the exec bit set.
- Reference material goes in `references/*.md`, loaded on demand by the skill body. These files
  ship with the skill — assume they exist rather than writing defensive "if missing" handling.
- **`model:` and `effort:` override the user's session choice, so a pin has to earn overruling
  them.** Both default to inheriting, and that is right for most skills: when the session is set
  to Opus at `high`, a judgment-heavy skill is already getting what it needs and a pin saying so
  is residue.
  - Pin `model:` **downward only**, and only where the job is mechanical enough that the
    session's model is overkill: `release-gate` (reads a table a script produced),
    `cc-release-review` (diffs two versions against a template). Use the **alias** (`sonnet`),
    never a model ID — an alias tracks the current model in its tier, an ID is a pin with a
    version number on it. `sonnet` rather than `haiku` on both because each one writes.
  - The other case for a downward pin is a **fan-out worker**, and it holds even when the work
    is the opposite of mechanical — ideation, say.
    The economics invert when a parent spawns N workers and does all the synthesis itself:
    cost multiplies by N while quality is aggregated, so a weak option from one worker is
    discarded by a step that never left the session's model. What the fan-out actually buys is
    context isolation — three separate contexts cannot anchor on each other — and that property
    does not come from the workers' model. Pin a worker downward; never pin the synthesis.
  - Pin `effort:` **above the session only**; a pin at or below the session's level restates
    or undercuts the user's choice. `code-theory` and `code-walkthrough` get `xhigh` because
    they emit standing documents (`THEORY.md`, `WALKTHROUGH.md`) that **nothing checks at
    all** — neither the prose nor the snippets — so a weak first draft stays wrong silently
    until a reader trips on it.
  - `release-ship` stays inheriting despite its irreversible tag-and-release steps: it is
    `disable-model-invocation: true`, so the user picks the model at the moment they choose to
    ship. Pinning it would say the session choice isn't trusted for the most deliberate act here.
- The `code-*` skills write to `.issues/` in whatever project they run against and require
  `.issues` in `~/.gitignore` (via `core.excludesfile`) so findings never ship. That entry is
  not tracked here and a fresh machine will not have it; the skills verify it with
  `git check-ignore` and refuse to file without it.
