# Architecture & Implementation

Deep dive into how continuous-learning works.

## Observation Hooks

Observation is the foundation of the system. Two hooks capture all tool usage:

### PreToolUse Hook

Fires **before** any tool executes in your session.

**Location**: `hooks/instincts-observe.sh`

**Captures**:

- User prompt/query (the request Claude received)
- Tool name being invoked
- Tool parameters
- Session context (time, file context, etc.)

**Why pre-capture**: Ensures we capture the intent before the tool runs

### PostToolUse Hook

Fires **after** the tool completes.

**Location**: `hooks/observe.sh post`

**Captures**:

- Tool output/result
- Execution time
- Success/failure status
- Any errors

**Why post-capture**: Lets us see outcomes and correlate with results

### Hook Reliability

Unlike skills (which fire ~50-80% of the time), hooks fire **100% of the time**. This guarantees:

- Complete observation coverage
- No missed patterns
- Deterministic learning

**Setup**: Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/instincts-observe.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/instincts-observe.sh"
          }
        ]
      }
    ]
  }
}
```

## Observations Storage

All captured data flows into `observations.jsonl` (one JSON object per line).

**Location**: `~/.claude/learning/observations.jsonl`

**Format**:

```json
{
  "timestamp": "2025-01-29T13:45:23Z",
  "session_id": "sess-abc123",
  "phase": "pre",
  "tool": "Grep",
  "params": { "pattern": "TODO:", "path": "src/" },
  "prompt": "Find all TODO comments in the codebase"
}
```

**Lifecycle**:

1. Hooks write observations to current `.jsonl` file
2. File grows until it reaches `max_file_size_mb` (default: 10MB)
3. Old observations are archived to `observations.archive/`
4. Observer agent reads and analyzes observations

**Configuration**: See `instincts.yaml`:

- `max_file_size_mb` - Size before rotation
- `archive_after_days` - When to archive processed observations
- `capture_tools` - Which tools to observe (default: Edit, Write, Bash, Read, Grep, Glob)
- `ignore_tools` - Tools to skip

## Observer Agent

The Observer is a background Haiku agent that analyzes observations and creates instincts.

**Location**: `agents/observer.md` and `agents/start-observer.sh`

**Process**:

1. **Read Observations**: Loads unprocessed observations from `observations.jsonl`
2. **Detect Patterns**: Looks for:
   - User corrections (when you manually fix something Claude did)
   - Error resolutions (when an error is fixed)
   - Repeated workflows (the same sequence multiple times)
   - Tool preferences (always using specific tools for tasks)
   - File patterns (how you organize code)

3. **Create/Update Instincts**: Generates markdown files in `~/.claude/learning/instincts/personal/`

4. **Confidence Scoring**: Assigns confidence (0.3-0.9) based on:
   - Frequency of observation
   - User validation (corrections increase confidence)
   - Consistency across sessions

**Running Manually**:

```bash
~/.claude/scripts/start-observer.sh
```

**Configuration**: See `instincts.yaml`:

- `observer.enabled` - Turn observer on/off
- `observer.model` - AI model (default: haiku for speed)
- `observer.run_interval_minutes` - How often to analyze (default: 5)
- `observer.min_observations_to_analyze` - Wait for N observations before analyzing
- `observer.patterns_to_detect` - Which patterns to look for

## Instinct Format

Each instinct is a small, focused markdown file with metadata:

**Location**: `~/.claude/learning/instincts/personal/prefer-functional-style.md`

**Format**:

```yaml
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
domain: "code-style"
source: "session-observation"
created: "2025-01-15"
last_observed: "2025-01-29"
---

# Prefer Functional Style

## Action
Use functional patterns over classes when appropriate.

## Evidence
- Observed 5 instances of functional pattern preference
- User corrected class-based approach to functional on 2025-01-15
- Consistent across 3 different projects
```

**Properties**:

- **id** - Unique identifier (kebab-case)
- **trigger** - When this instinct applies
- **confidence** - 0.3 (tentative) to 0.9 (near-certain)
- **domain** - code-style, testing, git, workflow, debugging, etc.
- **source** - "session-observation" or "repo-analysis" or "inherited"
- **created/last_observed** - Timestamps for aging and decay

## Evolution: From Instincts to Skills

The evolution process turns related instincts into structured, reusable tools.

**Triggering**:

```text
/evolve
```

**Process**:

1. **Cluster Detection**: Groups instincts by domain and similarity
2. **Threshold Check**: Only evolve if cluster has ≥3 related instincts (configurable)
3. **Type Selection**: Determines if cluster becomes a skill, command, or agent:
   - **Skill**: Patterns about how to approach problems (e.g., "testing methodology")
   - **Command**: Utility patterns for specific tasks (e.g., "git workflow")
   - **Agent**: Complex patterns needing multiple steps (e.g., "code refactoring")

4. **Generation**: Creates new markdown file in `~/.claude/learning/evolved/{type}/`
5. **Linking**: Tracks instinct sources for evolution history

**Example Evolution**:

Input instincts:

- `always-test-first.md` (0.9 confidence)
- `test-edge-cases.md` (0.8 confidence)
- `use-jest-fixtures.md` (0.7 confidence)

Output skill:

```markdown
---
name: tdd-workflow
source_instincts: [always-test-first, test-edge-cases, use-jest-fixtures]
evolved_from: "instinct clustering"
---

# TDD Workflow Skill

...
```

**Configuration**: See `instincts.yaml`:

- `evolution.cluster_threshold` - Instincts required to evolve (default: 3)
- `evolution.evolved_path` - Where to store evolved artifacts
- `evolution.auto_evolve` - Automatically run /evolve (default: false, manual)

## File Structure

Repository structure (this is a Claude Code installation template):

```text
.
├── skills/
│   └── instincts/                   # This skill (documentation)
│       ├── SKILL.md
│       ├── ARCHITECTURE.md
│       ├── COMMANDS.md
│       ├── CONFIG.md
│       └── instincts.yaml
├── hooks/
│   └── instincts-observe.sh         # Observation hook (PreToolUse/PostToolUse)
├── agents/
│   └── observer.md                  # Observer agent definition
├── commands/
│   ├── instinct-status.md           # Command: show all instincts
│   ├── instinct-export.md           # Command: export instincts
│   ├── instinct-import.md           # Command: import instincts
│   └── evolve.md                    # Command: evolve instincts to skills/commands/agents
├── scripts/
│   ├── instinct-cli.py              # Python CLI implementation
│   └── start-observer.sh            # Start background observer
└── .claude-plugin/
    └── plugin.json                  # Plugin manifest
```

**Learning data** (created at runtime in `~/.claude/learning/`):

```text
~/.claude/learning/
├── identity.json                    # Your profile (technical level, specialties)
├── observations.jsonl               # Current session observations
├── observations.archive/            # Processed/rotated observations
├── instincts/
│   ├── personal/                    # Auto-learned patterns from your sessions
│   │   ├── prefer-functional.md
│   │   ├── always-test-first.md
│   │   └── use-zod-validation.md
│   └── inherited/                   # Imported from others
│       ├── team-testing-standards.md
│       └── project-conventions.md
└── evolved/
    ├── agents/                      # Generated specialist agents
    ├── skills/                      # Generated skills
    └── commands/                    # Generated commands
```

## Configuration

All behavior is controlled by `instincts.yaml` in the `skills/instincts/` directory. Copy this to `~/.claude/` alongside other configurations if needed.

**Key sections**:

| Section       | Controls                                             |
| ------------- | ---------------------------------------------------- |
| `observation` | Hook behavior, file size, archival                   |
| `instincts`   | Confidence thresholds, decay rates, instinct storage |
| `observer`    | Background agent settings, pattern detection         |
| `evolution`   | Clustering and skill generation                      |
| `integration` | Skill Creator compatibility and API configuration    |

See `CONFIG.md` for detailed option reference.

## Privacy & Control

**What gets stored locally**:

- Your raw observations (prompts, tool calls, outcomes)
- Your instincts (patterns, not code)
- Your evolved skills (generated documentation)

**What can be exported**:

- Only instinct patterns (via `/instinct-export`)
- Observations are **never** shared automatically
- You explicitly export what you want to share

**What cannot be exported**:

- Raw conversation content
- Actual code from your sessions
- Personal identifiable information

## Implementation Files

| File                       | Purpose                                                                              |
| -------------------------- | ------------------------------------------------------------------------------------ |
| `hooks/observe.sh`         | PreToolUse and PostToolUse hook implementation                                       |
| `agents/observer.md`       | Observer agent definition                                                            |
| `agents/start-observer.sh` | Script to start background observer                                                  |
| `scripts/instinct-cli.py`  | Shared implementation backend for all four commands (status, export, import, evolve) |
| `instincts.yaml`           | All configuration options                                                            |
