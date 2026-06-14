---
name: Market Velocity Report
description: "Track market speed — absorption rate, DOM trends, inventory changes, and price velocity. Identifies heating or cooling markets. Triggers on: market velocity, days on market, absorption rate, how fast, market speed, market momentum."
---

# Market Velocity Report

## Overview
Measures how fast a market is moving. Absorption rate, DOM trends, and price velocity tell you whether to move fast or wait on deals.

## When to Use
- Deciding how aggressively to offer
- Timing exit strategy (sell now vs hold)
- Identifying markets shifting from seller to buyer
- Monthly market monitoring

## Inputs
- Target area
- Property type
- Lookback period (default: 6 months for trend)

## Process

### Step 1: Calculate Velocity Metrics
- **Absorption Rate:** Closed sales / Active listings per month
- **DOM Trend:** Average DOM this month vs 3 months ago vs 6 months ago
- **Price Velocity:** Median price change per month
- **Inventory Trend:** Active listings this month vs prior months
- **List-to-Sale Ratio:** Average sale price / list price

### Step 2: Classify Market Speed

| Speed | Indicators |
|-------|-----------|
| HOT | Absorption >20%, DOM <15, price rising >1%/mo |
| WARM | Absorption 10-20%, DOM 15-30, prices stable/rising |
| COOL | Absorption 5-10%, DOM 30-60, prices flat |
| COLD | Absorption <5%, DOM >60, prices declining |

## Output Format
```
MARKET VELOCITY — [Area] — [Date]
═════════════════════════════════
Absorption Rate: [X]% | DOM: [X] days (trend: [↑↓→])
Inventory: [X] ([+/-X]% vs last quarter)
Price Velocity: [+/-]$[X]/month ([X]% monthly)
List-to-Sale: [X]%

SPEED: [HOT/WARM/COOL/COLD]
TREND: [Accelerating/Stable/Decelerating]

INVESTOR IMPLICATION:
[What this means for buying, selling, and holding]
```

## Example Prompts
- "How fast is the Lubbock market moving right now? Give me velocity metrics."
- "Is Dallas cooling down? Show me DOM and absorption rate trends."

## Suggested Next Steps
1. **`/deal-analysis/market-snapshot`** — Full market overview
2. **`/reporting/exit-timing-advisor`** — Should I sell based on market speed?
