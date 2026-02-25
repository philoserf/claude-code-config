---
name: cc-plan
description: >-
  Interviews the user to plan a feature and produce a PRD. Covers scoping
  requirements, defining specs, and designing solutions. Use when starting new
  work that needs planning, requirements definition, feature scoping, or
  creating a product requirements document.
---

A user wants to build: $ARGUMENTS

Your job is to interview them until you can fill in every field of the PRD below without guessing. Do not write code, suggest implementations, or name technologies unless the user raises them first.

Interview rules:

- Ask the most important unresolved question first. If several questions are closely related, batch them (max 3 per turn).
- Do not re-ask anything the user has already answered.
- If the user says "I don't know" or defers a field, note it as TBD and move on — do not block the entire PRD on one unknown.
- Stop asking when every PRD field can be filled with confidence (or marked TBD).

PRD fields you must be able to complete before drafting:

1. Problem — what situation is broken or missing, and why does it matter?
2. User — who experiences the problem, and in what context?
3. Success criteria — what observable outcome confirms the solution works?
4. Scope — what must the solution do?
5. Out of scope — what are we explicitly not solving?
6. Constraints — deadlines, platforms, existing systems it must fit, non-negotiables.

When all fields are answerable, write the PRD in plain language under the heading "Draft PRD". Keep it under one page. Match the format shown in the [example PRD](#example-prd). End with exactly this line:

"Reply 'approved' to proceed, or tell me what to change."

Do not write any code or implementation plan until the user replies with approval.

## Example PRD

Use this as a format and tone reference when drafting PRDs.

---

### Draft PRD

#### Problem

The team's fish shell configuration has no way to quickly check whether dotfiles are in sync with the remote. Developers only discover drift when they manually run `dot status`, which means uncommitted changes accumulate silently.

#### User

Individual developers managing their dotfiles across multiple machines (MacBook Air, Mac Mini). They interact with dotfiles through the `dot` wrapper function in fish shell.

#### Success Criteria

- Running a single command shows whether local dotfiles have uncommitted changes, unpushed commits, or are behind the remote.
- The check completes in under 2 seconds on a typical home network.

#### Scope

- Add a `dot-sync-check` fish function that reports: uncommitted changes, unpushed commits, and commits behind remote.
- Output a clean one-line summary when everything is in sync, or a bulleted list of issues when not.
- Register the function as a fish completion for `dot`.

#### Out of Scope

- Automatic syncing or auto-commit behavior.
- Notifications or scheduled checks.
- Support for shells other than fish.

#### Constraints

- Must work with the bare git repo pattern (`--git-dir=$HOME/.dotfiles/ --work-tree=$HOME`).
- No external dependencies beyond git and fish builtins.
- Must not run `git fetch` without user consent (network operation).

---

Reply "approved" to proceed, or tell me what to change.
