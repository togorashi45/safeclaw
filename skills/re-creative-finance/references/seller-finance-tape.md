---
name: Seller Finance Tape Aggregator
description: "Aggregate seller finance notes into a standardized tape format for portfolio review or sale preparation. Triggers on: seller finance tape, note tape, aggregate notes."
---

# Seller Finance Tape Aggregator

## Overview
Compile all seller-financed notes into a standardized tape (spreadsheet) format. Used for portfolio review, note sales, and investor reporting. Aggregates UPB, payment status, yields, and performance metrics across your note portfolio.

## When to Use
- Reviewing your note portfolio performance
- Preparing notes for sale to a note buyer
- Investor reporting on note portfolio
- Portfolio-level risk assessment

## Inputs
- **All active seller finance notes** (from mind/active-portfolio.md)
- Each note needs: borrower, property, UPB, rate, payment, origination date, maturity, status

## Process

### Step 1: Compile Note Data
| # | Borrower | Property | Orig Bal | UPB | Rate | Payment | Orig Date | Maturity | Status | LTV |
|---|----------|----------|----------|-----|------|---------|-----------|----------|--------|-----|

### Step 2: Portfolio Metrics
```
Total Notes:           [X]
Total UPB:             $[X]
Performing:            [X] ($[X] UPB)
Non-Performing:        [X] ($[X] UPB)
Weighted Avg Rate:     [X]%
Weighted Avg LTV:      [X]%
Monthly Income:        $[X]
Annual Yield:          [X]%
```

### Step 3: Risk Distribution
| Risk Grade | Count | UPB | % of Portfolio |
|-----------|-------|-----|----------------|
| A (Low) | | | |
| B (Moderate) | | | |
| C (Higher) | | | |
| D (Distressed) | | | |

## Output Format
```
SELLER FINANCE NOTE TAPE — [Date]
══════════════════════════════════
[Full tape table]
[Portfolio metrics summary]
```

## Example Prompts
- "Compile my seller finance tape — show all notes with performance status."
- "What's the total UPB and weighted average yield on my note portfolio?"
- "Prepare a note tape for a potential buyer — I want to sell 3 of my notes."

## Suggested Next Steps
1. **`/creative-finance/note-sale-readiness`** — Prepare notes for sale
2. **`/creative-finance/note-yield-calculator`** — Calculate yields on each note
3. **`/creative-finance/note-portfolio-tracker`** — Detailed portfolio dashboard
