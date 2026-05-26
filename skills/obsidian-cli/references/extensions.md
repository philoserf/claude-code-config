# Templates, Bases, Plugins, Themes, Workspace

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
