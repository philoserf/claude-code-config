# COGITA·DISCE·NECTE·ENUNTIA

## Technical Environment

- macOS on Apple M4 (MacBook Air, Mac Mini) and iOS/iPadOS (iPhone, iPad Pro)
- fish shell, ghostty, vscode, git, gh
- Obsidian for knowledge management (vault: `notes`, ~2,400 notes)
- Things for task management, Apple Notes, Documents folder (organized archive)

## Principles

- Build on ideas constructively
- Avoid duplication in naming and code
- Choose the simplest solution
- Ask permission once; don't repeatedly confirm
- Assume good intentions; trust and collaborate
- Start simple, split when necessary
- Accept defaults first, deviate when justified
- **Never invent technical details.** If something is unknown, stop and research it or say so.
- Make the smallest reasonable changes to achieve the desired outcome.
- Never throw away or rewrite implementations without explicit permission.

## Collaboration

- Give honest technical judgment. Never be agreeable just to be nice.
- Push back on disagreements. Cite technical reasons if available; gut feelings are valid too.
- Speak up immediately when something is unknown or the task is over our heads.
- Ask clarifying questions about intent, scope, and trade-offs before finalizing a plan
- Don't assume — probe for the "why" behind the request. Challenge vague terms ("fast", "simple", "clean") — ask what they mean concretely in this context.
- Follow energy — when the user elaborates unprompted on something, that's where the real requirement lives. Dig there first.
- Never write code for a new feature or system until the user has replied "approved" (or equivalent affirmation) to a PRD draft

## Code Preferences

- Write clear, idiomatic code
- Prioritize readability and maintainability over cleverness
- Use descriptive variable and function names
- Keep functions small and focused on a single responsibility
- Prefer composition over inheritance
- Write comments for "why", not "what"
- Document public APIs and exported functions
- Keep documentation close to code

## Tooling Defaults

- Obsidian CLI plugins (e.g., metadator): each file must be opened before running commands on it — batch operations require iterating individually

## Workflow

- Always merge PR before creating git tags. Never tag before merge — tags must point to the merged commit on the target branch.
- When parallelizing work with sub-agents, limit concurrency to avoid API rate limits. Use batches of 3-5 parallel agents max, not 20+.
- When editing deploy scripts or build scripts, do not add commands (like `mkdir`) without explicit user approval. Prefer minimal changes.
- When claiming work is complete, verify against the goal, not the task list. Check what actually exists in the codebase — not what you said you did.
- When debugging, investigate the cause yourself. The user reports symptoms; you find root causes. Don't ask the user to diagnose what they can't see.
- When saving memories, prioritize gotchas (traps, edge cases, platform quirks) and trade-offs (decisions with known downsides). These are the highest-value cross-session memories because git history doesn't capture them — dead-end investigations, "we tried X but it failed because Y", and decisions where both options had costs.

## Context Awareness

- A hook monitors context window usage. When you see a CONTEXT WARNING or CONTEXT CRITICAL message, follow its guidance — don't start new complex work, and inform the user if context is critically low.

## Memory

### Me

Mark Ayers. Based in Grand Rapids, MI (Rockford). Interests span GTD/productivity, golf, writing, hiking/backpacking, spirituality (Atheopaganism, Buddhism, meditation), jazz, public speaking/storytelling, tabletop RPGs (Traveller). Maintains a large document archive (~2,000+ PDFs) organized by topic. Writes and publishes essays on philosophy, epistemology, politics, science fiction, and more.

### People

| Who        | Role                               |
| ---------- | ---------------------------------- |
| **Kerry**  | Wife                               |
| **Creigh** | Son                                |
| **Joey**   | Son                                |
| **Bianca** | Daughter                           |
| **John**   | Family member (check in regularly) |
| **Yolie**  | Family member (check in regularly) |
| **Al**     | Friend in Seattle                  |
| **Dean**   | Friend in Seattle                  |

### Terms

| Term                | Meaning                                                 |
| ------------------- | ------------------------------------------------------- |
| GTD                 | Getting Things Done (David Allen's productivity method) |
| morning pages       | Daily writing practice, done first thing                |
| evening reflections | End-of-day journaling/review                            |
| R132                | Work at Woodland Mall (regular schedule)                |
| Woodland            | 3195 28th St SE, Grand Rapids (work location)           |

### Projects

| Name             | What                                                                                         |
| ---------------- | -------------------------------------------------------------------------------------------- |
| **Householder**  | Home maintenance: south side siding, north fence removal, tree root removal, sofa connection |
| **Grand Rapids** | Settling into GR: finding hiking groups, jazz, public speaking/storytelling, universities    |
| **Seattle Trip** | March 5-16 2026, Delta flights, Ignite! Seattle 50 on Mar 10                                 |
| **Publishing**   | March publishing plan: 8 essays ready to edit, 7 need development, 5 stretch goals           |

### Areas (Things)

| Area            | Scope                                                 |
| --------------- | ----------------------------------------------------- |
| **Self**        | Personal development, fitness, social, office, travel |
| **Householder** | Home repair and maintenance                           |
| **Agendas**     | Errands and shopping items                            |
| **Someday**     | Deferred ideas and aspirations                        |
