# GitHub issue tracker

Shared by the engineering skills (`to-spec`, `to-tickets`, `triage`, `wayfinder`,
`implement`, `implement-spec`, `spec-review`), which reference it by path. This file is the
canonical copy. Change it here.

Every philoserf repo tracks work in its GitHub issues. Use the `gh` CLI; run inside a
clone, it infers the repo from `git remote -v`. Pull requests are not a triage surface:
these repos take no external PRs as requests.

## Operations

- **Create an issue**: `gh issue create --title "..." --body-file <file>`. Write a
  multi-line body to a file in the session scratchpad first.
- **Read an issue**: `gh issue view <n> --json number,title,body,labels,comments`.
- **List issues**: `gh issue list --state open --json number,title,body,labels` with
  `--label` and `--state` filters as needed.
- **Sub-issue of a parent**: `gh issue create --parent <parent> ...`, or
  `gh issue edit <parent> --add-sub-issue <child>` afterwards.
- **Blocking edge**:
  `gh api --method POST repos/{owner}/{repo}/issues/<blocked>/dependencies/blocked_by -F issue_id=<blocker-db-id>`.
  `<blocker-db-id>` is the blocker's database id
  (`gh api repos/{owner}/{repo}/issues/<n> --jq .id`), not its `#number` or `node_id`.
  Read open blockers from `issue_dependencies_summary.blocked_by` on the issue. An issue is
  unblocked when every blocker is closed.
- **Comment**: `gh issue comment <n> --body-file <file>`.
- **Labels**: `gh issue edit <n> --add-label "..."` / `--remove-label "..."`.
- **Close**: `gh issue close <n> --comment "..."`.

"Publish to the issue tracker" means create an issue. "Fetch the ticket" means read it.

## Labels

The repos share one vocabulary. Apply a label only if `gh label list` shows the repo has
it; never create labels.

- **Category**: `bug`, `enhancement`, `chore`, `tech-debt`, `documentation`.
- **Kind**: `kind:decision` for an issue whose resolution is a decision, not a deliverable.
  Other `kind:*` labels belong to the skills that file them (`code-theory`,
  `code-walkthrough`, audits); don't apply them from here.
- **Severity**: `severity:critical|high|medium|low`, mirroring a `**Severity:**` line in the
  body, on the scale in [`findings-protocol.md`](findings-protocol.md).
- **Closing**: `wontfix` on an issue closed without action; `duplicate` on one closed in
  favor of another, named in the closing comment.

Readiness is not a label. Priority, Size and Status live on the Workbench project board
(philoserf project #5), whose README is the rubric.

## Wayfinding

Used by `/wayfinder`. The map is one issue; its tickets are its sub-issues.

- **Map**: an issue labelled `kind:decision`, holding the Destination / Notes /
  Decisions-so-far / Not-yet-specified / Out-of-scope body.
- **Ticket**: a sub-issue of the map, labelled `kind:decision`. Its body opens with a
  `**Type:** research | prototype | grilling | task` line, then the `## Question`.
- **Blocking**: native blocking edges, as above.
- **Frontier**: the map's open sub-issues
  (`gh api repos/{owner}/{repo}/issues/<map>/sub_issues`), minus any with an open blocker or
  an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: comment the answer, close the issue, then append a context pointer (gist +
  link) to the map's Decisions-so-far.
