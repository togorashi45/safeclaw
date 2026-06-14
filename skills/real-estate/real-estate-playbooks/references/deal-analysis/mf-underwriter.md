---
name: Multifamily Underwriter
description: "Underwrite multifamily apartment deals — NOI, cap rate, DSCR, cash-on-cash, price per unit, expense ratios, and value-add projections. Triggers on: multifamily, apartment underwrite, MF deal, unit analysis, apartment analysis."
---

# Multifamily Underwriter

## Overview
Full underwriting analysis for multifamily properties (2-200+ units). Calculates all key metrics investors and lenders need to evaluate the deal.

## When to Use
- Evaluating a multifamily acquisition
- Preparing a lender package
- Comparing multiple MF opportunities
- Value-add analysis (current vs pro-forma)

## Inputs
- Property address, unit count, unit mix
- Purchase price (or asking price)
- Current rent roll (per-unit rents)
- Current occupancy rate
- Operating expenses (taxes, insurance, utilities, management, maintenance, payroll)
- Financing terms (LTV, rate, term, amortization)
- Rehab/CapEx plans (if value-add)

## Process

### Step 1: Income Analysis
```
Gross Potential Rent (GPR): [all units at market rent × 12]
- Vacancy Loss ([X]%): -$[X]
+ Other Income (laundry, parking, fees): +$[X]
= Effective Gross Income (EGI): $[X]
```

### Step 2: Expense Analysis
```
Taxes: $[X]
Insurance: $[X]
Utilities: $[X]
Management ([X]%): $[X]
Maintenance/Repairs: $[X]
CapEx Reserve: $[X]
Payroll (if applicable): $[X]
Other: $[X]
Total Operating Expenses: $[X]
Expense Ratio: [X]% of EGI
```

### Step 3: Key Metrics
```
NOI = EGI - Operating Expenses
Cap Rate = NOI / Purchase Price
Price Per Unit = Purchase Price / Units
Price Per Sqft = Purchase Price / Total Sqft
DSCR = NOI / Annual Debt Service
Cash-on-Cash = Annual Cash Flow / Total Cash Invested
GRM = Purchase Price / Annual Gross Rent
```

### Step 4: Value-Add Pro Forma (if applicable)
Project metrics after renovations and rent increases.

## Output Format
```
MULTIFAMILY UNDERWRITE — [Address]
══════════════════════════════════
Units: [X] | Sqft: [X] | Year Built: [X] | Occupancy: [X]%
Price: $[X] | Per Unit: $[X] | Per Sqft: $[X]

INCOME:
  GPR: $[X] | Vacancy: [X]% | EGI: $[X]

EXPENSES:
  Total: $[X] | Expense Ratio: [X]%

KEY METRICS:
  NOI: $[X]
  Cap Rate: [X]%
  DSCR: [X]x
  Cash-on-Cash: [X]%
  GRM: [X]

VERDICT: [Strong Buy / Acceptable / Below Threshold / Pass]
```

## Example Prompts
- "Underwrite this 12-unit: asking $1.2M, gross rents $10,800/mo, expenses $4,500/mo, 95% occupied."
- "Analyze this apartment deal with a value-add play — rents are $200 below market per unit."

## Suggested Next Steps
1. **`/deal-analysis/value-add-opportunity`** — Detail the value-add plan
2. **`/creative-finance/lender-package`** — Package for lender
3. **`/deal-analysis/noi-analyzer`** — Deep dive on NOI components
