---
name: mcp-toggle-normalize
description: Re-normalizes MCP connector enable/disable state across all project entries in ~/.claude.json (computer-use on; claude-in-chrome and claude.ai connectors off). Use when project dirs drift off the connector spec and every entry needs fixing at once.
disable-model-invocation: true
---

# Normalize MCP connector toggles

## Desired state

`computer-use` **enabled**; `claude-in-chrome`, `claude.ai Gmail`, `claude.ai Google Calendar`, `claude.ai Google Drive` **disabled**, in every project.

## Where the state lives

These are **not** a `settings.json` key. State lives per-project in `~/.claude.json` under each project's `enabledMcpServers` / `disabledMcpServers` arrays. `claudeInChromeDefaultEnabled: false` is the only global default. New project dirs may start off-spec.

## Procedure

1. **Quit all other Claude Code sessions first.** A running instance rewrites `~/.claude.json` from memory and will clobber external edits. (The session running this skill is itself a writer — warn the user of that residual risk before editing.)
2. Back up: `cp ~/.claude.json ~/.claude.json.bak-mcp-normalize`
3. Apply. Creates missing keys, dedupes, and removes names cross-listed in the other array:

   ```sh
   python3 - <<'EOF'
   import json, pathlib
   p = pathlib.Path.home() / '.claude.json'
   d = json.loads(p.read_text())
   ENABLE = ['computer-use']
   DISABLE = ['claude-in-chrome', 'claude.ai Gmail',
              'claude.ai Google Calendar', 'claude.ai Google Drive']
   for proj in d.get('projects', {}).values():
       en = [s for s in proj.get('enabledMcpServers', []) if s not in DISABLE]
       dis = [s for s in proj.get('disabledMcpServers', []) if s not in ENABLE]
       proj['enabledMcpServers'] = en + [s for s in ENABLE if s not in en]
       proj['disabledMcpServers'] = dis + [s for s in DISABLE if s not in dis]
   p.write_text(json.dumps(d, indent=2))
   EOF
   ```

## Verify

1. JSON still parses: `python3 -m json.tool ~/.claude.json > /dev/null && echo valid`
2. Re-scan every project for compliance:

   ```sh
   python3 - <<'EOF'
   import json, pathlib
   d = json.loads((pathlib.Path.home() / '.claude.json').read_text())
   DISABLE = {'claude-in-chrome', 'claude.ai Gmail',
              'claude.ai Google Calendar', 'claude.ai Google Drive'}
   bad = [k for k, p in d.get('projects', {}).items()
          if 'computer-use' not in p.get('enabledMcpServers', [])
          or not DISABLE <= set(p.get('disabledMcpServers', []))]
   print('\n'.join(bad) or 'all compliant')
   EOF
   ```

**Done when:** step 1 prints `valid` and step 2 prints `all compliant`. If any project is listed, re-run the apply step and re-verify.
