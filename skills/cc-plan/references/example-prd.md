# Example PRD

Use this as a format and tone reference when drafting PRDs.

---

## Draft PRD

### Problem

The team's fish shell configuration has no way to quickly check whether dotfiles are in sync with the remote. Developers only discover drift when they manually run `dot status`, which means uncommitted changes accumulate silently.

### User

Individual developers managing their dotfiles across multiple machines (MacBook Air, Mac Mini). They interact with dotfiles through the `dot` wrapper function in fish shell.

### Success Criteria

- Running a single command shows whether local dotfiles have uncommitted changes, unpushed commits, or are behind the remote.
- The check completes in under 2 seconds on a typical home network.

### Scope

- Add a `dot-sync-check` fish function that reports: uncommitted changes, unpushed commits, and commits behind remote.
- Output a clean one-line summary when everything is in sync, or a bulleted list of issues when not.
- Register the function as a fish completion for `dot`.

### Out of Scope

- Automatic syncing or auto-commit behavior.
- Notifications or scheduled checks.
- Support for shells other than fish.

### Constraints

- Must work with the bare git repo pattern (`--git-dir=$HOME/.dotfiles/ --work-tree=$HOME`).
- No external dependencies beyond git and fish builtins.
- Must not run `git fetch` without user consent (network operation).

---

Reply "approved" to proceed, or tell me what to change.
