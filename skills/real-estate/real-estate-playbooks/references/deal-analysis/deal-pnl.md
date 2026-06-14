---
name: Deal P&L Calculator
description: "Calculate complete profit and loss for any real estate deal — wholesale, flip, or rental. Includes all costs, fees, holding costs, and net profit. Triggers on: deal P&L, deal profit, what did I make, deal financials, deal numbers."
---

# Deal P&L Calculator

## Overview
Calculate the true profit on any deal by accounting for ALL costs — not just purchase minus sale. Covers wholesale assignments, flips, and rental acquisitions.

## When to Use
- Before making an offer (projected P&L)
- After closing (actual P&L)
- Comparing profitability across deal types
- Monthly/quarterly deal profitability review

## Inputs
- Deal type (wholesale, flip, BRRRR, buy-and-hold)
- Purchase price
- Sale price or assignment fee
- Rehab costs (if applicable)
- Holding costs (months held, monthly carrying cost)
- Closing costs (buy side and sell side)
- Financing costs (points, interest)
- Marketing/acquisition cost allocated to this deal

## Process

### Step 1: Calculate by Deal Type

**Wholesale:**
```
Assignment Fee: $[X]
- Marketing cost per deal: -$[X]
- Earnest money at risk: $[X] (recovered at close)
- Transaction costs: -$[X]
= Net Profit: $[X]
```

**Flip:**
```
Sale Price: $[X]
- Purchase Price: -$[X]
- Rehab Costs: -$[X]
- Holding Costs ([X] months): -$[X]
- Buy Closing Costs: -$[X]
- Sell Closing Costs (agent, title, etc.): -$[X]
- Financing Costs (points + interest): -$[X]
- Marketing/Acquisition Cost: -$[X]
= Net Profit: $[X]
  Profit Margin: [X]%
  ROI: [X]%
  Annualized ROI: [X]%
```

### Step 2: Calculate Returns
- Profit Margin: Net Profit / Sale Price × 100
- ROI: Net Profit / Total Cash Invested × 100
- Annualized ROI: ROI / (Months Held / 12)

## Output Format
```
DEAL P&L — [Address]
═══════════════════
Type: [Wholesale/Flip/BRRRR]

REVENUE:
  [Sale Price or Assignment Fee]: $[X]

COSTS:
  Purchase:        $[X]
  Rehab:           $[X]
  Holding ([X]mo): $[X]
  Closing (buy):   $[X]
  Closing (sell):  $[X]
  Financing:       $[X]
  Marketing:       $[X]
  ─────────────────────
  TOTAL COSTS:     $[X]

NET PROFIT: $[X]
Margin: [X]% | ROI: [X]% | Annualized: [X]%
```

## Example Prompts
- "Calculate P&L: bought at $95K, rehab $35K, sold at $185K, held 4 months, closing costs $12K total."
- "What's my profit on this wholesale deal? Assignment fee $18K, I spent $800 in marketing to get it."
- "Compare profitability of these 3 deals I closed this quarter."

## Suggested Next Steps
1. **`/reporting/monthly-pnl`** — Roll into monthly financials
2. **`/reporting/kpi-tracker`** — Update deal volume and profitability KPIs
3. **`/marketing/deal-case-study`** — Turn profitable deals into marketing content
