---
name: Note Workout Strategy Modeler
description: "Decision framework for non-performing notes — reinstatement, modification, forbearance, deed-in-lieu, cash-for-keys, foreclosure with side-by-side NPV comparison. Triggers on: workout, non-performing, NPL strategy, note workout."
---

# Note Workout Strategy Modeler

## Overview
Model workout strategies for non-performing notes with side-by-side NPV comparisons. Evaluates reinstatement, loan modification, forbearance, short sale, deed-in-lieu, cash-for-keys, and foreclosure — ranking each by net present value, timeline, and probability of success. The goal: maximize recovery while minimizing time and legal cost.

## When to Use
- Just acquired a non-performing note — need a workout plan
- Borrower contact made — evaluating modification terms
- Foreclosure timeline is long — exploring alternatives
- Comparing multiple exit strategies on an NPL

## Inputs
- **Note**: UPB, rate, payment, months delinquent, arrears amount
- **Property**: address, value (BPO), condition, occupancy
- **Borrower**: contact status, willingness to cooperate, financial situation
- **Legal**: state (judicial vs non-judicial foreclosure), estimated foreclosure timeline and cost
- **Your basis**: what you paid for the note

## Process

### Step 1: Assess Borrower Situation
| Factor | Status | Implication |
|--------|--------|------------|
| Contactable? | Yes/No | No contact → foreclosure or door knock |
| Wants to stay? | Yes/No | Yes → modification; No → DIL or C4K |
| Can afford payments? | Full/Partial/No | Determines mod terms |
| Bankruptcy? | Active/None | Active = automatic stay, must get relief |
| Military (SCRA)? | Yes/No | Additional protections apply |
| Occupancy | Owner/Tenant/Vacant | Impacts timeline and strategy |

### Step 2: Model Each Strategy

#### Option A: Reinstatement
```
Arrears Owed:              $[X]
Probability borrower pays: [X]%
Timeline:                  30-60 days
Your recovery:             Full UPB (note becomes performing)
NPV:                       $[X]
```

#### Option B: Loan Modification
```
Modified terms:            [Lower rate / extended term / principal reduction]
New payment:               $[X]/mo (must be affordable — 31% DTI target)
Re-performance timeline:   6-12 months trial period
Modified UPB:              $[X]
Yield on modified note:    [X]%
NPV of modified cash flow: $[X]
Can sell as re-performer:  Yes, at [X]% of UPB after 12 months performance
```

#### Option C: Forbearance Agreement
```
Forbearance period:        [X] months
Reduced/deferred payments: $[X]/mo during forbearance
Arrears repayment plan:    $[X]/mo over [X] months after forbearance
NPV:                       $[X]
Risk:                      Borrower may default again after forbearance
```

#### Option D: Short Sale
```
Property value:            $[X]
Expected net sale price:   $[X] (minus agent/closing costs)
Your recovery:             $[X]
Timeline:                  60-120 days
NPV:                       $[X]
```

#### Option E: Deed-in-Lieu of Foreclosure
```
Property value:            $[X]
Condition at transfer:     [Estimate]
Renovation needed:         $[X]
Net after REO sale:        $[X]
Timeline:                  30-60 days (faster than foreclosure)
NPV:                       $[X]
Advantage:                 No foreclosure costs, faster than judicial
```

#### Option F: Cash-for-Keys
```
Offer to borrower:         $[X] (typically $1K-5K)
Property value at vacancy: $[X]
Net after REO sale:        $[X] minus C4K payment minus reno
Timeline:                  15-45 days
NPV:                       $[X]
Advantage:                 Fastest path to vacant property
```

#### Option G: Foreclosure
```
State:                     [Judicial / Non-Judicial]
Estimated timeline:        [X] months
Legal costs:               $[X]
Property taxes accruing:   $[X]
Insurance during process:  $[X]
Total carry cost:          $[X]
Property value at sale:    $[X]
Net recovery:              $[X]
NPV:                       $[X]
```

### Step 3: Side-by-Side Comparison

| Strategy | Net Recovery | Timeline | Prob. Success | NPV | Rank |
|----------|-------------|----------|---------------|-----|------|
| Reinstatement | $[X] | [X] mo | [X]% | $[X] | |
| Modification | $[X] | [X] mo | [X]% | $[X] | |
| Forbearance | $[X] | [X] mo | [X]% | $[X] | |
| Short Sale | $[X] | [X] mo | [X]% | $[X] | |
| Deed-in-Lieu | $[X] | [X] mo | [X]% | $[X] | |
| Cash-for-Keys | $[X] | [X] mo | [X]% | $[X] | |
| Foreclosure | $[X] | [X] mo | [X]% | $[X] | |

### Step 4: Recommended Strategy and Sequencing
Typical NPL workout sequence:
1. Attempt contact (door knock, skip trace, letter)
2. If cooperative → modification or reinstatement
3. If wants to leave → deed-in-lieu or cash-for-keys
4. If no contact / uncooperative → foreclosure as last resort
5. Always run parallel tracks (negotiate while filing)

## Output Format
```
NPL WORKOUT ANALYSIS — [Property Address]
══════════════════════════════════════════
UPB: $[X] | Your Basis: $[X] | Property Value: $[X]
Months Delinquent: [X] | Arrears: $[X]
Borrower Status: [Contactable/Cooperative/Unresponsive]

STRATEGY COMPARISON:
[Side-by-side table]

RECOMMENDED: [Strategy] → [Backup Strategy]
Expected Recovery: $[X]
ROI on Basis: [X]%
Timeline: [X] months

IMMEDIATE ACTIONS:
1. [First step]
2. [Second step]
3. [Third step]
```

## Example Prompts
- "Model workout strategies for my NPL: $120K UPB, bought at $48K, property worth $165K, borrower is 14 months behind, non-judicial state."
- "Borrower wants to stay — compare modification at 4% vs 5% vs principal reduction to $100K."
- "No contact with borrower after 3 attempts. Property is vacant. What's my best path?"

## Suggested Next Steps
1. **`/creative-finance/borrower-workout-outreach`** — Draft outreach to borrower
2. **`/creative-finance/note-yield-calculator`** — Calculate yield under each scenario
3. **`/creative-finance/note-sale-readiness`** — If selling the note instead of working out
