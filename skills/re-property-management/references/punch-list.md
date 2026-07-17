---
name: Punch List Generator
description: "Generate renovation/turnover punch lists — room-by-room items, contractor assignment, cost estimates, completion tracking, and quality verification. Triggers on: punch list, final walkthrough, fix list, turnover checklist."
---

# Punch List Generator

## Overview
Create detailed punch lists for property turnovers, rehab projects, and final walkthroughs. Organizes items by room and trade, assigns contractors, estimates costs, and tracks completion. Ensures nothing gets missed before listing or closing.

## When to Use
- Turning a unit between tenants
- Final walkthrough on a rehab/flip
- Pre-listing preparation
- Contractor accountability tracking

## Inputs
- **Property address**
- **Context** — turnover, rehab, final walkthrough, pre-listing
- **Scope** — cosmetic only, full rehab, specific rooms
- **Items found** — from inspection or walkthrough
- **Available contractors/trades**
- **Budget**

## Process

### Step 1: Document Items by Room and Trade

| Room | Item | Trade | Priority | Est Cost | Assigned | Status |
|------|------|-------|----------|----------|----------|--------|
| Kitchen | Replace faucet | Plumber | High | $250 | | Pending |
| Kitchen | Paint walls | Painter | Medium | $300 | | Pending |
| Bath 1 | Re-caulk tub | Handyman | High | $75 | | Pending |
| Exterior | Power wash | Handyman | Low | $200 | | Pending |

### Step 2: Group by Trade for Efficiency
```
PLUMBER: [items]  — Est total: $[X]
ELECTRICIAN: [items] — Est total: $[X]
PAINTER: [items] — Est total: $[X]
HANDYMAN: [items] — Est total: $[X]
FLOORING: [items] — Est total: $[X]
HVAC: [items] — Est total: $[X]
```

### Step 3: Sequencing
1. Demo/haul (if any)
2. Rough trades (plumbing, electrical, HVAC)
3. Drywall/patching
4. Paint
5. Flooring
6. Fixtures/hardware
7. Appliances
8. Final clean
9. Touch-ups
10. Final walkthrough

### Step 4: Track Completion
Each item: Pending → In Progress → Complete → Verified

## Output Format
```
PUNCH LIST — [Property Address]
═══════════════════════════════
Context: [Turnover/Rehab/Pre-listing]
Date: [Date]
Items: [X] total | [X] complete | [X] remaining

[Room-by-room table with all items]

BUDGET SUMMARY:
Estimated: $[X]
Actual:    $[X]
Remaining: $[X]

COMPLETION: [X]%
TARGET DATE: [Date]
```

## Example Prompts
- "Create a turnover punch list for 123 Main — tenant moved out, unit needs paint, carpet cleaning, faucet repair, and deep clean."
- "Generate a final walkthrough punch list for my flip — what should I check before listing?"
- "Update the punch list — painter finished all rooms, plumber coming Thursday."

## Suggested Next Steps
1. **`/property-management/materials-list`** — Generate BOM for punch list items
2. **`/property-management/work-order`** — Convert punch list items to work orders
3. **`/property-management/move-in-out-inspection`** — Final inspection before new tenant
