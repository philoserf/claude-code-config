# Skill Groups

Interoperating skills that form workflows when used together.

## Contents

- [Skill Lifecycle](#skill-lifecycle)
- [Code Health Pipeline](#code-health-pipeline)
- [Quality Gates](#quality-gates)
- [Instructions and Learning](#instructions-and-learning)
- [Planning and Setup](#planning-and-setup)

---

## Skill Lifecycle

Skills for building and maintaining other skills. Run in order.

```text
skill-creator → cc-lint → cc-check → skill-quality → skill-improve
   create        validate   test        score          fix
```

| Skill         | Role                        | Input             | Output                   |
| ------------- | --------------------------- | ----------------- | ------------------------ |
| skill-creator | Create new skills           | User intent       | SKILL.md + references    |
| cc-lint       | Structural validation       | Any customization | Pass/fail findings       |
| cc-check      | Functional testing          | Any customization | Test report              |
| skill-quality | Quality scoring (1-5)       | Skills only       | Weighted score + tier    |
| skill-improve | Improvement recommendations | Skills only       | Prioritized action items |

**Typical flow**: Create with `skill-creator`, validate with `cc-lint`, test with `cc-check`, score with `skill-quality`, then iterate with `skill-improve` until satisfied.

---

## Code Health Pipeline

Diagnose-treat-prevent triad for codebase quality.

```text
tech-debt → refactor-clean → tdd-cycle
 diagnose      treat          prevent
```

| Skill          | Role                     | Modifies code? | Relationship                                                 |
| -------------- | ------------------------ | -------------- | ------------------------------------------------------------ |
| tech-debt      | Inventory and prioritize | No (read-only) | Produces roadmap for refactor-clean                          |
| refactor-clean | Apply structural fixes   | Yes            | Consumes tech-debt output; shares rubric with tdd-cycle      |
| tdd-cycle      | Test-first development   | Yes            | REFACTOR phase delegates to refactor-clean's analysis rubric |

**Cross-references**: tdd-cycle's refactor phase uses `refactor-clean/references/analysis-rubric.md` directly.

**Related command**: `deps-audit` covers dependency vulnerabilities and license issues (adjacent concern, not structural debt).

---

## Quality Gates

Language-specific check runners. All follow the same pattern: format (auto-fix) → lint (report) → test (report) → summary table.

| Skill                   | Language        | Formatter        | Linter         | Type checker | Test runner |
| ----------------------- | --------------- | ---------------- | -------------- | ------------ | ----------- |
| bash-quality-gate       | Shell           | shfmt            | shellcheck     | —            | —           |
| go-quality-gate         | Go              | gofumpt          | golangci-lint  | go vet       | go test     |
| python-quality-gate     | Python          | ruff format      | ruff check     | mypy         | pytest      |
| typescript-quality-gate | TypeScript / JS | biome / prettier | biome / eslint | tsc          | bun test    |

**Design**: These are intentionally independent — each is self-contained with no cross-references. Pick the one matching your project language.

**Integration**: refactor-clean and tdd-cycle can invoke the appropriate quality gate during their verify steps, though this is implicit (they detect the test runner) rather than an explicit dependency.

---

## Instructions and Learning

Skills that improve Claude's effectiveness across sessions by updating persistent instructions.

| Skill                | When                         | What it updates           |
| -------------------- | ---------------------------- | ------------------------- |
| cc-md-improver       | Auditing CLAUDE.md quality   | CLAUDE.md files           |
| improve-instructions | After repeated corrections   | CLAUDE.md files           |
| session-review       | End-of-session retrospective | CLAUDE.md, Obsidian vault |

**Flow**: `session-review` identifies patterns → `improve-instructions` proposes CLAUDE.md changes → `cc-md-improver` validates overall quality.

**Distinction**: `improve-instructions` is reactive (responds to conversation patterns), while `cc-md-improver` is proactive (audits against a quality rubric). `session-review` is the broadest — it captures architecture insights, preferences, and gaps beyond just instructions.

---

## Planning and Setup

Skills for starting new work.

| Skill                     | When                                 | Output                     |
| ------------------------- | ------------------------------------ | -------------------------- |
| cc-plan                   | Starting a feature or project        | PRD document               |
| cc-automation-recommender | Setting up Claude Code for a project | Automation recommendations |

**Flow**: `cc-automation-recommender` for initial project setup, then `cc-plan` for each feature within that project.

---

## Standalone Skills

These operate independently without interoperating with other skills:

| Skill           | Purpose                                      |
| --------------- | -------------------------------------------- |
| last30days      | Research recent discussions across platforms |
| let-fate-decide | Entropy-based decision-making via Tarot      |
| vc-ship         | End-to-end git workflow (branch → PR)        |
