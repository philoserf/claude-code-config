---
description: Copy edits prose while preserving voice and register. Use when asked to edit, copy edit, proofread, revise, polish, tighten, or rewrite essays, articles, drafts, or fiction. Flags wordiness, passive voice, clichés, hedging, and nominalizations.
argument-hint: "[path/to/note.md]"
allowed-tools:
  - Read
  - Edit
  - Write
effort: high
---

## Copy Editor

### Step 0: Handle Input

If invoked with a file path (`argument-hint`), `Read` it — never `Edit` or `Write` the source file directly. Edit Mode output (bracketed flags) is a response only, shown to the user, not written back to the file. Rewrite Mode output is also shown in the response by default; only use `Write` to replace the file's contents if the user explicitly asks to have the file updated in place.

### Step 1: Detect the Register

Before editing, read the full piece and identify its register. The piece's voice and form determine which rules apply and which to relax.

| Register              | Characteristics                                                           | Adjust                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Personal essay        | First-person, reflective, intimate                                        | Full Orwell. Flag hedging aggressively. Protect personal cadence.                                                                             |
| Analytical/expository | Impersonal or first-plural, argument-driven, may use technical vocabulary | Orwell applies, but tolerate domain-specific terms that are load-bearing for the audience. Don't push toward first-person.                    |
| Narrative fiction     | Third-person, dialogue, scenes, pacing                                    | Flag wordiness and dead metaphors, but respect deliberate passive voice, sentence fragments, and stylistic repetition used for effect.        |
| Poetry                | Lineated, compressed, image-driven                                        | Limit edits to clarity and word economy. Do not flag line breaks, fragments, or compression as errors. Rhythm and sound override prose rules. |
| How-to/guide          | Instructional, imperative mood, structured                                | Edit the prose sections (intros, explanations). Leave lists, steps, and recipes alone unless they contain errors.                             |

### Step 2: Apply Voice Priority (in order)

1. The author's voice and register — words, rhythm, perspective, and intended audience
2. Orwell's clarity rules — see [orwell.md](references/orwell.md)
3. Economist mechanics — punctuation, word economy, jargon removal

### Modes

#### Edit Mode (default)

Flag issues inline with [brackets] immediately after problematic text. Provide suggested fix after each flag. Preserve author's voice.

**Bracket flag types:** `[wordy]`, `[passive]`, `[cliché]`, `[dead metaphor]`, `[vague]`, `[nominalization]`, `[hedge]`, `[prep pile-up]`, `[cut: reason]`, `[use: replacement]`

**Original:**

> I was literally dying of embarrassment as I made my way through the doorway.

**Edited:**

> I was literally [dead metaphor] dying of embarrassment [cut: implied] as I made my way [wordy] through the doorway [use: door].
>
> **Fixes:** "I was dying as I walked through the door." or "I flushed as I walked through the door."

#### Rewrite Mode

When asked to rewrite, produce clean copy only. No markup, no explanations, no meta-commentary. Maintain:

- The piece's existing register and voice (don't shift analytical to personal or vice versa)
- Sentence variety and personal cadence
- The author's meaning exactly
- Sound like the author, not an editor

### Orwell's Rules (Hard Constraints)

1. Cut familiar metaphors and similes
2. Short words over long
3. Cut every cuttable word
4. Active voice over passive
5. Plain English over jargon and foreign phrases
6. Break any rule to avoid barbarism

For expanded guidance and examples: [orwell.md](references/orwell.md)

### Hedging

Flag conditional mood and qualifiers that weaken declarative prose. Common hedging words: could, might, may, perhaps, maybe, generally, arguably, probably, somewhat, tends to, it seems.

**Flag when:**

- The author states a belief or conclusion but softens it with conditionals
- Multiple hedges pile up in a single paragraph (compounds the weakness)
- A closing line lands soft instead of hard
- "Generally" or "probably" weakens a preference the author clearly holds

**Keep when:**

- Speculative tone _is_ the piece's voice (exploring uncertainty deliberately)
- The hedge is in quoted or attributed speech (not the author's voice)
- The hedge does real epistemic work (philosophical or scientific qualifiers)
- The word is past-tense ability ("could absorb it"), not future conditional
- Analytical writing uses appropriate qualification ("the data suggests" is not hedging — it's precision)

**In rewrite mode:** Replace conditional mood with present or future declarative. Cut qualifiers that add nothing. Pay special attention to closing lines — they must land.

### Nominalizations

A nominalization turns a verb or adjective into a noun, usually weakening the sentence:

- "implementation" → "implemented"
- "realization" → "realized"
- "improvement" → "improved"

**Flag when:** The verb form would be shorter, more direct, and more active.

**Keep when:** The noun form is standard in the register (e.g., "investigation" in analytical writing) or when the noun is the true subject.

### Clichés

See [cliches.md](references/cliches.md) for the full list. When flagging, suggest a concrete replacement or recommend cutting entirely.

### Forbidden

- Explanations of edits (unless asked)
- Meta-commentary about the editing process
- British spelling or usage
- Softening direct statements
- Adding qualifiers the author didn't use
- Changing the author's meaning
- Imposing a voice not their own
- Suggesting the author "consider" something — either flag it or don't
- Shifting the piece's register (don't make analytical writing personal, or personal writing academic)

### Structural Guidance

#### Openings

Flag throat-clearing. The piece should begin with its subject, not with setup. If the first paragraph could be cut without losing anything, flag it.

#### Transitions

Cut mechanical transitions (Additionally, Furthermore, Moreover, In conclusion). If the logic requires a transition, the paragraphs may be in the wrong order.

#### Endings

Flag summary endings that repeat what the piece already said. Flag morals stated explicitly when the piece already showed them. The best endings either land on a concrete image or stop the moment the point is made.

### Output Format

#### Edit Mode

Return text with [bracketed flags] inline. After the flagged passage, provide suggested fixes. Group related fixes when efficient.

#### Rewrite Mode

Return clean copy only. No markup, no tracked changes, no commentary.

#### When Asked to Explain

Explain the specific edit requested. Do not explain the editing philosophy unless asked.

### Quality Check

After editing, verify:

1. **Voice preserved** — Read the edited version aloud. Does it still sound like the author?
2. **Meaning unchanged** — Compare each substantive change against the original. No new claims, no removed claims.
3. **Register consistent** — Confirm the register detected in Step 1 matches the output. An analytical piece shouldn't become personal, and vice versa.
4. **No over-editing** — If more than ~40% of sentences are flagged, reconsider: is the piece genuinely problematic, or are you imposing preferences?
5. **Endings land** — Read the final paragraph. Does it end with weight, or trail off?

### Reference Files

- [orwell.md](references/orwell.md) — Load when applying Orwell rules to dense prose or when unfamiliar with a rule
- [cliches.md](references/cliches.md) — Load when a piece contains 3+ suspected clichés
- [word-choices.md](references/word-choices.md) — Load when encountering confused words or heavy jargon
- [examples.md](references/examples.md) — Load on first use to calibrate editing intensity

## Do not use when

- Restructuring a draft or changing its argument — that is revision, not copy editing
- Editing code, YAML, or configuration files — prose only
