---
paths:
  - "bin/**/*.ts"
  - "**/*.ts"
  - "**/*.tsx"
  - "package.json"
  - "biome.json"
  - "tsconfig.json"
---

# TypeScript Rules

## Tooling

- Use `bunx` to run external tools and CLI utilities (e.g., `bunx tsx`, `bunx biome check`, `bunx esbuild`)
- Use `bun run <script>` for package.json scripts defined in `scripts` section
- Never use `npm` or `yarn`—use `bun install` for dependencies

## Runtime & Execution

- Target Bun as the runtime. Use Bun's native APIs where applicable (file I/O, testing, bundling)
- Use `bun run` to execute scripts defined in package.json
- Use Bun's native test runner with `bun test` for all test files (_.test.ts,_.spec.ts)

## Code Style & Linting

- Biome is the single source of truth for formatting and linting
- Follow biome.json configuration exactly; do not suggest overrides without explicit request
- Run `biome check --fix` or `biome format --write` via `bun run` script when changes are needed
- TypeScript strict mode is enabled; submit to its defaults unless there's a strong reason to deviate

## Packaging & Building

- Use Bun's bundler (`bun build`) for creating bundles
- Use Bun's package exports feature in package.json for multi-entry publishing
- Ensure all TypeScript compiles cleanly with `tsc --noEmit` if a build step exists

## Project Structure

- Respect existing directory structure (e.g., bin/, src/, tests/)
- Follow the conventions established in existing files within each directory
