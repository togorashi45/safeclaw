---
name: Note Investing Analyzer
description: "Analyze notes for purchase — yield calculation, ITV, collateral assessment, borrower analysis, and risk grading. Triggers on: note investing, buy notes, note analysis, performing note."
---

# Note Investing Analyzer

## Overview
Evaluate real estate notes for acquisition. Calculates yield, investment-to-value ratio, assesses collateral and borrower quality, and assigns a risk grade (A-D). Determines whether to bid, pass, or dig deeper on due diligence.

## When to Use
- Evaluating a performing or non-performing note for purchase
- Screening individual notes from a tape
- Deciding what to bid on a note
- Comparing multiple note acquisition opportunities

## Inputs
- **Note details**: UPB, interest rate, monthly payment, origination date, maturity date
- **Purchase price** (asking or your target bid)
- **Property**: address, type, estimated value
- **Borrower**: payment history (last 12-24 months), credit score if available
- **Loan position**: 1st lien, 2nd lien
- **Performance status**: performing, sub-performing, non-performing

## Process

### Step 1: Investment Metrics
```
Unpaid Principal Balance (UPB):  $[X]
Purchase Price:                  $[X]
Discount:                        [X]% ($[UPB - Price])
Property Value (BPO/Appraisal):  $[X]
Investment-to-Value (ITV):       [Price / Property Value]%
Loan-to-Value (LTV):             [UPB / Property Value]%
Monthly Payment:                 $[X]
Remaining Payments:              [X]
Interest Rate:                   [X]%
```

### Step 2: Yield Calculation
```
Yield if Held to Maturity:
  Total Payments Remaining:    $[Payment × Remaining Months]
  Total Return on Investment:  $[Total Payments - Purchase Price]
  Annualized Yield (IRR):     [X]%
  Cash-on-Cash (Year 1):      [Annual Payments / Purchase Price]%

Yield if Borrower Pays Off Early:
  Payoff at Month 12: $[UPB at month 12] → Yield: [X]%
  Payoff at Month 24: $[UPB at month 24] → Yield: [X]%
  Payoff at Month 36: $[UPB at month 36] → Yield: [X]%
```

### Step 3: Risk Grading Matrix

| Factor | Weight | A (Low Risk) | B (Moderate) | C (Higher) | D (Distressed) |
|--------|--------|-------------|-------------|------------|----------------|
| Payment History | 25% | 24/24 on time | 21-23/24 on time | 18-20/24 | <18/24 or NPL |
| ITV | 20% | <65% | 65-80% | 80-90% | >90% |
| LTV | 15% | <60% | 60-75% | 75-85% | >85% |
| Lien Position | 15% | 1st lien | 1st lien (high LTV) | 2nd lien (low CLTV) | 2nd lien (high CLTV) |
| Property Condition | 15% | Good/occupied | Fair/occupied | Vacant/maintained | Vacant/distressed |
| Borrower Credit | 10% | 680+ | 620-679 | 580-619 | <580 or unknown |

### Step 4: Bid Strategy
| Risk Grade | Target Yield | Typical Bid (% of UPB) |
|-----------|-------------|----------------------|
| A | 8-12% | 85-95% of UPB |
| B | 12-18% | 70-85% of UPB |
| C | 18-25% | 50-70% of UPB |
| D (NPL) | 25-40%+ | 30-55% of UPB |

### Step 5: Deal or No Deal
- **BUY** if: yield meets target, ITV <80%, exit strategy clear
- **DIG DEEPER** if: yield is attractive but DD flags exist
- **PASS** if: yield too low, ITV too high, no clear exit, legal issues

## Output Format
```
NOTE ANALYSIS — [Property Address]
═══════════════════════════════════
Note Type: [1st/2nd Lien] | Status: [Performing/NPL]
UPB: $[X] | Ask: $[X] | Discount: [X]%
Property Value: $[X] | ITV: [X]% | LTV: [X]%

YIELD ANALYSIS:
  IRR (hold to maturity): [X]%
  Cash-on-Cash (Year 1):  [X]%
  Yield if payoff at 24mo: [X]%

RISK GRADE: [A/B/C/D]
  Payment History: [X]/10
  ITV:             [X]/10
  Lien Position:   [X]/10
  Property:        [X]/10
  Borrower:        [X]/10

RECOMMENDED BID: $[X] ([X]% of UPB)
VERDICT: [BUY / DIG DEEPER / PASS]

EXIT STRATEGIES:
1. Hold for cash flow (yield: [X]%)
2. Borrower payoff (expected: month [X])
3. Re-sell note at [X]% of UPB
4. Foreclose and sell REO (net: $[X])
```

## Example Prompts
- "Analyze this note: $85K UPB, 6% rate, $510/mo, property worth $140K, asking $72K, 1st lien, performing 24/24."
- "Is this NPL worth buying? $120K UPB, property worth $180K, asking $55K, borrower 8 months delinquent."
- "Compare these two notes and tell me which is the better buy."

## Suggested Next Steps
1. **`/creative-finance/note-due-diligence`** — Full DD checklist before buying
2. **`/creative-finance/note-yield-calculator`** — Detailed yield scenarios
3. **`/creative-finance/note-portfolio-tracker`** — Add to portfolio after purchase
