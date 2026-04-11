---
allowed-tools: WebSearch, WebFetch
description: "Researches any topic from the last 30 days. Use when researching current topics, finding what's trending, getting recent discussions, or looking up community opinions. Searches Reddit, X, YouTube, Hacker News, and the broader web for what people are discussing and recommending."
---

# last30days: Research Any Topic from the Last 30 Days

Research ANY topic across Reddit, X, YouTube, Hacker News, and the web. Surface what people are actually discussing, recommending, and debating right now.

## Reference Files

- [examples.md](references/examples.md) - Complete output examples for all query types
- [advanced.md](references/advanced.md) - Depth flags, agent mode, Polymarket, sparse results

## Step 1: Parse User Intent

Before doing anything, parse the user's input:

1. **TOPIC** — what they want to learn about
2. **QUERY_TYPE** — one of:
   - **PROMPTING** — "X prompts", "prompting for X" → wants techniques and copy-paste prompts
   - **RECOMMENDATIONS** — "best X", "top X", "what X should I use" → wants a ranked list
   - **NEWS** — "what's happening with X", "X news" → wants current events
   - **GENERAL** — anything else → wants broad understanding
3. **TARGET_TOOL** — where they'll use prompts (if specified). Only set when query contains "for [tool]".

Common patterns:

- `[topic] for [tool]` → tool is specified
- `best [topic]` or `top [topic]` → RECOMMENDATIONS
- Just `[topic]` → GENERAL

**Do NOT ask about target tool before research.** Research first, ask after.

Display your parsing before any research:

```text
I'll research {TOPIC} across Reddit, X, and the web to find what's been discussed in the last 30 days.

Parsed intent:
- TOPIC = {TOPIC}
- QUERY_TYPE = {QUERY_TYPE}

Research typically takes 2-8 minutes. Starting now.
```

Only include TARGET_TOOL in the parsed intent display if one was detected.

## Step 2: Research Across All Sources

Search five sources for discussions from the last 30 days (or `--days=N` if specified). Run searches in parallel where possible. Use `--quick` or `--deep` to control search depth (see [advanced.md](references/advanced.md)).

### 2a. Platform Searches

Search each platform using the most reliable method. Run in parallel.

| Source          | Strategy                                                                                                                                                                                                    |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Reddit**      | WebSearch `{TOPIC} Reddit discussion 2026` — include "Reddit" in query instead of `site:` operator. Try subreddit-specific terms if subs emerge.                                                            |
| **X/Twitter**   | WebSearch `site:x.com {TOPIC}` — site-scoped search works reliably for X.                                                                                                                                   |
| **YouTube**     | WebSearch `{TOPIC} YouTube video 2026` — include "YouTube" in query instead of `site:` operator.                                                                                                            |
| **Hacker News** | WebFetch `https://hn.algolia.com/api/v1/search?query={TOPIC}&tags=story&hitsPerPage=10` — public JSON API, no auth needed. Parse `hits[]` array for `title`, `url`, `points`, `num_comments`, `created_at`. |

**Why not `site:` for Reddit/YouTube/HN?** WebSearch `site:` scoping fails intermittently for these domains. Keyword-inclusive queries return the same results more reliably.

### 2b. Supplemental Web Search

After platform searches, run general web searches to fill gaps. Adapt queries to QUERY_TYPE:

- **RECOMMENDATIONS** → "best {TOPIC} recommendations", "most popular {TOPIC}"
- **NEWS** → "{TOPIC} news 2026", "{TOPIC} announcement update"
- **PROMPTING** → "{TOPIC} prompts examples 2026", "{TOPIC} techniques tips"
- **GENERAL** → "{TOPIC} 2026", "{TOPIC} discussion"

### 2c. Enrichment

Fetch full page content selectively on high-signal results — X posts with engagement data, HN threads with deep discussion. Reddit and YouTube enrichment often hits rate limits or returns noise; skip unless the snippet alone is insufficient.

If a platform returns 0 results, omit it from synthesis and stats entirely.

See [examples.md](references/examples.md) for complete output examples. See [advanced.md](references/advanced.md) for depth flags, agent mode, Polymarket, and sparse results handling.

## Step 3: Synthesize

Weight sources by signal quality:

1. **Reddit/X** — highest (real engagement: upvotes, likes)
2. **YouTube** — high (views, likes, transcript content)
3. **Hacker News** — medium-high (technical community, points + comments)
4. **Web** — lower (no engagement data)

Cross-platform signals are strongest. When the same story appears on multiple platforms, lead with it.

### Ground in Research, Not Pre-existing Knowledge

Read research output carefully. Use exact product/tool names, specific quotes, and what sources actually say. Do NOT substitute your own knowledge for what the research found.

## Step 4: Present Results

### Synthesis (adapt to QUERY_TYPE)

**If RECOMMENDATIONS** — show a ranked list:

```text
🏆 Most mentioned:

[Name] — {n}x mentions
Use Case: [what it does]
Sources: @handle1, r/sub, blog.com

[Name] — {n}x mentions
...

Notable mentions: [others with 1-2 mentions]
```

**If PROMPTING/NEWS/GENERAL** — show narrative with patterns:

```text
What I learned:

**{Topic 1}** — [1-2 sentences, per @handle or r/sub]

**{Topic 2}** — [1-2 sentences, per @handle or r/sub]

KEY PATTERNS from the research:
1. [Pattern] — per @handle
2. [Pattern] — per r/sub
3. [Pattern] — per @handle
```

### Citation Rules

Priority (most to least preferred):

1. @handles from X — "per @handle"
2. r/subreddits — "per r/subreddit"
3. YouTube channels — "per [channel] on YouTube"
4. HN — "per HN"
5. Web — ONLY when social sources don't cover that fact

**Lead with people, not publications.** Never paste raw URLs — use publication names.

### Stats Block

Summarize what the research actually found. Omit any platform that returned nothing.

```text
---
├─ 🟠 Reddit: {N} threads │ r/{sub1}, r/{sub2}
├─ 🔵 X: {N} posts │ {N} likes │ top: @{handle}
├─ 🔴 YouTube: {N} videos
├─ 🟡 HN: {N} stories │ {N} points
├─ 🌐 Web: {N} pages — Source Name, Source Name
└─ 🗣️ Top voices: @{handle1}, @{handle2} │ r/{sub1}
---
```

Use approximate counts where exact engagement data wasn't available. Never fabricate precision.

## Step 5: Expert Mode

After research, you are an expert on this topic.

- **DO NOT** run new searches for follow-up questions — answer from research
- **If user asks a question** → answer from findings with citations
- **If user asks for a prompt** → write one copy-paste-ready prompt using research insights, appropriate for TARGET_TOOL if set
- **If user describes something to create** → write one tailored prompt

When writing prompts:

- Match the FORMAT the research recommends (JSON, structured, natural language)
- Use specific patterns/keywords discovered in research
- Ready to paste with zero edits (or minimal [PLACEHOLDERS])

Only do new research if the user asks about a DIFFERENT topic.

## Do not use when

- Looking up stable documentation or reference material — use `defuddle` or WebFetch directly
- Researching the repository's own history — use `git log` and git blame
