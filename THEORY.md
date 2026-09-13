# A theory of `~/.claude`

*2026-09-13T23:23:53Z by Showboat 0.6.1*
<!-- showboat-id: 2db79ef9-373b-48b2-8b5f-f2f4ef36cd43 -->

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
distinct skill directory names appear somewhere in this history. Nine survive under
`skills/`, with two more under `.claude/skills/`. Deletion
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
`.claude/CLAUDE.md`, required of everything under `skills/`, and carried by ten of the
eleven `SKILL.md` files in the tree. The exception is `mcp-toggle-normalize`, which the
convention exempts by its own wording: it binds `.claude/skills/` only "where it applies."

Most entries do not point at sibling skills. They point at built-in slash commands:
`/code-review`, `/simplify`, `/doctor`. Those
sections are usually described as disambiguation, and they are, but they are also a
ledger. Each one records territory that upstream absorbed and that a local skill therefore
stopped claiming. `code-reduction` does not review diffs because `/simplify` does.
`code-audit` does not review harness config because `/doctor` does. The skill inventory
shrinks because the thing underneath it grows, and the "do not use when" sections are
where that pressure is written down.

**The repository's clock is one line in a text file.**
`state/cc-release-review-version.txt` contains a version number — currently `2.1.270` —
and has been bumped 44 times. The `cc-release-review` skill reads it, diffs it against
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
because three of the five — `code-audit`, `code-reduction`, and `code-refactor` — run forked
and cannot stop to ask.

**What varies across skills is how far the tree is willing to overrule the user.** It is
tempting to read the inventory as "advisory tools," and for the `code-*` family that holds.
It does not generalize: `obsidian-ship` pushes tags, `editor` rewrites prose in place,
`mcp-toggle-normalize` rewrites `~/.claude.json` for every project on the machine. But
capability is not the axis the frontmatter actually encodes. Three keys vary across the
eleven `SKILL.md` files — `disable-model-invocation`, `model`, and `effort` — and all three
answer one question: at this moment, does the tree know better than the person sitting
there?

`disable-model-invocation: true` sits on `obsidian-ship`, `mcp-toggle-normalize`, and
`cc-release-review`. It takes a decision away from the model and hands it to the user:
these three start only when a human types the name.

`model:` and `effort:` run the other way — they are overrides of what the user chose for
the session. `ba06a04` states the test that follows, and it is not the obvious one. The
question is never "does this job want a capable model," because every job does and the
session already supplies one. It is "is this job's need different enough to overrule a
choice the user already made?" Answer no and the key belongs absent; a pin that merely
agrees with the user is residue, which is what `01fd9a8` deleted and what `7d29230` deleted
again after two pins rode back in on a resurrected file.

So the pins are directional, and the two keys point opposite ways. `model:` pins only
_downward_ — onto `obsidian-gate`, `cc-release-review`, and `mcp-toggle-normalize`, three
jobs mechanical enough that the session's model is overkill: read a table a script printed,
diff two versions against a template, apply a written spec to a file. Always the alias
`sonnet`, never a model ID, so the pin tracks its tier instead of carrying a version number
that goes stale in silence. `effort:` pins only _upward_, because its default is already
`high`; the three skills that once said `effort: high` were restating the default and lost
it. `code-theory` and `code-walkthrough` get `xhigh` for a reason specific to what they
emit, taken up under the tensions below.

`obsidian-ship` is the case that shows the axis is deference rather than caution. It is the
most irreversible thing here — it tags and publishes — and it carries no pin at all. It
does not need one: it is `disable-model-invocation: true`, so the user is choosing the model
in the same breath they choose to ship. Pinning it would overrule them at the single most
deliberate moment in the repository.

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

**The `agents/` tier is the one place the two-tier split does not hold, and that is not an
oversight.** Everything else here doubles: `CLAUDE.md` and `.claude/CLAUDE.md`, `skills/`
and `.claude/skills/`, each pair splitting on whether the thing concerns a user project or
Claude Code's own configuration. `agents/frames-worker.md` has no `.claude/` counterpart
because a subagent must be loadable wherever the skill that spawns it runs, and
`skills/frames/` runs against other projects. A `.claude/agents/` copy would load only
inside `~/.claude` — absent at every moment it was wanted. One tier, because only one of the
two works.

That tier also lacks the guard the skill tier has. There is no `disable-model-invocation`
for an agent, so nothing structural stops a stray brainstorm from being auto-delegated to
the worker; its `description` saying it is not for general use is the entire defense.
`7a3332b` names this trade rather than burying it, which is the right disclosure and still
leaves a seam where the enforcement is prose.

The worker carries the tree's only `model: haiku`, and the obvious reading of that is wrong.
Generating options under a cognitive frame is not mechanical — it is the least mechanical
job here — so the downward-pin rule above would condemn the file. What earns the pin is the
shape of the call. `frames` spawns three workers whose entire output is options, and keeps
the synthesis for itself on the session's model, so a weak option from one worker is
discarded by a step that never dropped a tier: cost multiplies by three while quality does
not. And the thing the fan-out exists to buy — three contexts that cannot anchor on each
other — comes from spawning them separately, not from what they run on. The worker gets
`tools: Read, Grep, Glob`: no `Agent`, so it cannot recurse, and no `Write` or `Edit`,
because `frames` is advisory. Pin a worker down; never pin the synthesis.

**The thinnest seam is the one between the `code-*` skills and their own repository.** In
an Obsidian plugin repo, gate check 8 in `release-check.sh` runs `uvx showboat verify
WALKTHROUGH.md` and blocks a release when it fails; `obsidian-ship` Phase 4 calls
`code-walkthrough` to regenerate the document before tagging. That is a complete loop:
produce, verify, gate. Here, where the protocol is authored, there is no CI and no
gate — but `task` now ends with the two things that can fail, the test suite and
`showboat verify` over the standing documents, so a stale walkthrough breaks the command a
maintainer already runs. The loop is closed by habit rather than by a gate, which is
weaker, and it is the strongest enforcement a repository that is never tagged can have.

## The standing tensions

The sections above describe the design as settled. Parts of it are not, and will not become
settled, because they are trades between values that both matter rather than problems with
answers. A maintainer who reads a recurring argument here as a defect will keep trying to fix
it, and each fix will surface the same argument somewhere else. These are the ones that
recur.

**Arriving reliably versus costing nothing.** The three loading conditions are a budget
allocation, not a taxonomy. Anything in the root `CLAUDE.md` arrives every session and is
paid for every session. Anything in `rules/` arrives only when a glob matches — cheaper, and
it may fail to arrive when it should, which is why `rules/obsidian-plugin.md` lists both the
bare and `**/`-prefixed forms of every pattern against matching semantics nobody has
documented. Anything in a skill is cheapest and least reliable: it arrives only if the model
decides to load it from a description. Commit `8db05dd` moved the Go and TypeScript guidance
one step along that scale, from invoked to automatic. No placement is correct in general;
each file's tier is a bet about how often the guidance is needed against what it costs to
always have it.

**Fewer concepts versus enforced invariants.** `code-reduction` starts from the position that
less prose is better because prose costs context. `code-refactor` proposed adding task
targets and a test section — more machinery, more to maintain, and the only way to make an
invariant fail loudly instead of silently. Both are right, and they pull opposite directions
on the same files. `.prettierignore` was the clean case, and it has been decided: it was a
tracked _symlink_ to `.gitignore`, so "populate it so a tracked file can be exempted" was
never actually on the table — entries written to it would have landed in `.gitignore` and
hidden the standing documents from `git status`. It was deleted in favor of prettier's
defaults. One instance settled; the trade itself is not, and the next case will not come
with a symlink to decide it. Whoever decides should know they are choosing a side rather
than discovering afterward that they did.

**Deletion is cheap, except in the one place the review skills write.** The metabolism
described above rests entirely on git remembering. It does not remember `.issues/`, which is
globally ignored precisely so that findings never ship — and the property that makes it safe
to write findings into someone else's repository is the same property that makes a deleted
finding unrecoverable. There is no configuration that grants both. A finding removed from
`.issues/` is gone in a way that no skill, no rule, and no `SKILL.md` ever is.

**Verified versus stable.** `WALKTHROUGH.md` earns its keep because showboat re-executes its
code blocks, so its claims cannot quietly stop being true. But the most honest snippets — a
file listing, a count, a grep across the tree — are the ones that go stale first, because
they capture the repository rather than a fixed fact about it. Snippets that never break are
usually snippets that show less. `WALKTHROUGH.md:36` buys stability by excluding two paths
with a pathspec, and every exclusion is a small lie about what the tree contains.

The sharper version of this trade is the document you are reading. The protocol names two
standing documents and `task verify:docs` runs `showboat verify` over both, which makes them
look like peers. They are not. `WALKTHROUGH.md` is roughly half captured output; `THEORY.md`
has never contained a single fenced block in its entire history, so verifying it re-executes
nothing and exits 0 against any content whatsoever. The document making the longest-lived
claims is the one with no mechanism behind it at all.

The asymmetry is not cosmetic, and the drift record shows it. A walkthrough snippet that
goes stale forces a regeneration, and regeneration drags the whole file — prose included —
past a human's eyes every few commits. Nothing does that here. This document sat twelve
commits behind while `verify:docs` reported success on it every time, and what it had
drifted on were exactly the things no code block could have caught: a version number, a
count, an uncertainty that had since been resolved, and one claim the repository had
reversed outright. A verifier that reads no commentary is not a weak check on prose. On a
prose-only document it is not a check.

`effort: xhigh` on `code-theory` and `code-walkthrough` is the response to that asymmetry,
and it is worth seeing what kind of response it is. It does not add a check; it buys a
better first draft of the output that has none. That is a reasonable thing to spend on and
it is not the same thing as verification, which is why the pin belongs in this tension
rather than settling it.

**Prose is the medium, and prose has no compiler.** A review pass named the absence of
cross-file checking as a structural gap in this repository. That is the wrong frame. It is
the cost side of the choice that makes the repository work at all: prose is why a skill can
be deleted on a hunch and restored three days later, why a rule is a file rather than a
plugin, and why the whole tree is legible to the thing that consumes it. The price is that
two copies of a fact can disagree indefinitely and nothing will announce it. Checks can be
added at specific points, and should be where drift is expensive — but the medium does not
change, and most of this tree will always be unchecked by construction.

None of these resolve. The useful move when an argument recurs is to notice which tension it
is an instance of and decide that case on its merits, rather than re-deriving the trade and
mistaking it for a discovery.

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
  protocol's safety property is an entry in `~/.gitignore`, which this repository still does
  not track and cannot. What changed in `d8c3e34` is that it is now _checked_ —
  `git check-ignore -q .issues` is the first of the protocol's four pre-filing steps, and a
  skill that finds it missing stops rather than files. That makes it the one invariant here
  that graduated from asserted to enforced, and what earned it that was blast radius: these
  are user-level skills run against other people's repositories, so a missing ignore rule
  writes AI-authored findings into a stranger's working tree, one `git add -A` from their
  history. The dependency is still external. The failure is no longer silent.

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

**The re-run rules have now been exercised, which is not the same as being sound.** The
previous edition of this document said they were entirely untested, the family being hours
old. That has changed: `code-refactor` left `000-refactor.md`, a triage pass re-verified the
whole set against a tree four days older, and `code-walkthrough` ran a second time on
2026-09-13 — it read the existing `.issues/` files, found no duplicates, and filed three new
ones alongside them. The rules held. But every one of those runs was a skill meeting another
skill's output, which is the easy direction. The case the protocol spends the most words on
— **Related**, where a second pass lands on the same location as the first with a different
`Source:` and must say which reading wins — had never fired until this pass, and it has now
fired exactly once: the finding below lands on `taskfile.yml`'s `verify:docs`, which
`.issues/000-refactor.md` proposed under `Source: code-refactor`. The two do not conflict,
which is the mild version of the case. Whether the rule holds when a second pass wants to
contradict the first is still untested.

**The two skills that emit standing documents cannot see their own staleness, and I am one
of them.** `effort: xhigh` on `code-theory` and `code-walkthrough` is justified by the
observation that their prose is the one output with no check behind it. That is correct, and
it is also not a fix: raising effort improves the first draft, not the tenth week. This
document drifted across twelve commits under exactly that pin. I can tell you the mechanism
is missing; I cannot tell you from inside it how much of what you are reading is already
wrong.

**This is the second theory document, and the first did not survive.** A `THEORY.md`
existed from 2026-04-10 (`b45fe01`) to 2026-06-30, 45 lines, with the same section headings
this one uses. It was deleted in `17b4b1a`, "chore: sync config, skill tooling, and docs,"
as one bullet among five. Not retired by a decision — swept out during housekeeping. I
cannot tell whether it had gone stale, whether the sweep was deliberate and undocumented, or
whether it was simply not missed. Any of those should lower your confidence that this
document will be current when you read it. Check `git log -- THEORY.md` before trusting it.

**The family's own premise is not held as firmly as the protocol's prose implies.** The
protocol states how many `code-*` skills run forked in two places and they disagree: the
paragraph under pre-filing check 1 names `code-audit` and `code-reduction`, while
**Re-running** names those two plus `code-refactor`. The latter is right. What makes this
more than a typo is the order. `196ca36` added `context: fork` to `code-refactor`, and the
stale sentence was written _after_ it, in `d8c3e34` — a commit whose entire subject is
verifying a property rather than asserting one, and whose message repeats the wrong pair
verbatim. I cannot tell from the tree whether the author had forgotten the fork or never
registered it, and the difference matters: one is an editing slip, the other says the
five-skills-one-protocol premise is thinner than it reads. Filed either way.

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

Two passes of `code-theory` have run here. The first, on 2026-09-09, filed three findings;
they were migrated to GitHub issues the same day and the local files removed. All three are
now closed, as is every other issue in the repository — the tracker holds 165 and none are
open. That is worth stating precisely once, because the previous edition of this section
called #393 "still open" and was wrong by the time anyone read it. Treat the numbers below
as provenance, not status.

| #   | Severity | Issue                                                                                                     | Primary location                                       |
| --- | -------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| 1   | medium   | [#394](https://github.com/philoserf/claude-code-config/issues/394) opus pins reintroduced by resurrection | `skills/editor/SKILL.md:6`, `skills/frames/SKILL.md:6` |
| 2   | medium   | [#397](https://github.com/philoserf/claude-code-config/issues/397) standing docs unverified in this repo  | `issues-protocol.md:20-31`, `release-check.sh:144-153` |
| 3   | low      | [#407](https://github.com/philoserf/claude-code-config/issues/407) skill tier rule narrower than practice | `.claude/CLAUDE.md:27-31`                              |

The second pass, on 2026-09-13, filed one finding:

| #   | Severity | Issue                                    | Primary location               |
| --- | -------- | ---------------------------------------- | ------------------------------ |
| 1   | medium   | `theory-md-unverifiable-by-construction` | `taskfile.yml:35-41`, `THEORY.md` |

**Total: 1 issue (0 critical, 0 high, 1 medium, 0 low)**

It is the residue of the fix to #2 above. `0b5a144` closed #397 by adding `verify:docs`,
which runs `showboat verify` across both standing documents — but `THEORY.md` has never held
a fenced block, so that half of the target re-executes nothing and passes unconditionally.
The task's own description says it re-runs "the code blocks in the standing documents."

**Related findings from the other passes.** `code-walkthrough`, `code-audit`, and
`code-reduction` ran on 2026-09-09 and filed seventeen more, now
[#389–#408](https://github.com/philoserf/claude-code-config/issues). Two are cited above:
[#393](https://github.com/philoserf/claude-code-config/issues/393) on the `~/.gitignore`
dependency, closed by `d8c3e34` — the graduation from asserted to enforced described under
the second-machine bullet — and
[#395](https://github.com/philoserf/claude-code-config/issues/395) on the `.prettierignore`
collision, closed by deleting the symlink and the flag.

`code-walkthrough` ran again on 2026-09-13 and left three findings live in `.issues/`:
`issues-protocol-forked-count-contradiction`, `walkthrough-line-ranges-drift-silently`, and
`claude-md-unfilled-commit-placeholder`. The first is the one this document's uncertainties
section argues with; it belongs to that pass and is not re-filed here.

