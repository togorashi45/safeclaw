---
name: Weekly Pipeline Report
description: "Generate weekly pipeline report — active deals by stage, stalled deals, deals needing action, projected closings, and revenue forecast. Triggers on: pipeline review, weekly pipeline, deal status, what's active, pipeline report."
---

# Weekly Pipeline Report

## Overview
Weekly snapshot of your entire deal pipeline. Shows where every deal stands, what's stalled, and what revenue is projected to close.

## When to Use
- Weekly team meeting or solo review
- End-of-week assessment
- Investor/partner update
- Identifying bottlenecks in deal flow

## Inputs
- Current deal list with stages (from mind/active-deals.md)
- Or: provide deal updates verbally

## Process

### Step 1: Categorize All Deals by Stage
Group into: New Leads, Contacted, Qualified, Offer Made, Under Contract, Closing This Week, Closed (this period).

### Step 2: Flag Issues
- Stalled deals (sitting in one stage too long)
- Deals needing immediate action
- Contracts expiring soon
- Buyer/seller gone quiet

### Step 3: Revenue Projection
For deals under contract or near closing, project revenue and timing.

## Output Format
```
WEEKLY PIPELINE — Week of [Date]
════════════════════════════════
Active Deals: [X] | Under Contract: [X] | Projected Revenue: $[X]

BY STAGE:
| Stage | Count | Total Value | Key Deals |
|-------|-------|-------------|-----------|

NEEDS ACTION NOW:
1. [Deal] — [Issue] — [Required action]

CLOSING THIS WEEK/NEXT:
1. [Deal] — [Close date] — [Expected revenue]

STALLED:
1. [Deal] — [Days in stage] — [Recommendation]

PIPELINE HEALTH: [Strong / Needs Attention / Weak]
```

## Example Prompts
- "Run my weekly pipeline review. Here's what's active: [list deals]."
- "What deals need attention this week?"
- "How much revenue am I projecting to close this month?"

## Suggested Next Steps
1. **`/reporting/kpi-tracker`** — Update KPIs with pipeline data
2. **`/lead-generation/lead-orchestrator`** — Route stalled leads to action
3. **`/reporting/monthly-pnl`** — Roll closed deals into monthly financials
