---
name: Move-In/Out Inspection
description: "Generate property condition inspection reports — room-by-room checklist, condition ratings, damage assessment, and deposit deduction calculations. Triggers on: inspection, move-in, move-out, condition report, walkthrough."
---

# Move-In/Out Inspection

## Overview
Create detailed property condition reports for move-in and move-out inspections. Room-by-room checklist with condition ratings, photo documentation guide, and deposit deduction calculations. Protects against disputes and documents property state.

## When to Use
- New tenant moving in — document baseline condition
- Tenant moving out — assess damage vs normal wear
- Mid-lease inspection (if permitted by lease)
- Pre-acquisition inspection for rental properties

## Inputs
- **Property address and unit**
- **Inspection type** — move-in or move-out
- **Tenant name**
- **Date of inspection**
- **Move-in report** (for comparison on move-out)
- **Security deposit amount** (for deduction calculations)

## Process

### Step 1: Room-by-Room Inspection

**Rating Scale:** 1 = Poor/Damaged, 2 = Fair/Worn, 3 = Good, 4 = Excellent/New

For each room, inspect:

| Item | Rating (1-4) | Notes | Photo # |
|------|-------------|-------|---------|
| Walls/Paint | | | |
| Ceiling | | | |
| Flooring | | | |
| Windows/Screens | | | |
| Doors/Locks | | | |
| Light Fixtures | | | |
| Outlets/Switches | | | |
| Closets | | | |

**Rooms to inspect:** Living room, Kitchen, Bedrooms (each), Bathrooms (each), Dining room, Hallways, Garage, Exterior/Yard, HVAC closet, Laundry area

**Kitchen-specific:** Countertops, Cabinets, Sink/Faucet, Appliances (each), Hood/Vent
**Bathroom-specific:** Tub/Shower, Toilet, Vanity, Mirror, Tile/Grout, Exhaust fan

### Step 2: Systems Check
- [ ] HVAC — runs, filter condition, thermostat
- [ ] Water heater — working, no leaks
- [ ] Plumbing — all faucets, toilets, drains
- [ ] Electrical — all outlets, switches, GFCI
- [ ] Smoke detectors — present and working
- [ ] CO detectors — present and working
- [ ] Exterior — siding, gutters, foundation visible issues

### Step 3: Move-Out Damage Assessment (Move-Out Only)
| Item | Move-In Condition | Move-Out Condition | Normal Wear? | Deduction |
|------|------------------|-------------------|-------------|-----------|
| | | | Yes/No | $[X] |

**Normal Wear vs Damage Guide:**
| Normal Wear (No Deduction) | Damage (Deductible) |
|---------------------------|---------------------|
| Minor scuffs on walls | Holes in walls larger than nail holes |
| Faded paint | Unauthorized paint colors |
| Worn carpet in traffic areas | Stains, burns, pet damage to carpet |
| Loose door handles | Broken doors/locks |
| Minor scratches on counters | Burns, chips, cracks |

### Step 4: Deposit Deduction Calculation (Move-Out Only)
```
Security Deposit:              $[X]
Total Deductions:              $[X]
  - [Item]: $[X]
  - [Item]: $[X]
Refund Due to Tenant:          $[X]
Refund Due By:                 [Date per state law]
```

## Output Format
```
PROPERTY INSPECTION REPORT
══════════════════════════
Type: [MOVE-IN / MOVE-OUT]
Property: [Address/Unit]
Tenant: [Name]
Date: [Date]
Inspector: [Name]

[Room-by-room ratings and notes]

SYSTEMS: [All pass / Issues noted]

OVERALL CONDITION: [Excellent/Good/Fair/Poor]

[MOVE-OUT ONLY]
DEPOSIT RECONCILIATION:
Deposit held: $[X]
Deductions: $[X]
Refund: $[X]

PHOTOS: [X] photos taken and filed
```

## Example Prompts
- "Create a move-in inspection for 123 Main St Unit B — new tenant Sarah moves in May 1."
- "Run a move-out inspection — tenant leaving April 30, I need to calculate deposit deductions."
- "Compare move-in vs move-out condition to figure out what to charge the outgoing tenant."

## Suggested Next Steps
1. **`/property-management/punch-list`** — Generate repair list from inspection findings
2. **`/property-management/tenant-onboarding`** — Prepare move-in package (if move-in)
3. **`/property-management/work-order`** — Create work orders for needed repairs
