---
name: NOI Analyzer
description: "Calculate and analyze Net Operating Income for rental and commercial properties. Break down income vs expenses and identify optimization opportunities. Triggers on: NOI, net operating income, income vs expenses, operating income, expense analysis."
---

# NOI Analyzer

## Overview
Deep analysis of Net Operating Income — the most important number in rental and commercial investing. Identifies where income can be increased and expenses reduced.

## When to Use
- Verifying seller-provided NOI on an acquisition
- Optimizing NOI on a property you own
- Comparing NOI across multiple properties
- Preparing for a refinance (lenders underwrite on NOI)

## Inputs
- Property details (address, units, type)
- Income sources (rent roll, other income)
- All operating expenses (itemized)
- Comparables for expense benchmarking (optional)

## Process

### Step 1: Income Analysis
Itemize all income sources and verify against market rates.

### Step 2: Expense Audit
Compare each expense line to industry benchmarks:
| Expense | Benchmark (% of EGI) |
|---------|---------------------|
| Property Taxes | Market-specific |
| Insurance | 2-5% |
| Management | 8-12% |
| Maintenance | 5-10% |
| Utilities (owner-paid) | 3-8% |
| CapEx Reserve | 3-7% |
| Total Expense Ratio | 35-55% |

Flag any line item significantly above benchmark.

### Step 3: Calculate and Optimize
```
Current NOI = EGI - Operating Expenses
Optimized NOI = EGI (with rent bumps) - Optimized Expenses
NOI Gap = Optimized - Current
Value Impact = NOI Gap / Market Cap Rate
```

## Output Format
```
NOI ANALYSIS — [Address]
════════════════════════
INCOME: $[X] (EGI)
EXPENSES: $[X] ([X]% ratio)
NOI: $[X]

EXPENSE AUDIT:
| Line Item | Actual | Benchmark | Flag |
|-----------|--------|-----------|------|

OPTIMIZATION OPPORTUNITIES:
1. [Opportunity] — Impact: +$[X]/year NOI
2. [Opportunity] — Impact: +$[X]/year NOI
Total NOI Improvement Potential: $[X]/year
Value Impact at [X]% cap: +$[X]
```

## Example Prompts
- "Verify the NOI on this 8-unit the seller says is $48K/year. Here's the rent roll and expenses."
- "Where can I improve NOI on my duplex? Current rents $2,400/mo, expenses $1,100/mo."

## Suggested Next Steps
1. **`/deal-analysis/value-add-opportunity`** — Plan to capture NOI improvements
2. **`/deal-analysis/mf-underwriter`** — Full underwrite with optimized NOI
3. **`/property-management/lease-renewal`** — Implement rent increases
