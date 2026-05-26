# Content Metadata

Properties, tasks, tags, links, bookmarks. Add `active` to many list commands to scope to the currently open file.

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
