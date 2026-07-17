---
name: Daily MLS Feed
description: "Pull and filter daily new MLS listings matching investor buy criteria — price, area, condition, deal type. Surfaces deals before competition. Triggers on: MLS feed, new listings, daily listings, MLS alerts, what's new on market."
---

# Daily MLS Feed

## Overview
Daily scan of new MLS listings filtered to investor-relevant criteria. Catches underpriced listings, motivated seller signals, and opportunities before other investors see them.

## When to Use
- Every morning as part of daily briefing
- When actively looking for deals in specific markets
- Monitoring new inventory in target zip codes

## Inputs
- Target zip codes or city/market
- Max price or price range
- Property type (SFR, duplex, MF, commercial)
- Minimum beds/baths
- Keywords to flag (motivated, estate, as-is, investor, handyman, fixer)
- Deal type interest (flip, BRRRR, wholesale, creative finance)

## Process

### Step 1: Pull New Listings (Last 24 Hours)
Search Redfin, Zillow, Realtor.com for new listings posted in the last 24 hours matching base criteria.

### Step 2: Apply Investor Filters
Flag listings with:
- Below median price for the zip by 15%+
- Keywords in description: "as-is", "estate", "motivated", "investor", "cash only", "handyman special", "needs work", "priced to sell"
- Days on market = 0-1 (just listed)
- Price per sqft below area average

### Step 3: Quick Analysis
For each flagged listing, estimate:
- ARV range (based on area $/sqft for updated condition)
- Potential spread (ARV minus list price minus estimated rehab)
- Deal type suitability (flip, BRRRR, wholesale, hold)

### Step 4: Prioritize and Alert

## Output Format
```
DAILY MLS FEED — [Date] — [Market]
═══════════════════════════════════
New Listings: [X] | Investor-Relevant: [X] | Hot Deals: [X]

HOT DEALS (Act Today):
1. [Address] — $[Price] | [Beds/Baths] | [Sqft] | Est. ARV: $[X] | Spread: $[X]
   Signal: [why it's hot]

WORTH A LOOK:
1. [Address] — $[Price] | [Beds/Baths] | Quick take: [analysis]

MARKET PULSE:
- New listings today: [X] (vs [X] avg)
- Median list price: $[X]
- Inventory trend: [rising/falling/flat]
```

## Example Prompts
- "Pull today's new listings in 75217, 75216, 75215 Dallas under $200K."
- "What hit the MLS overnight in Lubbock? Flag anything that looks like a deal."
- "Show me new listings with 'as-is' or 'estate' in the description in my target zips."

## Suggested Next Steps
1. **`/deal-analysis/comp-pull`** — Pull comps on any hot deals
2. **`/deal-analysis/arv-calculator`** — Get precise ARV on promising properties
3. **`/lead-generation/agent-outreach`** — Contact listing agent on off-market potential
