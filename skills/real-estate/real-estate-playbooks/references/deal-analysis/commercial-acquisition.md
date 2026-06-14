---
name: Commercial Acquisition Analyzer
description: "Analyze commercial property acquisitions — retail, office, industrial, mixed-use. Cap rate, NOI, lease analysis, and tenant evaluation. Triggers on: commercial deal, commercial property, retail, office, industrial, commercial acquisition."
---

# Commercial Acquisition Analyzer

## Overview
Full analysis framework for commercial property acquisitions. Evaluates NOI quality, lease structure, tenant creditworthiness, and market positioning.

## When to Use
- Evaluating a commercial property for purchase
- Comparing commercial vs residential investments
- Analyzing a seller's offering memorandum
- Due diligence on commercial deal under contract

## Inputs
- Property type (retail, office, industrial, mixed-use)
- Address and size (sqft, units/suites)
- Asking price
- Rent roll with lease terms
- Operating expense breakdown (T-12 or T-3)
- Tenant information

## Process

### Step 1: Lease Analysis
For each tenant:
- Lease type (NNN, Modified Gross, Full Service)
- Rent per sqft
- Lease term and expiration
- Renewal options
- Rent escalations
- Tenant creditworthiness

### Step 2: Income and NOI
Calculate based on lease terms, not proforma assumptions.
Use T-12 (trailing 12 months) actuals when available.

### Step 3: Key Commercial Metrics
```
Cap Rate = NOI / Purchase Price
Price Per Sqft = Purchase Price / Rentable Sqft
DSCR = NOI / Debt Service
Breakeven Occupancy = (Expenses + Debt Service) / Gross Income
WALT = Weighted Average Lease Term
```

### Step 4: Risk Assessment
- Tenant concentration risk (one tenant = >50% income?)
- Lease rollover risk (multiple leases expiring soon?)
- Market risk (vacancy in submarket?)
- Capital risk (deferred maintenance?)

## Output Format
```
COMMERCIAL ANALYSIS — [Address]
═══════════════════════════════
Type: [Retail/Office/Industrial] | Sqft: [X] | Occupancy: [X]%
Price: $[X] | Per Sqft: $[X]

LEASE SUMMARY:
| Tenant | Sqft | Rent/sqft | Lease Type | Expires | % of Income |

FINANCIALS:
NOI: $[X] | Cap Rate: [X]% | DSCR: [X]x
WALT: [X] years | Breakeven: [X]% occupancy

RISKS: [List with severity]
VERDICT: [Buy / Negotiate / Pass]
```

## Example Prompts
- "Analyze this strip center: 5 tenants, asking $1.8M, NOI $144K, NNN leases."
- "Is this office building worth it? 80% occupied, 2 leases expire next year."

## Suggested Next Steps
1. **`/creative-finance/capital-stack`** — Structure the financing
2. **`/creative-finance/lender-package`** — Prepare lender submission
3. **`/deal-analysis/cap-rate-comp`** — Compare cap rate to market
