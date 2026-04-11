## Requesting review via subagent

- Use at phase boundaries during long work, not end-of-change cleanup — for end-of-change use `review-fix`
- Dispatch the reviewer as a subagent with a self-contained prompt; do not rely on session history leaking in
- Include in the prompt: BASE and HEAD git SHAs, what was built, what it should do, brief description
- Ask the subagent to return: strengths, issues by severity (Critical / Important / Minor), overall assessment
- Act on feedback: fix Critical immediately, fix Important before proceeding, note Minor for later

## Receiving feedback

- No performative agreement — never "you're absolutely right!", "great point!", "thanks for catching that!", or any gratitude expression
- Read complete feedback without reacting, then verify each item against codebase reality before implementing
- Unclear items: stop, ask for clarification before implementing anything partial — partial understanding produces wrong implementation
- YAGNI-check "professional" features: grep for actual usage before "implementing properly"; if unused, propose removal instead
- Push back with technical reasoning when a suggestion breaks existing functionality, violates YAGNI, conflicts with prior architectural decisions, or the reviewer lacks full context
- State fixes factually: "Fixed. [what changed]" — actions speak, the code shows you heard
- When pushback turns out to be wrong: correct factually, don't over-apologize or over-explain ("You were right — checked X and it does Y. Implementing now.")
