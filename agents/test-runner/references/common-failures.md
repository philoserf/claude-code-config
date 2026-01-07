---
name: Common Test Failures
description: Catalog of common failure patterns when testing Claude Code customizations (skills, agents, commands, hooks)
---

# Common Test Failures

This document catalogs common failure patterns for different types of Claude Code customizations.

## Skills

- **Discovery Failure**: Skill doesn't trigger on expected queries
- **Tool Restriction Violation**: Tries to use tools not in allowed-tools
- **Reference Loading Error**: References not found or broken links
- **Output Format Issues**: Doesn't produce expected structure

## Agents

- **Frontmatter Invalid**: Missing or incorrect YAML
- **Wrong Tools Used**: Uses tools outside expected set
- **Poor Output Quality**: Doesn't follow output format
- **Context Bloat**: Uses too much context for simple tasks

## Commands

- **Broken Delegation**: Doesn't invoke correct agent/skill
- **Argument Handling**: Fails with valid arguments
- **Documentation Mismatch**: Usage docs don't match behavior

## Hooks

- **Exit Code Error**: Returns wrong exit code
- **Poor Error Messages**: Unclear why blocked
- **Performance Issues**: Takes too long to execute
- **JSON Parsing Failure**: Can't handle malformed input
