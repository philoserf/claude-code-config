# Vault Structure, History, and Sync

## Vault structure

```bash
obsidian files folder="Projects" ext=md
obsidian folders
obsidian file file="My Note"                      # show file info
obsidian folder path="Projects" info=size
obsidian vault info=files                         # vault-level stats
obsidian vaults verbose                           # list all known vaults
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
