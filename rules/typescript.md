---
globs:
  - "bin/**/*.ts"
  - "**/*.ts"
  - "**/*.tsx"
  - "package.json"
  - "biome.json"
  - "tsconfig.json"
---

- Use `bunx` for external tools, `bun run` for scripts, `bun install` for dependencies—never npm/yarn
- Target Bun as the runtime; use Bun's native APIs where applicable (file I/O, testing, bundling)
- Use Bun's native test runner with `bun test` for all test files (_.test.ts,_.spec.ts)
- Biome is the single source of truth for formatting and linting
- Follow biome.json configuration exactly; do not suggest overrides without explicit request
- Run `biome check --fix` or `biome format --write` via `bun run` when changes are needed
- TypeScript strict mode is enabled; submit to its defaults unless there's a strong reason to deviate
- Use Bun's bundler (`bun build`) for creating bundles
- Ensure all TypeScript compiles cleanly with `tsc --noEmit` if a build step exists
- Respect existing directory structure (e.g., bin/, src/, tests/) and conventions
