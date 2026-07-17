---
name: Lease Renewal Manager
description: "Manage lease renewals — market rent comparison, rent increase calculation, renewal letter generation, and counter-offer handling. Triggers on: renew lease, lease renewal, extend lease, renewal terms."
---

# Lease Renewal Manager

## Overview
Manage the lease renewal process from analysis to execution. Compares current rent to market, calculates appropriate increase, generates renewal offers, and handles counter-negotiations. Keeps good tenants while maximizing rental income.

## When to Use
- Lease expiration approaching (60-90 days out)
- Tenant asks about renewal terms
- Evaluating whether to renew or turn the unit
- Market rents have shifted — need to adjust

## Inputs
- **Tenant name** and property address
- **Current rent** and lease expiration date
- **Current market rent** for comparable units (or ask to run market rent analysis)
- **Tenant quality** — payment history, property care, complaints
- **Local rent increase limits** (rent control areas)
- **Desired outcome** — maximize rent, retain tenant, or both

## Process

### Step 1: Market Analysis
```
Current Rent:          $[X]/month
Market Rent (comps):   $[X]/month
Gap:                   $[X] ([X]%)
Tenant Since:          [Date] ([X] years)
Payment History:       [On-time % / late count]
```

### Step 2: Rent Increase Calculation
| Strategy | Increase | New Rent | Risk Level |
|----------|----------|----------|------------|
| Aggressive (to market) | [X]% | $[X] | High turnover risk |
| Moderate (split the gap) | [X]% | $[X] | Balanced |
| Conservative (CPI + 1-2%) | [X]% | $[X] | Low risk, retains tenant |
| Hold (good tenant retention) | 0% | $[X] | No risk |

**Turnover Cost Estimate:**
```
Vacancy (avg 30 days):     $[rent/month]
Turnover repairs/cleaning: $500-2,000
Marketing/showing time:    $200-500
Total turnover cost:       $[X]
Months to recoup increase: [X]
```

### Step 3: Generate Renewal Letter
- Professional tone
- Current lease expiration reference
- Proposed new terms (rent, term length, any changes)
- Required notice period compliance
- Response deadline
- Contact information

### Step 4: Counter-Offer Handling
If tenant pushes back, options:
- Split the difference
- Offer longer term for lower increase
- Add value (minor upgrade) instead of reducing increase
- Month-to-month at higher rate vs fixed at lower rate

## Output Format
```
LEASE RENEWAL ANALYSIS — [Property/Unit]
════════════════════════════════════════
Tenant: [Name] | Since: [Date]
Current Rent: $[X] | Market: $[X] | Gap: [X]%
Lease Expires: [Date]

RECOMMENDATION: [Strategy] — $[X]/mo ([X]% increase)

RENEWAL LETTER DRAFT:
[Full letter text]

TURNOVER COST IF TENANT LEAVES: $[X]
BREAKEVEN ON INCREASE: [X] months
```

## Example Prompts
- "Lease expires June 30 — current rent $1,200, market is $1,400. Good tenant, always pays on time. What should I do?"
- "Generate a renewal letter — raising rent from $1,350 to $1,425, new 12-month term."
- "Tenant countered my $100 increase, wants to stay at current rent. Options?"

## Suggested Next Steps
1. **`/property-management/market-rent`** — Pull current market rent comps
2. **`/property-management/tenant-communication`** — Draft the renewal communication
3. **`/property-management/lease-generator`** — Generate the new lease
