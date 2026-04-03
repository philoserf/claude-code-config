---
name: No invented technical claims
description: Never assert technical facts without verification — especially about SDK behavior and platform compatibility
type: feedback
---

Do not claim a library "requires" a specific platform without checking the docs. `dangerouslyAllowBrowser` in the Anthropic SDK enables usage in _any_ browser-like environment (including Obsidian mobile), not just Electron.

**Why:** Incorrectly set `isDesktopOnly: true` based on an invented claim that the SDK required Electron. This broke mobile support and required a follow-up PR to fix. Violated Mark's core principle: "Never invent technical details."

**How to apply:** When making a change based on a technical assumption (especially about platform compatibility), verify with docs or source code first. If unsure, say so and research it.
