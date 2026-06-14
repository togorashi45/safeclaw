---
name: Competitor Flip Tracker
description: "Track competitor flip activity — who is buying, where, at what price, rehab scope, and resale performance. Know your competition. Triggers on: competitor flips, who's flipping, flip activity, competition, other investors."
---

# Competitor Flip Tracker

## Overview
Monitor flip activity by other investors in your market. Understand who's competing for deals, what they're paying, and how they're performing.

## When to Use
- Entering a new market
- Feeling increased competition
- Benchmarking your performance against peers
- Identifying areas competitors are ignoring

## Inputs
- Target market/zip codes
- Lookback period (default: 12 months)
- Specific competitors to track (optional)

## Process

### Step 1: Identify Flips
Search for properties that:
- Sold twice within 12 months
- Second sale significantly higher than first
- Buyer entity is LLC or trust (investor signal)
- Permits pulled between sales (rehab signal)

### Step 2: Analyze Activity
For each flip found:
- Buy price and date
- Sale price and date
- Estimated rehab (from permit value or price delta)
- Hold time
- Estimated profit
- Buyer entity/investor name

### Step 3: Map Patterns
- Which zip codes have most flip activity?
- Which investors are most active?
- What's the average buy discount and rehab scope?
- Are flips selling above or below list price?

## Output Format
```
COMPETITOR FLIP TRACKER — [Market] — [Period]
═════════════════════════════════════════════
Total Flips Identified: [X]
Top Active Investors: [List]

| Investor | Deals | Avg Buy | Avg Sale | Avg Profit | Avg Hold |
|----------|-------|---------|----------|------------|----------|

HOTTEST FLIP ZIPS:
| Zip | Flip Count | Avg Spread | Avg DOM (resale) |

GAPS (Under-served areas):
[Zips with deals but low flip activity — your opportunity]
```

## Example Prompts
- "Who's flipping houses in Dallas 75217? How many flips in the last year?"
- "Show me flip activity in Lubbock — buy price, sale price, and hold time."
- "Find areas in my market where no one is flipping but deals exist."

## Suggested Next Steps
1. **`/deal-analysis/market-snapshot`** — Deep dive on competitor-heavy areas
2. **`/deal-analysis/neighborhood-scoring`** — Score underserved areas
3. **`/lead-generation/expired-listings-hunter`** — Target areas competitors miss
