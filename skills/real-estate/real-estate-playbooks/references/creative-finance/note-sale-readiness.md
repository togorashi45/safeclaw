---
name: Note Sale Readiness
description: "Prepare notes for sale — loan file assembly, pricing at target yields, marketing package creation, and buyer channel identification. Triggers on: sell note, note sale, package note, note exit."
---

# Note Sale Readiness

## Overview
Prepare notes for sale to secondary market buyers. Assembles the complete loan file, calculates pricing at various buyer yield targets, creates the marketing/offering package, and identifies the right buyer channels. A well-packaged note sells faster and at a higher price.

## When to Use
- Exiting a note position — ready to sell
- Rebalancing your note portfolio
- Liquidating to free up capital for new acquisitions
- Selling a re-performing note at a premium

## Inputs
- **Note details**: UPB, rate, payment, origination date, maturity, lien position
- **Performance history**: months performing, payment track record
- **Property**: address, type, current value (BPO within 6 months)
- **Loan file**: list of documents you have
- **Your basis**: what you paid
- **Target price or minimum acceptable yield to buyer**

## Process

### Step 1: Loan File Assembly Checklist
| # | Document | Have? | Notes |
|---|----------|-------|-------|
| 1 | Original promissory note (or copy + allonge) | | |
| 2 | Recorded Deed of Trust / Mortgage | | |
| 3 | Complete chain of assignments (recorded) | | |
| 4 | Title search / O&E report (recent) | | |
| 5 | BPO or appraisal (within 6 months) | | |
| 6 | Payment history (full, from servicer) | | |
| 7 | Borrower credit report (if available) | | |
| 8 | Loan modification docs (if modified) | | |
| 9 | Insurance verification | | |
| 10 | Tax status (current) | | |
| 11 | Servicer transfer letter / boarding docs | | |
| 12 | Correspondence file | | |

**Completeness score**: [X]/12 — Notes with complete files sell at 5-15% premium

### Step 2: Pricing Calculator
```
Your Basis:                    $[X]
Current UPB:                   $[X]
Remaining Payments:            [X] months
Monthly Payment:               $[X]
Property Value:                $[X]
LTV:                           [X]%

PRICING AT BUYER YIELD TARGETS:
  Buyer wants 8% yield:  → Price: $[X] ([X]% of UPB)
  Buyer wants 10% yield: → Price: $[X] ([X]% of UPB)
  Buyer wants 12% yield: → Price: $[X] ([X]% of UPB)
  Buyer wants 15% yield: → Price: $[X] ([X]% of UPB)

YOUR P&L AT EACH PRICE:
  At 8% buyer yield:  Profit: $[X] (ROI: [X]%)
  At 10% buyer yield: Profit: $[X] (ROI: [X]%)
  At 12% buyer yield: Profit: $[X] (ROI: [X]%)
```

### Step 3: Marketing Package
Create an offering memo with:
- Note summary (property, borrower, terms, performance)
- Payment history grid (last 12-24 months)
- Property details with BPO/photos
- LTV and ITV at asking price
- Yield to buyer at asking price
- Loan file completeness status
- Required buyer qualifications

### Step 4: Buyer Channels
| Channel | Best For | Expected Timeline |
|---------|----------|------------------|
| Note exchanges (Paperstac, FCI, etc.) | Performing notes | 2-6 weeks |
| Note brokers | Larger UPB, pools | 2-4 weeks |
| Note investing groups/meetups | Small-balance performing | 1-4 weeks |
| Direct to known buyers | Repeat relationships | 1-2 weeks |
| Hedge funds | Large pools ($1M+) | 4-8 weeks |

## Output Format
```
NOTE SALE PACKAGE — [Property Address]
══════════════════════════════════════
UPB: $[X] | Rate: [X]% | Payment: $[X]/mo
Status: [Performing/Re-performing] | LTV: [X]%
Your Basis: $[X]

LOAN FILE: [X]/12 complete
MISSING: [List any missing docs]

ASKING PRICE: $[X] ([X]% of UPB)
BUYER YIELD AT ASK: [X]%
YOUR PROFIT AT ASK: $[X] (ROI: [X]%)

RECOMMENDED CHANNELS: [Top 2-3]
ESTIMATED TIME TO SELL: [X] weeks
```

## Example Prompts
- "Package my 123 Main St note for sale — $78K UPB, performing 18 months, I paid $52K."
- "What should I ask for my re-performing note? Buyer wants 10% yield, UPB is $95K."
- "What docs am I missing to sell this note? I have the note, DOT, and payment history."

## Suggested Next Steps
1. **`/creative-finance/note-yield-calculator`** — Verify yield calculations for marketing
2. **`/creative-finance/note-portfolio-tracker`** — Update portfolio after sale
3. **`/creative-finance/seller-finance-tape`** — If selling multiple notes as a tape
