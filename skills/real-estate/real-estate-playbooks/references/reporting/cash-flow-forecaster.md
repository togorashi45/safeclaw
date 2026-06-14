---
name: Cash Flow Forecaster
description: "Forward-looking cash flow forecast — project income and expenses 3-12 months forward including known closings, rental income, and seasonal adjustments. Triggers on: forecast, cash flow forecast, multi-entity forecast, project forward."
---

# Cash Flow Forecaster

## Overview
Project your business cash flow 3-12 months forward. Incorporates known deal closings, recurring rental/note income, planned marketing spend, seasonal patterns, and pipeline probability. Answers: will I have enough cash, and when?

## When to Use
- Planning marketing spend for next quarter
- Evaluating whether to take on a new deal (capital available?)
- Forecasting distributions to investors/partners
- Cash reserve planning

## Inputs
- **Current cash position**
- **Known income**: scheduled closings, rental income, note payments
- **Pipeline deals**: with probability-weighted revenue
- **Known expenses**: recurring (rent, payroll, software) + planned (marketing, rehab)
- **Seasonal adjustments**: slower months, Q4 dip, etc.

## Process

### Step 1: Monthly Cash Flow Projection

| | Month 1 | Month 2 | Month 3 | Month 4 | Month 5 | Month 6 |
|---|---------|---------|---------|---------|---------|---------|
| **INCOME** | | | | | | |
| Scheduled closings | $[X] | $[X] | $[X] | — | — | — |
| Pipeline (prob-weighted) | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| Rental income | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| Note payments | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| Other income | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| **Total Income** | **$[X]** | **$[X]** | **$[X]** | **$[X]** | **$[X]** | **$[X]** |
| | | | | | | |
| **EXPENSES** | | | | | | |
| Marketing | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| Payroll/VAs | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| Overhead | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| Debt service | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| Rehab costs | $[X] | $[X] | — | — | — | — |
| Acquisitions | — | $[X] | — | $[X] | — | — |
| **Total Expenses** | **$[X]** | **$[X]** | **$[X]** | **$[X]** | **$[X]** | **$[X]** |
| | | | | | | |
| **Net Cash Flow** | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |
| **Running Balance** | $[X] | $[X] | $[X] | $[X] | $[X] | $[X] |

### Step 2: Scenario Analysis
- **Best case**: all pipeline deals close + new deals
- **Expected**: probability-weighted pipeline
- **Worst case**: only confirmed closings, no new deals

### Step 3: Cash Crunch Detection
Flag any month where running balance drops below minimum reserve (recommend 2-3 months of operating expenses).

## Output Format
```
CASH FLOW FORECAST — Next [X] Months
═════════════════════════════════════
Starting Cash: $[X]
Min Reserve Target: $[X]

[Monthly projection table]

CASH CRUNCH RISK: [None / Month X at risk]
6-MONTH NET POSITION: $[X]

SCENARIOS:
  Best case:  +$[X]
  Expected:   +$[X]
  Worst case: +$[X]
```

## Example Prompts
- "Forecast my cash flow for the next 6 months — I have $45K cash, $8K/mo rental income, $6K/mo expenses, 2 deals in pipeline."
- "Can I afford a $25K marketing push next month? Show me the cash impact."
- "When will I run out of cash if no new deals close?"

## Suggested Next Steps
1. **`/reporting/monthly-pnl`** — Historical data to inform projections
2. **`/dispositions/weekly-pipeline`** — Pipeline deals for revenue projections
3. **`/reporting/goal-tracker`** — Align forecast with business goals
