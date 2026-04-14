---
description: Interacts with Obsidian vaults via the Obsidian CLI to read, create, and manage notes, tasks, properties, tags, bookmarks, and templates. Use when working with an Obsidian vault from the command line, adding to daily notes, querying by tag or link, checking sync status, or developing and debugging Obsidian plugins and themes.
allowed-tools: Bash
---

# Obsidian CLI

Use the `obsidian` CLI to interact with a running Obsidian instance. Requires Obsidian to be open.

## Contents

- [Troubleshooting](#troubleshooting) · [Gotchas](#gotchas) · [Syntax](#syntax) · [File targeting](#file-targeting) · [Vault targeting](#vault-targeting)
- [Notes](#notes) · [Vault structure](#vault-structure) · [Properties](#properties) · [Tasks](#tasks) · [Tags and links](#tags-and-links)
- [Bookmarks](#bookmarks) · [History and sync](#history-and-sync) · [Templates](#templates) · [Bases](#bases)
- [Commands and hotkeys](#commands-and-hotkeys) · [Plugins](#plugins) · [QuickAdd](#quickadd) · [Tabs and workspace](#tabs-and-workspace)
- [Verifying operations](#verifying-operations) · [Plugin development](#plugin-development)

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

**No `search` command exists.** To find notes, use `files`, `tags`, `properties`, `backlinks`, `orphans`, or `base:query`.

## Notes

```bash
obsidian read file="My Note"
obsidian create name="New Note" content="# Hello" template="Template" silent
obsidian append file="My Note" content="New line"
obsidian prepend file="My Note" content="Top line"
obsidian open file="My Note" newtab
obsidian delete file="Old Note"
obsidian move file="My Note" to="Archive/My Note.md"
obsidian rename file="My Note" name="Better Name"
obsidian random:read                              # read a random note
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
obsidian tasks done                               # completed tasks
obsidian task file="My Note" line=12 toggle       # toggle a specific task
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
obsidian history:read file="My Note" version=1    # read a version
obsidian history:restore file="My Note" version=2
obsidian sync:status
obsidian sync:history file="My Note"
obsidian sync:restore file="My Note" version=3
obsidian diff file="My Note" from=1 to=2
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
obsidian plugin id="dataview"                     # plugin info
obsidian plugin:enable id="dataview"
obsidian plugin:disable id="dataview"
obsidian plugin:install id="dataview" enable
obsidian plugin:uninstall id="dataview"
```

## QuickAdd

```bash
obsidian quickadd:list
obsidian quickadd choice="Daily Capture" vars='{"input":"note text"}'
obsidian quickadd:check choice="Daily Capture"    # check missing inputs
```

## Tabs and workspace

```bash
obsidian tabs ids
obsidian tab:open file="My Note"
obsidian workspace                                # show workspace tree
obsidian recents
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
