---
name: Note Tape Screener
description: "Screen and filter note tapes for acquisition targets — filter by UPB, ITV, state, performance status, interest rate, and remaining term. Score notes and flag red flags. Triggers on: screen tape, filter notes, tape analysis, note tape review."
---

# Note Tape Screener

## Overview
Filter large note tapes down to actionable acquisition targets. Apply your buy-box criteria across UPB, ITV, state, lien position, performance status, and property type. Score each note, flag red flags, and suggest bid prices. Turns a 500-line tape into a shortlist of 10-20 targets.

## When to Use
- Received a note tape from a seller, broker, or exchange
- Screening a large portfolio for cherry-picking
- Building a bid list from a tape
- Comparing tapes from multiple sellers

## Inputs
- **Note tape** (data from CSV/Excel — key columns below)
- **Your buy-box criteria** (or use defaults)
- **Target yield** for bid pricing
- **States you operate in** (foreclosure timeline matters)

## Process

### Step 1: Required Tape Columns
| Column | Description | Filter? |
|--------|-------------|---------|
| Property Address | Location | By state/zip |
| Property Type | SFR, MF, Condo, Land | By type |
| UPB | Unpaid principal balance | Min/Max range |
| Interest Rate | Note rate | Min/Max |
| Monthly Payment (P&I) | Contractual payment | |
| Origination Date | When note was created | |
| Maturity Date | When note matures | |
| Last Payment Date | Last payment received | Performance |
| Lien Position | 1st or 2nd | Usually 1st only |
| BPO/Value | Estimated property value | For ITV calc |
| Asking Price | Seller's ask per note | For yield calc |
| Occupancy | Owner/Tenant/Vacant | |
| Note Status | Performing/Sub/NPL | |

### Step 2: Apply Buy-Box Filters

| Criteria | Default | Your Criteria |
|----------|---------|---------------|
| Lien Position | 1st only | |
| UPB Range | $30K-250K | |
| Max ITV | 80% | |
| Max LTV | 90% | |
| States | Non-judicial preferred | |
| Property Type | SFR, 2-4 unit | |
| Note Status | All (but price differently) | |
| Min Rate | 4% | |
| Occupancy | Owner-occupied preferred | |

### Step 3: Score Surviving Notes (1-10)

| Factor | Weight | Scoring |
|--------|--------|---------|
| ITV | 25% | <50%=10, 50-65%=8, 65-75%=6, 75-85%=4, >85%=2 |
| LTV | 15% | <60%=10, 60-75%=8, 75-85%=6, >85%=4 |
| Payment History | 20% | Current=10, 30-day=7, 60-day=5, 90+=3, NPL=score by equity |
| State (FC timeline) | 15% | <6mo=10, 6-12mo=7, 12-18mo=5, >18mo=3 |
| Property Type | 10% | SFR=10, 2-4 unit=9, Condo=6, Land=4 |
| Occupancy | 15% | Owner=10, Tenant=7, Vacant=5 |

### Step 4: Red Flag Detection
- **CRITICAL**: LTV >100% (underwater), broken chain of title, judicial state + NPL + high UPB
- **WARNING**: 2nd lien, BPO >12 months old, unknown occupancy, land/lot notes
- **INFO**: Balloon approaching, rate below market, maturity within 2 years

### Step 5: Bid Pricing
```
For each target note:
  Target Yield:     [X]%
  Monthly Payment:  $[X]
  Remaining Months: [X]
  Suggested Bid:    $[X] (to achieve target yield)
  Bid as % of UPB:  [X]%
```

## Output Format
```
TAPE SCREENING RESULTS
══════════════════════
Tape: [Seller/Source]
Total Notes on Tape: [X]
After Filters: [X]
Scored & Ranked: [X]

TOP TARGETS:
| Rank | Address | UPB | Value | ITV | Status | Score | Bid |
|------|---------|-----|-------|-----|--------|-------|-----|

RED FLAGS:
[Notes with critical issues]

TAPE SUMMARY:
  Total UPB (filtered): $[X]
  Total Suggested Bids: $[X]
  Weighted Avg ITV:     [X]%
  Avg Target Yield:     [X]%
```

## Example Prompts
- "Screen this tape — 200 notes, I only want 1st lien SFR in non-judicial states, UPB $50-150K, ITV under 70%."
- "Filter for performing notes only, rate above 5%, owner-occupied, in TX/AZ/CO."
- "Score and rank the top 20 from this tape based on ITV and payment history."

## Suggested Next Steps
1. **`/creative-finance/note-due-diligence`** — Run DD on top targets
2. **`/creative-finance/note-investing-analyzer`** — Deep analysis on shortlisted notes
3. **`/creative-finance/note-yield-calculator`** — Calculate exact yields for bid pricing
