---
name: Multi-Entity Tax Prep
description: "Multi-entity tax preparation — entity structure review, inter-entity transactions, consolidated reporting, and entity-specific deductions. Triggers on: multi-entity tax, entity taxes, LLC taxes, holding company."
---

# Multi-Entity Tax Prep

## Overview
Organize tax preparation across multiple entities — LLCs, S-Corps, holding companies, and trusts. Maps inter-entity transactions, identifies entity-specific deductions, and generates a consolidated view for your CPA. Prevents missed deductions and ensures proper entity separation.

## When to Use
- Year-end tax prep with multiple entities
- Reviewing entity structure for tax efficiency
- Tracking inter-entity loans, management fees, or property transfers
- CPA asks for consolidated entity summary

## Inputs
- **All entities**: name, type (LLC, S-Corp, C-Corp, Trust), EIN, purpose
- **Entity relationships**: who owns what, management structure
- **Inter-entity transactions**: loans, fees, rent, transfers
- **Income and expenses by entity**
- **Properties held by each entity**

## Process

### Step 1: Entity Map
| Entity | Type | EIN | Purpose | Properties | Tax Filing |
|--------|------|-----|---------|-----------|------------|
| [Name] LLC | SMLLC | [X] | Wholesale operations | None | Sched C / disregarded |
| [Name] LLC | Multi-member | [X] | Rental holdings | 5 SFR | 1065 (partnership) |
| [Name] Inc | S-Corp | [X] | Management company | None | 1120S |
| [Name] Trust | Land trust | [X] | Title holding | 3 properties | Grantor trust |

### Step 2: Inter-Entity Transactions
| From | To | Type | Amount | Arm's Length? | Documentation |
|------|-----|------|--------|--------------|---------------|
| Mgmt S-Corp | Rental LLC | Management fee | $[X]/mo | Yes/No | Contract on file? |
| You personally | Flip LLC | Capital contribution | $[X] | N/A | Operating agreement |
| Rental LLC | You personally | Distribution | $[X] | N/A | K-1 |

### Step 3: Entity-Specific Deductions
**S-Corp specific**: reasonable salary, health insurance, retirement contributions
**LLC (disregarded)**: flows to personal return, SE tax on all income
**Partnership LLC**: K-1 allocations, special allocations, basis tracking
**Land trust**: no separate filing if grantor trust, property tax payments

### Step 4: Consolidated Summary
```
CONSOLIDATED TAX SUMMARY — [Year]
═══════════════════════════════════
Total Entities: [X]
Total Revenue (all entities):    $[X]
Total Expenses (all entities):   $[X]
Total Net Income:                $[X]
Inter-Entity Eliminations:       $[X]

BY ENTITY:
[Entity 1]: Revenue $[X] | Expenses $[X] | Net $[X]
[Entity 2]: Revenue $[X] | Expenses $[X] | Net $[X]

ESTIMATED TOTAL TAX LIABILITY:   $[X]
```

## Output Format
```
MULTI-ENTITY TAX PREP — [Year]
══════════════════════════════
[Entity map table]
[Inter-entity transactions]
[Entity-specific deductions]
[Consolidated summary]

CPA ACTION ITEMS:
1. [Items requiring CPA review]
```

## Example Prompts
- "Map my entity structure for taxes — I have a wholesale LLC, rental LLC, and S-Corp for management fees."
- "Track inter-entity transactions: my S-Corp charges $1,500/mo management fee to the rental LLC."
- "Consolidated tax summary across all 3 entities for 2025."

## Suggested Next Steps
1. **`/reporting/tax-prep`** — Individual entity tax prep detail
2. **`/reporting/monthly-pnl`** — P&L by entity
3. **`/reporting/financial-qa`** — Entity structure optimization questions
