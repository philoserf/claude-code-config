---
name: brainstorming
description: Explores user intent, requirements, and design through conversational dig-and-advise before implementation. Use when starting creative work — features, components, architecture — where the problem space is not yet well-defined. Produces an approved design that lives in the conversation, not a committed artifact.
---

# Brainstorming

Turn a rough idea into an approved design through collaborative dialogue. The goal is shared understanding before implementation, not a heavyweight deliverable.

Design outputs live in the conversation. No spec file is written. When durable artifacts are needed, `writing-plans` produces them.

## Process

1. **Explore context first** — read recent commits, current files, relevant docs. Understand what exists before proposing what to add.
2. **Scope check** — if the request spans multiple independent subsystems (chat + billing + analytics + auth), flag it. Don't refine details of a project that needs decomposition first. Help split into sub-projects, each with its own design cycle.
3. **Ask clarifying questions one at a time.** Prefer multiple choice when possible. Focus on purpose, constraints, success criteria. One question per message.
4. **Propose 2-3 approaches with tradeoffs.** Lead with a recommendation and the reasoning. Present it as something the user can redirect, not a decided plan.
5. **Present the design in sections.** Scale each section to its complexity — a few sentences for simple parts, more for nuanced ones. Get approval after each section before moving on.
6. **Exit on approval.** State "design approved, ready to plan" and stop. No file written.

## Design principles

- Break the system into small, well-bounded units with clear interfaces. Each unit has one responsibility and can be understood independently.
- Files that change together live together. Split by responsibility, not technical layer.
- Prefer smaller focused files over large ones doing too much.
- In existing codebases, explore current structure first and follow established patterns. Where existing code has problems that directly affect the work, include targeted improvements — but don't propose unrelated refactoring.
- Ruthless YAGNI. Remove unnecessary features from every design.

## Scale to the problem

Simple projects get short designs — a few sentences is fine. Complex projects get more detail. Don't skip the conversation for "simple" projects though — "simple" is where unexamined assumptions cause the most wasted work.

## Invocation

- Standalone: `brainstorming` — start from a user-provided topic
- From `/use-discipline`: invoked after problem framing converges

## What this skill does not do

- No committed design doc
- No TodoWrite per step
- No hard gates or mandatory checklists
- No auto-invocation of other skills

When the design is approved, the user decides what comes next — `writing-plans` for durable artifacts, direct implementation for trivial changes, or further exploration.
