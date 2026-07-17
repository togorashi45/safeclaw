---
name: Addendum Builder
description: "Create contract addenda and amendments to modify existing purchase agreements — price changes, deadline extensions, repair credits, and special terms. Triggers on: addendum, contract addendum, amendment, modify contract."
---

# Addendum Builder

## Overview
Generate addenda to modify existing real estate purchase contracts. Handles price reductions, closing date extensions, repair credits, contingency waivers, and any other contract modifications that both parties need to agree on.

## When to Use
- Inspection revealed issues — need a price reduction or repair credit
- Closing date needs to be extended
- Adding or removing contingencies
- Changing financing terms
- Adding special provisions (personal property, seller lease-back, etc.)

## Inputs
- **Original contract date** and reference
- **Property address**
- **Buyer and seller names** (must match original contract)
- **Specific modification(s)** — what's changing and why
- **Effective date** of amendment
- **Any new deadlines** created by the change

## Process

### Step 1: Identify Modification Type

| Type | Common Scenarios |
|------|-----------------|
| Price Reduction | Post-inspection issues, appraisal gap, market shift |
| Closing Extension | Financing delay, title issue, seller needs more time |
| Repair Credit | Seller credits buyer at closing instead of making repairs |
| Contingency Waiver | Buyer waives inspection, financing, or appraisal contingency |
| Term Change | Financing type change, EMD adjustment, possession date |
| Addition | Personal property, seller lease-back, rent proration |
| Cancellation | Mutual release and cancellation of contract |

### Step 2: Draft Amendment Language
- Reference original contract by date and parties
- State the specific section(s) being modified
- Use "strike and replace" language for clarity
- All other terms remain unchanged
- Require signatures from all original parties

### Step 3: Generate Document

## Output Format
```
ADDENDUM / AMENDMENT TO PURCHASE AGREEMENT
═══════════════════════════════════════════
Addendum #: [X]
Date: [Date]

Reference: Purchase Agreement dated [Original Date]
Property: [Address]
Buyer: [Name]
Seller: [Name]

The parties agree to the following modification(s):

[MODIFICATION]:
Original Term: [What it currently says]
Amended Term:  [What it now says]

Reason: [Brief explanation]

All other terms and conditions of the original agreement
remain in full force and effect.

BUYER: _______________  Date: _______
SELLER: ______________  Date: _______
```

## Example Prompts
- "Create an addendum to reduce price from $95K to $88K after inspection found foundation issues."
- "Extend closing from April 15 to April 30 — buyer's lender needs more time."
- "Add a $5K repair credit at closing for the HVAC replacement."
- "Draft a mutual cancellation — both parties want to walk away, return EMD to buyer."

## Suggested Next Steps
1. **`/transactions/wholesale-tc`** — Update closing checklist with new terms
2. **`/transactions/escrow-change-alert`** — Notify title company of changes
3. **`/deal-analysis/deal-pnl`** — Recalculate profit with updated terms
