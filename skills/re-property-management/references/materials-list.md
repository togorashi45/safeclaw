---
name: Materials List Generator
description: "Generate materials and supplies lists for rehabs — bill of materials by room, quantity calculator, budget tracking, and vendor recommendations. Triggers on: materials, supplies, what to buy, rehab materials, BOM."
---

# Materials List Generator

## Overview
Generate detailed bills of materials (BOM) for rehab projects, turnovers, and repairs. Organized by room and trade, with quantity estimates, cost projections, and budget vs actual tracking.

## When to Use
- Planning a rehab — need to estimate material costs
- Turnover prep — what supplies to order
- Contractor is asking for materials list
- Comparing material costs across vendors

## Inputs
- **Property address** and scope (full rehab, cosmetic, turnover)
- **Rooms/areas** included in scope
- **Quality level** — investor grade (B), mid-range (B+), high-end (A)
- **Specific items needed** or general scope description
- **Sqft** for flooring, paint, and other area-based calculations

## Process

### Step 1: Scope Assessment by Room

### Step 2: Generate BOM

| Category | Item | Qty | Unit | Unit Cost | Total | Vendor |
|----------|------|-----|------|-----------|-------|--------|
| Paint | Interior latex (5 gal) | [X] | bucket | $[X] | $[X] | |
| Flooring | LVP planks | [X] | sqft | $[X] | $[X] | |
| Kitchen | Faucet | 1 | ea | $[X] | $[X] | |
| Bath | Toilet | [X] | ea | $[X] | $[X] | |

### Step 3: Quantity Calculators
```
PAINT: (Total wall sqft ÷ 350) = gallons needed + 10% waste
FLOORING: (Room sqft × 1.10) = sqft to order (10% waste factor)
TILE: (Wall/floor sqft × 1.15) = sqft to order (15% waste for cuts)
DRYWALL: (Wall sqft ÷ 32) = 4x8 sheets needed
```

### Step 4: Budget Summary
```
Category Totals:
  Paint/Supplies:  $[X]
  Flooring:        $[X]
  Kitchen:         $[X]
  Bathroom(s):     $[X]
  Electrical:      $[X]
  Plumbing:        $[X]
  Hardware:        $[X]
  Exterior:        $[X]
  Misc/Contingency (10%): $[X]
  
TOTAL MATERIALS: $[X]
```

## Output Format
```
MATERIALS LIST — [Property Address]
═══════════════════════════════════
Scope: [Full Rehab / Cosmetic / Turnover]
Quality: [Investor Grade / Mid-Range / High-End]

[Full BOM table by room/category]

BUDGET SUMMARY: $[X] total materials
CONTINGENCY (10%): $[X]
GRAND TOTAL: $[X]
```

## Example Prompts
- "Generate a materials list for a cosmetic rehab — 3/2, 1,400 sqft. New paint, LVP flooring throughout, update both bathrooms."
- "What materials do I need for a kitchen update? New counters, faucet, hardware, paint."
- "Full rehab BOM for my flip at 123 Main — 1,800 sqft, investor grade finishes."

## Suggested Next Steps
1. **`/property-management/punch-list`** — Match materials to punch list items
2. **`/deal-analysis/deal-pnl`** — Factor materials into deal P&L
3. **`/property-management/work-order`** — Create work orders for installation
