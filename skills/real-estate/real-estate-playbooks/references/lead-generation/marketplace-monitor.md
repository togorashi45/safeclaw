---
name: Marketplace Monitor
description: "Monitor Facebook Marketplace, Craigslist, and FSBO sites for motivated seller listings. Score and alert on matches. Triggers on: marketplace, facebook marketplace, craigslist, FSBO, monitor listings, for sale by owner."
---

# Marketplace Monitor

## Overview
Scan online marketplaces for FSBO and motivated seller listings. These sellers are often less sophisticated and more open to investor offers since they're avoiding agent commissions.

## When to Use
- Daily monitoring of marketplace for new FSBO listings
- Looking for deals outside MLS
- Targeting FSBO sellers for direct outreach
- Supplementing other lead gen channels

## Inputs
- Target area (city, zip codes)
- Property type (house, duplex, land, mobile home)
- Price range
- Keywords to flag (motivated, must sell, estate, as-is, below market, cash)

## Process

### Step 1: Define Search Parameters
Set up monitoring for:
- Facebook Marketplace → Housing → For Sale
- Craigslist → Housing → Real Estate By Owner
- FSBO.com, ForSaleByOwner.com
- Zillow FSBO filter
- Local classified sites

### Step 2: Scan and Filter
For each listing found:
- Does it match price range?
- Does it match property type?
- Does the description contain motivation keywords?
- Is the price below estimated market value?
- How long has it been listed?

### Step 3: Score Listings
| Signal | Points |
|--------|--------|
| Below market price (15%+) | 25 |
| Motivation keywords | 20 |
| Listed 30+ days | 15 |
| Multiple reposts | 15 |
| "Must sell" or urgency language | 20 |
| Price reduced | 10 |

### Step 4: Generate Alert Report

## Output Format
```
MARKETPLACE SCAN — [Date] — [Area]
═══════════════════════════════════
Listings Found: [X] | Investor-Relevant: [X] | Hot: [X]

HOT LEADS:
1. [Platform] — [Address/Area] — $[Price] — Score: [X]
   [1-line description + why it's interesting]
   Contact: [Phone/link]
```

## Example Prompts
- "Scan Facebook Marketplace and Craigslist for FSBO houses in Lubbock under $150K."
- "Any new FSBO listings in my target zips since yesterday?"
- "Find motivated seller posts on Craigslist — look for keywords like 'must sell' or 'as-is'."

## Suggested Next Steps
1. **`/lead-generation/cold-caller`** — Call the FSBO sellers directly
2. **`/deal-analysis/arv-calculator`** — Estimate ARV on promising finds
3. **`/lead-generation/lead-auto-qualifier`** — Score the leads before reaching out
