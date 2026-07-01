---
description: Interacts with Obsidian vaults via the Obsidian CLI. Use when working with a vault from the command line, adding to daily notes, querying by tag/link, or debugging Obsidian plugins/themes. Manages notes, properties, tags, bookmarks, templates.
allowed-tools: Bash
---

Use the `obsidian` CLI to interact with a running Obsidian instance. Requires Obsidian to be open.

## Troubleshooting

If commands fail with a connection error or no output, check:

1. **Obsidian is running** — the CLI talks to a live Obsidian process. If Obsidian is closed, every command fails silently or with a connection refused error.
2. **Correct vault** — if multiple vaults exist, the CLI targets the most recently focused one. Use `vault=<name>` to be explicit.

## Gotchas

- **Metadator and similar plugins**: each file must be opened in Obsidian before running commands on it. Batch operations require iterating files individually — there is no bulk mode.
- **The `silent` flag** prevents notes from opening in the UI. Always use it for batch/automated operations to avoid tab explosion.
- **Destructive/disruptive commands**: `delete ... permanent`, `restart`, `plugin:uninstall`, and `theme:uninstall` are irreversible or interrupt the running app. Confirm the target (`file=`/`path=`/`id=`/`name=`) with the user before running any of these — don't infer the target and proceed silently.

## Command reference

Run `obsidian help` to see all available commands. This is always up to date. Full docs: https://help.obsidian.md/cli

## Syntax

**Parameters** take a value with `=`. Quote values with spaces:

```bash
obsidian create name="My Note" content="Hello world"
```

**Flags** are boolean switches with no value:

```bash
obsidian create name="My Note" silent overwrite
```

For multiline content use `\n` for newline and `\t` for tab.

## File targeting

Many commands accept `file` or `path` to target a file. Without either, the active file is used.

- `file=<name>` — resolves like a wikilink (name only, no path or extension needed)
- `path=<path>` — exact path from vault root, e.g. `folder/note.md`

## Vault targeting

Commands target the most recently focused vault by default. Use `vault=<name>` as the first parameter to target a specific vault:

```bash
obsidian vault="My Vault" read file="My Note"
```

## Global flags

Use `--copy` on any command to copy output to clipboard. Use `silent` to prevent files from opening. Use `total` on list commands to get a count. Many list commands support `format=json|tsv|csv`.

The `active` flag on `aliases`, `properties`, `tags`, and `tasks` scopes the output to the currently active file.

## Notes

```bash
obsidian read file="My Note"
obsidian create name="New Note" content="# Hello" template="Template" silent
obsidian append file="My Note" content="New line"
obsidian append file="My Note" content="more" inline   # no leading newline
obsidian prepend file="My Note" content="Top line"
obsidian open file="My Note" newtab
obsidian delete file="Old Note"                   # add `permanent` to skip trash
obsidian move file="My Note" to="Archive/My Note.md"
obsidian rename file="My Note" name="Better Name"
obsidian random folder="Inbox" newtab             # open a random note
obsidian random:read                              # read a random note
```

## Search

```bash
obsidian search query="needle" path="Notes" limit=20
obsidian search:context query="needle" case format=json   # results with matching lines
obsidian search:open query="needle"                       # open Obsidian's search view
```

## Verifying operations

After creating or modifying notes, confirm the result:

```bash
obsidian read file="My Note"          # verify content after create/append
obsidian property:read name="status" file="My Note"  # verify after property:set
obsidian search query="Old Note" path="Trash"         # verify after delete (or find missing after `permanent`)
obsidian read path="Archive/My Note.md"               # verify after move
obsidian read file="Better Name"                      # verify after rename
obsidian plugin id="dataview"                         # verify plugin enabled/disabled state
obsidian theme                                        # verify active theme after theme:set
```

## More topics

Load the topical reference for the area you need — don't preload all of them.

- [content.md](references/content.md) — properties, tasks, tags & links, bookmarks
- [structure-sync.md](references/structure-sync.md) — vault structure (files/folders), history, sync
- [extensions.md](references/extensions.md) — templates, bases, plugins, themes, CSS snippets, QuickAdd, tabs/workspace, app control
- [plugin-development.md](references/plugin-development.md) — develop/test cycle, dev commands, debugging

## Do not use when

- Working directory is not an Obsidian vault — use direct file tools (Read, Edit, Write)
- Editing source files in a code project — use Read/Edit/Write directly
