# Evaluation Process

This document describes the step-by-step process for evaluating Claude Code customizations.

## Step 1: Identify Extension Type

Determine what type of customization is being evaluated:

- Agent (in `~/.claude/agents/` or `.claude/agents/`)
- Command (in `~/.claude/commands/` or `.claude/commands/`)
- Skill (in `~/.claude/skills/` or `.claude/skills/`)
- Hook (in `~/.claude/hooks/` or `.claude/hooks/`)
- Output-Style (in `~/.claude/output-styles/` or `.claude/output-styles/`)
- Setup (entire .claude/ configuration)

## Step 2: Apply Type-Specific Validation

Use Read tool to examine the file(s), then check:

### For Agents

1. Extract frontmatter and verify fields
2. Check model validity
3. Verify name matches filename
4. Review focus areas for specificity
5. Assess approach section completeness
6. Evaluate context economy (target <500 lines)

### For Skills

1. Extract frontmatter from SKILL.md
2. Check description length and trigger quality
3. Verify progressive disclosure (SKILL.md size vs references/)
4. Check allowed-tools if present
5. Verify reference files are one level deep
6. Assess organization and navigation

### For Commands

1. Check for clear purpose statement
2. Identify delegation pattern
3. Verify simplicity (no complex logic)
4. Check usage instructions

### For Hooks

1. Verify executable shebang
2. Check JSON stdin handling
3. Review exit code usage
4. Assess error handling
5. Check stderr message clarity

### For Output-Styles

1. Extract frontmatter
2. Check persona definition clarity
3. Assess tone appropriateness
4. Verify use case explanation

## Step 3: Check Integration with Settings

Use Read to examine `~/.claude/settings.json`:

1. Verify hooks are registered if needed
2. Check for permission conflicts
3. Ensure tool permissions cover needs
4. Look for orphaned hook references

## Step 4: Assess Context Economy

Calculate approximate size and efficiency:

1. Count total lines
2. Identify redundant content
3. Check progressive disclosure usage
4. Estimate token count impact

## Step 5: Verify Tool Permissions

For skills and agents with allowed-tools:

1. List tools mentioned in content
2. Compare to allowed-tools list
3. Check for missing or excessive permissions
4. Assess security implications

## Step 6: Generate Structured Report

Create comprehensive evaluation following the report format (see [report-format.md](report-format.md)).
