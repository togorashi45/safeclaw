---
name: Cap Rate Comparison
description: "Compare cap rates across properties or submarkets for rental and commercial investment analysis. Triggers on: cap rate, compare cap rates, cap rate by area, cap rate comparison."
---

# Cap Rate Comparison

## Overview
Compare capitalization rates across multiple properties or submarkets to identify the best risk-adjusted returns for rental and commercial investments.

## When to Use
- Comparing multiple rental/commercial acquisition targets
- Evaluating whether a market's cap rates justify investment
- Benchmarking a deal against submarket averages

## Inputs
- Properties to compare (address, price, NOI or rent/expenses)
- OR: Markets/submarkets to compare
- Property type (SFR rental, duplex, MF, commercial)

## Process

### Step 1: Calculate Cap Rate Per Property
```
Cap Rate = (Net Operating Income / Purchase Price) × 100
NOI = Gross Income - Operating Expenses (excluding debt service)
```

### Step 2: Pull Market Cap Rate Benchmarks
Research average cap rates for the property type in each submarket.

### Step 3: Compare and Rank

## Output Format
```
CAP RATE COMPARISON
═══════════════════
| Property/Market | Price | NOI | Cap Rate | vs Market Avg | Verdict |
|----------------|-------|-----|----------|---------------|---------|

Market Averages:
- [Market A]: [X]% avg cap rate for [property type]
- [Market B]: [X]% avg cap rate

ANALYSIS:
[Which properties/markets offer the best risk-adjusted returns and why]
```

## Example Prompts
- "Compare cap rates on these 3 duplexes I'm looking at: [details]"
- "What are average cap rates for SFR rentals in Lubbock vs Dallas vs San Antonio?"
- "This 4-plex is listed at $400K with $36K NOI. How does that cap rate compare to the market?"

## Suggested Next Steps
1. **`/deal-analysis/noi-analyzer`** — Deep dive on NOI accuracy
2. **`/deal-analysis/cash-flow-projector`** — Full cash flow with debt service
3. **`/deal-analysis/mf-underwriter`** — Full multifamily underwrite
