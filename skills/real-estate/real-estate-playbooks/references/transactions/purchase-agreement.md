---
name: Purchase Agreement Generator
description: "Generate real estate purchase agreements with investor-friendly terms, contingencies, and closing provisions. Triggers on: purchase agreement, buy contract, purchase contract."
---

# Purchase Agreement Generator

## Overview
Generate purchase agreements for acquiring investment properties. Builds contracts with investor-friendly clauses — as-is, assignability, inspection contingencies, and flexible closing terms. Works for wholesale acquisitions, flips, and rental purchases.

## When to Use
- Making an offer on a property (any acquisition strategy)
- Need a contract template customized to your deal terms
- Converting a verbal agreement to a written contract

## Inputs
- **Buyer** — name/entity, address
- **Seller** — name(s), address
- **Property** — full address, legal description if available
- **Purchase price** and how determined
- **Earnest money deposit** — amount, where held, timeline
- **Closing date** — specific date or "on or before" date
- **Contingencies** — inspection, financing, appraisal, title
- **Option/inspection period** — days and fee (if applicable)
- **Deal type** — wholesale (needs assignability), flip, rental, creative
- **Special terms** — seller concessions, personal property included, occupancy

## Process

### Step 1: Determine Contract Type
| Deal Type | Key Clauses Needed |
|-----------|-------------------|
| Wholesale | Assignability, short inspection, as-is, quick close |
| Flip | Inspection contingency, as-is, title contingency |
| Rental | Financing contingency, inspection, tenant estoppel |
| Sub-To | Subject-to existing financing, seller cooperation |
| Seller Finance | Promissory note terms, security instrument |

### Step 2: Build Core Terms
```
Purchase Price:     $[X]
Earnest Money:      $[X] — deposited within [X] days to [Title Co]
Option Fee:         $[X] (if applicable, non-refundable)
Inspection Period:  [X] days from effective date
Financing:          Cash / Conventional / Hard Money / Seller Finance
Closing Date:       On or before [Date]
Possession:         At closing / [X] days after closing
```

### Step 3: Generate Standard Clauses
1. **Parties and Property** — Legal identification
2. **Purchase Price and Payment** — How and when paid
3. **Earnest Money** — Deposit, escrow, refund conditions
4. **Title** — Marketable title required, title insurance, survey
5. **Inspection Contingency** — Scope, timeline, remedies
6. **Financing Contingency** — Type, timeline, waiver conditions
7. **As-Is Clause** — Property accepted in current condition
8. **Assignability** — "Buyer and/or assigns" language
9. **Closing Costs** — Who pays what (title policy, transfer tax, etc.)
10. **Prorations** — Taxes, rent, HOA, utilities
11. **Default and Remedies** — Buyer default, seller default
12. **Disclosures** — Required seller disclosures
13. **Entire Agreement / Amendments** — Written modifications only
14. **Governing Law** — State jurisdiction
15. **Signatures and Date**

### Step 4: Add Deal-Specific Addenda
- Personal property list (if appliances, fixtures included)
- Seller financing addendum (if applicable)
- Lease assignment (if tenants in place)
- Repair credit addendum
- Closing date extension provisions

## Output Format
```
REAL ESTATE PURCHASE AGREEMENT
══════════════════════════════
Effective Date: [Date]

BUYER: [Name/Entity] and/or assigns
SELLER: [Name(s)]
PROPERTY: [Address]

TERMS SUMMARY:
  Purchase Price:    $[X]
  Earnest Money:     $[X]
  Inspection Period: [X] days
  Closing Date:      [Date]
  Financing:         [Type]

[Full contract text with all sections]

BUYER: _______________  Date: _______
SELLER: ______________  Date: _______
```

## Example Prompts
- "Draft a purchase agreement for 123 Main St at $85K cash, $1K EMD, close in 21 days, as-is with 7-day inspection."
- "Create a purchase contract for a rental I'm buying with seller financing — $150K, 5% down, 6% rate, 30-year am with 5-year balloon."
- "Generate an assignable purchase agreement for wholesale — $65K, $500 EMD, 14-day close."

## Suggested Next Steps
1. **`/transactions/addendum-builder`** — Add any special terms or modifications
2. **`/deal-analysis/arv-calculator`** — Verify your numbers before sending
3. **`/transactions/wholesale-tc`** — Start the closing checklist
