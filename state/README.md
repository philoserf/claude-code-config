# state/

Long-lived state written by skills or hooks that needs to persist across Claude Code sessions but isn't user-visible configuration.

## What belongs here

- Small, machine-written files that record "last seen" or "last processed" markers used to detect new work (e.g., the last-reviewed Claude Code release version).
- Values a skill needs to remember between runs to avoid repeating work or resurfacing the same prompt.
- State that should survive `~/.claude/cache/` being wiped but doesn't belong in `settings.json`.

## What does _not_ belong here

- **Logs or telemetry** — use `logs/`, which is gitignored and rotated.
- **Runtime caches** — use `cache/`, which is gitignored and safe to delete.
- **Scratch/working documents** — use `scratch/`, which is gitignored and ephemeral.
- **Plans** — use `plans/` (gitignored) for in-flight work, per `writing-plans`.
- **Per-machine secrets or overrides** — use `settings.local.json` (gitignored).
- **User preferences or Claude Code harness config** — use `settings.json`.

## Conventions

- One purpose per file; descriptive names (`<skill-or-topic>-<what>.<ext>`).
- Prefer plain text or single-value files for grep-ability (`cc-release-review-version.txt`).
- Tracked in git — only commit state that should be shared across machines or restored by `git clone`.
- If a file is per-machine or changes constantly, it belongs in one of the gitignored directories above instead.
