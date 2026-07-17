---
name: Days on Market Tracker
description: "Track average days on market for target areas to identify market speed changes. Triggers on: days on market, DOM, how long listed, market speed, DOM trend."
---

# Days on Market Tracker

## Overview
Monitor DOM trends in your target markets. Rising DOM = cooling market (more negotiation power). Falling DOM = heating market (move fast).

## When to Use
- Monthly market monitoring
- Adjusting offer strategy based on market speed
- Identifying shifting market conditions early

## Inputs
- Target zip codes or areas
- Property type
- Lookback period (default: 6 months)

## Process

### Step 1: Pull DOM Data
Get average and median DOM for target area from Redfin, Zillow, or MLS data.

### Step 2: Trend Analysis
Compare current DOM to 30, 60, 90, and 180 days ago.

### Step 3: Strategy Implications
- DOM falling: Offer faster, offer higher, expect competition
- DOM rising: More room to negotiate, less urgency, more inventory coming
- DOM stable: Market is balanced

## Output Format
```
DOM TRACKER — [Area]
═══════════════════
Current Avg DOM: [X] days | Median: [X] days

TREND:
| Period | Avg DOM | Change |
|--------|---------|--------|
| Current | [X]    | —      |
| 30d ago | [X]    | [+/-X] |
| 90d ago | [X]    | [+/-X] |
| 180d ago | [X]   | [+/-X] |

Direction: [FASTER / SLOWER / STABLE]
Strategy: [Move fast / Negotiate hard / Standard approach]
```

## Example Prompts
- "What's the average DOM in Lubbock right now? Is it trending up or down?"
- "Track DOM in my 5 target zip codes — which areas are slowing down?"

## Suggested Next Steps
1. **`/deal-analysis/market-velocity`** — Full velocity report
2. **`/deal-analysis/market-snapshot`** — Complete market overview
