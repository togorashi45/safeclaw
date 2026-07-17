---
name: Double Close Compliance
description: "Structure and manage double (simultaneous) closings with compliance checklists, transactional funding requirements, and A-B / B-C coordination. Triggers on: double close, simultaneous close, back-to-back closing."
---

# Double Close Compliance

## Overview
Structure compliant double closings (simultaneous closes) where you buy from the seller (A-B) and sell to the end buyer (B-C) on the same day or within a few days. Covers transactional funding, title company coordination, and compliance requirements to avoid deal blowups.

## When to Use
- Assignment fee is large and you don't want to disclose it
- Seller or buyer contract prohibits assignment
- HUD/REO/bank-owned properties that don't allow assignments
- You want cleaner optics on title chain

## Inputs
- **A (Seller)** — name, property, sale price
- **B (You/Entity)** — name/entity
- **C (End Buyer)** — name, purchase price
- **A-B contract details** — price, closing date, title company
- **B-C contract details** — price, closing date
- **Transactional funding** — needed? Lender identified?
- **Title company** — confirmed double-close friendly?

## Process

### Step 1: Deal Structure Analysis
```
A-B Transaction (Your Purchase):
  Seller (A):          [Name]
  Buyer (B):           [Your Entity]
  Purchase Price:      $[X]
  Closing Costs (est): $[X]

B-C Transaction (Your Sale):
  Seller (B):          [Your Entity]
  Buyer (C):           [Name]
  Sale Price:          $[X]
  Closing Costs (est): $[X]

SPREAD: $[B-C Price] - $[A-B Price] - $[Total Closing Costs] = $[Profit]
```

### Step 2: Transactional Funding Assessment
| Scenario | Funding Needed? |
|----------|----------------|
| C's funds can be used to close A-B (wet funding state) | No — but verify with title company |
| Dry funding state or title company requires separate funds | Yes — transactional lender needed |
| Same-day close, both transactions funded independently | No |
| Close A-B first, B-C next day | Yes — need to fund A-B independently |

**Transactional Funding Costs:**
```
Typical fee: 1-2% of A-B purchase price
Minimum fee: $500-1,500
Duration: 1-3 days
Required docs: A-B contract, B-C contract, proof of C's funds/financing
```

### Step 3: Title Company Coordination Checklist
- [ ] Title company confirmed double-close friendly
- [ ] Separate closing files for A-B and B-C
- [ ] Separate HUD-1/CD for each transaction
- [ ] Title company understands funding sequence
- [ ] Both closings scheduled (same day preferred)
- [ ] Wire instructions prepared for both transactions
- [ ] Title insurance for both transactions ordered

### Step 4: Compliance Checklist
- [ ] Both contracts are independent and valid
- [ ] No seasoning requirements violated (if C is using financing)
- [ ] Proper entity used (B entity consistent on both contracts)
- [ ] All disclosures made as required by state law
- [ ] No commingling of funds between A-B and B-C
- [ ] Title clears between transactions
- [ ] Recording of A-B deed before or simultaneous with B-C
- [ ] Anti-fraud documentation in place

### Step 5: Timeline Management
```
Day 1: A-B closing (morning) → Record deed → B-C closing (afternoon)
  OR
Day 1: A-B closing → Day 2-3: B-C closing (if seasoning needed)
```

## Output Format
```
DOUBLE CLOSE STRUCTURE — [Property Address]
════════════════════════════════════════════
A-B TRANSACTION:
  Seller → You:    $[X]
  Closing Costs:   $[X]
  
B-C TRANSACTION:
  You → Buyer:     $[X]
  Closing Costs:   $[X]

NET PROFIT:        $[X]

TRANSACTIONAL FUNDING: [Yes/No]
  Lender: [Name]
  Fee:    $[X]

TIMELINE:
  A-B Close: [Date/Time]
  B-C Close: [Date/Time]

COMPLIANCE CHECKLIST: [X/11 items complete]

RISKS/FLAGS:
- [Any issues identified]
```

## Example Prompts
- "Structure a double close: buying at $75K, selling at $110K, same day. Need transactional funding?"
- "Run the compliance checklist for my double close at 123 Main — A-B closes Monday, B-C Tuesday."
- "My end buyer is using FHA financing — can I still double close? What are the seasoning issues?"

## Suggested Next Steps
1. **`/transactions/wholesale-tc`** — Run closing checklists for both A-B and B-C
2. **`/deal-analysis/deal-pnl`** — Calculate net profit after all closing costs
3. **`/transactions/purchase-agreement`** — Generate the B-C contract
