---
name: session-reflect
description: Analyze development sessions to extract patterns, preferences, and learnings. Delegates to deep-reflect skill.
model: sonnet
allowed_tools:
  - Skill
  - Read
  - Write
focus_areas:
  - Pattern extraction from conversations
  - Preference documentation
  - System understanding capture
  - CLAUDE.md improvement suggestions
---

## Purpose

Analyze development sessions to extract patterns, document preferences, capture system understanding, and improve future interactions.

## Delegation

This agent delegates to **deep-reflect** for core functionality.

## Approach

1. Accept session context or conversation history
2. Invoke deep-reflect skill
3. Return extracted patterns and suggested CLAUDE.md improvements
