---
name: Cap Rate Tracker
description: "Track cap rate trends over time for target markets. Identify cap rate compression or expansion as investment timing signals. Triggers on: track cap rate, cap rate trend, cap rate history, market cap rates."
---

# Cap Rate Tracker

## Overview
Monitor how cap rates are moving in your target markets over time. Cap rate compression means prices rising faster than rents (harder to cash flow). Expansion means better deals emerging.

## When to Use
- Quarterly market review
- Deciding when to buy vs wait in a market
- Comparing market timing across multiple metros

## Inputs
- Target markets (city/zip/submarket)
- Property type
- Historical period (default: 24 months)

## Process

### Step 1: Gather Historical Data
Pull sold rental/commercial properties over the period and calculate implied cap rates from sale prices and estimated NOI.

### Step 2: Trend Analysis
- Calculate average cap rate per quarter
- Identify direction (compressing, expanding, flat)
- Compare to interest rate movement

### Step 3: Investment Timing Signal

## Output Format
```
CAP RATE TREND — [Market] — [Property Type]
════════════════════════════════════════════
| Quarter | Avg Cap Rate | Trend | Signal |
|---------|-------------|-------|--------|
| Q1 2025 | X.X%        | —     | —      |
| Q2 2025 | X.X%        | ↓     | Compressing |
| Q3 2025 | X.X%        | ↓     | Compressing |
| Q4 2025 | X.X%        | ↑     | Expanding |

Current Trend: [COMPRESSING/EXPANDING/FLAT]
Investment Signal: [BUY/HOLD/WAIT]
Reasoning: [explanation]
```

## Example Prompts
- "How have cap rates moved in Lubbock TX for SFR rentals over the last 2 years?"
- "Are cap rates compressing or expanding in Dallas multifamily right now?"

## Suggested Next Steps
1. **`/deal-analysis/market-snapshot`** — Full market overview
2. **`/reporting/exit-timing-advisor`** — Should you sell or hold based on trends
