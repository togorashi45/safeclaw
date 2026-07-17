---
name: Portfolio Dashboard
description: "Generate portfolio overview — all properties, occupancy rates, rent roll, maintenance status, lease expirations, cash flow summary, and equity position. Triggers on: portfolio, all properties, property overview, portfolio summary."
---

# Portfolio Dashboard

## Overview
Generate a comprehensive dashboard view of your entire property portfolio. Aggregates occupancy, rent roll, cash flow, maintenance status, lease expirations, and equity positions across all properties. Your 30,000-foot view of the rental business.

## When to Use
- Monthly portfolio review
- Preparing investor reports
- Identifying underperforming properties
- Planning acquisitions or dispositions
- Bank/lender meetings

## Inputs
- **Portfolio data** from mind/active-portfolio.md
- **Specific focus area** (if any) — cash flow, occupancy, maintenance, equity

## Process

### Step 1: Occupancy Summary
```
Total Units:        [X]
Occupied:           [X] ([X]%)
Vacant:             [X] ([X]%)
Notice Given:       [X] (moving out within 60 days)
Under Renovation:   [X]
```

### Step 2: Rent Roll
| Property | Unit | Tenant | Rent | Paid Thru | Lease Exp | Status |
|----------|------|--------|------|-----------|-----------|--------|
| | | | | | | Current/Late/Vacant |

```
Total Monthly Rent:     $[X]
Collection Rate (MTD):  [X]%
Delinquent Amount:      $[X]
```

### Step 3: Cash Flow Summary
| Property | Rent | Mortgage | Taxes | Ins | Mgmt | Maint | Net CF |
|----------|------|---------|-------|-----|------|-------|--------|
| | | | | | | | |

```
Total Monthly Income:    $[X]
Total Monthly Expenses:  $[X]
Net Monthly Cash Flow:   $[X]
Annual Cash Flow:        $[X]
Portfolio Cash-on-Cash:  [X]%
```

### Step 4: Maintenance Status
| Property | Open WOs | Priority | Oldest Open | Est Cost |
|----------|----------|----------|-------------|----------|
| | | | | |

### Step 5: Lease Expiration Calendar
| Month | Property | Unit | Tenant | Current Rent | Market Rent | Action |
|-------|----------|------|--------|-------------|-------------|--------|
| | | | | | | Renew/Increase/Turn |

### Step 6: Equity Position
| Property | FMV | Mortgage | Equity | LTV | Appreciation |
|----------|-----|---------|--------|-----|-------------|
| | | | | | |

```
Total Portfolio Value:   $[X]
Total Debt:              $[X]
Total Equity:            $[X]
Weighted Avg LTV:        [X]%
```

## Output Format
```
PORTFOLIO DASHBOARD — [Date]
═══════════════════════════
Properties: [X] | Units: [X] | Occupancy: [X]%

[Each section above formatted with current data]

KEY ACTIONS NEEDED:
1. [Most urgent item]
2. [Second priority]
3. [Third priority]

PERFORMANCE vs LAST MONTH:
  Cash Flow: $[X] → $[X] ([+/-X]%)
  Occupancy: [X]% → [X]%
  Collections: [X]% → [X]%
```

## Example Prompts
- "Show me my portfolio dashboard — how are all my properties doing?"
- "What's my total monthly cash flow across the portfolio?"
- "Which leases expire in the next 90 days?"
- "What's my total equity position?"

## Suggested Next Steps
1. **`/reporting/monthly-pnl`** — Detailed P&L for the business
2. **`/property-management/lease-renewal`** — Address upcoming expirations
3. **`/deal-analysis/value-add-opportunity`** — Find forced appreciation opportunities
