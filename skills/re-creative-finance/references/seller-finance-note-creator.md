---
name: Seller Finance Note Creator
description: "Draft promissory notes for seller-financed deals — terms, rate, payments, maturity, late fees, default provisions, acceleration, and prepayment. Triggers on: create note, promissory note, seller carry note."
---

# Seller Finance Note Creator

## Overview
Generate promissory notes for seller-financed real estate transactions. Includes all standard provisions: payment terms, interest rate, late fees, default/acceleration, prepayment rights, and security instrument reference. The note is the promise to pay; the deed of trust/mortgage is the security.

## When to Use
- Closing a seller-financed deal — need the note
- Restructuring an existing seller finance arrangement
- Creating a wrap note
- Documenting a private money loan

## Inputs
- **Borrower name(s) and entity**
- **Lender/Note holder** (seller or your entity)
- **Principal amount**
- **Interest rate** (fixed or adjustable)
- **Monthly payment amount**
- **First payment date and due day**
- **Maturity date** (or balloon date)
- **Late fee** structure
- **Prepayment terms** (penalty or free)
- **Property address** (collateral)
- **Security instrument** — Deed of Trust or Mortgage

## Process

### Step 1: Calculate Payment Schedule
```
Principal:        $[X]
Rate:             [X]% fixed
Monthly P&I:      $[X]
First Payment:    [Date]
Maturity:         [Date]
Balloon (if any): $[X] due [Date]
Total Payments:   [X]
Total Interest:   $[X]
```

### Step 2: Note Provisions
1. **Promise to Pay** — Amount, payee
2. **Interest Rate** — Fixed/variable, calculation method
3. **Payment Terms** — Amount, due date, where to send
4. **Late Charge** — Amount/percentage, grace period (typically 10-15 days)
5. **Default** — What constitutes default (missed payment, insurance lapse, tax delinquency)
6. **Acceleration** — Right to demand full balance upon default
7. **Prepayment** — Allowed without penalty / with penalty (specify)
8. **Security** — Reference to Deed of Trust/Mortgage
9. **Due on Sale** — Transfer triggers acceleration (optional)
10. **Escrow** — Taxes and insurance escrow requirements
11. **Governing Law** — State
12. **Signatures** — All borrowers sign

### Step 3: Generate Document

## Output Format
```
PROMISSORY NOTE
═══════════════
Date: [Date]
Principal: $[X]
Rate: [X]%
Maturity: [Date]

Borrower: [Name]
Lender: [Name]
Property: [Address]

[Full note text with all provisions]

Borrower Signature: _____________ Date: _______
```

## Example Prompts
- "Create a promissory note: $135K at 5%, 30-year am, 5-year balloon, $725/mo, first payment June 1."
- "Draft a note for my seller finance deal — $200K, 4.5%, no balloon, 20-year term."
- "Generate a wrap note — $165K at 8%, payments $1,210/mo, underlying is $120K at 3.5%."

## Suggested Next Steps
1. **`/creative-finance/seller-finance-clauses`** — Add special protective clauses
2. **`/creative-finance/dodd-frank-dti`** — Verify compliance before finalizing
3. **`/creative-finance/wrap-payment-manager`** — Set up payment tracking if wrap
