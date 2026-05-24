---
description: Interacts with Obsidian vaults via the Obsidian CLI to read, create, and manage notes, tasks, properties, tags, bookmarks, and templates. Use when working with an Obsidian vault from the command line, adding to daily notes, querying by tag or link, checking sync status, or developing and debugging Obsidian plugins and themes.
allowed-tools: Bash
---

# Obsidian CLI

Use the `obsidian` CLI to interact with a running Obsidian instance. Requires Obsidian to be open.

## Contents

- [Troubleshooting](#troubleshooting) · [Gotchas](#gotchas) · [Syntax](#syntax) · [File targeting](#file-targeting) · [Vault targeting](#vault-targeting)
- [Notes](#notes) · [Search](#search) · [Vault structure](#vault-structure) · [Properties](#properties) · [Tasks](#tasks) · [Tags and links](#tags-and-links)
- [Bookmarks](#bookmarks) · [History and sync](#history-and-sync) · [Templates](#templates) · [Bases](#bases)
- [Commands and hotkeys](#commands-and-hotkeys) · [Plugins](#plugins) · [Themes](#themes) · [CSS snippets](#css-snippets) · [QuickAdd](#quickadd)
- [Tabs and workspace](#tabs-and-workspace) · [App control](#app-control) · [Verifying operations](#verifying-operations) · [Plugin development](#plugin-development)

## Troubleshooting

If commands fail with a connection error or no output, check:

1. **Obsidian is running** — the CLI talks to a live Obsidian process. If Obsidian is closed, every command fails silently or with a connection refused error.
2. **Correct vault** — if multiple vaults exist, the CLI targets the most recently focused one. Use `vault=<name>` to be explicit.

## Gotchas

- **Metadator and similar plugins**: each file must be opened in Obsidian before running commands on it. Batch operations require iterating files individually — there is no bulk mode.
- **The `silent` flag** prevents notes from opening in the UI. Always use it for batch/automated operations to avoid tab explosion.

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

## Vault structure

```bash
obsidian files folder="Projects" ext=md
obsidian folders
obsidian file file="My Note"                      # show file info
obsidian folder path="Projects" info=size
obsidian vault info=files                         # vault-level stats
obsidian vaults verbose                           # list all known vaults
```

## Properties

```bash
obsidian property:set name="status" value="done" file="My Note"
obsidian property:set name="rating" value="5" type=number file="My Note"
obsidian property:read name="status" file="My Note"
obsidian property:remove name="draft" file="My Note"
obsidian properties sort=count counts             # vault-wide property usage
obsidian properties file="My Note"                # properties on one file
```

## Tasks

```bash
obsidian tasks daily todo                         # incomplete tasks from daily note
obsidian tasks file="My Note" verbose             # tasks grouped by file with line numbers
obsidian tasks active                             # tasks in the active file
obsidian tasks done                               # completed tasks
obsidian tasks status="/"                         # filter by status character
obsidian task file="My Note" line=12 toggle       # toggle a specific task
obsidian task ref="folder/Note.md:12" done        # ref shorthand for path+line
obsidian task daily done                          # mark daily task done
```

## Tags and links

```bash
obsidian tags sort=count counts
obsidian tag name="project" verbose               # files with a specific tag
obsidian backlinks file="My Note" counts
obsidian aliases verbose
obsidian orphans                                  # files with no incoming links
obsidian deadends                                 # files with no outgoing links
obsidian unresolved counts                        # broken links
```

## Bookmarks

```bash
obsidian bookmarks verbose
obsidian bookmark file="My Note" title="Reference"
obsidian bookmark search="query" title="Saved Search"
obsidian bookmark url="https://example.com" title="Link"
```

## History and sync

```bash
obsidian history file="My Note"                   # list versions
obsidian history:list                             # files that have history
obsidian history:read file="My Note" version=1    # read a version
obsidian history:restore file="My Note" version=2
obsidian history:open file="My Note"              # open file recovery UI
obsidian sync on                                  # resume sync (off to pause)
obsidian sync:status
obsidian sync:history file="My Note"
obsidian sync:read file="My Note" version=3       # read a sync version
obsidian sync:restore file="My Note" version=3
obsidian sync:deleted total                       # count deleted files in sync
obsidian sync:open file="My Note"                 # open sync history UI
obsidian diff file="My Note" from=1 to=2 filter=sync
```

## Templates

```bash
obsidian templates
obsidian template:read name="Daily" resolve title="2026-03-26"
obsidian template:insert name="Daily"             # insert into active file
```

## Bases

```bash
obsidian bases                                    # list all base files
obsidian base:views file="Tasks"                  # list views in a base
obsidian base:query file="Tasks" view="Active" format=md
obsidian base:create file="Tasks" name="New Item" content="# New"
```

## Commands and hotkeys

```bash
obsidian commands filter=daily                    # list commands by prefix
obsidian command id="daily-notes"                 # execute a command
obsidian hotkeys
obsidian hotkey id="daily-notes" verbose
```

## Plugins

```bash
obsidian plugins filter=community versions
obsidian plugins:enabled
obsidian plugins:restrict on                      # toggle restricted (safe) mode
obsidian plugin id="dataview"                     # plugin info
obsidian plugin:enable id="dataview"
obsidian plugin:disable id="dataview"
obsidian plugin:install id="dataview" enable
obsidian plugin:uninstall id="dataview"
obsidian plugin:reload id="my-plugin"             # reload during development
```

## Themes

```bash
obsidian themes versions
obsidian theme                                    # show active theme
obsidian theme name="Things"                      # theme info
obsidian theme:set name="Things"                  # activate (empty name resets)
obsidian theme:install name="Things" enable
obsidian theme:uninstall name="Things"
```

## CSS snippets

```bash
obsidian snippets
obsidian snippets:enabled
obsidian snippet:enable name="hide-properties"
obsidian snippet:disable name="hide-properties"
```

## QuickAdd

```bash
obsidian quickadd:list type=Capture commands
obsidian quickadd choice="Daily Capture" vars='{"input":"note text"}'
obsidian quickadd:run id="abc123" vars='{"input":"text"}'  # by choice id
obsidian quickadd:check choice="Daily Capture"    # check missing inputs
```

## Tabs and workspace

```bash
obsidian tabs ids
obsidian tab:open file="My Note" group="<group-id>" view="markdown"
obsidian workspace ids                            # workspace tree with item IDs
obsidian recents
```

## App control

```bash
obsidian version                                  # show Obsidian version
obsidian reload                                   # reload the vault
obsidian restart                                  # restart the app
```

## Verifying operations

After creating or modifying notes, confirm the result:

```bash
obsidian read file="My Note"          # verify content after create/append
obsidian property:read name="status" file="My Note"  # verify after property:set
```

## Plugin development

See [plugin-development.md](references/plugin-development.md) for the develop/test cycle, dev commands, and debugging tools.

## Do not use when

- Working directory is not an Obsidian vault — use direct file tools (Read, Edit, Write)
- Editing source files in a code project — use Read/Edit/Write directly
