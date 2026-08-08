# Report Template

Single consolidated report with three sections, in this order. Skip any section that's empty.

```markdown
## Release Review: v<last_reviewed+1> → v<installed>

Reviewed N versions. <One-sentence summary of overall scope, e.g. "Mostly bug fixes; one
new hook field; two security tightenings on existing permissions.">

### Action items

<!--
Things tied to the user's current config that they may want to act on.
Each bullet must include: (a) what changed, (b) which file/line in their config it
touches, (c) the specific recommended change, (d) version it shipped in.
Skip this section entirely if there are zero action items.
-->

- **<Short label>** (vX.Y.Z): <what changed>. Affects `settings.json:<line>` (<which key>).
  Recommended: <add/remove/update X>.

### Notable, no action required

<!--
One line per item. Group by category if it helps scanning. Each line ends with the
version in parens. These are things the user should know about but don't need to do
anything about — bug fixes that benefit them, behavioral changes that don't conflict
with their setup, new features that aren't relevant.
Collapse cross-version themes into one line where possible (e.g. "find fd usage
reduced (v2.1.120, v2.1.121)").
-->

- <One-line summary> (vX.Y.Z)

### Added surface area

<!--
Categorized rollup of every additive change in the slice — new settings, env vars,
CLI flags/subcommands, hook events/fields, permission patterns, MCP capabilities,
slash commands, skill/agent frontmatter, OpenTelemetry attrs, native/platform changes.
This section is built-in by default — do not omit it unless the slice contained no
additions at all.
Only list additions, not bug fixes or removals. Tag each with version.
-->

#### Settings (`settings.json` keys)

- `<key>` — <what it does> (vX.Y.Z)

#### Environment variables

- `<NAME>` — <what it does> (vX.Y.Z)

#### CLI subcommands & flags

- `<flag or subcommand>` — <what it does> (vX.Y.Z)

#### Hooks

- <new event / new field / new capability> (vX.Y.Z)

#### Permissions / Security

- <new pattern / tightened behavior on existing pattern> (vX.Y.Z)

#### MCP

- <new capability> (vX.Y.Z)

#### Skills / Slash commands / Agents

- <new feature> (vX.Y.Z)

#### Telemetry / OpenTelemetry

- <new event / new attribute> (vX.Y.Z)

#### Native / platform

- <change> (vX.Y.Z)
```

Add other categories as needed (themes, output styles, etc.). Drop categories with no entries.
