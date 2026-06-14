---
name: Comp Pull Bot
description: "Pull and analyze comparable sales for any property. Builds a structured comp grid with adjustments, ARV range, and confidence score. Triggers on: comps, pull comps, comparable sales, comp analysis, comp grid."
---

# Comp Pull Bot

## Overview
Pull recent comparable sales for any property and build a formatted comp grid with price adjustments. The foundation of every deal analysis — accurate comps drive accurate offers.

## When to Use
- Analyzing any potential acquisition
- Verifying a seller's price expectations
- Preparing an offer package
- Refreshing comps on active deals

## Inputs
- Subject property address (full address)
- Property details: beds, baths, sqft, year built, condition (A/B/C/D)
- Target comp radius (default 0.5 mile, expand to 1 mile if needed)
- Lookback period (default 6 months, expand to 12 if needed)
- Data source preference (Redfin, Zillow, PropStream)

## Process

### Step 1: Search for Comps
Pull recent sales matching:
- Within radius of subject
- Within timeframe
- Size within +/-20% sqft
- Same property type
- Beds within +/-1
- Exclude REO distress, family transfers, partial interest sales

Target: 3-6 comps minimum

### Step 2: Build Comp Grid
| # | Address | Sale Price | $/sqft | Beds/Ba | Sqft | Year | Sale Date | Dist | Notes |
|---|---------|-----------|--------|---------|------|------|-----------|------|-------|

### Step 3: Apply Adjustments
For each comp, adjust to match subject property:
- Sqft: $50-100/sqft for differences beyond 10%
- Beds: $5,000-10,000 per bed difference
- Baths: $5,000-7,500 per bath difference
- Condition: percentage adjustment based on grade
- Garage: $10,000-20,000
- Age: $2,000-5,000 per decade

Flag comps requiring >15% total adjustment as "weak."

### Step 4: Calculate ARV
```
Adjusted values: [list]
Average: $X | Median: $Y
Conservative: $X | Mid: $Y | Aggressive: $Z
Confidence: [HIGH/MEDIUM/LOW]
```

## Output Format
```
COMP ANALYSIS — [Subject Address]
Generated: [Date]
Subject: [Beds]BR/[Baths]BA | [Sqft] sqft | Built [Year] | [Condition]

COMPARABLE SALES:
| # | Address | Sale $ | $/sqft | Beds/Ba | Sqft | Dist | Adj $ | Notes |
|---|---------|--------|--------|---------|------|------|-------|-------|

ADJUSTED VALUES: $[X] | $[Y] | $[Z]
Average: $[X] | Median: $[Y]

ARV RANGE:
Conservative: $[X]
Mid (Recommended): $[Y]
Aggressive: $[Z]

Confidence: [LEVEL] ([reason])
```

## Example Prompts
- "Pull comps for 1234 Main St Denver CO 80205. 3/2, 1,450 sqft, built 1965, C condition."
- "I need fresh comps on this property — 4/2 SFR in 75217, 2,100 sqft. Use Redfin, 6 month lookback."
- "Compare these 3 properties and tell me which has the best comp support."

## Suggested Next Steps
1. **`/deal-analysis/arv-calculator`** — Full ARV calculation with MAO
2. **`/deal-analysis/deal-pnl`** — Run the full deal numbers
3. **`/transactions/purchase-agreement`** — Draft the offer if numbers work
