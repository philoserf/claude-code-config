---
created: 2026-04-03
status: approved
---

## review-fix

Iterative review-fix loop using the existing code-reviewer agent. Reviews a
diff, presents findings, lets the user choose which to fix, applies fixes,
re-reviews. Max 3 iterations.

### Flow

1. Ask scope (uncommitted | branch diff | specific commit)
2. Run code-reviewer agent on the diff
3. Present findings by severity
4. If APPROVE: done
5. User selects which findings to address (or "all")
6. Claude applies fixes
7. Re-run review (iteration 2/3)
8. Repeat until APPROVE or iteration 3
9. At iteration 3 with remaining issues: stop, summarize what's unresolved

### Decisions

- Reuses `code-reviewer` agent as-is (no new review logic)
- Scope options: uncommitted (`git diff HEAD`), branch diff
  (`git diff main...HEAD`), specific commit
- Interactive gate between review and fix — user sees findings before anything
  changes
- Hard stop at 3 iterations with explicit "these remain unresolved" summary
- No external dependencies — pure Claude Code skill using existing agent and
  tools

### Out of scope

- No pre-push hook wiring (vc-ship Phase 5 already covers that gate)
- No external model review (that's second-opinion's job)
- No automatic fix without approval

### Origin

Evaluated Local-Review (84codes) and decided to build the gap it covers
(review-fix loop) using existing components rather than adopting the tool.
Local-Review was too immature (0 stars, no license, 3 weeks old) and redundant
with our code-reviewer agent + second-opinion skill.
