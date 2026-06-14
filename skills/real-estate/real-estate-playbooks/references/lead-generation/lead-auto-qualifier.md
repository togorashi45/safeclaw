---
name: Lead Auto-Qualifier
description: "Score and qualify inbound leads based on motivation, timeline, equity, property condition, and situation. Outputs a 1-10 score with recommended action. Triggers on: qualify lead, score lead, is this lead good, lead quality, rate this lead."
---

# Lead Auto-Qualifier

## Overview
Instantly score inbound seller leads on a 1-10 scale using key qualification criteria. Separates hot leads from tire-kickers so you spend time on deals that close.

## When to Use
- New lead comes in from any source (cold call, text, form, referral)
- Batch-scoring a list of leads for prioritization
- Deciding whether to make an offer or keep nurturing

## Inputs
Provide as much as available:
- **Seller name and contact**
- **Property address**
- **Motivation level** — why are they selling?
- **Timeline** — how soon do they need to sell?
- **Property condition** — scale of 1-5 or description
- **Asking price vs estimated ARV**
- **Mortgage balance / equity position**
- **Occupancy** — owner-occupied, tenant, vacant
- **How they found you** — lead source

## Process

### Step 1: Score Each Qualification Factor

| Factor | Weight | 10 (Hot) | 5 (Warm) | 1 (Cold) |
|--------|--------|----------|----------|----------|
| **Motivation** | 30% | Must sell (foreclosure, divorce, death, relocation) | Would like to sell, open to offers | Just curious, testing market |
| **Timeline** | 20% | Needs to close in <30 days | 30-90 days | 6+ months or no rush |
| **Equity** | 20% | 30%+ equity, room for discount | 10-30% equity | Underwater or minimal equity |
| **Condition** | 15% | Needs major rehab (our sweet spot) | Moderate updates needed | Move-in ready (retail buyer territory) |
| **Price Flexibility** | 15% | Will take 60-70% ARV | Wants 75-85% ARV | Wants full retail |

### Step 2: Calculate Weighted Score
```
Score = (Motivation × 0.30) + (Timeline × 0.20) + (Equity × 0.20) + (Condition × 0.15) + (Price Flexibility × 0.15)
```

### Step 3: Classify and Recommend Action

| Score | Classification | Action |
|-------|---------------|--------|
| 8-10 | HOT | Make offer within 24 hours. Set appointment immediately. |
| 6-7 | WARM | Schedule follow-up within 48 hours. Add to active nurture. |
| 4-5 | LUKEWARM | Add to drip sequence. Check back in 30 days. |
| 1-3 | COLD | Log in CRM. Long-term nurture only. |

### Step 4: Output the Score Card

## Output Format
```
LEAD SCORE CARD
═══════════════
Seller: [Name]
Property: [Address]
Source: [Lead source]
Date Scored: [Today]

QUALIFICATION BREAKDOWN:
  Motivation:       [X]/10 — [reason]
  Timeline:         [X]/10 — [reason]
  Equity Position:  [X]/10 — [reason]
  Condition:        [X]/10 — [reason]
  Price Flexibility: [X]/10 — [reason]

WEIGHTED SCORE: [X.X]/10
CLASSIFICATION: [HOT/WARM/LUKEWARM/COLD]

RECOMMENDED ACTION:
[Specific next step based on classification]

RED FLAGS:
- [Any concerns — title issues, unrealistic expectations, etc.]

NOTES:
[Additional context]
```

## Example Prompts
- "Score this lead: seller John at 123 Main St, behind on mortgage 3 months, needs to sell in 2 weeks, house needs full rehab, owes $80K on a $180K ARV property."
- "Qualify this lead — seller says they might want to sell sometime next year, house is in good shape, wants full market value."
- "Rate these 5 leads and tell me which one to call first."

## Suggested Next Steps
1. **`/deal-analysis/comp-pull`** — Pull comps to verify ARV and equity position
2. **`/lead-generation/appointment-setter`** — Book an appointment with hot leads
3. **`/lead-generation/adaptive-follow-up`** — Set up nurture sequence for warm/lukewarm leads
