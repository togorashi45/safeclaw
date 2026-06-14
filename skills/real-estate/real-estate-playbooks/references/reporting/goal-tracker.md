---
name: Goal Tracker
description: "Track business goals vs actuals — revenue targets, deal counts, marketing spend, and portfolio growth with progress tracking. Triggers on: goals, targets, progress, revenue goal, deal goal."
---

# Goal Tracker

## Overview
Track business goals against actual performance. Covers revenue, deal count, marketing, portfolio growth, and custom goals. Shows progress percentage, run rate, and whether you're on pace to hit each target. Updates mind/weekly-goals.md.

## When to Use
- Weekly check-in on goal progress
- Monthly goal review and adjustment
- Setting new quarterly or annual goals
- Identifying which goals need more focus

## Inputs
- **Goals**: what you're targeting (from mind/weekly-goals.md or stated)
- **Actuals**: current performance data
- **Time period**: weekly, monthly, quarterly, annual

## Process

### Step 1: Goal Dashboard

| Goal | Target | Actual | % Complete | On Pace? | Gap |
|------|--------|--------|-----------|----------|-----|
| Revenue | $[X] | $[X] | [X]% | Yes/No | $[X] |
| Deals Closed | [X] | [X] | [X]% | Yes/No | [X] |
| Leads Generated | [X] | [X] | [X]% | Yes/No | [X] |
| Marketing Spend | $[X] | $[X] | [X]% | Over/Under | $[X] |
| Properties Acquired | [X] | [X] | [X]% | Yes/No | [X] |
| Portfolio Cash Flow | $[X]/mo | $[X]/mo | [X]% | Yes/No | $[X] |
| Avg Deal Profit | $[X] | $[X] | [X]% | Yes/No | $[X] |

### Step 2: Run Rate Analysis
```
Period: [Month X of Y]
Time Elapsed: [X]%

Revenue Run Rate:  $[actual] ÷ [months elapsed] × 12 = $[projected annual]
Deal Run Rate:     [actual] ÷ [months elapsed] × 12 = [projected annual]
Required Run Rate: $[remaining target] ÷ [months remaining] = $[X]/month needed
```

### Step 3: Goal Adjustment Recommendations
- Goals >110% complete: raise the bar
- Goals 80-110%: on track, maintain
- Goals 50-80%: needs attention, identify blockers
- Goals <50%: at risk, needs intervention or goal reset

## Output Format
```
GOAL TRACKER — [Period]
═══════════════════════
[Goal dashboard table]

ON TRACK: [X] of [X] goals
AT RISK: [X] goals

RUN RATE: $[X]/mo actual vs $[X]/mo needed

TOP PRIORITY: [Goal most at risk + recommended action]
```

## Example Prompts
- "Track my Q2 goals: $100K revenue, 8 deals, 200 leads, $5K marketing budget."
- "Am I on pace? I'm 2 months into the quarter with $38K revenue against a $100K target."
- "Update my weekly goals — closed a deal this week for $14K."

## Suggested Next Steps
1. **`/reporting/kpi-tracker`** — Detailed KPIs driving goal performance
2. **`/operations/weekly-review`** — Weekly review against goals
3. **`/reporting/monthly-pnl`** — Financial context for revenue goals
