---
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
disable-model-invocation: true
description: Audits Claude Code skills, hooks, agents, rules — lint checks, quality scores across 6 dimensions, prioritized fixes. Use when reviewing, auditing, scoring, or validating any customization. Produces pass/fail checks, scores, and P1-P5 action items.
---

This skill analyzes and reports. It does not modify files — surface findings and let the user decide what to apply.

## Reference Files

- [dimensions.md](references/dimensions.md) — 6 weighted quality dimensions: rubrics, evidence, improvement patterns
- [lint-rules.md](references/lint-rules.md) — Structural validation checks by customization type (PASS/WARN/FAIL)
- [prioritization.md](references/prioritization.md) — P1-P5 impact/effort matrix for recommendations
- [scoring-examples.md](references/scoring-examples.md) — Calibration: real skill assessments with score rationale
- [improvement-examples.md](references/improvement-examples.md) — Before/after fix examples by dimension
- [report-template.md](assets/report-template.md) — Unified 3-phase report format

## Scoping

- Current working directory is the project root
- Look for `<project-root>/.claude/` as the customization directory
- When the project root IS `~/.claude/`, the customization directory is the project root itself
- If a specific file or directory is passed as an argument, review that target directly
- Check `settings.json` for integration validation

Once inside the customization directory, locate the target by type:

- **Skills**: `skills/<name>/SKILL.md`
- **Agents**: `agents/*.md` (if an `agents/` dir exists)
- **Hooks**: resolve the script path from the matching `hooks` entry in `settings.json`
- **Rules**: rule files under `rules/` or frontmatter `globs`-scoped files

## Three Phases

**Phase 1 — Lint**: Structural validation. Each check reports PASS, WARN, or FAIL. Rules in [lint-rules.md](references/lint-rules.md). Lint failures contextualize scores (e.g., missing description → Trigger Coverage = 1).

**Phase 2 — Score**: 6 dimensions table (Effectiveness 28%, Clarity 22%, Best Practices 17%, Documentation 15%, Verification 10%, Trigger Coverage 8%). Quality tiers table (Production Ready 4.5-5.0, Good 3.5-4.4, Needs Work 2.5-3.4, Poor 1.5-2.4, Unusable 1.0-1.4). Rubrics in [dimensions.md](references/dimensions.md).

**Phase 3 — Improve**: Each finding becomes a recommendation with dimension, impact/effort, priority (P1-P5), and specific fix. P1 first. Matrix in [prioritization.md](references/prioritization.md).

## Process

1. Locate target and identify customization type (skill, agent, hook, rule). If the target doesn't exist or the type can't be determined, report FAIL and stop before scoring.
2. Run structural lint checks ([lint-rules.md](references/lint-rules.md))
3. Score each dimension ([dimensions.md](references/dimensions.md))
4. Calculate weighted total and determine quality tier
5. Generate prioritized recommendations ([prioritization.md](references/prioritization.md))
6. Verify: weighted sum arithmetic checks out; tier matches score range
7. Produce report ([report-template.md](assets/report-template.md))

**Batch reviews:** when the target is multiple customizations (a directory of skills, or a full sweep), enumerate the targets first, run steps 2–6 per target, then produce one consolidated report — the comparison table plus abbreviated per-target format from [report-template.md](assets/report-template.md), with full detail reserved for P1/P2 findings.

## Scoring Principles

- **Be specific** — cite exact text, line numbers, files as evidence
- **Be fair** — consider the customization's intended scope and type
- **Be consistent** — apply the same standards across all customizations
- **Be calibrated** — a 5 is exemplary; see [scoring-examples.md](references/scoring-examples.md) for anchors

## Do not use when

- Reviewing application or project code (not harness files) — use `code-audit`
- Reviewing a specific git diff for bugs — use `/code-review`
- Evaluating config only against a newly-shipped Claude Code release — use `cc-release-review`
