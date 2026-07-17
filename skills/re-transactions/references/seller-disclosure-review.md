---
name: Seller Disclosure Review
description: "Systematically review seller property disclosures for red flags, hidden costs, and negotiation leverage points. Triggers on: seller disclosure, disclosure review, property disclosure."
---

# Seller Disclosure Review

## Overview
Review seller property disclosure forms section by section to identify red flags, estimate costs for disclosed issues, and find negotiation leverage points. A thorough disclosure review can save you from costly surprises and give you ammunition for price reductions.

## When to Use
- Received seller's property disclosure during due diligence
- Evaluating a deal before making an offer
- Preparing for inspection — want to know what seller already disclosed
- Building a case for a price reduction

## Inputs
- **Seller disclosure document** (text or summary of disclosed items)
- **Property type and age**
- **Your intended use** — flip, rental, wholesale
- **Original offer price** — to calculate impact of findings

## Process

### Step 1: Review Each Disclosure Category

| Category | Red Flag Items | Cost Impact |
|----------|---------------|-------------|
| **Foundation/Structure** | Cracks, settling, previous repairs, pier work | $5K-50K+ |
| **Roof** | Age, leaks, patches, hail damage claims | $5K-25K |
| **Plumbing** | Leaks, polybutylene pipe, sewer line issues, well/septic | $2K-30K |
| **Electrical** | Aluminum wiring, knob-and-tube, panel issues, no GFCI | $2K-15K |
| **HVAC** | Age, last service, R-22 refrigerant, ductwork issues | $3K-15K |
| **Water Damage** | Current/past leaks, flooding history, mold remediation | $2K-50K+ |
| **Pest/Termite** | Active infestation, previous treatment, damage | $1K-20K |
| **Environmental** | Lead paint, asbestos, radon, underground tanks | $2K-30K+ |
| **Title/Legal** | Liens, easements, encroachments, boundary disputes | Variable |
| **HOA/Deed Restrictions** | Violations, special assessments, rental restrictions | Variable |
| **Flood Zone** | FEMA zone, flood history, insurance costs | $1K-5K/year |

### Step 2: Flag Severity Levels
- **CRITICAL** — Deal-killers or major cost items (>$10K)
- **MODERATE** — Significant but manageable ($2K-10K)
- **MINOR** — Small issues or maintenance items (<$2K)
- **LEVERAGE** — Not costly but useful for negotiation

### Step 3: Estimate Repair Costs

### Step 4: Negotiation Strategy
```
Total Estimated Cost of Disclosed Issues: $[X]
Recommended Price Reduction Request:      $[X]
Alternative: Repair Credit at Closing:    $[X]
Revised MAO After Disclosures:            $[X]
```

## Output Format
```
SELLER DISCLOSURE REVIEW — [Property Address]
══════════════════════════════════════════════
Review Date: [Date]
Original Offer: $[X]

CRITICAL FLAGS:
🔴 [Item] — Est. cost: $[X] — [Details]

MODERATE FLAGS:
🟡 [Item] — Est. cost: $[X] — [Details]

MINOR FLAGS:
🟢 [Item] — Est. cost: $[X] — [Details]

TOTAL ESTIMATED COST: $[X]

NEGOTIATION RECOMMENDATION:
Request price reduction of $[X] OR
Request repair credit of $[X] at closing

ITEMS NEEDING FURTHER INVESTIGATION:
- [Items to verify during inspection]

DEAL IMPACT:
Original offer: $[X]
Revised recommended price: $[X]
Still a deal? [YES/NO] — [Brief analysis]
```

## Example Prompts
- "Review this seller disclosure: seller says roof is 18 years old, HVAC replaced 2019, foundation has been repaired with piers, evidence of past water damage in master bath."
- "The disclosure says aluminum wiring, polybutylene plumbing, and previous termite treatment. What's my cost exposure?"
- "Seller disclosed flood zone X and one prior flood claim. Should I still pursue this deal?"

## Suggested Next Steps
1. **`/transactions/addendum-builder`** — Create price reduction or repair credit addendum
2. **`/deal-analysis/arv-calculator`** — Recalculate ARV accounting for disclosed issues
3. **`/property-management/insurance-gap-detector`** — Check insurance implications of disclosures
