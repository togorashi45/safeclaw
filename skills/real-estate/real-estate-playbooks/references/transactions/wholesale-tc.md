---
name: Wholesale Transaction Coordinator
description: "Step-by-step closing checklist for wholesale deals from contract to close — document tracking, deadline management, and coordination. Triggers on: transaction coordinator, TC checklist, closing checklist, wholesale closing."
---

# Wholesale Transaction Coordinator

## Overview
Manage the complete wholesale transaction from executed contract to closed deal. Tracks every document, deadline, and communication needed to get to the closing table. Prevents deals from falling apart due to missed steps or deadlines.

## When to Use
- Just got a contract signed — need to manage through closing
- Checking status on an active deal — what's done, what's outstanding
- Coordinating between seller, buyer, and title company
- Deal is getting close to closing date — final verification

## Inputs
- **Property address**
- **Seller name and contact**
- **Buyer name and contact** (end buyer or assignee)
- **Title company** name and contact
- **Key dates** — contract date, option expiration, closing date
- **Deal type** — assignment or double close
- **Contract price and assignment fee / spread**

## Process

### Step 1: Immediate Post-Contract (Days 1-2)
- [ ] Executed contract scanned and filed
- [ ] Earnest money delivered to title company
- [ ] EMD receipt obtained from title company
- [ ] Title company has full copy of contract
- [ ] Option fee delivered (if applicable, TX)
- [ ] Title ordered
- [ ] Deal entered in CRM (GHL)
- [ ] Seller notified of title company contact info
- [ ] Begin marketing to buyers (if not already assigned)

### Step 2: Due Diligence Period (Days 2-7)
- [ ] Property access confirmed for inspections
- [ ] Inspection scheduled or completed
- [ ] Comps pulled / ARV verified
- [ ] Rehab estimate finalized
- [ ] Photos taken for buyer marketing
- [ ] Buyer identified and under assignment contract
- [ ] Assignment agreement executed (if assigning)
- [ ] Buyer's EMD collected

### Step 3: Title and Closing Prep (Days 7-14)
- [ ] Title commitment received and reviewed
- [ ] No title issues / clouds cleared
- [ ] Survey reviewed (if applicable)
- [ ] Closing date confirmed with all parties
- [ ] Closing disclosure / settlement statement drafted
- [ ] Wire instructions verified (fraud prevention)
- [ ] Buyer's financing confirmed (if not cash)
- [ ] All addenda and amendments sent to title

### Step 4: Pre-Closing (3-5 Days Before)
- [ ] Final settlement statement reviewed — numbers correct
- [ ] Assignment fee on settlement statement (or separate check)
- [ ] Seller confirmed for closing (date, time, location)
- [ ] Buyer confirmed for closing
- [ ] ID requirements communicated to all parties
- [ ] Power of Attorney filed (if applicable)
- [ ] Utility transfer information provided to buyer

### Step 5: Closing Day
- [ ] All parties present or docs signed remotely
- [ ] Settlement statement signed
- [ ] Deed signed and notarized
- [ ] Funds disbursed
- [ ] Assignment fee received (wire or check)
- [ ] Keys transferred
- [ ] Deed recorded with county

### Step 6: Post-Closing
- [ ] Confirm deed recorded
- [ ] File all closing documents
- [ ] Update CRM — deal marked CLOSED
- [ ] Update mind/active-deals.md
- [ ] Send thank you to seller
- [ ] Buyer follow-up (ask for referrals)
- [ ] Calculate and log final P&L
- [ ] Profit deposited / accounted for

## Output Format
```
WHOLESALE TC CHECKLIST — [Property Address]
════════════════════════════════════════════
Seller: [Name]        Buyer: [Name]
Title Co: [Name]      Closer: [Name]
Type: [Assignment / Double Close]

KEY DATES:
  Contract Date:      [Date]
  Option Expires:     [Date]
  Closing Date:       [Date]
  Days Remaining:     [X]

FINANCIALS:
  Purchase Price:     $[X]
  Assignment Fee:     $[X] (or Spread: $[X])
  Buyer's Price:      $[X]

PROGRESS: [X/35 items complete]

OUTSTANDING ITEMS:
⚠️ [Item 1] — Due by [Date]
⚠️ [Item 2] — Due by [Date]

NEXT ACTION: [Most urgent outstanding item]
```

## Example Prompts
- "Start a TC checklist for my deal at 123 Main — just got the contract signed today, closing May 1."
- "What's left to do on the 456 Oak deal? Closing is next Friday."
- "Run the pre-closing checklist — my deal closes in 3 days."

## Suggested Next Steps
1. **`/transactions/assignment-agreement`** — Generate assignment if not done
2. **`/transactions/escrow-change-alert`** — Track escrow and title changes
3. **`/deal-analysis/deal-pnl`** — Calculate final P&L at closing
