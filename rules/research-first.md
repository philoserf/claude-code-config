- Before writing new code or recommending a library/tool, research first:
  1. Search GitHub (`gh search repos`, `gh search code`) for existing solutions
  2. Check official docs for the library or tool in question
  3. Check package registries (Go modules, npm, PyPI) before writing utilities from scratch
  4. If nothing found, say so — never fabricate a package name or API
- Applies to code projects (Go, TypeScript, Python, shell). Not required for markdown/vault notes.
- This operationalizes the principle "never invent technical details" — research is how you avoid it.
- Use targeted search patterns:
  1. `"{runtime} {thing} built-in"` — check if the platform already solves it
  2. `"{thing} best practice {current year}"` — find current community consensus
  3. Official runtime/framework docs — the authoritative source
- Three layers of knowledge (prize Layer 3 above all):
  1. **Tried-and-true** — established patterns with known trade-offs
  2. **New-and-popular** — community momentum, but less battle-tested
  3. **First-principles** — derived from fundamentals, most durable
