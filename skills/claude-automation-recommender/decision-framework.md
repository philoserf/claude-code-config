# Decision Framework

Use this framework to decide which automation types to recommend based on codebase signals.

## When to Recommend MCP Servers

- External service integration needed (databases, APIs)
- Documentation lookup for libraries/SDKs
- Browser automation or testing
- Team tool integration (GitHub, Linear, Slack)
- Cloud infrastructure management

## When to Recommend Skills

- Document generation (docx, xlsx, pptx, pdf -- also in plugins)
- Frequently repeated prompts or workflows
- Project-specific tasks with arguments
- Applying templates or scripts to tasks (skills can bundle supporting files)
- Quick actions invoked with `/skill-name`
- Workflows that should run in isolation (`context: fork`)

**Invocation control:**

- `disable-model-invocation: true` -- User-only (for side effects: deploy, commit, send)
- `user-invocable: false` -- Claude-only (for background knowledge)
- Default (omit both) -- Both can invoke

## When to Recommend Hooks

- Repetitive post-edit actions (formatting, linting)
- Protection rules (block sensitive file edits)
- Validation checks (tests, type checks)

## When to Recommend Subagents

- Specialized expertise needed (security, performance)
- Parallel review workflows
- Background quality checks

## When to Recommend Plugins

- Need multiple related skills
- Want pre-packaged automation bundles
- Team-wide standardization

---

## Configuration Tips

### MCP Server Setup

**Team sharing**: Check `.mcp.json` into repo so entire team gets same MCP servers

**Debugging**: Use `--mcp-debug` flag to identify configuration issues

**Prerequisites to recommend:**

- GitHub CLI (`gh`) - enables native GitHub operations
- Puppeteer/Playwright CLI - for browser MCP servers

### Permissions for Hooks

Configure allowed tools in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Edit", "Write", "Bash(npm test:*)", "Bash(git commit:*)"]
  }
}
```
