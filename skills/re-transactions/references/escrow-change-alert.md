---
name: Escrow Change Alert
description: "Monitor and manage escrow changes, EMD tracking, title commitment review, and wire fraud prevention for active deals. Triggers on: escrow, escrow change, title company, earnest money."
---

# Escrow Change Alert

## Overview
Track and manage all escrow-related changes on active deals. Covers earnest money deposit tracking, title commitment review, settlement statement verification, and wire fraud prevention. Catches changes that can derail closings.

## When to Use
- EMD status needs verification
- Title commitment received — need to review for issues
- Settlement statement / closing disclosure arrived — verify numbers
- Any change to title company, closing agent, or wire instructions
- Wire fraud prevention check before sending funds

## Inputs
- **Property address** and deal reference
- **Title company** name and closer contact
- **EMD amount** and delivery method
- **Change being tracked** — what's different from original terms
- **Wire instructions** (for verification)

## Process

### Step 1: EMD Tracking
| Item | Status |
|------|--------|
| EMD Amount | $[X] |
| Delivery Method | Wire / Check / Other |
| Delivered Date | [Date] |
| Receipt Confirmed | Yes / No |
| Held By | [Title Company] |
| Refundable? | Yes (until [date]) / No |

### Step 2: Title Commitment Review Checklist
- [ ] Property legal description matches contract
- [ ] Seller name matches contract (all parties)
- [ ] No unexpected liens or judgments
- [ ] No unreleased mortgages
- [ ] Tax status current (no delinquencies)
- [ ] No code violations or municipal liens
- [ ] Easements identified and acceptable
- [ ] HOA status letter obtained (if applicable)
- [ ] Title exceptions reviewed and acceptable
- [ ] Survey exceptions noted

### Step 3: Wire Fraud Prevention
**CRITICAL — Verify before sending any wire:**
- [ ] Wire instructions received directly from title company (not forwarded email)
- [ ] Phone number on wire instructions verified independently (not from the email)
- [ ] Called title company at known number to confirm instructions
- [ ] Account name matches title company / escrow agent
- [ ] No last-minute changes to wire instructions (RED FLAG)
- [ ] Email domain matches title company's known domain

### Step 4: Settlement Statement Verification
- [ ] Purchase price matches contract
- [ ] Assignment fee correct (if applicable)
- [ ] Proration calculations accurate (taxes, rent, HOA)
- [ ] Closing costs within expected range
- [ ] Credits applied correctly
- [ ] Net proceeds / amount due calculated correctly

## Output Format
```
ESCROW STATUS — [Property Address]
══════════════════════════════════
Title Company: [Name]
Closer: [Name] | [Phone] | [Email]

EMD STATUS:
  Amount: $[X] | Delivered: [Date] | Receipt: [Yes/No]

TITLE COMMITMENT: [Received/Pending]
  Issues Found: [None / List]

SETTLEMENT STATEMENT: [Received/Pending]
  Net to Seller: $[X]
  Net to Buyer: $[X] due at closing
  Assignment Fee: $[X]

WIRE FRAUD CHECK: [Verified/Pending]

ALERTS:
⚠️ [Any changes or issues flagged]
```

## Example Prompts
- "Check the escrow status on 123 Main — did title receive our EMD?"
- "Review the title commitment for 456 Oak — are there any liens?"
- "Verify wire instructions before I send closing funds — the title company emailed new instructions."
- "The settlement statement came in — verify the numbers match our contract."

## Suggested Next Steps
1. **`/transactions/wholesale-tc`** — Update overall closing checklist
2. **`/transactions/addendum-builder`** — Create addendum if terms need to change
3. **`/deal-analysis/deal-pnl`** — Verify final P&L against settlement statement
