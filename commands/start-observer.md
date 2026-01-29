---
name: start-observer
description: Start, stop, or check the status of the background observer agent
command: /start-observer
implementation: ~/.claude/scripts/start-observer.sh
---

# Start Observer Command

Manages the background observer agent that continuously analyzes observations and creates instincts.

## Usage

```text
/start-observer           # Start observer in background
/start-observer stop      # Stop the running observer
/start-observer status    # Check if observer is running
```

## What It Does

The observer agent:

1. Runs continuously in the background (every 5 minutes by default)
2. Reads observations from `~/.claude/learning/observations.jsonl`
3. Detects patterns (user corrections, error resolutions, repeated workflows, etc.)
4. Creates/updates instinct files in `~/.claude/learning/instincts/personal/`
5. Logs activity to `~/.claude/learning/observer.log`

## Examples

### Start observer

```bash
/start-observer
```

Output:

```text
Observer started (PID: 12345)
Log: ~/.claude/learning/observer.log
```

### Check status

```bash
/start-observer status
```

Output:

```text
Observer is running (PID: 12345)
Log: ~/.claude/learning/observer.log
Observations: 127 events logged
```

### Stop observer

```bash
/start-observer stop
```

Output:

```text
Stopping observer (PID: 12345)...
Observer stopped.
```

## Configuration

Observer behavior is controlled by `~/.claude/learning/instincts.yaml`:

- `observer.enabled` - Auto-start on session begin (requires Claude Code integration)
- `observer.model` - Which Claude model to use (default: haiku)
- `observer.run_interval_minutes` - How often to analyze (default: 5)
- `observer.min_observations_to_analyze` - Wait for N observations before analyzing (default: 20)
- `observer.patterns_to_detect` - Which patterns to look for

See [CONFIG.md](../skills/instincts/CONFIG.md) for detailed options.

## Requirements

- `~/.claude/learning/` directory structure initialized
- `instincts.yaml` configuration file in place
- Observer enabled in settings (or started manually)

## Performance Notes

- Runs as a detached background process
- Uses Haiku model by default (fast and cheap)
- Only analyzes when there are 20+ pending observations (configurable)
- Writes PID to `~/.claude/learning/.observer.pid`
- Logs to `~/.claude/learning/observer.log`

## Troubleshooting

**Observer not starting**:

```bash
# Check if it's already running
/start-observer status

# Check the log
tail -f ~/.claude/learning/observer.log
```

**Observer running but not creating instincts**:

```bash
# Check observation count
wc -l ~/.claude/learning/observations.jsonl

# Verify configuration
cat ~/.claude/learning/instincts.yaml | grep -A 5 observer:
```

**Stop stale observer**:

```bash
/start-observer stop
rm -f ~/.claude/learning/.observer.pid
/start-observer
```
