---
allowed-tools: WebSearch, WebFetch
description: "Researches any topic using sources tailored to the query — places (local papers, Ground News, city .gov), consumer products (Wirecutter, Serious Eats, Reddit, owner forums), tech/software (official changelogs, GitHub, awesome-lists), medical (PubMed, Cochrane, clinical guidelines), sports (ESPN, SBN blogs, team officials, ISW-style trackers), geopolitics (wire services, think tanks, credentialed analysts), and general trends (Reddit, X, YouTube, HN). Use this skill whenever the user mentions a place, product, person, team, event, a specific app/tool/library, a medical condition or drug, a sports matchup, current news, 'best X' recommendations, 'what's happening with Y,' 'prompts for Z,' or any topic where last-30-days context matters — even if they don't explicitly ask for research. Produces dated synthesis grounded in what sources actually say."
---

# last30days: Research Any Topic from the Last 30 Days

Research ANY topic with a source mix tailored to the query shape. The source table and weighting overrides in Step 2/3 pick between general social (Reddit, X, YouTube, HN, web), place-based (local papers, Ground News, city .gov), consumer-product (Wirecutter-tier review aggregators, owner forums), tech/software (official changelogs, GitHub, awesome-lists), sports (league/team official, SBN blogs, ESPN), medical (PubMed, Cochrane, guidelines), geopolitics (wire services, specialist trackers, think tanks), and niche/stable-category (owner forums + durable community consensus). Surface what sources actually say right now — with dated attributions.

## Reference Files

- [examples.md](references/examples.md) — Output examples for each QUERY_TYPE. Study before producing results.
- [source-catalog.md](references/source-catalog.md) — Canonical source lists by domain (review aggregators by category, medical guidelines, sports sources, think tanks, owner forums, daily trackers). Cross-referenced from the table in §2a.
- [advanced.md](references/advanced.md) — Depth flags (`--quick`/`--deep`/`--days=N`/`--agent`), Polymarket integration, sparse-results fallback.

## Step 1: Parse User Intent

Three sub-steps: (1a) classify QUERY_TYPE, (1b) detect shape and domain signals, (1c) display parsing before searching.

### 1a. QUERY_TYPE

Pick one:

- **PROMPTING** — "X prompts", "prompting for X" → wants techniques and copy-paste prompts
- **RECOMMENDATIONS** — "best X", "top X", "what X should I use" → wants a ranked list
- **NEWS** — "what's happening with X", "X news" → wants current events
- **LOCATION** — topic is a place (city, town, neighborhood, region) → wants local happenings
- **GENERAL** — anything else → wants broad understanding

Common patterns:

- `[topic] for [tool]` → tool is specified; set **TARGET_TOOL**
- `best [topic]` or `top [topic]` → RECOMMENDATIONS
- `[City] [State]` or a place name → LOCATION
- Just `[topic]` → GENERAL

**TARGET_TOOL** is where user will use prompts (if specified). Only set when query contains "for [tool]". Do NOT ask about target tool before research. Research first, ask after.

**Compound topics.** "X configuration, tips, and tricks" blends RECOMMENDATIONS + PROMPTING. Pick the **dominant** type for the output template — don't run both. For tips/tricks lists, RECOMMENDATIONS usually wins; note the blend in synthesis prose.

### 1b. Shape & domain detection (drives source-mix selection in §2)

Scan the TOPIC for these signals. Multiple can apply.

- **Niche / discontinued / stable-category** (a RECOMMENDATIONS sub-shape). Signals: discontinued product/vehicle, no mainstream-review coverage, community threads span 2020–2026 with consistent top picks. Examples: Honda Element seat covers, Saab 9-3 parts, vintage Nikon F lenses, Commodore 64 accessories, fountain-pen inks. When detected: lead synthesis with "stable-category topic — durable community consensus"; owner forums + Reddit tier-1; review aggregators often N/A. **Named vehicle/hobby pattern** for `[Vehicle/product] + [accessory]` shapes: dedicated sub → owner forum → enthusiast blog → manufacturer model-specific page.

- **Sports matchup** (`[Team A] vs [Team B]`). Needs: H2H history + recent form + roster/injury news + past-vs-upcoming framing. Classify as NEWS. Source chain: league official → both team officials → SBN team blogs + The Athletic beat writers → ESPN game pages → highlight YouTube. Keep YouTube tier-1 (highlights are the medium). If <~3 dated-in-window findings, apply the honest-gap pattern (§4 synthesis).

- **High-stakes domain** (medical, legal, financial, tax, geopolitics/conflict, elections/political). Triggers authority-inverted weighting (§3) and a standardized disclaimer at the top of synthesis (§4).

- **Ambiguous place name.** Common collisions: Rockford, Springfield, Portland, Cambridge, Vienna, Venice, Georgia, Lebanon, Manchester. **Disambiguate BEFORE searching** — present candidates as a numbered list:

  ```text
  "Rockford" matches multiple places — which did you mean?
  1. Rockford, IL (population ~150k, Illinois)
  2. Rockford, MI (village near Grand Rapids)
  3. Something else
  ```

  A wrong disambiguation wastes the whole research run.

- **Product-name collision** (common noun / short phrase that collides with a video game, band, movie, meme). Examples: "pepper grinder" → kitchen tool AND Devolver Digital game; "AirPods" → Apple earbuds AND Nike SB sneakers; "Obsidian" → note app AND gaming studio AND rock; "Cursor" → IDE AND generic UI term. Auto-append a disambiguating category term: `pepper grinder kitchen`, `AirPods earbuds`, `Obsidian note-taking app`. If first-pass results are dominated by the wrong meaning, flag and re-run with tighter terms.

### 1c. Display parsing before research

Tailor the opening line to the source mix the detected shapes will trigger:

```text
{Opening line per QUERY_TYPE — see below}

Parsed intent:
- TOPIC = {TOPIC}
- QUERY_TYPE = {QUERY_TYPE}
{- TARGET_TOOL = {TARGET_TOOL} — only if specified}
{- Shape: {niche/stable-category | sports matchup | high-stakes | ...} — only if detected}

Research typically takes {2-8 minutes | 2-10 for LOCATION}. Starting now.
```

Opening lines by QUERY_TYPE:

- **PROMPTING / RECOMMENDATIONS / NEWS / GENERAL**: "I'll research {TOPIC} across Reddit, X, YouTube, HN, and the web."
- **LOCATION**: "I'll research {PLACE} using local papers, Ground News, city/municipal sources, and Reddit/X — last 30 days."

When halting for disambiguation (§1b): still display the parsed-intent block first so the user sees what you inferred, then the numbered-list disambiguation prompt, then stop. Don't run searches until the user picks.

## Step 2: Research Across All Sources

Source mix depends on QUERY_TYPE. Run searches in parallel where possible. Use `--quick` or `--deep` to control search depth (see [advanced.md](references/advanced.md)).

### 2a. Platform Searches — default mix (non-LOCATION)

For PROMPTING / RECOMMENDATIONS / NEWS / GENERAL, search in two passes: (1) always-consider platforms run on every query; (2) domain-specific sources activate only when TOPIC matches the trigger. Run in parallel within each pass.

**Always-consider platforms** (run on every non-LOCATION query):

| Source            | Strategy                                                                                                                                                                                                                           |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Reddit**        | WebSearch `{TOPIC} Reddit discussion 2026` — include "Reddit" in query instead of `site:`. Try subreddit-specific terms if subs emerge.                                                                                            |
| **X/Twitter**     | WebSearch `site:x.com {TOPIC}`. If results are dominated by non-x.com URLs (site-scope ignored), re-query without `site:` and target known handles. Deprioritize for consumer-product RECOMMENDATIONS (affiliate-spam/joke noise). |
| **YouTube**       | WebSearch `{TOPIC} YouTube video 2026`. **Deprioritize** for fast-moving tech (AI tools, CLIs, JS frameworks on weekly cadence) — text leads video. Keep tier-1 for stable evergreen (reviews, cooking, sports).                   |
| **Hacker News**   | WebFetch `https://hn.algolia.com/api/v1/search?query={TOPIC}&tags=story&hitsPerPage=10`. **Skip in first pass** for software products older than ~3 years — results accumulate and skew pre-cutoff.                                |
| **Web (general)** | Supplemental web search per §2b.                                                                                                                                                                                                   |

**Domain-specific sources** (activate only when TOPIC matches the trigger — check each against the TOPIC, include matching rows):

| Trigger — activate when...                          | Source class                | Strategy (see [source-catalog.md](references/source-catalog.md) for full lists)                                                                                                                                                                                                                                                                                                                   |
| --------------------------------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| TOPIC names a specific app/CLI/SDK/library          | **Official changelog**      | WebFetch the vendor's `/changelog`, `/releases`, or `/whats-new` page directly. Tier-1 for app/tool topics — analogous to "local paper" in LOCATION mode.                                                                                                                                                                                                                                         |
| TOPIC is a consumer product                         | **Review aggregators**      | Catalog by category: kitchen (Wirecutter, Serious Eats, ATK…), audio (Wirecutter, RTINGS, SoundGuys…), outdoor (OGL, GearJunkie, REI…), tech (Wirecutter, Reviewed, Verge…). WebSearch `best {TOPIC} 2026 Wirecutter Serious Eats` and fetch top 2–3. **Absence-is-signal:** zero roundups means community is the authority — demote this row to N/A and promote owner forums + Reddit to tier-1. |
| TOPIC is vehicle/hobby/collector-specific           | **Owner/hobbyist forums**   | WebSearch `"{product or vehicle} owners forum"` or `"{product} owners club"`. Catalog has canonical examples (elementownersclub, tacomaworld, fountainpennetwork, rokslide). Treat as peer of Reddit for niche/hobbyist RECOMMENDATIONS.                                                                                                                                                          |
| TOPIC is a developer/tooling/library topic          | **GitHub**                  | WebSearch `site:github.com {TOPIC}` and separately `"awesome-{topic-slug}"` — curated lists and reference repos often the highest-signal source.                                                                                                                                                                                                                                                  |
| TOPIC is a plugin/extension/theme ecosystem         | **Ecosystem stats tracker** | Look for a community stats/updates site (e.g., `obsidianstats.com`). WebSearch `"{topic}stats"` or `"{topic} plugin updates 2026"`. One weekly tracker digest beats many single-day hits.                                                                                                                                                                                                         |
| TOPIC is a sports team / matchup / league / athlete | **Sports sources**          | League official + team official + SBN team blog + The Athletic beat writer + ESPN. Catalog has full list. On X: target team/league/beat-writer handles by name. On Reddit: r/{TeamName} + r/{league} explicitly. YouTube stays tier-1 (highlights are the medium).                                                                                                                                |
| TOPIC is a medical condition / drug / treatment     | **Medical/health sources**  | Peer-reviewed (PubMed, Cochrane), preprints (biorxiv, medrxiv), guidelines (ACC/AHA, USPSTF, NICE, WHO), clinical centers (Mayo, Cleveland, Hopkins, NIH), clinician media (Medscape, JAMA, NEJM Journal Watch). Catalog has tiered list. High-stakes — apply authority-inverted weighting (§3) and disclaimer (§4).                                                                              |
| TOPIC is war / foreign-policy / conflict            | **Geopolitics/conflict**    | Wire services + specialist trackers (ISW, Russia Matters, DeepState, LiveUAmap) + think tanks (CSIS, CFR, Carnegie, RAND, Brookings, RUSI, IISS) + credentialed OSINT/analyst handles. Catalog has full list. High-stakes info-ops-contested — apply authority-inverted weighting (§3); attribute contested numbers to reporting source.                                                          |
| TOPIC is a rapidly-evolving current event           | **Daily/weekly trackers**   | Specialist tracker with consistent methodology: ISW for war, NWS/NHC for weather, Decision Desk HQ for elections, USGS for earthquakes, SEC EDGAR for filings. Analogous to "official changelog" for software.                                                                                                                                                                                    |
| TOPIC has a prediction market                       | **Polymarket**              | WebSearch `site:polymarket.com {TOPIC}` for elections, crypto, policy, AI-capability bets, corporate milestones. Weave odds into narrative ("Polymarket has X at Y%, up Z% this month"). Include 📊 in stats block. Skip for topics unlikely to have markets.                                                                                                                                     |

**Why not `site:` for Reddit/YouTube/HN?** WebSearch `site:` scoping fails intermittently for these domains. Keyword-inclusive queries return the same results more reliably.

**Tech-topic heuristic:** TOPIC names a CLI, SDK, AI tool, framework, library, or dev workflow → promote GitHub + official changelog to tier-1, demote YouTube, and consider skipping HN if the product is mature (>3 years).

### 2a-LOC. Platform Searches — LOCATION mix

For LOCATION queries, the default mix is wrong: HN is virtually always empty, YouTube surfaces evergreen "moving to X" SEO videos not 30-day news, and generic Reddit search pulls in same-name towns from other states. Use this mix instead:

| Source                 | Strategy                                                                                                                                                                                                                                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Ground News**        | WebFetch `https://ground.news/interest/{slug}`. US places: try `{city}-{state}` (e.g., `rockford-michigan`). International places: try city-only first (e.g., `vicenza`), fall back to `{city}-{country}` if that 404s. Aggregates dated local-news headlines across outlets.                     |
| **Local papers (2-3)** | Mid-size cities have multiple outlets — fetch 2–3, not one. Identify via a quick WebSearch for "{city} newspaper" or "giornale di {city}", then WebFetch each front page. Triangulation catches stories any one paper missed.                                                                     |
| **City .gov site**     | US places: WebFetch `cityof{x}.gov` / `{city}.{state}.us` news page — RFPs, closures, notices are primary civic news channel. International places: often less news-oriented; skip unless first pass is thin.                                                                                     |
| **Reddit**             | WebSearch `"{CITY} {STATE-or-COUNTRY}" site:reddit.com` — quote the full phrase to avoid same-name collisions. US: look for metro sub (e.g., r/grandrapids for Rockford MI). International: topic subs (r/soccer, r/ItalyTravel) and r/{country} often carry more signal than a sparse metro sub. |
| **X/Twitter**          | WebSearch `site:x.com "{CITY} {STATE-or-COUNTRY}"` — quote the full "City State" phrase. Look for local government, paper, and school accounts.                                                                                                                                                   |
| **Mil-town specialty** | If the place hosts a US military installation (Vicenza/Aviano IT, Ramstein/Kaiserslautern DE, Yokosuka/Okinawa JP, Bahrain, Stuttgart, etc.), add Stars & Stripes (stripes.com) and DVIDS (dvidshub.net) — they carry unique on-base coverage you won't see elsewhere.                            |

Skip HN and YouTube for LOCATION queries by default — include only if the user specifically asked about tech-industry or video coverage of the place.

### 2b. Supplemental Web Search

After platform searches, run general web searches to fill gaps. Adapt queries to QUERY_TYPE:

- **RECOMMENDATIONS** → "best {TOPIC} recommendations", "most popular {TOPIC}"
- **NEWS** → "{TOPIC} news 2026", "{TOPIC} announcement update"
- **PROMPTING** → "{TOPIC} prompts examples 2026", "{TOPIC} techniques tips"
- **LOCATION** → "{CITY} {STATE} news 2026", "things to do {CITY} {STATE}", "{CITY} {STATE} downtown events"
- **GENERAL** → "{TOPIC} 2026", "{TOPIC} discussion"

**Local-language query (mandatory for non-anglophone LOCATION).** When the place is in a non-English-speaking country, run at least one supplemental query in the local language — this is almost always the highest-signal single query for hyperlocal cronaca/news/events that English searches miss. Examples:

- Italy → "{city} Italia notizie aprile 2026 cronaca"
- France → "{ville} actualités avril 2026"
- Germany → "{stadt} Nachrichten April 2026"
- Spain/LatAm → "{ciudad} noticias abril 2026"
- Japan → "{市} ニュース 2026年4月"

Fall back to English-only only if no native-language outlet is reachable.

### 2c. Enrichment

Fetch full page content selectively on high-signal results — X posts with engagement data, HN threads with deep discussion. Reddit and YouTube enrichment often hits rate limits or returns noise; skip unless the snippet alone is insufficient.

If a platform returns 0 results, omit it from synthesis and stats entirely.

### 2d. Date discipline

WebSearch does NOT reliably filter to the last 30 days — results routinely leak older stories dated months or years back. For each finding, check the dateline:

- Within 30 days → include as primary finding
- 30–90 days old → include only if still load-bearing context (e.g., the event that everyone is still reacting to); mark as "earlier"
- Older than 90 days → drop unless the user explicitly asked for deeper history

Never present an older story as if it were from this month. If a date is not visible in the source, say "undated — likely recent" rather than assert a date you can't verify.

**Durable-consensus exception.** For certain TOPIC classes, the 90-day drop rule is wrong — older material _is_ the answer because durable consensus, foundational science, or prior-season context is what everyone currently operating in that domain references. Include older sources as dated earlier-context; do not drop them. Flag the date provenance **once upfront** at the top of synthesis rather than burying a caveat in the footer. Named sub-cases:

- **Stable-category products** (detected per Step 1: discontinued vehicles, hobbyist/collector niches, stable craft tools): community top picks recur across years; include old threads as "durable community consensus, not 30-day news."
- **Sports seasons**: current-season events + major trophies/finals from the prior season stay relevant because the new-season narrative references them ("defending champions", "revenge match"). Date explicitly ("Aug 2025 Leagues Cup Final").
- **Medical foundational science**: landmark trials, systematic reviews, and guideline-underlying studies are load-bearing even when older; the 2026 guideline update cites them as the evidence base.
- **Ongoing conflicts / current news cycles**: prior-cycle events that shape the current frame ("the 28-point peace plan from Nov 2025") remain in-context; treat as earlier-context, not drop.

When direct 30-day content is thin, combine this exception with the **honest-gap pattern** (§4 synthesis) — name the gap explicitly, then pivot to load-bearing durable context.

See [examples.md](references/examples.md) for complete output examples. See [advanced.md](references/advanced.md) for depth flags, agent mode, Polymarket, and sparse results handling.

## Step 3: Synthesize

Weight sources by signal quality. The default weighting below applies to **opinion/trend discovery** for everyday topics; **several overrides follow for software, high-stakes domains, and LOCATION — check those first if the TOPIC fits.** If the TOPIC is a mature software product, a medical/legal/financial/geopolitical/electoral topic, or a place, skip the default and use the matching override.

Default weighting:

1. **Reddit/X** — highest (real engagement: upvotes, likes)
2. **YouTube** — high (views, likes, transcript content)
3. **Hacker News** — medium-high (technical community, points + comments)
4. **Web** — lower (no engagement data)

For mature software/tool topics (TOPIC is an app, CLI, library, framework), override to:

1. **Official changelog / releases page** — highest (dated, version-specific, authoritative)
2. **Ecosystem stats trackers + GitHub (awesome-lists, major repos)** — high
3. **Reddit/X commentary** — medium (hot takes and recommendations, not "what shipped")
4. **Web (review blogs, aggregators)** — lower

The default weighting is calibrated for opinion/trend discovery; for "what shipped" in software, vendor-authoritative sources beat social engagement.

For high-stakes domains (medical, legal, financial, tax, **geopolitics/conflict**, elections/political), authority-inverted weighting:

1. **Peer-reviewed literature + official guidelines/regulations + specialist trackers** — highest (PubMed, Cochrane, ACC/AHA, USPSTF, Federal Register, court opinions, SEC filings, ISW daily assessments, NWS/NHC, Decision Desk HQ)
2. **Clinical centers / regulatory bodies / think tanks / institutional analysts** — high (Mayo, Cleveland Clinic, CSIS, CFR, Carnegie, RAND, Brookings, RUSI, IISS, law-firm client alerts, major-bank research)
3. **Credentialed commentary** — medium (handles with MD/JD/CFA/institutional/military-analyst affiliation in bio; journal-aligned media like JAMA/NEJM/Medscape; named beat journalists)
4. **Reddit/X anecdote or opinion** — lowest (anecdote ≠ evidence; engagement ≠ authority in domains where misinformation has consequences AND where info ops actively distort the social layer)

Engagement is not authority in these domains. A high-engagement X post from a non-credentialed account is lower-signal than an ISW daily assessment or an ACC/AHA guideline. Filter social by credential, not by likes. For war/geopolitics/elections specifically: expect info-ops contamination; attribute contested numbers to their reporting source ("per Ukrainian MoD", "per Russian MoD") rather than stating as neutral fact.

For LOCATION queries, use this weighting instead:

1. **Local paper + City .gov** — highest (dated, authoritative, hyperlocal)
2. **Ground News aggregation** — high (cross-outlet coverage with dates)
3. **Metro-area Reddit sub / local X accounts** — medium (engagement, but sparse)
4. **General web** — lower (often SEO-bait for place names)

Cross-platform signals are strongest. When the same story appears on multiple platforms, lead with it.

### Ground in Research, Not Pre-existing Knowledge

Read research output carefully. Use exact product/tool names, specific quotes, and what sources actually say. Do NOT substitute your own knowledge for what the research found.

## Step 4: Present Results

### High-stakes disclaimer (medical / legal / financial / tax)

For any TOPIC in these domains, lead the synthesis with a one-line disclaimer — not buried in the footer. Use this standardized phrasing:

- Medical/health: _"Not medical advice — if this applies to you, consult a clinician."_
- Legal: _"Not legal advice — consult an attorney for your situation."_
- Financial/investment: _"Not investment advice — consult a financial advisor."_
- Tax: _"Not tax advice — consult a CPA or tax attorney."_

Place above the synthesis body, below the parsing-display. Keep it one line; no hedging elsewhere in the response needs compensatory softening.

### Synthesis (adapt to QUERY_TYPE)

**If RECOMMENDATIONS** — show a ranked list:

```text
🏆 Most mentioned:

[Name] — ~{n} mentions (or {n}+ if you didn't track exactly)
Best for: [specific audience or use case — e.g., "budget-conscious home cooks", "one-handed grinding", "high-volume kitchens"]
Price: ~$X (when research surfaced it)
Sources: @handle1, r/sub, blog.com

[Name] — ~{n} mentions
...

Notable mentions: [others with 1-2 mentions]
```

- **"Best for:" beats "Use Case:"** — when products all do the same thing (grinders grind, earbuds play audio), what differentiates is the _audience/context_, not the function. Use "Best for:" for consumer products; "Use Case:" is fine when items genuinely do different things (tools, SDKs).
- **Price/tier** — for consumer-product RECOMMENDATIONS, price is load-bearing. Include `Price: ~$X` when the research surfaced a number or range; omit if not surfaced (don't fabricate).
- **Count notation**: if you tallied mentions as you read results, write the exact number (`6 mentions`). If you eyeballed, use `~6` or `6+` — never a bare `6x mentions` count you didn't actually verify.

**Mainstream vs. community-canon split.** For consumer-product RECOMMENDATIONS, watch for divergence between mainstream review publishers (Wirecutter, Serious Eats, etc.) and community forums (Reddit, niche subs). When they disagree, call it out explicitly — the split is itself the insight:

```text
### Mainstream vs. community canon
- **Mainstream reviewers lead with:** [Peugeot Paris, Cole & Mason Derwent]
- **Community (r/BuyItForLife) canonizes:** [Unicorn Magnum, Pepper Cannon]
- **Why they diverge:** [mainstream tests a broad audience; community optimizes for decade-of-use durability]
```

Only add this section when divergence is meaningful (one camp's top pick is absent from the other's list); skip when they converge.

**If LOCATION** — group by recency (this week first, then earlier in the 30-day window), then patterns:

```text
What I learned about {PLACE} (last 30 days):

### This week
**{Headline 1}** — [1-2 sentences, per Local Paper] (date)
**{Headline 2}** — [1-2 sentences, per @handle or City of X] (date)

### Earlier this month
**{Headline 3}** — [1-2 sentences, per {source}] (date)

### Key patterns
1. [Civic/infrastructure theme] — per {source}
2. [Business/employer theme] — per {source}
3. [Community/schools theme] — per {source}
```

Flag disambiguation risk explicitly when same-name towns surfaced noise in results.

**If PROMPTING** — narrative + patterns + **the actual prompt** (the prompt IS the primary deliverable, not a narrative map):

```text
What I learned:

**{Topic 1}** — [1-2 sentences, per @handle or r/sub]

**{Topic 2}** — [1-2 sentences, per @handle or r/sub]

KEY PATTERNS from the research:
1. [Pattern] — per @handle
2. [Pattern] — per r/sub

### Copy-paste-ready prompt (based on research patterns)

{ONE prompt, formatted for the inferred TARGET_TOOL, with placeholders in [BRACKETS]}
```

- **Deliver ONE prompt, not a menu.** The user wants the prompt; a landscape of three options is worse than one sharp prompt that embodies the research.
- **Prompt format matches TARGET_TOOL:**
  - Claude/Anthropic tools (Claude Code, Claude API, skills) → XML tags (`<context>`, `<task>`, `<rules>`)
  - ChatGPT / GPT-4 → markdown headers + natural-language sections
  - API / automation contexts → structured JSON or structured prose with explicit schemas
  - Generic LLM / unspecified → natural language with clear role + task + constraints
- **Infer TARGET_TOOL if not specified.** When the query didn't include "for [tool]" but 80%+ of findings point at one tool (e.g., every source is Claude-specific), infer it and match the prompt format. State the inference briefly above the prompt: "Inferred TARGET_TOOL: Claude Code, based on research concentration."

**If NEWS/GENERAL** — show narrative with patterns:

```text
What I learned:

**{Topic 1}** — [1-2 sentences, per @handle or r/sub]

**{Topic 2}** — [1-2 sentences, per @handle or r/sub]

KEY PATTERNS from the research:
1. [Pattern] — per @handle
2. [Pattern] — per r/sub
3. [Pattern] — per @handle
```

**Honest-gap pattern** (applies to any QUERY_TYPE when direct 30-day content is thin — fewer than ~3 dated-in-window findings for a specific matchup, a niche intersection, or a quiet news cycle). Lead with the gap explicitly rather than padding:

```text
### Direct 30-day content: thin
My 30-day window has {N} direct findings on {specific sub-topic}. Here's the load-bearing context that's shaping current coverage instead:

{dated earlier context + current-season/current-cycle material}
```

Don't silently substitute older material for recent findings — name the gap, then pivot honestly to durable context. This is how sports matchups with no 30-day H2H, niche intersections (e.g., "Obsidian with Claude Code"), and quiet news cycles should be handled.

### Citation Rules

Priority (most to least preferred). Default:

1. @handles from X — "per @handle"
2. r/subreddits — "per r/subreddit"
3. YouTube channels — "per [channel] on YouTube"
4. HN — "per HN"
5. Web — ONLY when social sources don't cover that fact

LOCATION priority:

1. Local paper — "per {Paper Name}"
2. City/town .gov — "per City of {Name}"
3. Regional outlet (TV/business) — "per {Outlet}"
4. Metro Reddit sub / local X accounts — "per r/sub" or "per @handle"
5. Aggregator (Ground News) — used to find the above, cite the source itself

**Lead with people, not publications.** In the prose synthesis, use publication/handle names ("per Il Giornale di Vicenza", "per @handle") — don't inline raw URLs mid-sentence. The WebSearch tool requires a "Sources:" section with markdown-linked URLs; put that at the END of the response, after the stats block. Prose readable → links parkable.

### Stats Block

Summarize what the research actually found. Omit any platform that returned nothing. Pick the variant that matches the dominant source class; for mixed topics, combine rows.

**Default** (general + tech + RECOMMENDATIONS):

```text
---
├─ 🟠 Reddit: {N} threads │ r/{sub1}, r/{sub2}
├─ 🔵 X: {N} posts │ {N} likes │ top: @{handle}
├─ 🔴 YouTube: {N} videos
├─ 🟡 HN: {N} stories │ {N} points
├─ 🐙 GitHub: {N} repos │ top: owner/repo
├─ 📊 Polymarket: {N} markets │ {brief top-odds summary}
├─ 🌐 Web: {N} pages — Source Name, Source Name
└─ 🗣️ Top voices: @{handle1}, @{handle2} │ r/{sub1}
---
```

**LOCATION**:

```text
---
├─ 📰 Local paper: {Paper Name} — {N} headlines
├─ 🏛️ City .gov: {N} notices/RFPs
├─ 🌐 Ground News: {N} aggregated stories
├─ 🔵 X: {N} local accounts active │ top: @{handle}
├─ 🟠 Reddit: {N} threads in r/{metro-sub}
└─ 🗣️ Top voices: {Paper}, City of {X}, @{handle}
---
```

**Medical / high-stakes**:

```text
---
├─ 📚 Peer-reviewed: {N} papers/reviews │ top: PubMed/Cochrane/JAMA
├─ 🏥 Clinical centers / guidelines: {N} │ top: Mayo, Cleveland, ACC/AHA
├─ 📰 Clinician media: {N} │ top: Medscape, NEJM Journal Watch
├─ 🔵 X: {N} credentialed posts │ top: @JAMACardio, @NEJM
├─ 🟠 Reddit: {N} threads (anecdote, not authority)
└─ 🗣️ Top voices: {guideline body}, {clinical center}, {credentialed handle}
---
```

**Sports**:

```text
---
├─ 🏆 League/team official: {N} releases │ {teams cited}
├─ 📰 SBN team blogs + The Athletic: {N} articles │ top: {blog/writer}
├─ 📺 ESPN / wire: {N} game pages/recaps
├─ 🔴 YouTube: {N} highlight videos │ top: {channel}
├─ 🔵 X: {N} beat-writer/team posts │ top: @{handle}
├─ 🟠 Reddit: {N} threads in r/{TeamSub}, r/{league}
└─ 🗣️ Top voices: {beat writer}, {league official}, r/{sub}
---
```

**Geopolitics / conflict**:

```text
---
├─ 🏛️ Wire services: {N} articles │ top: Reuters, AP, BBC, NPR
├─ 📊 Specialist trackers: {N} assessments │ top: ISW daily, Russia Matters weekly
├─ 🧠 Think tanks: {N} briefs │ top: CSIS, CFR, Carnegie
├─ 🔵 X (credentialed only): {N} posts │ top: @RALee85, @KofmanMichael
├─ 🟠 Reddit: {N} r/CredibleDefense / r/{country} threads
└─ 🗣️ Top voices: ISW, {analyst}, {wire service}
---
```

`N` in the stats block = count of **distinct items that contributed to synthesis**, not raw search-hit counts. If Reddit returned 12 results but only 4 were relevant and dated in-window, report `4 threads`, not `12`. Use approximate counts where exact engagement data wasn't available. Never fabricate precision.

## Step 5: Expert Mode

After research, you are an expert on this topic.

- **DO NOT** run broad new searches for follow-up questions — answer from research
- **If user asks a question** → answer from findings with citations
- **If user asks for a prompt** → write one copy-paste-ready prompt using research insights, appropriate for TARGET_TOOL if set
- **If user describes something to create** → write one tailored prompt

Narrow follow-up exception (all QUERY_TYPES): if the user asks about a specific sub-topic, intersection, or sub-facet the broad research didn't cover — a particular neighborhood (LOCATION), a specific plugin/integration (tech), an intersection like "X with Y" — ONE targeted search is allowed. Say "let me check that specifically" first. Don't chain multiple searches — if one focused query doesn't surface it, tell the user and stop.

Intersections ("Obsidian with Claude Code", "Hugo for Notion users", "Django in a Kubernetes setup") are a recurring follow-up shape and always qualify for this exception. If research already covers the intersection adequately, answer from research; otherwise one targeted search.

When writing prompts:

- Match the FORMAT the research recommends (JSON, structured, natural language)
- Use specific patterns/keywords discovered in research
- Ready to paste with zero edits (or minimal [PLACEHOLDERS])

Only do new broad research if the user asks about a DIFFERENT topic.

## Do not use when

- Looking up stable documentation or reference material — use `defuddle` or WebFetch directly
- Researching the repository's own history — use `git log` and git blame
