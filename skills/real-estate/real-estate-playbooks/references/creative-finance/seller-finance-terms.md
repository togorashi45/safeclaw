---
name: Seller Finance Term Calculator
description: "Structure seller finance offers — calculate payments at various rates/terms, balloon scenarios, amortization schedules, and compare to traditional financing. Triggers on: seller finance, owner finance, terms, seller carry, seller note."
---

# Seller Finance Term Calculator

## Overview
Structure seller-financed deal terms with full amortization calculations. Compare multiple rate/term scenarios side by side. Generate payment schedules including balloon payment calculations. Helps both sides understand the deal economics.

## When to Use
- Negotiating seller finance terms with a motivated seller
- Comparing seller finance vs bank financing
- Calculating balloon payment amounts at different timeframes
- Presenting multiple offer scenarios to seller

## Inputs
- **Purchase price**
- **Down payment amount or percentage**
- **Interest rate(s) to compare** (seller's desired rate, your target rate)
- **Amortization period** (15, 20, 25, 30 years)
- **Balloon term** (if any — 3, 5, 7, 10 years)
- **Monthly rent** (for cash flow analysis)

## Process

### Step 1: Scenario Builder
| Scenario | Price | Down | Financed | Rate | Am Period | Balloon | Payment |
|----------|-------|------|----------|------|-----------|---------|---------|
| A | $[X] | $[X] | $[X] | [X]% | [X] yr | [X] yr | $[X] |
| B | $[X] | $[X] | $[X] | [X]% | [X] yr | [X] yr | $[X] |
| C | $[X] | $[X] | $[X] | [X]% | [X] yr | [X] yr | $[X] |

### Step 2: Payment Calculation
```
Monthly P&I = P × [r(1+r)^n] / [(1+r)^n - 1]
Where: P = principal, r = monthly rate, n = total payments

Balloon Balance = P × [(1+r)^n - (1+r)^p] / [(1+r)^n - 1]
Where: p = payments made before balloon
```

### Step 3: Cash Flow Comparison
```
Monthly Rent:        $[X]
Monthly Payment:     $[X]
Taxes/Insurance:     $[X]
Net Cash Flow:       $[X]
Annual Cash Flow:    $[X]
Cash-on-Cash:        [X]%
```

### Step 4: Balloon Payment Planning
```
Balloon Due:         Month [X] / Year [X]
Remaining Balance:   $[X]
Exit Strategy:       Refinance / Sell / Renegotiate
```

## Output Format
```
SELLER FINANCE ANALYSIS — [Property Address]
════════════════════════════════════════════
Purchase: $[X] | Down: $[X] | Financed: $[X]

SCENARIO COMPARISON:
[Table of all scenarios]

RECOMMENDED TERMS: Scenario [X]
Monthly Payment: $[X]
Cash Flow: $[X]/mo
Cash-on-Cash: [X]%
Balloon: $[X] due [Date]
```

## Example Prompts
- "Calculate seller finance payments: $150K purchase, $15K down, 5% rate, 30-year am, 5-year balloon."
- "Compare 4% vs 5% vs 6% seller finance on a $200K deal with $20K down."
- "What's the balloon payment after 5 years on a $135K note at 4.5%, 30-year am?"

## Suggested Next Steps
1. **`/creative-finance/seller-finance-note-creator`** — Draft the promissory note
2. **`/creative-finance/dodd-frank-dti`** — Verify Dodd-Frank compliance
3. **`/creative-finance/seller-finance-clauses`** — Add protective clauses
