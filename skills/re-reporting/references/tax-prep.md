---
name: Tax Prep Assistant
description: "Tax preparation helper — categorize expenses, identify deductions, flag audit triggers, and generate CPA-ready summaries. Triggers on: tax, deductions, write-offs, CPA, tax prep."
---

# Tax Prep Assistant

## Overview
Organize your RE investment business finances for tax preparation. Categorizes income and expenses into IRS-recognized categories, identifies commonly missed deductions, flags potential audit triggers, and generates a CPA-ready summary. Not tax advice — a preparation tool.

## When to Use
- Year-end tax prep (most common)
- Quarterly estimated tax planning
- Preparing for CPA meeting
- Reviewing deductions you might be missing

## Inputs
- **Tax year**
- **Entity structure** (sole prop, LLC, S-Corp, partnership)
- **Income sources**: deals closed, rental income, note income
- **Expenses**: by category or raw list to categorize
- **Assets**: properties purchased/sold, vehicles, equipment

## Process

### Step 1: Income Categorization
| Source | Amount | IRS Category | Form |
|--------|--------|-------------|------|
| Wholesale assignment fees | $[X] | Ordinary income | Sched C / 1065 |
| Flip profits | $[X] | Ordinary income (dealer) | Sched C / 1065 |
| Rental income (gross) | $[X] | Rental income | Sched E |
| Note interest income | $[X] | Interest income | 1099-INT / Sched B |
| Capital gains (property sale) | $[X] | Cap gains (if held >1 yr) | Sched D |

### Step 2: Expense Categories (Schedule C / Entity Return)
| Category | Amount | Common Items |
|----------|--------|-------------|
| Advertising/Marketing | $[X] | PPC, direct mail, signs, website |
| Car/Truck Expenses | $[X] | Mileage ($0.67/mi) or actual costs |
| Contract Labor | $[X] | VAs, cold callers, skip tracing |
| Insurance | $[X] | E&O, general liability, vehicle |
| Legal/Professional | $[X] | Attorney, CPA, bookkeeper |
| Office Expense | $[X] | Supplies, software, coworking |
| Rent/Lease | $[X] | Office space |
| Repairs/Maintenance | $[X] | Property repairs (not improvements) |
| Taxes/Licenses | $[X] | State/local taxes, business licenses |
| Travel | $[X] | Conferences, property visits, meals (50%) |
| Utilities | $[X] | Phone, internet |
| Home Office | $[X] | Simplified ($5/sqft, max $1,500) or actual |
| Education/Training | $[X] | Courses, coaching, books |
| Software/Subscriptions | $[X] | CRM, tools, data services |

### Step 3: RE-Specific Deductions Checklist
- [ ] **Depreciation** — rental properties (27.5 yr residential, 39 yr commercial)
- [ ] **Cost segregation** — accelerate depreciation on components (potential $10-50K+ year 1)
- [ ] **1031 exchange** — defer capital gains on investment property sales
- [ ] **Pass-through deduction (199A)** — 20% QBI deduction (income limits apply)
- [ ] **Bonus depreciation** — 40% in 2026 (step-down from 100%)
- [ ] **Self-employment tax** — deduct 50% of SE tax
- [ ] **Health insurance** — self-employed health insurance deduction
- [ ] **Retirement contributions** — SEP-IRA, Solo 401(k)
- [ ] **Entity election optimization** — S-Corp election to reduce SE tax

### Step 4: Audit Trigger Flags
- Home office deduction >$1,500 (increased scrutiny)
- Meals/entertainment >10% of revenue
- Vehicle 100% business use (rare for sole props)
- Large losses against W-2 income (passive activity rules)
- Cash transactions >$10K
- Hobby loss rules (3 of 5 years must be profitable)

### Step 5: CPA-Ready Summary
```
TAX PREP SUMMARY — [Year]
Entity: [Name] — [Type]
EIN: [X]

INCOME:
[Category totals]
TOTAL INCOME: $[X]

EXPENSES:
[Category totals]
TOTAL EXPENSES: $[X]

NET INCOME (before depreciation): $[X]
DEPRECIATION: $[X]
NET TAXABLE INCOME: $[X]

ESTIMATED TAX (at [X]% effective rate): $[X]

DEDUCTIONS TO DISCUSS WITH CPA:
- [List items needing CPA guidance]
```

## Example Prompts
- "Help me prep taxes — I did 12 wholesale deals, have 3 rentals, and spent $28K on marketing this year."
- "What deductions am I probably missing as a real estate investor?"
- "Categorize these expenses for my CPA: $3K cold calling, $5K direct mail, $1.2K skip tracing, $2K Podio."
- "Should I do a cost segregation study on my rental I bought for $185K?"

## Suggested Next Steps
1. **`/reporting/tax-prep-multi-entity`** — If you have multiple LLCs/entities
2. **`/reporting/monthly-pnl`** — Full year P&L to support tax prep
3. **`/reporting/financial-qa`** — Ask specific tax strategy questions
