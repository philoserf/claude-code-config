# Configuration Reference

Complete guide to all options in `instincts.yaml`.

## observation

Controls how sessions are captured by hooks.

```json
"observation": {
  "enabled": true,
  "store_path": "~/.claude/learning/observations.jsonl",
  "max_file_size_mb": 10,
  "archive_after_days": 7,
  "capture_tools": ["Edit", "Write", "Bash", "Read", "Grep", "Glob"],
  "ignore_tools": ["TodoWrite"]
}
```

### enabled

- **Type**: boolean
- **Default**: true
- **Purpose**: Turn observation on/off (disable to pause learning)

### store_path

- **Type**: string (path)
- **Default**: `~/.claude/learning/observations.jsonl`
- **Purpose**: Where to write observations
- **Notes**: Use `~` to reference home directory

### max_file_size_mb

- **Type**: number
- **Default**: 10
- **Purpose**: Rotate observations file when it exceeds this size
- **Notes**: Higher values = fewer rotations, larger files. Lower = more frequent archival.

### archive_after_days

- **Type**: number
- **Default**: 7
- **Purpose**: Move processed observations to archive after N days
- **Notes**: Archived observations can still be re-analyzed if needed

### capture_tools

- **Type**: array of strings
- **Default**: ["Edit", "Write", "Bash", "Read", "Grep", "Glob"]
- **Purpose**: Which tools to observe
- **Options**: Any Amp tool name (Read, Bash, Grep, Glob, edit_file, create_file, etc.)
- **Notes**: Restricting reduces file size but may miss patterns

### ignore_tools

- **Type**: array of strings
- **Default**: ["TodoWrite"]
- **Purpose**: Tools to explicitly skip (opposite of capture_tools)
- **Notes**: Useful for noisy tools that don't contribute to learning

---

## instincts

Controls how instincts are stored and scored.

```json
"instincts": {
  "personal_path": "~/.claude/learning/instincts/personal/",
  "inherited_path": "~/.claude/learning/instincts/inherited/",
  "min_confidence": 0.3,
  "auto_approve_threshold": 0.7,
  "confidence_decay_rate": 0.02,
  "max_instincts": 100
}
```

### personal_path

- **Type**: string (path)
- **Default**: `~/.claude/learning/instincts/personal/`
- **Purpose**: Where to store auto-learned instincts
- **Notes**: Use `~` for home directory

### inherited_path

- **Type**: string (path)
- **Default**: `~/.claude/learning/instincts/inherited/`
- **Purpose**: Where imported instincts are stored
- **Notes**: Kept separate so you can distinguish personal vs shared

### min_confidence

- **Type**: number (0.0-1.0)
- **Default**: 0.3
- **Purpose**: Minimum confidence to create an instinct
- **Notes**: Tentative patterns (0.3) are the lowest tier

### auto_approve_threshold

- **Type**: number (0.0-1.0)
- **Default**: 0.7
- **Purpose**: Instincts at this confidence are applied automatically
- **Notes**: Below this threshold, instincts are suggested but not applied

### confidence_decay_rate

- **Type**: number (0.0-1.0)
- **Default**: 0.02
- **Purpose**: How fast confidence decreases if pattern isn't re-observed
- **Notes**: 0.02 = 2% per day decay. Higher = forgetting faster.

### max_instincts

- **Type**: number
- **Default**: 100
- **Purpose**: Maximum number of personal instincts to keep
- **Notes**: Oldest/lowest-confidence instincts are pruned when exceeded

---

## observer

Controls the background observer agent.

```json
"observer": {
  "enabled": false,
  "model": "haiku",
  "run_interval_minutes": 5,
  "min_observations_to_analyze": 20,
  "patterns_to_detect": [
    "user_corrections",
    "error_resolutions",
    "repeated_workflows",
    "tool_preferences",
    "file_patterns"
  ]
}
```

### enabled

- **Type**: boolean
- **Default**: false
- **Purpose**: Run observer agent automatically in background (requires Claude Code auto-startup integration)
- **Notes**: Set to true to enable continuous learning. Otherwise, use `/start-observer` command to start manually. Most users should set this to true after initial setup.

### model

- **Type**: string
- **Default**: "haiku"
- **Options**: "haiku", "sonnet", "opus"
- **Purpose**: Which Claude model to use for pattern detection
- **Notes**: "haiku" is fastest and cheapest. "sonnet"/"opus" are more accurate.

### run_interval_minutes

- **Type**: number
- **Default**: 5
- **Purpose**: How often to run pattern detection (in minutes)
- **Notes**: More frequent = more responsive but more resource usage

### min_observations_to_analyze

- **Type**: number
- **Default**: 20
- **Purpose**: Wait for N observations before analyzing
- **Notes**: Batch analysis is more efficient than analyzing every single observation

### patterns_to_detect

- **Type**: array of strings
- **Default**: ["user_corrections", "error_resolutions", "repeated_workflows", "tool_preferences", "file_patterns"]
- **Options**:
  - `user_corrections` - When you manually fix something
  - `error_resolutions` - How errors are resolved
  - `repeated_workflows` - Sequences you do repeatedly
  - `tool_preferences` - Tools you consistently use for certain tasks
  - `file_patterns` - How you organize and structure files
- **Purpose**: Which patterns to look for in observations
- **Notes**: Remove patterns you don't care about to speed up analysis

---

## evolution

Controls how instincts become skills/commands/agents.

```json
"evolution": {
  "cluster_threshold": 3,
  "evolved_path": "~/.claude/learning/evolved/",
  "auto_evolve": false
}
```

### cluster_threshold

- **Type**: number
- **Default**: 3
- **Purpose**: Minimum instincts required to trigger evolution
- **Notes**: Lower threshold = evolve sooner but with fewer patterns. Higher = wait for more evidence.

### evolved_path

- **Type**: string (path)
- **Default**: `~/.claude/learning/evolved/`
- **Purpose**: Where to store generated skills, commands, and agents
- **Notes**: Subdirectories created automatically: agents/, skills/, commands/

### auto_evolve

- **Type**: boolean
- **Default**: false
- **Purpose**: Automatically run evolution after observer completes
- **Notes**: If true, evolved artifacts are created without manual approval. If false, use `/evolve` command manually.

---

## integration

Controls compatibility with external systems.

```json
"integration": {
  "skill_creator_api": "https://skill-creator.app/api",
  "backward_compatible_v1": true
}
```

### skill_creator_api

- **Type**: string (URL)
- **Default**: "<https://skill-creator.app/api>"
- **Purpose**: Endpoint for Skill Creator GitHub App integration
- **Notes**: Allows generating instincts from repository history

### backward_compatible_v1

- **Type**: boolean
- **Default**: true
- **Purpose**: Legacy configuration option
- **Notes**: Retained for configuration file compatibility

---

## Configuration Examples

### Aggressive Learning (capture everything)

```json
{
  "observation": {
    "enabled": true,
    "max_file_size_mb": 20,
    "capture_tools": [
      "Edit",
      "Write",
      "Bash",
      "Read",
      "Grep",
      "Glob",
      "create_file",
      "edit_file"
    ],
    "ignore_tools": []
  },
  "observer": {
    "enabled": true,
    "run_interval_minutes": 1,
    "min_observations_to_analyze": 5
  },
  "evolution": {
    "cluster_threshold": 2,
    "auto_evolve": true
  }
}
```

**Use case**: You want rapid learning and don't mind extra processing.

### Minimal Learning (capture selectively)

```json
{
  "observation": {
    "enabled": true,
    "capture_tools": ["Read", "Bash"],
    "ignore_tools": ["TodoWrite", "mermaid"]
  },
  "observer": {
    "enabled": false
  },
  "evolution": {
    "cluster_threshold": 5,
    "auto_evolve": false
  }
}
```

**Use case**: You only want to learn critical patterns and prefer manual evolution.

### Privacy-First (minimal capture)

```json
{
  "observation": {
    "enabled": true,
    "max_file_size_mb": 5,
    "archive_after_days": 3,
    "capture_tools": ["Bash", "Grep"],
    "ignore_tools": ["Read", "edit_file", "create_file"]
  },
  "observer": {
    "enabled": false
  }
}
```

**Use case**: You want learning but with minimal data retention and no code capture.

---

## Quick Changes

### Pause Learning (Keep Config)

```json
"observation": { "enabled": false }
```

### Speed Up Analysis

```json
"observer": { "model": "haiku", "run_interval_minutes": 2 }
```

### Only Learn Workflow Patterns

```json
"observer": {
  "patterns_to_detect": ["repeated_workflows"]
}
```

### Disable Evolution

```json
"evolution": { "auto_evolve": false, "cluster_threshold": 999 }
```

### Clear Space (Reduce Instinct Count)

```json
"instincts": { "max_instincts": 50 }
```
