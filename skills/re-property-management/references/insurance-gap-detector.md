---
name: Insurance Gap Detector
description: "Identify insurance coverage gaps — policy review, replacement cost analysis, liability adequacy, flood/wind requirements, and umbrella policy needs. Triggers on: insurance gap, coverage gap, underinsured, policy review."
---

# Insurance Gap Detector

## Overview
Review property insurance policies for coverage gaps that could leave you exposed. Checks replacement cost vs actual cash value, liability limits, flood/wind requirements, vacancy clauses, and umbrella policy adequacy across your portfolio.

## When to Use
- Acquiring a new property — need to set up insurance
- Annual policy review
- After a claim or near-miss
- Adding properties to portfolio — umbrella coverage review
- Property transitioning (occupied to vacant, rental to flip)

## Inputs
- **Property address and type** (SFR, MF, commercial)
- **Current policy details** (if reviewing existing)
- **Property value / replacement cost estimate**
- **Use** — rental, flip (vacant rehab), owner-occupied, vacant
- **Mortgage requirements** (if financed)
- **Portfolio size** (for umbrella assessment)

## Process

### Step 1: Coverage Checklist

| Coverage Type | Have? | Amount | Adequate? | Gap? |
|---------------|-------|--------|-----------|------|
| Dwelling (replacement cost) | | $[X] | | |
| Liability | | $[X] | | |
| Loss of Rent | | $[X] | | |
| Flood | | $[X] | | |
| Wind/Hail | | $[X] | | |
| Umbrella / Excess Liability | | $[X] | | |
| Vacancy endorsement | | — | | |
| Builder's Risk (if rehab) | | $[X] | | |
| Equipment/Tools (if on-site) | | $[X] | | |

### Step 2: Common Gaps for Investors

| Gap | Risk | Solution |
|-----|------|----------|
| ACV instead of Replacement Cost | Paid depreciated value, not rebuild cost | Switch to RCV policy |
| No vacancy endorsement | Claims denied if property vacant >30-60 days | Add vacancy endorsement for flips |
| Insufficient liability | Personal assets exposed in lawsuits | Minimum $1M per property, umbrella on top |
| No flood insurance | Flood not covered by standard policy | Separate flood policy (NFIP or private) |
| No loss of rent coverage | No income during repairs after a claim | Add loss of rent rider |
| Underinsured (dwelling) | Rebuild cost exceeds coverage | Get replacement cost estimate, adjust |
| No builder's risk | Active rehab not covered by standard policy | Builder's risk policy during construction |
| No umbrella | Liability claims exceed per-property limits | $1-5M umbrella based on portfolio size |

### Step 3: Portfolio-Level Assessment
```
Total Properties:          [X]
Total Insured Value:       $[X]
Total Liability Coverage:  $[X]
Umbrella Coverage:         $[X]
Recommended Umbrella:      $[X] (typically $1M per property or $2-5M minimum)
```

## Output Format
```
INSURANCE GAP ANALYSIS — [Property/Portfolio]
═════════════════════════════════════════════
Property: [Address]
Use: [Rental/Flip/Vacant]
Current Policy: [Carrier] — Policy #[X]

GAPS IDENTIFIED:
🔴 CRITICAL: [Gap] — [Risk and recommendation]
🟡 MODERATE: [Gap] — [Risk and recommendation]
🟢 ADEQUATE: [Coverage areas that are sufficient]

RECOMMENDED ACTIONS:
1. [Action item with estimated cost]
2. [Action item]

ESTIMATED ADDITIONAL PREMIUM: $[X]/year
```

## Example Prompts
- "Review insurance on my rental at 123 Main — I have a standard landlord policy, $200K dwelling, $300K liability."
- "I just bought a flip — it'll be vacant during rehab. What insurance do I need?"
- "I have 5 rentals and no umbrella. What should I get?"
- "Is my $150K dwelling coverage enough? Replacement cost estimate is $210K."

## Suggested Next Steps
1. **`/property-management/portfolio-dashboard`** — Review all properties and coverage
2. **`/reporting/financial-qa`** — Insurance cost deductibility questions
3. **`/property-management/lead-paint-cert`** — Lead paint liability exposure
