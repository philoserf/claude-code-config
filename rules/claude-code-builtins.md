- Built-in slash commands and CLI flags are handled by the Claude Code harness, not by Claude. They are invisible during a session — do not attempt to run them via Bash or simulate their behavior.
- When the user needs a built-in action, tell them the command to run (e.g., "Run `/model opus`") rather than trying to execute it yourself.
- New builtins appear in release notes — flag them during `/cc-release-review`.

## Slash commands (run inside session with `/`)

### Session

`/clear` `/resume [session]` `/branch [name]` `/rename [name]` `/exit` `/btw <question>`

### Model & effort

`/model [model]` `/effort [level]` `/fast [on|off]`

### Configuration

`/config` `/permissions` `/keybindings` `/terminal-setup` `/statusline` `/sandbox` `/login` `/logout` `/privacy-settings` `/memory` `/hooks` `/extra-usage`

### Information

`/help` `/status` `/cost` `/context` `/stats` `/insights` `/release-notes` `/skills` `/doctor` `/usage`

### Code & project

`/diff` `/copy [N]` `/export [filename]` `/rewind` `/security-review` `/plan [description]` `/ultraplan <prompt>` `/add-dir <path>`

### Tools & integrations

`/mcp` `/plugin` `/ide` `/chrome` `/reload-plugins`

### Remote & scheduling

`/schedule` `/desktop` `/remote-control` `/remote-env`

### GitHub & external

`/install-github-app` `/install-slack-app`

### Tasks

`/tasks`

### Bundled skills (not user-defined)

`/simplify` `/batch` `/debug` `/loop`

## CLI commands (run from terminal)

`claude` `claude -p "query"` `claude -c` `claude -r "<session>"` `claude -w [name]` `claude --remote` `claude --teleport` `claude update` `claude auth login|logout|status` `claude agents` `claude mcp` `claude plugin` `claude auto-mode defaults|config`

## Key CLI flags

`--model` `--effort` `--permission-mode` `--tools` `--disallowedTools` `--add-dir` `--agent` `--system-prompt` `--max-budget-usd` `--max-turns` `--output-format` `--settings` `--mcp-config`

## Keyboard shortcuts (session)

`Shift+Tab` / `Alt+M` — cycle permission modes · `Option+P` — switch model · `Option+T` — toggle thinking · `Option+O` — toggle fast mode · `Ctrl+B` — background tasks · `Ctrl+G` — open in editor · `@` — file autocomplete · `!` — bash mode
