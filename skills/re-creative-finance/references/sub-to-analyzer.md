---
name: Subject-To Analyzer
description: "Analyze subject-to deals — existing mortgage terms, equity capture, cash flow, DSCR, and due-on-sale risk assessment. Triggers on: subject to, sub-to, take over payments, existing mortgage."
---

# Subject-To Analyzer

## Overview
Analyze the viability of acquiring a property subject to the existing mortgage. Calculates equity capture at acquisition, monthly cash flow, DSCR, and assesses due-on-sale risk. The key question: does the existing loan create a better deal than getting new financing?

## When to Use
- Seller has a low-interest-rate mortgage you want to keep in place
- Seller is behind on payments and you can bring the loan current
- Traditional financing isn't available or competitive
- Evaluating sub-to vs other creative structures

## Inputs
- **Property address and value (FMV)**
- **Existing mortgage**: balance, rate, monthly P&I, escrow, years remaining
- **Loan type**: conventional, FHA, VA, USDA
- **Monthly rent potential**
- **Seller's situation**: current on payments? arrears amount?
- **Cash to seller** (if any)
- **Estimated repairs** needed
- **Property taxes and insurance** (annual)

## Process

### Step 1: Equity Capture Analysis
```
Fair Market Value (FMV):    $[X]
Existing Mortgage Balance:  $[X]
Cash to Seller:             $[X]
Arrears to Cure:            $[X]
Closing Costs (est):        $[X]
Repairs Needed:             $[X]
─────────────────────────────
Total Acquisition Cost:     $[X]
Instant Equity Captured:    $[FMV - Total Cost]
Equity Capture %:           [X]%
```

### Step 2: Cash Flow Analysis
```
Monthly Rent:               $[X]
Less: Existing P&I:         ($[X])
Less: Taxes (monthly):      ($[X])
Less: Insurance (monthly):  ($[X])
Less: Property Mgmt (8-10%):($[X])
Less: Vacancy Reserve (5%): ($[X])
Less: Maintenance (5%):     ($[X])
Less: CapEx Reserve (5%):   ($[X])
─────────────────────────────
Net Monthly Cash Flow:      $[X]
Annual Cash Flow:           $[X]
```

### Step 3: Key Metrics
```
DSCR:           [Rent / Total Debt Service]
Cash-on-Cash:   [Annual CF / Total Cash Invested]
Cap Rate:       [NOI / FMV]
Equity Position: [X]% LTV
Rate Advantage:  [Existing Rate]% vs [Current Market Rate]%
Monthly Savings: $[X] vs new conventional loan
```

### Step 4: Due-on-Sale Risk Assessment

| Factor | Risk Level | Notes |
|--------|-----------|-------|
| Loan Type | FHA/VA = Higher risk, Conv = Lower | Government loans more scrutinized |
| Loan Servicer | Some servicers more aggressive | Research servicer history |
| Payment History | Current = Low risk | Bringing current reduces attention |
| Insurance Change | Name change triggers flags | Use trust or entity carefully |
| Escrow Changes | Tax/insurance changes can flag | Maintain existing escrow if possible |

**Risk Mitigation:**
- Land trust with seller as beneficiary initially
- Maintain insurance in seller's name initially
- Keep payments automated and on-time
- Build reserves for full payoff if called

### Step 5: Deal Scorecard

## Output Format
```
SUBJECT-TO ANALYSIS — [Property Address]
════════════════════════════════════════
Existing Loan: $[Balance] at [Rate]% — $[P&I]/mo — [Years] remaining
FMV: $[X] | Rent: $[X]/mo

EQUITY CAPTURE: $[X] ([X]%)
NET CASH FLOW: $[X]/mo ($[X]/yr)
CASH-ON-CASH: [X]%
DSCR: [X]

DUE-ON-SALE RISK: [LOW/MEDIUM/HIGH]
RATE ADVANTAGE: [X]% below current market

VERDICT: [STRONG BUY / PROCEED WITH CAUTION / PASS]
```

## Example Prompts
- "Analyze this sub-to: $180K FMV, $140K mortgage at 3.25%, P&I $608/mo, rents for $1,500. Seller wants $5K cash."
- "Is this sub-to worth it? Seller is 3 months behind, balance $95K on a $150K house, 4.5% rate."
- "Compare sub-to vs getting a new loan on this deal — existing rate is 3.5%, current market is 7%."

## Suggested Next Steps
1. **`/creative-finance/dodd-frank-dti`** — If wrapping to end buyer, check compliance
2. **`/creative-finance/wrap-mortgage-calculator`** — Calculate wrap terms on top of sub-to
3. **`/deal-analysis/cash-flow-projector`** — Detailed long-term cash flow projection
