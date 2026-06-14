---
name: Market Snapshot
description: "Generate a comprehensive market overview for any zip code or city — median prices, DOM, inventory, price trends, rent ratios, and investment signals. Triggers on: market snapshot, market overview, market stats, area analysis, market report."
---

# Market Snapshot

## Overview
One-page market intelligence report for any area. Gives you the key numbers an investor needs to decide whether to buy, sell, or hold in a market.

## When to Use
- Evaluating a new market to invest in
- Quarterly review of existing markets
- Preparing for a seller meeting (know their market)
- Comparing multiple markets for expansion

## Inputs
- Target area (zip code, city, or county)
- Property type focus (SFR, MF, commercial)
- Comparison market (optional)

## Process

### Step 1: Pull Key Metrics
Research current data for:
- Median sale price and price per sqft
- Median days on market
- Active inventory count
- Months of supply
- Price trend (YoY change)
- Median rent and rent-to-price ratio
- Population and job growth
- New construction permits

### Step 2: Assess Market Conditions
- Seller's market: <3 months supply, DOM <30, prices rising
- Balanced: 3-6 months supply
- Buyer's market: >6 months supply, DOM >60, prices flat/declining

### Step 3: Investment Signal

## Output Format
```
MARKET SNAPSHOT — [Area] — [Date]
═════════════════════════════════
Property Type: [SFR/MF/Commercial]

KEY METRICS:
  Median Sale Price:    $[X] ([+/-X]% YoY)
  Median $/sqft:        $[X]
  Median DOM:           [X] days
  Active Inventory:     [X] listings
  Months of Supply:     [X]
  Median Rent:          $[X]/month
  Rent-to-Price Ratio:  [X]%
  Population Growth:    [X]% YoY

MARKET CONDITION: [Seller's/Balanced/Buyer's] Market
INVESTMENT SIGNAL: [BUY/HOLD/SELL/WATCH]

ANALYSIS:
[2-3 sentences on what this means for investors]
```

## Example Prompts
- "Give me a market snapshot for zip 79401 Lubbock TX — SFR focus."
- "Compare Dallas vs San Antonio markets for SFR investing."
- "Is the Denver market still hot or cooling down? Give me the numbers."

## Suggested Next Steps
1. **`/deal-analysis/cap-rate-tracker`** — Track cap rates in this market
2. **`/deal-analysis/neighborhood-scoring`** — Score specific neighborhoods within the market
3. **`/lead-generation/daily-mls-feed`** — Start monitoring this market for deals
