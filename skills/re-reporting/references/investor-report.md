---
name: Investor Report Generator
description: "Generate LP/investor update reports — capital deployed, returns, deal pipeline, distributions, and portfolio performance. Triggers on: investor update, investor report, LP report, capital update."
---

# Investor Report Generator

## Overview
Generate professional quarterly or monthly investor update reports for limited partners and capital partners. Covers capital deployment, returns, pipeline, distributions, and portfolio performance. Formatted for credibility and transparency.

## When to Use
- Quarterly LP updates (most common cadence)
- Monthly updates for active investors
- Capital call communications
- Distribution notifications
- Year-end summary reports

## Inputs
- **Reporting period**
- **Fund/entity name**
- **Capital committed and deployed**
- **Deals closed and in pipeline**
- **Returns generated** (realized and unrealized)
- **Distributions made**
- **Market conditions** and outlook

## Process

### Step 1: Executive Summary
2-3 paragraph overview of the period: what happened, key wins, market conditions, outlook.

### Step 2: Capital Account Summary
```
CAPITAL ACCOUNT — [Entity/Fund Name]
════════════════════════════════════
Total Committed:        $[X]
Capital Called:          $[X] ([X]% of committed)
Capital Deployed:       $[X] ([X]% of called)
Distributions to Date:  $[X]
Unrealized Value:       $[X]
Total Value (D + UV):   $[X]
Multiple on Invested:   [X]x
IRR (annualized):       [X]%
```

### Step 3: Deal Activity
| Deal | Type | Status | Invested | Current Value | Return |
|------|------|--------|----------|---------------|--------|
| [Address] | [Wholesale/Flip/Note] | [Active/Exited] | $[X] | $[X] | [X]% |

### Step 4: Portfolio Performance
```
PERIOD PERFORMANCE:
  Revenue This Period:      $[X]
  Expenses This Period:     $[X]
  Net Income:               $[X]
  Cash-on-Cash (annualized): [X]%

CUMULATIVE:
  Total Revenue:            $[X]
  Total Distributions:      $[X]
  Unrealized Gains:         $[X]
  Total Return:             [X]%
```

### Step 5: Pipeline and Outlook
- Deals in pipeline: [X] ($[X] projected revenue)
- Market outlook: [brief assessment]
- Next distribution: [date and estimated amount]
- Upcoming capital calls: [if any]

## Output Format
```
INVESTOR UPDATE — [Period]
[Entity/Fund Name]
══════════════════════════

[Executive Summary]

[Capital Account]
[Deal Activity Table]
[Performance Metrics]
[Pipeline & Outlook]

Prepared by: [Your Name]
Date: [Date]
```

## Example Prompts
- "Generate a Q1 investor report — we deployed $180K across 3 deals, returned $42K in distributions, 2 deals still active."
- "Create a monthly LP update — closed 2 wholesale deals this month for $24K profit, 1 flip in progress."
- "Write the executive summary for our year-end investor letter."

## Suggested Next Steps
1. **`/reporting/monthly-pnl`** — Detailed financials backing the report
2. **`/reporting/cash-flow-forecaster`** — Projected returns for next period
3. **`/dispositions/weekly-pipeline`** — Pipeline detail for the report
