# Scenario: Protected Branch Handling

## Situation

Currently on main/master branch with uncommitted changes.

## Problem

Cannot commit directly to main (protected branch policy).

## Goal

Safely move work to feature branch without losing changes.

## Phase 0 Detection

Git workflow detects:

- Current branch is main/master
- Uncommitted changes exist
- Must migrate to feature branch
