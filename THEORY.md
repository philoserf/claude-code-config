# A theory of `~/.claude`

You are inheriting a repository whose working tree is also a running program's
configuration directory. Nothing here is built, deployed, or installed. The files git
tracks and the files Claude Code reads at startup are the same bytes on disk, so a commit
takes effect the next time a session starts, and a mistake takes effect just as fast. That
one fact explains most of what follows, but it is not the interesting part. The
interesting part is what this repository is _for_, which is harder to see because it is
mostly visible in what has been removed.

## What the system is for

The problem being solved is not "configure a tool." It is: **an agent's behavior is
shaped by prose loaded into its context, that prose costs context budget and attention,
and the harness underneath it changes every few days.** Every design decision here is a
response to some part of that sentence.

The entities are small in number. There is _configuration_ — `settings.json` — which the
runtime reads directly and which is declarative. There are _hooks_ and a _status line_,
three shell scripts the runtime spawns with a JSON payload on stdin. And there is
_context_: markdown files that are loaded into the model's working memory under different
conditions, which is the category that matters and the one where the real design lives.

Three loading conditions exist, and choosing among them is the central act of design in
this repository:

- **Always** — `CLAUDE.md` at the root, loaded into every session on this machine.
  `.claude/CLAUDE.md` stacks on top when the working directory is `~/.claude` itself.
- **On path match** — files in `rules/`, gated by a `paths:` glob list in their
  frontmatter. `rules/go.md` reaches the model only once it touches a `.go` file.
- **On invocation** — `skills/<name>/SKILL.md`, loaded when the skill is called, with
  `references/*.md` loaded lazily beneath that.

The vocabulary maps onto the domain almost too neatly, which is why it is worth being
explicit: a "skill" is not a capability the agent lacks, it is _a body of prose plus a
condition for loading it_. Nothing in a `SKILL.md` extends what the model can do. It
changes what the model is thinking about. Once you hold that, the file layout stops
looking like a plugin system and starts looking like what it is — an index over a corpus,
keyed by trigger.

## The organizing ideas

**The design variable is the loading condition, not the content.** The clearest evidence
is commit `8db05dd` on 2026-08-05: "rules: restore go/typescript language rules,
retire quality-gate skills." Two skills totalling 197 lines were deleted and 46 lines
appeared in `rules/go.md` and `rules/typescript.md`. The guidance about `gofumpt` and
`golangci-lint` did not change in kind. What changed was that it stopped waiting to be
invoked and started arriving automatically whenever Go was in play. A maintainer who reads
that commit as "we deleted two skills" has read the wrong half. The trigger was the thing
worth changing; the content came along.

**Deletion is the default hypothesis, and git is what makes it cheap.** Roughly 135
distinct skill directory names appear somewhere in this history. Nine survive. Deletion
commits land every two or three weeks without interruption from January through September
2026 — "prune unused skills," "remove superseded skills," "YAGNI," "remove instinct
system." This is not a cleanup that happened once; it is the repository's metabolism.

The corollary is the part a newcomer gets wrong. Deletion here is not a verdict. `editor`
was removed on 2026-08-16 and restored on 2026-08-19. `code-audit` was removed and
re-added the same day. The move is to delete when a skill's value is in doubt and recover
with `git show <sha>^:<path>` if the loss is felt — cheap because git remembers. It has a
cost, filed below: git remembers the retired policies too, and a resurrected file carries
them back in.

**Skills survive only in the gap the harness has not filled.** Read the `## Do not use
when` section at the foot of every `SKILL.md` — the convention is stated in
`.claude/CLAUDE.md` and honored by all nine. Most entries do not point at sibling skills.
They point at built-in slash commands: `/code-review`, `/simplify`, `/doctor`. Those
sections are usually described as disambiguation, and they are, but they are also a
ledger. Each one records territory that upstream absorbed and that a local skill therefore
stopped claiming. `code-reduction` does not review diffs because `/simplify` does.
`code-audit` does not review harness config because `/doctor` does. The skill inventory
shrinks because the thing underneath it grows, and the "do not use when" sections are
where that pressure is written down.

**The repository's clock is one line in a text file.**
`state/cc-release-review-version.txt` contains a version number — currently `2.1.266` —
and has been bumped 43 times. The `cc-release-review` skill reads it, diffs it against
`claude --version`, pulls the intervening release notes out of the CLI's own local
changelog cache, and reports under three headings: Action items, Notable, and **Added
surface area**. That third heading is the mechanism by which upstream growth becomes local
deletion. New defaults arrive; settings that now merely restate a default get removed
(`f6154fe`, "config: drop settings that match current defaults"); skills whose territory
was absorbed get retired. Without that loop this repository would only accrete. It is the
single most important piece of state in the tree and it is one line long.

**The `code-*` family is a protocol with five entry points.** `code-audit`,
`code-reduction`, `code-refactor`, `code-theory`, and `code-walkthrough` ask different
questions about the same codebase and will therefore keep landing in the same files. Rather
than each inventing an output format, they share
`skills/code-audit/references/issues-protocol.md`, referenced by relative path from the
other four. The protocol's load-bearing distinction is **does this ship?** — standing
documents (`THEORY.md`, `WALKTHROUGH.md`) go to the repository root, tracked, admitted only
if they would still be correct in a year; working state (findings, plans) goes to
`.issues/`, which is ignored globally and therefore expires without ceremony. The rules
for re-running are stated as absolutes rather than preferences — overviews are regenerated
in place, finding files are never overwritten, nothing in `.issues/` is ever deleted —
because `code-audit` and `code-reduction` run forked and cannot stop to ask.

**What varies across skills is who may start them, not what they may do.** It is tempting
to read the inventory as "advisory tools," and for the `code-*` family that holds. It does
not generalize: `obsidian-ship` pushes tags, `editor` rewrites prose in place,
`mcp-toggle-normalize` rewrites `~/.claude.json` for every project on the machine. The
axis that actually varies is `disable-model-invocation: true`, which sits on
`obsidian-ship`, `mcp-toggle-normalize`, and `cc-release-review` — the skills the model
may not reach for on its own. Two of those three do things that are hard to undo or that
touch live state outside the repository, which is a coherent rule; `cc-release-review`
mutates almost nothing, so the rule may really be "expensive or attention-demanding"
rather than "irreversible." I am inferring from three data points.

## The seams

**The runtime boundary** is the sharpest and the best documented. `.gitignore` is not
housekeeping here; it is the line between configuration the user chose and state the
runtime owns, and it is grouped by _why_ each path is excluded rather than alphabetically.
`.claude/CLAUDE.md` carries an explicit list of directories that must never be hand-edited
— `sessions/`, `projects/`, `cache/`, `file-history/` — because corrupting them loses work.
The `/projects/` exclusion is subtle: memory files live under
`projects/<encoded-cwd>/memory/`, but the directory name is a hash of an absolute path, so
a memory written on one machine lands somewhere that does not exist on another. Portability
is why they are ignored, and `git add -f` is the documented escape.

**The upstream boundary** is `settings.json`, the most-revised file in the repository at
130 commits. Every key is a bet that the harness will keep honoring it. `.claude/CLAUDE.md`
records the discipline that follows — keys restating a current default are removed on
sight, `tui: "fullscreen"` is kept only because this account predates the date that made it
default, and the file admits no comments, which is why those notes live in `CLAUDE.md`
instead. The `autoMode` block is the exception that proves the boundary: it is prose
injected into the agent's safety reasoning, it is honored only from this file or a
`--settings` flag, and because it applies to every repository on the machine it deliberately
names no repository, path, or owner.

**The plugin boundary is closed, and it was closed the hard way.** Plugins were adopted in
March 2026 — symlinked skills replaced with official plugins, `skill-creator` swapped for
Anthropic's, `claude-hud` driving the status line. By late March a local `obsidian-cli`
skill was already shadowing its plugin equivalent. April brought a migration to the
`superpowers` plugin and, within days, commits removing `superpowers-dev` and dropping
dangling references. On 2026-05-22 the arc ended: "chore: reset to portable user-side
config." There is no plugin block in `settings.json` today, the status line is a local
shell script again, and a memory entry records `skill-creator` as vetoed — frozen since
2026-04-23 while the harness moved on. A maintainer who proposes solving a problem by
reaching for a plugin is walking into a decision that was made twice, expensively, in the
same direction.

**The thinnest seam is the one between the `code-*` skills and their own repository.** In
an Obsidian plugin repo, gate check 8 in `release-check.sh` runs `uvx showboat verify
WALKTHROUGH.md` and blocks a release when it fails; `obsidian-ship` Phase 4 calls
`code-walkthrough` to regenerate the document before tagging. That is a complete loop:
produce, verify, gate. Here, where the protocol is authored, there is no CI, no gate, and
no task that verifies anything — and `task format:md` rewrites the standing documents on
every run. The convention's home is the one place it is not enforced.

## What the system accommodates, and what it does not

Adding a skill is nearly free, which is exactly why the interesting question is when to
refuse. The shape to match: a directory under `skills/`, a `SKILL.md` whose frontmatter
declares `allowed-tools` and a description written for a model deciding whether to load it,
real logic pushed into `scripts/*.sh` next to it rather than inlined, reference material in
`references/*.md` loaded on demand, and a single `## Do not use when` section at the bottom
naming the built-in commands and sibling skills that own the neighboring territory. Match
that and the skill will be legible to the next person who has to decide whether to delete
it — which, on this repository's record, will be someone within a few months.

Adding a rule is cheaper still and is usually the better instinct. If guidance should
arrive whenever a file type is touched rather than when someone remembers to ask, it is a
rule, not a skill, and `rules/obsidian-plugin.md` shows the care that goes into the
frontmatter: both bare and `**/`-prefixed glob forms because the matching semantics are
undocumented, and a deliberate refusal to claim `package.json` because `rules/typescript.md`
already has it and this rule must not fire in every TypeScript repository. Trigger scope is
the whole design problem for a rule.

What would require rethinking something fundamental:

- **Anything needing state that outlives a session.** There is exactly one state file, one
  line long. There is no database, no cache the repository owns, no coordination between
  sessions. `mcp-toggle-normalize` runs into this directly and cannot fix it — it warns the
  user to quit other sessions first because Claude Code rewrites `~/.claude.json` from
  memory, and then admits the session running the skill is itself a writer. That race is
  unfixable from inside this repository.
- **Anything requiring the config to be non-portable.** The May 2026 reset chose
  portability over capability once already. Machine-specific paths in `autoMode`,
  host-dependent hooks, or a skill that assumes a particular clone location all cut against
  a decision already made.
- **A second machine, or a second person.** Everything here assumes one solo developer on
  one macOS host. `autoMode` says so explicitly. The scripts assume BSD userland —
  `auto-format-md.sh` hand-rolls a timeout because macOS has no `timeout(1)`. And at least
  one load-bearing dependency lives outside the repository entirely: the `.issues/`
  protocol's safety property is an entry in `~/.gitignore` that nothing here tracks or
  checks.

Where a maintainer who understands the theory looks first: `settings.json` for anything
about behavior, the `## Do not use when` sections for whether a capability already exists
upstream, and `git log --diff-filter=D` before adding anything — there is a real chance the
idea has been tried and removed already, and the commit message will say why.

Where a maintainer who does not understand the theory causes damage: adding a skill for
something a built-in command now covers; hand-editing `sessions/` or `projects/`; adding a
`settings.json` key that restates a current default and letting it rot; treating a deletion
as permanent and rewriting from scratch what `git show <sha>^:<path>` would have restored;
or restoring a file from history without checking what retired policy came back with it.

## Uncertainties

**The `code-*` family is hours old.** `d24548b` (shared protocol), `4f9a446`
(`code-refactor`), and `9164540` (the rename to `code-walkthrough`, the uppercase standing
documents, the move of plans into `.issues/`) all landed on 2026-09-09 within thirty-five
minutes of each other. `WALKTHROUGH.md` was committed fifteen minutes after that, and this
document is the first `THEORY.md` written under the protocol. No skill in the family has yet
run twice against the same `.issues/` directory, so the dedup and re-run rules — the
"Related" case, the never-overwrite rule, the regenerate-in-place rule — are entirely
untested. They are the most confidently stated and least exercised part of the design. Treat
my account of them as a description of intent.

**This is the second theory document, and the first did not survive.** A `THEORY.md`
existed from 2026-04-10 (`b45fe01`) to 2026-06-30, 45 lines, with the same section headings
this one uses. It was deleted in `17b4b1a`, "chore: sync config, skill tooling, and docs,"
as one bullet among five. Not retired by a decision — swept out during housekeeping. I
cannot tell whether it had gone stale, whether the sweep was deliberate and undocumented, or
whether it was simply not missed. Any of those should lower your confidence that this
document will be current when you read it. Check `git log -- THEORY.md` before trusting it.

**The `disable-model-invocation` rule is inferred from three instances.** I read it as
gating skills that are hard to undo or touch live state outside the repository.
`cc-release-review` fits poorly — it mutates one version-baseline line. "Expensive to run,
so don't start it unasked" fits all three equally well and I cannot distinguish them from
the code.

**`mcp-toggle-normalize` inlines two Python heredocs**, roughly twenty lines of real logic,
against a stated convention that logic belongs in `scripts/*.sh` "so it can be tested and
run directly." The convention's letter says "long shell" and applies to `.claude/skills/`
only "where it applies," so the skill is arguably exempt. Its rationale is not exempt —
this is the riskiest transformation in the repository, rewriting connector state for every
project on the machine. I could not decide which the author meant, and I could not name a
specific bug a test would have caught, so I have left it here rather than filing it.

**I did not verify that the harness honors every `settings.json` key currently set.** The
repository's discipline is to remove keys that restate defaults, and `cc-release-review` is
the mechanism, but I checked the config against its own documentation rather than against
the installed CLI's actual behavior. If a key here is a no-op, I would not have caught it.

**Where I inferred intent from code alone**: the reading of `## Do not use when` sections as
a ledger of absorbed territory is mine, not the repository's. No commit says it. It fits the
evidence — every `code-*` skill names built-in commands there, and the quality-gate and
`skill-creator` retirements both followed upstream gaining the capability — but the author
may simply have been writing disambiguation and I may be reading a pattern into it.

## Index

| #   | Severity | Issue                                    | Primary location                                       |
| --- | -------- | ---------------------------------------- | ------------------------------------------------------ |
| 1   | medium   | `opus-pins-reintroduced-by-resurrection` | `skills/editor/SKILL.md:6`, `skills/frames/SKILL.md:6` |
| 2   | medium   | `standing-docs-unverified-in-this-repo`  | `issues-protocol.md:20-31`, `release-check.sh:144-153` |
| 3   | low      | `skill-tier-rule-narrower-than-practice` | `.claude/CLAUDE.md:27-31`                              |

**Total: 3 issues (0 critical, 0 high, 2 medium, 1 low)**

**Related existing findings.** Three findings from the `code-walkthrough` pass on
2026-09-09 sit in `.issues/` and are not counted above.
`issues-protocol-depends-on-untracked-global-gitignore` and
`prettierignore-disabled-by-taskfile-flag` are both cited in the seams section and
cross-referenced from finding 2; `walkthrough-prettier-warning-overstated` concerns a claim
in `code-walkthrough/SKILL.md` that this pass did not revisit.
