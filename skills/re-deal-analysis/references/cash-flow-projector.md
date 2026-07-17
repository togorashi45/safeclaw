---
name: Cash Flow Projector
description: "Project monthly and annual cash flow for rental properties including vacancy, management, maintenance, taxes, insurance, and debt service. Triggers on: cash flow, project cash flow, rental cash flow, monthly cash flow, will this property cash flow."
---

# Cash Flow Projector

## Overview
Calculate whether a rental property will actually cash flow. Projects monthly and annual income after ALL expenses — not just the rosy numbers sellers show you.

## When to Use
- Evaluating a buy-and-hold acquisition
- BRRRR analysis (what's the cash flow after refi?)
- Comparing multiple rental properties
- Stress-testing a deal with different scenarios

## Inputs
- Property address and details
- Purchase price and financing terms (down payment, rate, term)
- Monthly rent (or use `/property-management/market-rent` to estimate)
- Property taxes (annual)
- Insurance (annual)
- HOA (if applicable)
- Estimated management fee (default: 10% of rent)
- Estimated maintenance (default: 10% of rent)
- Vacancy rate (default: 8%)
- CapEx reserve (default: 5% of rent)

## Process

### Step 1: Calculate Gross Income
```
Monthly Gross Rent: $[X]
Other Income (laundry, parking, etc.): $[X]
Gross Monthly Income: $[X]
```

### Step 2: Calculate Operating Expenses
```
Vacancy (8%): -$[X]
Property Management (10%): -$[X]
Maintenance (10%): -$[X]
CapEx Reserve (5%): -$[X]
Property Taxes: -$[X]/mo
Insurance: -$[X]/mo
HOA: -$[X]/mo
Total Operating Expenses: -$[X]
```

### Step 3: Calculate NOI and Cash Flow
```
NOI = Gross Income - Operating Expenses
Mortgage Payment (P&I): -$[X]
Monthly Cash Flow = NOI - Mortgage Payment
Annual Cash Flow = Monthly × 12
```

### Step 4: Investment Returns
```
Cash Invested: $[down payment + closing costs + rehab]
Cash-on-Cash Return: (Annual Cash Flow / Cash Invested) × 100
Cap Rate: (Annual NOI / Purchase Price) × 100
```

## Output Format
```
CASH FLOW PROJECTION — [Address]
════════════════════════════════
Purchase: $[X] | Down: $[X] ([X]%) | Rate: [X]% | Term: [X]yr

MONTHLY:
  Gross Rent:          $[X]
  - Vacancy (8%):      -$[X]
  - Management (10%):  -$[X]
  - Maintenance (10%): -$[X]
  - CapEx (5%):        -$[X]
  - Taxes:             -$[X]
  - Insurance:         -$[X]
  = NOI:               $[X]
  - Mortgage:          -$[X]
  = CASH FLOW:         $[X]/month ($[X]/year)

RETURNS:
  Cash Invested: $[X]
  Cash-on-Cash: [X]%
  Cap Rate: [X]%
  ROI Year 1: [X]%
```

## Example Prompts
- "Will this duplex cash flow? Purchase $180K, 20% down at 7.5%, rents $1,800/mo total, taxes $3,200/yr."
- "Run cash flow on 123 Main St — I'm buying at $120K, putting $30K rehab in, refinancing at 75% LTV. Rent should be $1,400."
- "Compare cash flow on these 3 properties and tell me which one wins."

## Suggested Next Steps
1. **`/property-management/market-rent`** — Verify rent assumptions
2. **`/deal-analysis/arv-calculator`** — Verify ARV for BRRRR refi
3. **`/creative-finance/lender-package`** — Prepare financing package
