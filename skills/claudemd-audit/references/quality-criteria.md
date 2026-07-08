# CLAUDE.md Quality Criteria

## Contents

- [Scoring Rubric](#scoring-rubric)
- [Assessment Process](#assessment-process)
- [Red Flags](#red-flags)

## Scoring Rubric

### 1. Commands/Workflows (20 points)

**20 points**: All essential commands documented with context

- Build, test, lint, deploy commands present
- Development workflow clear
- Common operations documented

**15 points**: Most commands present, some missing context

**10 points**: Basic commands only, no workflow

**5 points**: Few commands, many missing

**0 points**: No commands documented

### 2. Architecture Clarity (20 points)

**20 points**: Clear codebase map

- Key directories explained
- Module relationships documented
- Entry points identified
- Data flow described where relevant

**15 points**: Good structure overview, minor gaps

**10 points**: Basic directory listing only

**5 points**: Vague or incomplete

**0 points**: No architecture info

### 3. Non-Obvious Patterns (15 points)

**15 points**: Gotchas and quirks captured

- Known issues documented
- Workarounds explained
- Edge cases noted
- "Why we do it this way" for unusual patterns

**10 points**: Some patterns documented

**5 points**: Minimal pattern documentation

**0 points**: No patterns or gotchas

### 4. Conciseness (15 points)

**15 points**: Dense, valuable content

- No filler or obvious info
- Each line adds value
- No redundancy with code comments

**10 points**: Mostly concise, some padding

**5 points**: Verbose in places

**0 points**: Mostly filler or restates obvious code

### 5. Currency (15 points)

**15 points**: Reflects current codebase

- Commands work as documented
- File references accurate
- Tech stack current

**10 points**: Mostly current, minor staleness

**5 points**: Several outdated references

**0 points**: Severely outdated

### 6. Actionability (15 points)

**15 points**: Instructions are executable

- Commands can be copy-pasted
- Steps are concrete
- Paths are real

**10 points**: Mostly actionable

**5 points**: Some vague instructions

**0 points**: Vague or theoretical

## Assessment Process

1. Read the CLAUDE.md file completely
2. Cross-reference with actual codebase:
   - Verify documented commands look correct against the codebase (mentally — this skill has no `Bash` access to actually run them)
   - Check if referenced files exist
   - Verify architecture descriptions
3. Score each criterion
4. Calculate total and assign grade
5. List specific issues found
6. Propose concrete improvements

## Red Flags

Consolidated checklist of what to flag during an audit:

- Commands that would fail (wrong paths, missing deps) or are stale / no longer work
- Required tools or dependencies not mentioned
- References to deleted files/folders
- Architecture or file-structure descriptions that no longer match the tree
- Missing environment setup (required env vars or config)
- Broken or stale test commands
- Undocumented gotchas — non-obvious patterns not captured
- Outdated tech versions
- Copy-paste from templates without customization
- Generic advice not specific to the project
- "TODO" items never completed
- Duplicate info across multiple CLAUDE.md files
