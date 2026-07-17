---
name: Expired Listings Hunter
description: "Find expired and withdrawn MLS listings as motivated seller leads. Filter by equity, days on market, price drops, and area. Triggers on: expired listings, find expireds, MLS expired, expired leads, withdrawn listings."
---

# Expired Listings Hunter

## Overview
Expired listings are one of the highest-converting lead sources for investors. These sellers already tried to sell, failed, and may be open to a cash offer below market. This skill identifies and scores expired listings in target areas.

## When to Use
- Building a targeted lead list for outreach campaigns
- Looking for motivated sellers with failed listings
- Supplementing other lead sources with high-intent prospects

## Inputs
- Target zip codes, city, or county
- Minimum days listed before expiration (default: 60)
- Minimum equity threshold (default: 20%)
- Property type filter (SFR, MF, land)
- Price range
- Number of price reductions (optional filter)

## Process

### Step 1: Search for Expired/Withdrawn Listings
Search MLS-derived sources (Redfin, Zillow, Realtor.com) for:
- Status: Expired, Withdrawn, Cancelled
- Date: Expired within last 90 days
- Area: Within specified zip codes/city

### Step 2: Filter and Score
Score each listing:
- Multiple price reductions: +20 pts
- DOM > 120 days: +15 pts
- Estimated equity > 30%: +15 pts
- Vacant property: +10 pts
- Absentee owner: +10 pts
- Previously expired (listed multiple times): +20 pts

### Step 3: Enrich with Owner Data
For top-scoring leads, identify:
- Owner name and mailing address
- Estimated mortgage balance
- Tax status (delinquent?)
- Other properties owned

### Step 4: Generate Lead List

## Output Format
```
EXPIRED LISTINGS — [Area] — [Date]
═══════════════════════════════════
Total Found: [X] | Filtered: [X] | High Priority: [X]

| # | Address | Listed Price | DOM | Reductions | Est. Equity | Score | Priority |
|---|---------|-------------|-----|------------|-------------|-------|----------|
| 1 | [addr]  | $X          | X   | X          | X%          | X/100 | HIGH     |

RECOMMENDED OUTREACH ORDER:
1. [Address] — [why this one first]
2. [Address] — [why]
```

## Example Prompts
- "Find expired listings in 75217 Dallas from the last 60 days with at least 25% equity."
- "Pull all expired and withdrawn SFR listings in Lubbock TX, sort by days on market."
- "How many listings expired in Denver last month? Give me the top 20 by score."

## Suggested Next Steps
1. **`/lead-generation/cold-caller`** — Generate scripts to call these sellers
2. **`/marketing/postcard-mailer`** — Design a mailer campaign for the list
3. **`/lead-generation/adaptive-follow-up`** — Set up multi-touch follow-up sequence
