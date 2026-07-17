---
name: Monthly P&L Statement
description: "Generate monthly profit and loss statements — revenue from all sources vs expenses, with month-over-month comparison. Triggers on: P&L, profit loss, monthly financials, revenue, expenses."
---

# Monthly P&L Statement

## Overview
Generate a complete monthly P&L for your RE investment business. Breaks down revenue by source (wholesale, flips, rentals, notes, other) and expenses by category. Includes month-over-month comparison and margin analysis.

## When to Use
- End of month financial review
- Preparing for CPA or bookkeeper meeting
- Investor reporting
- Tracking profitability trends

## Inputs
- **Month/period** to report on
- **Revenue data**: closed deals, rental income, note payments, other income
- **Expense data**: marketing, skip tracing, overhead, payroll, software, etc.
- **Previous month** (for comparison)

## Process

### Step 1: Revenue Breakdown
```
REVENUE                           This Month    Last Month    Change
══════════════════════════════════════════════════════════════════════
Wholesale Assignment Fees         $[X]          $[X]          [+/-X]%
Flip Profits (closed this month)  $[X]          $[X]          [+/-X]%
Rental Income (gross)             $[X]          $[X]          [+/-X]%
Note Payments Received            $[X]          $[X]          [+/-X]%
Wrap Spread Income                $[X]          $[X]          [+/-X]%
Consulting / Other Income         $[X]          $[X]          [+/-X]%
──────────────────────────────────────────────────────────────────────
TOTAL REVENUE                     $[X]          $[X]          [+/-X]%
```

### Step 2: Cost of Revenue (Direct Deal Costs)
```
COST OF REVENUE                   This Month    Last Month
══════════════════════════════════════════════════════════════════════
Earnest Money Forfeited           $[X]          $[X]
Closing Costs (buy side)          $[X]          $[X]
Closing Costs (sell side)         $[X]          $[X]
Rehab / Construction Costs        $[X]          $[X]
Holding Costs (mortgage, tax, ins)$[X]          $[X]
Transactional Funding Fees        $[X]          $[X]
Commissions Paid                  $[X]          $[X]
──────────────────────────────────────────────────────────────────────
TOTAL COST OF REVENUE             $[X]          $[X]
═══════════════════════════════════════════════════════════════
GROSS PROFIT                      $[X]          $[X]
GROSS MARGIN                      [X]%          [X]%
```

### Step 3: Operating Expenses
```
OPERATING EXPENSES                This Month    Last Month
══════════════════════════════════════════════════════════════════════
MARKETING:
  PPC / Google Ads                $[X]          $[X]
  Facebook Ads                    $[X]          $[X]
  Direct Mail                     $[X]          $[X]
  Cold Calling / Dialer           $[X]          $[X]
  Skip Tracing                    $[X]          $[X]
  SEO / Content                   $[X]          $[X]
  Marketing Subtotal              $[X]          $[X]

PAYROLL & CONTRACTORS:
  Acquisitions Team               $[X]          $[X]
  VAs / Admin                     $[X]          $[X]
  Dispositions                    $[X]          $[X]
  Payroll Subtotal                $[X]          $[X]

OVERHEAD:
  Software (CRM, tools, etc.)     $[X]          $[X]
  Office / Coworking              $[X]          $[X]
  Phone / Communications          $[X]          $[X]
  Insurance (business)            $[X]          $[X]
  Legal / Accounting              $[X]          $[X]
  Education / Training            $[X]          $[X]
  Travel / Mileage                $[X]          $[X]
  Overhead Subtotal               $[X]          $[X]

PROPERTY MANAGEMENT:
  Property Mgmt Fees              $[X]          $[X]
  Repairs & Maintenance           $[X]          $[X]
  Vacancy Costs                   $[X]          $[X]
  PM Subtotal                     $[X]          $[X]
──────────────────────────────────────────────────────────────────────
TOTAL OPERATING EXPENSES          $[X]          $[X]
```

### Step 4: Bottom Line
```
═══════════════════════════════════════════════════════════════
NET OPERATING INCOME              $[X]          $[X]

Debt Service (loans, LOC)         ($[X])        ($[X])
Owner Distributions               ($[X])        ($[X])
──────────────────────────────────────────────────────────────
NET PROFIT / (LOSS)               $[X]          $[X]
NET MARGIN                        [X]%          [X]%
═══════════════════════════════════════════════════════════════
```

### Step 5: Key Ratios
```
Marketing Spend as % of Revenue:  [X]%
Payroll as % of Revenue:          [X]%
Cost per Deal:                    $[X]
Revenue per Deal:                 $[X]
Deals Closed This Month:          [X]
```

## Output Format
```
MONTHLY P&L — [Month Year]
══════════════════════════
[Full P&L as structured above]

HIGHLIGHTS:
- [Top revenue driver]
- [Largest expense change]
- [Margin trend]

FLAGS:
⚠️ [Any concerning trends]
```

## Example Prompts
- "Generate my March P&L — closed 3 wholesale deals, rental income from 5 units, spent $4K on marketing."
- "Compare this month's P&L to last month — where am I spending more?"
- "What's my cost per deal and net margin this month?"

## Suggested Next Steps
1. **`/reporting/kpi-tracker`** — Review KPIs alongside financials
2. **`/reporting/cash-flow-forecaster`** — Project next 3 months based on trends
3. **`/reporting/tax-prep`** — Categorize expenses for tax deductions
