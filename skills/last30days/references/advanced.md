# Advanced Options

## Depth Flags

| Flag       | Effect                                      |
| ---------- | ------------------------------------------- |
| `--quick`  | 2-3 searches per source, skip enrichment    |
| (default)  | 4-6 searches per source, enrich top results |
| `--deep`   | 8-10 searches per source, enrich broadly    |
| `--days=N` | Override 30-day window (e.g., `--days=7`)   |
| `--agent`  | Structured output, no user interaction      |

## Agent Mode (--agent flag)

When `--agent` is present:

1. Skip intro display and all user prompts
2. Run research normally
3. Output a structured report and stop:

```text
## Research Report: {TOPIC}
Generated: {date} | Sources: Reddit, X, YouTube, HN, Web

### Key Findings
[3-5 bullet points, highest-signal insights with citations]

### What I learned
{Full synthesis}

### Stats
{Standard stats block}
```

## Polymarket

When researching topics with prediction markets (elections, crypto, policy):

- Add `site:polymarket.com {TOPIC}` to platform searches
- Weave odds into narrative as supporting evidence: "Polymarket has X at Y% (up Z% this month)"
- Include in stats block: `├─ 📊 Polymarket: {N} markets │ {summary of top odds}`

Skip Polymarket for topics unlikely to have prediction markets.

## Handling Sparse Results

- If ALL social platforms (Reddit, X, YouTube, HN) return 0, pivot to web-only synthesis
- If total results across all sources < 5, acknowledge limited coverage and suggest broader terms or a longer time window (`--days=90`)
