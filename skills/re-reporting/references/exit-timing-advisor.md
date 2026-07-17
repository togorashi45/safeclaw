---
name: Exit Timing Advisor
description: "Analyze hold vs sell timing — market conditions, equity position, cash flow trajectory, tax implications, and opportunity cost. Triggers on: when to sell, exit timing, hold or sell, market timing."
---

# Exit Timing Advisor

## Overview
Analyze whether to hold or sell a property/note based on market conditions, equity position, cash flow trajectory, tax implications (1031 exchange timing), and opportunity cost. Quantifies the hold vs sell decision.

## When to Use
- Considering selling a rental property
- Flip is taking longer than expected — hold as rental or cut price?
- Market shifting — time to exit before downturn?
- 1031 exchange deadline approaching
- Evaluating portfolio rebalancing

## Inputs
- **Property/asset**: address, type, current value, purchase price, purchase date
- **Current financials**: cash flow, equity, mortgage balance
- **Market conditions**: appreciation trend, DOM trend, inventory
- **Tax situation**: capital gains exposure, 1031 eligibility, depreciation recapture
- **Alternative use of capital**: what would you do with the proceeds?

## Process

### Step 1: Current Position
```
Current Value:         $[X]
Purchase Price:        $[X]
Mortgage Balance:      $[X]
Equity:                $[X]
Monthly Cash Flow:     $[X]
Annual Cash-on-Cash:   [X]%
Cap Rate:              [X]%
Total Return to Date:  $[X] ([X]% annualized)
```

### Step 2: Hold Analysis (Next 1-3-5 Years)
```
Projected appreciation: [X]%/yr → Value in 3 yr: $[X]
Projected cash flow:    $[X]/yr × 3 = $[X]
Mortgage paydown:       $[X] over 3 years
Total hold return:      $[X] ([X]% annualized)
```

### Step 3: Sell Analysis
```
Sale Price (net):       $[X] (after closing costs, agent fees)
Capital Gains Tax:      $[X] (federal + state)
Depreciation Recapture: $[X] (25% rate)
Net Proceeds:           $[X]

If 1031 Exchange:
  Tax Deferred:         $[X]
  Net Proceeds:         $[X]
  Reinvestment required: $[X] (full exchange)
```

### Step 4: Opportunity Cost
```
Net proceeds if sold:      $[X]
Reinvested at [X]% yield:  $[X]/yr
Current property yield:    $[X]/yr
Opportunity cost of holding: $[X]/yr
```

### Step 5: Decision Matrix

| Factor | Hold | Sell | Weight |
|--------|------|------|--------|
| Cash flow trend | [improving/flat/declining] | Redeploy proceeds | 20% |
| Market direction | [appreciating/flat/declining] | Lock in gains | 20% |
| Tax efficiency | Defer gains, depreciation | 1031 available? | 20% |
| Equity trapped | [% of net worth in this asset] | Diversify | 15% |
| Maintenance burden | [increasing/stable] | Eliminate | 10% |
| Better opportunities | [available? at what yield?] | Higher returns? | 15% |

## Output Format
```
EXIT TIMING ANALYSIS — [Property]
═════════════════════════════════
Current Equity: $[X] | Cash Flow: $[X]/mo | CoC: [X]%

HOLD 3-YEAR PROJECTION:
  Total Return: $[X] | Annualized: [X]%

SELL NOW:
  Net Proceeds: $[X] (after tax) | 1031 Proceeds: $[X]

OPPORTUNITY COST: $[X]/yr by holding vs redeploying

RECOMMENDATION: [HOLD / SELL / SELL + 1031 / HOLD 12 MORE MONTHS]
REASONING: [Key factors]
```

## Example Prompts
- "Should I sell my rental? Bought at $140K, worth $210K, cash flows $300/mo, I've had it 4 years."
- "My flip has been sitting 60 days. Hold as rental or drop the price $10K?"
- "I have $180K equity in a property doing 6% CoC. Can I do better elsewhere?"

## Suggested Next Steps
1. **`/deal-analysis/cash-flow-projector`** — Detailed hold cash flow projection
2. **`/reporting/financial-qa`** — 1031 exchange rules and timing
3. **`/deal-analysis/cap-rate-comp`** — Compare yields on reinvestment targets
