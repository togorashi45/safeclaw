---
name: Deal Predictor
description: "Score deal probability of closing based on seller motivation, pricing, timeline, financing, and comparable deal outcomes. Triggers on: predict deal, deal probability, will this close, deal score, deal likelihood."
---

# Deal Predictor

## Overview
Predict whether a deal will actually close based on key risk factors. Gives you a probability score so you can focus energy on high-probability deals.

## When to Use
- Deciding which deals to prioritize this week
- Evaluating whether to spend money on due diligence
- Pipeline review — which deals are likely to fall through

## Inputs
- Deal details (address, price, terms)
- Seller motivation level and reason
- Financing method (cash, hard money, creative)
- Title status (clear, liens, probate)
- Timeline to close
- Contingencies remaining

## Process

### Step 1: Score Risk Factors
| Factor | Weight | Low Risk (10) | High Risk (1) |
|--------|--------|--------------|---------------|
| Seller Motivation | 25% | Must sell, deadline | Curious, testing market |
| Price Agreement | 20% | At or below MAO | Far apart on price |
| Financing | 15% | Cash, approved | Contingent on approval |
| Title | 15% | Clear title | Liens, probate, disputed |
| Timeline | 10% | 14-30 days | 90+ days or uncertain |
| Contingencies | 10% | None remaining | Multiple open |
| Seller Reliability | 5% | Responsive, consistent | Flaky, changing terms |

### Step 2: Calculate Probability
```
Probability = Weighted average of all factor scores × 10
```

### Step 3: Classify

| Score | Probability | Action |
|-------|------------|--------|
| 80-100% | Very Likely | Full speed ahead |
| 60-79% | Probable | Proceed but watch risk factors |
| 40-59% | Uncertain | Address weak factors before investing more |
| <40% | Unlikely | Consider walking or major renegotiation |

## Output Format
```
DEAL PROBABILITY — [Address]
════════════════════════════
Score: [X]% — [Classification]

RISK BREAKDOWN:
  Seller Motivation: [X]/10 — [note]
  Price Agreement: [X]/10 — [note]
  Financing: [X]/10 — [note]
  Title: [X]/10 — [note]
  Timeline: [X]/10 — [note]

TOP RISKS:
1. [Biggest risk factor and how to mitigate]
2. [Second risk and mitigation]

RECOMMENDATION: [Proceed / Address risks / Walk]
```

## Example Prompts
- "What's the probability this deal closes? Seller is motivated (foreclosure), we're $5K apart on price, cash deal, title is clear, close in 21 days."
- "Score my 4 active deals and tell me which is most likely to close."
- "This deal feels shaky — seller keeps changing terms. Predict the outcome."

## Suggested Next Steps
1. **`/deal-analysis/deal-pnl`** — Run full P&L on high-probability deals
2. **`/transactions/wholesale-tc`** — Start TC checklist on deals moving forward
3. **`/dispositions/weekly-pipeline`** — Review full pipeline with probability scores
