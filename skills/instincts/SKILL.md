---
name: instincts
description: Advanced learning system that captures your coding patterns from sessions and evolves them into reusable skills, commands, and agents with confidence scoring. Use when you want Claude to learn from your session history, remember how you do things, formalize repeated workflows, build personalized tools, automate things you do repeatedly, teach Claude your preferences, export patterns for sharing, or adapt to your coding style. Also triggers on learn my patterns, remember my preferences, track my habits, customize Claude behavior.
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob, Task]
---

# Instincts - Behavioral Learning System

An advanced learning system that turns your Claude Code sessions into reusable knowledge through atomic "instincts" - small learned behaviors with confidence scoring.

## The Instinct Model

An instinct is a small learned behavior:

```yaml
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
domain: "code-style"
source: "session-observation"
---

# Prefer Functional Style

## Action
Use functional patterns over classes when appropriate.

## Evidence
- Observed 5 instances of functional pattern preference
- User corrected class-based approach to functional on 2025-01-15
```

**Properties:**

- **Atomic** — one trigger, one action
- **Confidence-weighted** — 0.3 = tentative, 0.9 = near certain
- **Domain-tagged** — code-style, testing, git, debugging, workflow, etc.
- **Evidence-backed** — tracks what observations created it

## How It Works

```text
Session Activity
      │
      │ Hooks capture prompts + tool use (100% reliable)
      ▼
┌─────────────────────────────────────────┐
│         observations.jsonl              │
│   (prompts, tool calls, outcomes)       │
└─────────────────────────────────────────┘
      │
      │ Observer agent reads (background, Haiku)
      ▼
┌─────────────────────────────────────────┐
│          PATTERN DETECTION              │
│   • User corrections → instinct         │
│   • Error resolutions → instinct        │
│   • Repeated workflows → instinct       │
└─────────────────────────────────────────┘
      │
      │ Creates/updates
      ▼
┌─────────────────────────────────────────┐
│         instincts/personal/             │
│   • prefer-functional.md (0.7)          │
│   • always-test-first.md (0.9)          │
│   • use-zod-validation.md (0.6)         │
└─────────────────────────────────────────┘
      │
      │ /evolve clusters
      ▼
┌─────────────────────────────────────────┐
│              evolved/                   │
│   • commands/new-feature.md             │
│   • skills/testing-workflow.md          │
│   • agents/refactor-specialist.md       │
└─────────────────────────────────────────┘
```

## Commands

| Command                   | Description                                    |
| ------------------------- | ---------------------------------------------- |
| `/instinct-status`        | Show all learned instincts with confidence     |
| `/evolve`                 | Cluster related instincts into skills/commands |
| `/instinct-export`        | Export instincts for sharing                   |
| `/instinct-import <file>` | Import instincts from others                   |
| `/start-observer`         | Start, stop, or check background observer      |

## Configuration

Edit `instincts.yaml`:

```yaml
observation:
  enabled: true
  store_path: ~/.claude/learning/observations.jsonl
  max_file_size_mb: 10
  archive_after_days: 7
  capture_tools:
    - Edit
    - Write
    - Bash
    - Read
    - Grep
    - Glob
  ignore_tools:
    - TodoWrite

instincts:
  personal_path: ~/.claude/learning/instincts/personal/
  inherited_path: ~/.claude/learning/instincts/inherited/
  min_confidence: 0.3
  auto_approve_threshold: 0.7
  confidence_decay_rate: 0.02
  max_instincts: 100

observer:
  enabled: false
  model: haiku
  run_interval_minutes: 5
  patterns_to_detect:
    - user_corrections
    - error_resolutions
    - repeated_workflows
    - tool_preferences
    - file_patterns

evolution:
  cluster_threshold: 3
  evolved_path: ~/.claude/learning/evolved/
  auto_evolve: false
```

## File Structure

```text
~/.claude/learning/
├── identity.json           # Your profile, technical level
├── observations.jsonl      # Current session observations
├── observations.archive/   # Processed observations
├── instincts/
│   ├── personal/           # Auto-learned instincts
│   └── inherited/          # Imported from others
└── evolved/
    ├── agents/             # Generated specialist agents
    ├── skills/             # Generated skills
    └── commands/           # Generated commands
```

## Integration with Skill Creator

When you use the [Skill Creator GitHub App](https://skill-creator.app), it generates instinct collections to feed into the learning system.

Instincts from repo analysis have `source: "repo-analysis"` and include the source repository URL.

## Confidence Scoring

Confidence evolves over time:

| Score | Meaning      | Behavior                      |
| ----- | ------------ | ----------------------------- |
| 0.3   | Tentative    | Suggested but not enforced    |
| 0.5   | Moderate     | Applied when relevant         |
| 0.7   | Strong       | Auto-approved for application |
| 0.9   | Near-certain | Core behavior                 |

**Confidence increases** when:

- Pattern is repeatedly observed
- User doesn't correct the suggested behavior
- Similar instincts from other sources agree

**Confidence decreases** when:

- User explicitly corrects the behavior
- Pattern isn't observed for extended periods
- Contradicting evidence appears

## Why Hooks for Observation?

Hooks fire **100% of the time**, deterministically. This means:

- Every tool call is observed
- No patterns are missed
- Learning is comprehensive

## Privacy

- Observations stay **local** on your machine
- Only **instincts** (patterns) can be exported
- No actual code or conversation content is shared
- You control what gets exported

## Additional Resources

- [COMMANDS.md](COMMANDS.md) - Complete reference for all 4 commands
- [ARCHITECTURE.md](ARCHITECTURE.md) - Observer agent, hooks, and implementation details
- [CONFIG.md](CONFIG.md) - Detailed configuration and options

## Related

- [Skill Creator](https://skill-creator.app) - Generate instincts from repo history
- [Homunculus](https://github.com/humanplane/homunculus) - Inspiration for the architecture
- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) - Continuous learning section

---

_Instinct-based learning: teaching Claude your patterns, one observation at a time._
