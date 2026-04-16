# claude-code-setup

A personal [Claude Code](https://claude.com/claude-code) configuration, kept under version control in `~/.claude/` itself — so the checked-in tree and the live config Claude Code reads are the same files. Public because it may be useful as a reference, not because it is meant to be installed wholesale.

## Where to start

- **[THEORY.md](THEORY.md)** — what this system is, the organizing ideas, the seams, and what bends vs. what does not. The "why" for the whole repo.
- **[CLAUDE.md](CLAUDE.md)** — cross-project collaboration style, auto-loaded by Claude Code in every session on this machine.
- **[.claude/CLAUDE.md](.claude/CLAUDE.md)** — harness-maintenance guidance; applies only when editing this repo.

## Layout

| Path                    | What lives there                                                            |
| ----------------------- | --------------------------------------------------------------------------- |
| `skills/`               | Auto-selected pieces of expertise (one directory per skill with `SKILL.md`) |
| `agents/`               | Specialized sub-personas with their own tool grants                         |
| `hooks/`                | Shell and Python scripts the harness runs on lifecycle events               |
| `rules/`                | Markdown files auto-injected into every session's system prompt             |
| `plugins/marketplaces/` | Third-party skills, synced read-only — never edit                           |
| `settings.json`         | The one explicit wiring seam — permissions, hook events, statusline         |

Discover what is in each with `ls` rather than trusting a hand-maintained list; the repo evolves faster than catalogs stay honest.

## Vocabulary

Names in this repo carry more meaning than they look like they do.

- **`cc-`** prefix — meta-tooling that operates on the Claude Code harness itself (`cc-review`, `cc-release-review`).
- **`vc-`** prefix — version control operations (`vc-ship`, `vc-sync`); deliberately abstracted over `git-` even though every implementation is git today.
- **`md-`** prefix — CLAUDE.md operations specifically (`md-audit`, `md-capture`), not general markdown.
- **ship vs. sync** — `ship` means commit → organize → review → push → PR (finishing work); `sync` means pull → prune (catching up). Two skills on purpose.
- **quality gate** — fast, single-language check runners (`go-quality-gate`, `python-quality-gate`, and friends), distinct from the deeper, multi-phase `refactor-clean` and `tech-debt` skills.

## Installation

Don't. Read [THEORY.md](THEORY.md), steal what fits, leave the rest.
