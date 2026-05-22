# claude-code-setup

My personal [Claude Code](https://claude.com/claude-code) configuration, kept under version control in `~/.claude/` itself — the checked-in tree and the live config Claude Code reads are the same files.

## Don't use this directly

Cloning this over your own `~/.claude` will clobber your settings, memory, and credentials. Even if you back up first, this repo encodes my preferences, my projects, and my style — it is not a starter template.

Read it, take the ideas or snippets that fit your own workflow, leave the rest.

## Where to look

- [`CLAUDE.md`](CLAUDE.md) — user-level memory, loaded into every session.
- [`.claude/CLAUDE.md`](.claude/CLAUDE.md) — guidance for working inside this directory.
- [`.gitignore`](.gitignore) — which runtime paths Claude Code writes and why each is excluded.
- [`settings.json`](settings.json) — Claude Code settings.

## License

MIT. See [LICENSE](LICENSE).
