---
name: Note Due Diligence Coordinator
description: "Due diligence checklist for note purchases — 5-category DD across legal, collateral, borrower, payment history, and title. 15+ tracked items. Triggers on: note DD, note due diligence, note audit, verify note."
---

# Note Due Diligence Coordinator

## Overview
Run a structured 15+ item due diligence process before buying any note. Covers five categories: legal documents, collateral (property), borrower profile, payment history, and title/lien position. Each item is scored and tracked to a pass/fail/flag status. No note purchase should close without completing this checklist.

## When to Use
- Evaluating a note for purchase (performing or non-performing)
- Verifying seller representations on a note tape
- Re-underwriting a note after initial screening
- Auditing your existing note portfolio

## Inputs
- **Note details**: UPB, rate, payment, origination date, maturity, lien position
- **Loan documents** available: note, deed of trust/mortgage, allonges, assignments
- **Property**: address, type, estimated value, occupancy status
- **Borrower**: name, payment history, contact info
- **Servicer**: current servicer, transfer status
- **Seller**: who's selling the note, what reps/warranties they're providing

## Process

### Step 1: Legal Document Review
| # | Item | Status | Notes |
|---|------|--------|-------|
| 1 | Original promissory note (or copy with allonge) | | |
| 2 | Deed of Trust / Mortgage (recorded) | | |
| 3 | Chain of assignments (complete, recorded) | | |
| 4 | Loan modification agreements (if any) | | |
| 5 | Forbearance agreements (if any) | | |
| 6 | Borrower correspondence file | | |
| 7 | Power of Attorney (if applicable) | | |

**Red flags**: Missing original note, broken chain of assignments, unrecorded assignments, expired statute of limitations on enforcement

### Step 2: Collateral (Property) Assessment
| # | Item | Status | Notes |
|---|------|--------|-------|
| 8 | BPO or appraisal (within 6 months) | | Value: $_____ |
| 9 | Property condition assessment | | Occupied/Vacant/Distressed |
| 10 | Property tax status (current/delinquent) | | Owed: $_____ |
| 11 | HOA status and liens | | |
| 12 | Insurance status | | Active/Lapsed |
| 13 | Environmental/flood zone check | | |

**Key metrics**:
```
Property Value (BPO):    $[X]
UPB:                     $[X]
LTV:                     [UPB / Value]%
ITV:                     [Purchase Price / Value]%
Tax Delinquency:         $[X]
Senior Liens:            $[X]
Total Exposure:          $[UPB + Senior Liens + Tax Delq]
Total Exposure to Value: [Total / Value]%
```

### Step 3: Borrower Profile
| # | Item | Status | Notes |
|---|------|--------|-------|
| 14 | Borrower identity confirmed | | |
| 15 | Borrower credit pull (if available) | | Score: _____ |
| 16 | Occupancy status verified | | Owner-occupied / Tenant / Vacant |
| 17 | Bankruptcy search | | Active/Discharged/None |
| 18 | Litigation search | | |
| 19 | Skip trace (current contact info) | | |

**Red flags**: Active bankruptcy (automatic stay), borrower deceased with no estate, military (SCRA protections), disputed debt

### Step 4: Payment History
| # | Item | Status | Notes |
|---|------|--------|-------|
| 20 | Full payment history from servicer | | |
| 21 | Last payment date and amount | | |
| 22 | Delinquency timeline | | Months behind: _____ |
| 23 | Escrow balance and advances | | |
| 24 | Corporate advances outstanding | | $_____ |
| 25 | Pay history matches seller representations | | |

**Performance classification**:
```
Performing:      Current or <30 days late
Sub-Performing:  30-89 days delinquent
Non-Performing:  90+ days delinquent
Re-Performing:   Was NPL, now current 6+ months
```

### Step 5: Title and Lien Position
| # | Item | Status | Notes |
|---|------|--------|-------|
| 26 | Title search / O&E report | | |
| 27 | Lien position confirmed (1st, 2nd) | | |
| 28 | No senior liens in default | | |
| 29 | No IRS or state tax liens | | |
| 30 | No mechanics liens | | |
| 31 | No judgments against property | | |

### Step 6: DD Scorecard

| Category | Items | Passed | Flagged | Failed | Score |
|----------|-------|--------|---------|--------|-------|
| Legal Documents | 7 | | | | /10 |
| Collateral | 6 | | | | /10 |
| Borrower | 6 | | | | /10 |
| Payment History | 6 | | | | /10 |
| Title/Lien | 6 | | | | /10 |
| **TOTAL** | **31** | | | | **/50** |

**Decision thresholds**:
- 40-50: CLEAR TO CLOSE
- 30-39: PROCEED WITH CONDITIONS (address flagged items)
- 20-29: HIGH RISK — renegotiate price or pass
- <20: DO NOT PURCHASE

## Output Format
```
NOTE DUE DILIGENCE REPORT
═════════════════════════
Note: [Property Address]
Seller: [Name]
UPB: $[X] | Purchase Price: $[X] | LTV: [X]% | ITV: [X]%

DD SCORECARD: [X]/50
  Legal:     [X]/10
  Collateral:[X]/10
  Borrower:  [X]/10
  Payment:   [X]/10
  Title:     [X]/10

STATUS: [CLEAR TO CLOSE / CONDITIONS / HIGH RISK / DO NOT PURCHASE]

FLAGS:
⚠️ [Item] — [Issue and recommended action]

MISSING ITEMS:
- [Documents or info still needed]

ESTIMATED ADDITIONAL COSTS:
  Back taxes: $[X]
  Corp advances: $[X]
  BPO/Appraisal: $[X]
  Legal review: $[X]
  Total: $[X]

ADJUSTED BID (accounting for costs): $[X]
```

## Example Prompts
- "Run DD on this note: $95K UPB, 1st lien on SFR in Dallas, seller says performing, sending me the collateral file tomorrow."
- "What DD items am I missing? I have the note, DOT, and payment history but no title search yet."
- "The DD turned up a $4K tax lien and a broken assignment chain. Should I still buy this note at $62K?"

## Suggested Next Steps
1. **`/creative-finance/note-investing-analyzer`** — Final analysis with DD findings
2. **`/creative-finance/note-yield-calculator`** — Recalculate yield after DD adjustments
3. **`/creative-finance/note-workout-strategy`** — If NPL, plan the workout before buying
