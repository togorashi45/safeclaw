---
name: Note Portfolio Tracker
description: "Track portfolio of owned notes — payment log, UPB tracking, yield calculation, performance dashboard, event timeline, and watch list. Triggers on: note portfolio, track notes, note dashboard, all notes."
---

# Note Portfolio Tracker

## Overview
Full note portfolio management dashboard. Tracks every note you own with payment logs, current UPB, yield calculations, performance status, and key event timelines. Flags notes needing attention and provides portfolio-level performance metrics.

## When to Use
- Monthly portfolio review
- Tracking payment receipts and UPB balances
- Identifying notes that need workout attention
- Preparing portfolio reports for investors/partners
- Evaluating portfolio performance and yield

## Inputs
- **All owned notes** (from mind/active-portfolio.md Notes Owned section)
- **Monthly payment data** from servicer reports
- **Property value updates** (annual BPOs)
- **Any note events** (modifications, defaults, payoffs, sales)

## Process

### Step 1: Individual Note Tracking

| Field | Data |
|-------|------|
| Note ID / Property | [Address] |
| Borrower | [Name] |
| Original Balance | $[X] |
| Current UPB | $[X] |
| Your Basis (purchase price) | $[X] |
| Interest Rate | [X]% |
| Monthly Payment | $[X] |
| Origination Date | [Date] |
| Maturity / Balloon Date | [Date] |
| Lien Position | 1st / 2nd |
| Servicer | [Name] |
| Status | Performing / Sub / NPL / Re-Performing |
| Last Payment Received | [Date] |
| Payments Received (total) | $[X] |
| Remaining Payments | [X] months |
| Current LTV | [X]% |
| Yield at Basis | [X]% |

### Step 2: Payment Log (Monthly)
| Month | Expected | Received | Variance | Running UPB | Status |
|-------|----------|----------|----------|-------------|--------|
| [Mo] | $[X] | $[X] | $[X] | $[X] | On-time/Late/Missed |

### Step 3: Portfolio Dashboard
```
PORTFOLIO SUMMARY:
  Total Notes:              [X]
  Total UPB:                $[X]
  Total Basis (invested):   $[X]
  Portfolio LTV:            [X]%
  
PERFORMANCE:
  Performing:               [X] notes ($[X] UPB)
  Sub-Performing:           [X] notes ($[X] UPB)
  Non-Performing:           [X] notes ($[X] UPB)
  Re-Performing:            [X] notes ($[X] UPB)
  
INCOME:
  Monthly Expected:         $[X]
  Monthly Collected:        $[X]
  Collection Rate:          [X]%
  Annual Cash Flow:         $[X]
  Weighted Avg Yield:       [X]%
  
EVENTS:
  Balloons due (12 mo):    [X] notes — $[X] UPB
  Notes maturing (12 mo):  [X] notes
  Modifications active:     [X]
  Foreclosures in process:  [X]
```

### Step 4: Watch List
| Note | Issue | Action Needed | Deadline |
|------|-------|---------------|----------|
| [Property] | [Payment missed / Balloon approaching / etc.] | [Action] | [Date] |

### Step 5: Event Timeline
| Date | Note | Event | Impact |
|------|------|-------|--------|
| [Date] | [Property] | [Payment / Modification / Payoff / Default / Sale] | [Detail] |

## Output Format
```
NOTE PORTFOLIO DASHBOARD — [Date]
══════════════════════════════════
Notes: [X] | UPB: $[X] | Basis: $[X]
Performing: [X]% | Collection Rate: [X]%
Monthly Income: $[X] | Wtd Avg Yield: [X]%

[Individual note table]

WATCH LIST: [X] items needing attention
[Watch list table]

RECENT EVENTS:
[Last 30 days of note events]
```

## Example Prompts
- "Show me my note portfolio dashboard — how are all my notes performing?"
- "Which notes are on the watch list? Any payments missed this month?"
- "What's my weighted average yield across the portfolio?"
- "Log a payment received on the 123 Main St note — $510 received April 5."

## Suggested Next Steps
1. **`/creative-finance/note-workout-strategy`** — Workout plan for any NPLs on watch list
2. **`/creative-finance/note-yield-calculator`** — Recalculate yields with updated data
3. **`/creative-finance/note-sale-readiness`** — Prepare any notes for sale
