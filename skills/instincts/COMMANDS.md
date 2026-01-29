# Commands Reference

All available commands for the continuous-learning system.

## `/instinct-status`

Display all learned instincts with their confidence scores and metadata.

**Use when**:

- You want to see what patterns have been learned
- You need to review all personal instincts before evolution
- You want to check confidence scores on specific behaviors

**Output**:
Lists each instinct with:

- ID and name
- Trigger (when it applies)
- Confidence score (0.3-0.9)
- Domain (code-style, testing, git, etc.)
- Last observed date

**See also**: See `commands/instinct-status.md` for full details.

---

## `/evolve`

Cluster related instincts and evolve them into reusable skills, commands, or agents.

**Use when**:

- You have several related instincts that should become a single tool
- You want to formalize patterns into a structured skill or command
- You want to combine personal instincts with inherited patterns

**Process**:

1. Groups instincts by domain and similarity
2. Clusters instincts meeting the threshold (default: 3 related patterns)
3. Generates new skills, commands, or agents from clusters
4. Creates definition files in `~/.claude/learning/evolved/`

**Example**:
If you have instincts for "always write tests first", "prefer TDD", and "test edge cases", `/evolve` would cluster them into a single "TDD Workflow" skill.

**See also**: See `commands/evolve.md` for full details.

---

## `/instinct-export`

Export your learned instincts for sharing with others.

**Use when**:

- You want to share your patterns with a colleague
- You want to contribute your instincts to a community
- You want to back up your instincts

**Output**:
Generates a `.instincts` file containing:

- All personal instincts with confidence scores
- Evidence and observation history
- Domain tags and metadata
- **No actual code or conversation content** (privacy-safe)

**See also**: See `commands/instinct-export.md` for full details.

---

## `/instinct-import <file>`

Import instincts from another user or community source.

**Use when**:

- You want to adopt a colleague's coding patterns
- You want to load community instincts
- You want to integrate patterns from a specific project or team

**Process**:

1. Reads the `.instincts` file
2. Validates instinct format
3. Imports instincts to `~/.claude/learning/instincts/inherited/`
4. Marks them as imported with source attribution

**Note**: Imported instincts are kept separate from your personal ones and have lower default confidence until you validate them.

**See also**: See `commands/instinct-import.md` for full details.

---

## File Location

All command implementations are stored in:

- `commands/instinct-status.md`
- `commands/evolve.md`
- `commands/instinct-export.md`
- `commands/instinct-import.md`
