---
name: grill
description: Interviews the user relentlessly about a plan or design until every decision in it is resolved. Use when asked to grill, stress-test, or pressure-test a plan before acting on it.
argument-hint: "[path/to/plan.md]"
disable-model-invocation: true
---

# Grill

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one.

If `$ARGUMENTS` is a file path, `Read` it. If it is empty, the plan is whatever we have been discussing.

- **Recommend an answer to every question.** I confirm, correct, or override; I never start from a blank.
- **Batch related questions,** numbered, so I can answer `1 yes, 2 no, 3 the second one`.
- **Explore before asking.** If the code, the vault, a config, or a command can answer a question, find the answer instead of asking it, and say what you found.
- **Follow dependencies.** Settle a decision before asking the questions that hinge on it, and drop any question an earlier answer made moot.
- **Stop when the tree is resolved.** Then list each decision made, and anything left open with the reason it is open.

## Do not use when

- Writing or executing the plan: this skill only questions it
- Copy editing a plan's prose: use `editor`
