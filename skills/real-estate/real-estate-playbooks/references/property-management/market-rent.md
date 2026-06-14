---
name: Market Rent Analyzer
description: "Determine market rent using comparable rental analysis — nearby rental comps, amenity adjustments, seasonal factors, and rent positioning strategy. Triggers on: market rent, what should I charge, rent comp, rental rate."
---

# Market Rent Analyzer

## Overview
Determine optimal rent pricing using comparable rental analysis. Pulls nearby rental comps, applies adjustments for differences, considers seasonal factors, and recommends a rent positioning strategy (at market, above, or below).

## When to Use
- Setting rent on a new rental acquisition
- Lease renewal — check if current rent is at market
- Vacancy — need to price competitively to fill fast
- Market has shifted — time to adjust?

## Inputs
- **Property address**
- **Beds/baths/sqft**
- **Property condition and features** (updated kitchen, garage, yard, etc.)
- **Current rent** (if renewal)
- **Vacancy tolerance** — how fast do you need it filled?
- **Target tenant profile** — Section 8, working professional, family, etc.

## Process

### Step 1: Pull Rental Comps
Search criteria: same bed/bath count, within 1 mile, listed in last 90 days
- Active listings (what's competing now)
- Recently rented (what actually leased and at what price)

### Step 2: Apply Adjustments
| Factor | Adjustment |
|--------|-----------|
| Sqft (per 100 sqft difference) | +/- $25-50 |
| Updated kitchen | +$50-100 |
| Updated bathrooms | +$25-50 |
| Garage | +$50-100 |
| Fenced yard | +$25-75 |
| In-unit washer/dryer | +$50-100 |
| Pool | +$25-75 |
| Pet-friendly | +$25-50 (premium for allowing pets) |
| Age/condition premium | +/- $50-150 |

### Step 3: Seasonal Adjustment
| Season | Adjustment | Reasoning |
|--------|-----------|-----------|
| Spring (Mar-May) | +3-5% | Peak rental season, high demand |
| Summer (Jun-Aug) | +2-4% | Families moving, school timing |
| Fall (Sep-Nov) | Baseline | Normal demand |
| Winter (Dec-Feb) | -3-5% | Low demand, faster fill at slight discount |

### Step 4: Rent Positioning Strategy
```
Below Market (-5%):  Fill fast, reduce vacancy, attract more applicants
At Market:           Standard positioning, balanced approach
Above Market (+5%):  Premium tenant, longer vacancy risk, higher yield
```

## Output Format
```
MARKET RENT ANALYSIS — [Property Address]
═════════════════════════════════════════
Subject: [Beds/Baths] | [Sqft] | [Features]

COMPS:
| # | Address | Beds/Ba | Sqft | Rent | $/sqft | Status | Adj Rent |
|---|---------|---------|------|------|--------|--------|----------|

ADJUSTED MARKET RENT RANGE:
  Low:  $[X]/mo
  Mid:  $[X]/mo
  High: $[X]/mo

RECOMMENDED RENT: $[X]/mo
POSITIONING: [Below/At/Above Market]
SEASONAL FACTOR: [Adjustment applied]

CURRENT RENT GAP: $[X] ([X]% below/above market)
```

## Example Prompts
- "What should I charge for rent at 123 Main — 3/2, 1,400 sqft, updated kitchen, fenced yard?"
- "Is $1,200 the right rent for my duplex unit? 2/1, 900 sqft, no garage."
- "I need to fill a vacancy fast — what's the competitive rent for a 3/2 in 75217?"

## Suggested Next Steps
1. **`/property-management/lease-renewal`** — Apply findings to renewal offer
2. **`/deal-analysis/cash-flow-projector`** — Project cash flow at recommended rent
3. **`/property-management/lease-generator`** — Generate lease at new rent amount
