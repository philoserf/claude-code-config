# Evaluation Process

This document describes the step-by-step process for evaluating Claude Code customizations.

## Step 0: Determine Scope

Resolve the customization directory before scanning:

1. Use the current working directory as the **project root**
2. If project root is `~/.claude/`, the customization directory is the project root itself
3. Otherwise, the customization directory is `<project-root>/.claude/`
4. If a specific file or directory was passed as an argument, use that directly

All subsequent paths are relative to the resolved customization directory.

## Step 1: Identify Extension Type

Determine what type of customization is being evaluated:

- Agent (in `agents/`)
- Skill (in `skills/`)
- Hook (in `hooks/`)
- Setup (entire customization directory)

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
3. Verify progressive disclosure (SKILL.md size vs reference file count)
4. Verify only documented frontmatter fields are used
5. Verify reference files are in references/, assets in assets/, scripts in scripts/
6. Assess organization and navigation

### For Hooks

1. Verify executable shebang
2. Check JSON stdin handling
3. Review exit code usage
4. Assess error handling
5. Check stderr message clarity

## Step 3: Check Integration with Settings

Use Read to examine `settings.json` in the resolved customization directory:

1. Verify hooks are registered if needed
2. Check for permission conflicts
3. Look for orphaned hook references

## Step 4: Assess Context Economy

Calculate approximate size and efficiency:

1. Count total lines
2. Identify redundant content
3. Check progressive disclosure usage
4. Estimate token count impact

## Step 5: Generate Structured Report

Create comprehensive evaluation following the report format (see [report-format.md](../assets/report-format.md#report-template)).
