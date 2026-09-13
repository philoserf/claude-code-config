# claude-code-config

My personal [Claude Code](https://claude.com/claude-code) configuration, kept under version control in `~/.claude/` itself — the checked-in tree and the live config Claude Code reads are the same files.

## Don't use this directly

Cloning this over your own `~/.claude` will clobber your settings, memory, and credentials. Even if you back up first, this repo encodes my preferences, my projects, and my style — it is not a starter template.

Read it, take the ideas or snippets that fit your own workflow, leave the rest.

## Where to look

- [`CLAUDE.md`](CLAUDE.md) — user-level memory, loaded into every session.
- [`.claude/CLAUDE.md`](.claude/CLAUDE.md) — guidance for working inside this directory.
- [`skills/`](skills) — skills run against other projects; [`.claude/skills/`](.claude/skills) holds the ones that operate on Claude Code's own configuration.
- [`rules/`](rules) — language and project rules, loaded only when Claude touches matching files.
- [`hooks/`](hooks) — shell scripts wired to the `hooks` block in `settings.json`.
- [`.gitignore`](.gitignore) — which runtime paths Claude Code writes and why each is excluded.
- [`settings.json`](settings.json) — Claude Code settings.

## One prerequisite that lives outside this repo

The `code-*` review skills write findings to `.issues/` at the root of whatever project they
are run against, and rely on that directory being ignored so the findings never ship. The rule
is global, not per-repo — `~/.gitignore` (via `core.excludesfile`) must contain `.issues`.
Cloning this config does not bring it. The skills check `git check-ignore -q .issues` before
filing and stop if it fails, so the consequence of a missing entry is a refusal rather than a
surprise in someone's diff.

## License

MIT. See [LICENSE](LICENSE).
