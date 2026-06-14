---
name: ARV Calculator
description: "Calculate After Repair Value using comparable sales with adjustment methodology, confidence scoring, and MAO calculation. Triggers on: ARV, after repair value, what's it worth, value after rehab, property value."
---

# ARV Calculator

## Overview
Calculate the After Repair Value of any property using comparable sales analysis. Applies adjustments for differences in size, condition, features, and location. Outputs ARV range with confidence score and Maximum Allowable Offer.

## When to Use
- Evaluating a potential acquisition
- Preparing an offer
- Verifying a wholesaler's ARV claim
- Updating ARV on deals under contract (market shift check)

## Inputs
- Subject property address
- Beds, baths, sqft, year built, lot size
- Target condition after rehab (A/B/C)
- Comp radius preference (default 0.5 mile)
- Lookback period (default 6 months)

## Process

### Step 1: Pull Comparable Sales
Search for sold properties within criteria:
- Distance: 0.5 mile (expand to 1 mile if needed)
- Timeframe: 6 months (expand to 12 if needed)
- Size: Within 20% of subject sqft
- Type: Same property type (SFR, townhome, etc.)
- Beds: Within +/- 1

### Step 2: Apply Adjustments
| Factor | Adjustment Per Unit |
|--------|-------------------|
| Square footage | $50-100/sqft beyond 10% difference |
| Bedrooms | $5,000-10,000 per bedroom |
| Bathrooms | $5,000-7,500 per bathroom |
| Garage | $10,000-20,000 presence/absence |
| Year built | $2,000-5,000 per decade |
| Condition | A: +10%, B: +5%, C: baseline, D: -10% |
| Pool | $5,000-15,000 |
| Lot size | $5,000-15,000 per acre (rural) |

### Step 3: Calculate ARV Range
```
Conservative ARV: Average of lowest 2-3 adjusted comps
Mid ARV: Weighted average of all adjusted comps
Aggressive ARV: Average of highest 2-3 adjusted comps
Recommended ARV: Mid value, rounded to nearest $5,000
```

### Step 4: Confidence Score
- HIGH: 5+ strong comps, minimal adjustments
- MEDIUM: 3-4 comps, moderate adjustments
- LOW: <3 comps or large adjustments needed

### Step 5: Calculate MAO
```
MAO (70% Rule) = ARV × 0.70 - Estimated Rehab
MAO (Conservative) = ARV × 0.65 - Estimated Rehab
```

## Output Format
```
ARV ANALYSIS — [Subject Address]
════════════════════════════════
Subject: [Beds/Baths] | [Sqft] | Built [Year] | Target: [Condition]

COMPS:
| # | Address | Sold $ | $/sqft | Beds/Ba | Sqft | Adj $ | Distance |
|---|---------|--------|--------|---------|------|-------|----------|

ARV RANGE:
Conservative: $[X] | Mid: $[X] | Aggressive: $[X]
Recommended ARV: $[X]
Confidence: [HIGH/MEDIUM/LOW]

MAO (at 70% rule, $[rehab] rehab): $[X]
```

## Example Prompts
- "Calculate ARV for 123 Main St Denver — 3/2, 1,450 sqft, built 1965, will be C+ condition after rehab."
- "What's the ARV on this flip? 4/2.5 in 75217 Dallas, 2,100 sqft, full renovation to A condition."
- "Re-check ARV on my deal at 456 Oak — original ARV was $185K from January."

## Suggested Next Steps
1. **`/deal-analysis/comp-pull`** — Get the detailed comp grid
2. **`/deal-analysis/deal-pnl`** — Calculate full deal P&L with this ARV
3. **`/deal-analysis/cash-flow-projector`** — If holding as rental, project cash flow
