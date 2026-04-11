# Example Report

A completed recommendation report for a Next.js + Supabase SaaS application.

---

## Claude Code Automation Recommendations

I've analyzed your codebase and identified the top automations for each category. Here are my top 1-2 recommendations per type:

### Codebase Profile

- **Type**: TypeScript / Node.js
- **Framework**: Next.js 14 (App Router)
- **Key Libraries**: Supabase, Stripe, TailwindCSS, Playwright

---

### MCP Servers

#### context7

**Why**: Your project uses Next.js, Supabase, Stripe, and TailwindCSS — context7 provides live documentation for all of these, reducing hallucinated APIs and outdated patterns.
**Install**: `claude mcp add context7`

#### Supabase MCP

**Why**: You have `@supabase/supabase-js` in dependencies and 12 migration files — direct database access lets Claude query tables, inspect schemas, and debug auth flows without manual SQL.
**Install**: `claude mcp add supabase -- npx -y @supabase/mcp-server-supabase@latest`

---

### Skills

#### create-migration

**Why**: You have 12 existing migrations following a timestamp-prefix convention. A skill ensures new migrations match the pattern and run validation.
**Create**: `.claude/skills/create-migration/SKILL.md`
**Invocation**: User-only (`disable-model-invocation: true`)

#### project-conventions

**Why**: Your codebase uses `Result<T, E>` patterns, barrel exports, and specific naming conventions that Claude should follow automatically.
**Create**: `.claude/skills/project-conventions/SKILL.md`
**Invocation**: Claude-only (`user-invocable: false`)

---

### Hooks

#### Auto-format on Edit (Prettier + ESLint)

**Why**: Found `.prettierrc.json` and `eslint.config.js` — auto-formatting on every edit keeps code consistent without manual runs.
**Where**: `.claude/settings.json`

#### Block .env edits

**Why**: Found `.env`, `.env.local`, and `.env.production` — these contain Supabase keys and Stripe secrets that should never be modified by Claude.
**Where**: `.claude/settings.json`

---

### Subagents

#### security-reviewer

**Why**: Your codebase handles Stripe payments (`app/api/webhooks/stripe/`), user auth (`lib/auth/`), and PII (`app/api/users/`) — a dedicated security reviewer catches OWASP vulnerabilities in these critical paths.
**Where**: `.claude/agents/security-reviewer.md`

---

**Want more?** Ask for additional recommendations for any specific category (e.g., "show me more MCP server options" or "what other hooks would help?").

**Want help implementing any of these?** Just ask and I can help you set up any of the recommendations above.
