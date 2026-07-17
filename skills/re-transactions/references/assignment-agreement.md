---
name: Assignment Agreement Generator
description: "Generate wholesale assignment of contract agreements with all required clauses, fee structure, and buyer/seller details. Triggers on: assignment, assign contract, assignment agreement, assignment fee."
---

# Assignment Agreement Generator

## Overview
Generate a complete assignment of contract agreement for wholesale deals. Covers the transfer of your equitable interest in a purchase contract to an end buyer for an assignment fee. This is the core document that makes wholesaling work.

## When to Use
- You have a property under contract and a buyer ready to close
- Need to formalize the assignment fee and terms with your end buyer
- Re-assigning a deal to a new buyer after first buyer fell through

## Inputs
- **Original contract date** and contract reference number
- **Property address** (full legal if available)
- **Assignor** (you / your entity) — name, address, entity type
- **Assignee** (end buyer) — name, address, entity type
- **Original purchase price** from the A-B contract
- **Assignment fee** amount
- **Earnest money deposit** from assignee (amount and due date)
- **Closing date** (must match or precede original contract deadline)
- **Title company / closing agent** name and contact
- **Any special terms** (inspection period, as-is, etc.)

## Process

### Step 1: Verify Original Contract Status
Confirm:
- [ ] Original purchase agreement is fully executed
- [ ] Still within contract period (not expired)
- [ ] No anti-assignment clause in original contract
- [ ] Seller has been notified of assignment (if required)
- [ ] Title company is assignment-friendly

### Step 2: Calculate Fee Structure

| Item | Amount |
|------|--------|
| Original Purchase Price | $[X] |
| Assignment Fee | $[X] |
| Total Buyer Cost (Purchase + Fee) | $[X] |
| Buyer's EMD | $[X] |
| EMD Due Date | [Date] |
| Closing Date | [Date] |

### Step 3: Generate Agreement Clauses

**Required Sections:**
1. **Parties** — Assignor and Assignee with full legal names/entities
2. **Recitals** — Reference to original purchase agreement, property description
3. **Assignment of Interest** — Transfer of all rights, title, and interest
4. **Assignment Fee** — Amount, payment terms, when due (at closing vs upfront)
5. **Earnest Money** — Amount, where deposited, refundability conditions
6. **Assignee Obligations** — Assumes all buyer obligations under original contract
7. **As-Is Clause** — Property accepted in current condition
8. **Inspection Period** — If any, timeline and rights
9. **Closing** — Date, location, title company, who pays what
10. **Default** — Remedies if either party fails to perform
11. **Non-Circumvent** — Buyer cannot go directly to seller
12. **Entire Agreement** — Standard integration clause
13. **Signatures** — Both parties, date, notarization if required

### Step 4: Review and Output

## Output Format
```
ASSIGNMENT OF CONTRACT AGREEMENT
═════════════════════════════════
Date: [Date]
Reference: Assignment of Purchase Agreement dated [Original Date]

ASSIGNOR: [Name/Entity]
ASSIGNEE: [Name/Entity]
PROPERTY: [Full Address]

ORIGINAL PURCHASE PRICE: $[X]
ASSIGNMENT FEE: $[X]
TOTAL BUYER COST: $[X]

ASSIGNEE EMD: $[X] due by [Date]
CLOSING DATE: [Date]
TITLE COMPANY: [Name]

[Full agreement text with all clauses]

SIGNATURES:
____________________________    ____________________________
Assignor                        Assignee
Date: __________               Date: __________
```

## Example Prompts
- "Generate an assignment agreement: I'm assigning 123 Main St to John Smith for a $12K fee. Original price $85K, closing April 30."
- "Create assignment paperwork for my deal at 456 Oak. Buyer is ABC Investments LLC, $8,500 assignment fee."
- "Draft an assignment — need non-circumvent and as-is clauses, $15K fee, buyer putting up $2K EMD."

## Suggested Next Steps
1. **`/transactions/wholesale-tc`** — Run the closing checklist for this assignment
2. **`/dispositions/dispo-crm-updater`** — Log the buyer and assignment details
3. **`/deal-analysis/deal-pnl`** — Calculate your total profit on this deal
