---
name: Dispo Bot — Buyer Matcher
description: "Match wholesale deals to buyers based on buy-box criteria. Auto-segment buyer list, rank matches by fit, and prioritize outreach. Triggers on: dispo bot, auto-dispo, buyer matching, match buyer, who should I send this to."
---

# Dispo Bot — Buyer Matcher

## Overview
When you have a deal, this skill cross-references your buyer database and ranks which buyers are the best match based on their buy-box criteria, past behavior, and engagement level.

## When to Use
- New deal under contract — need to find the right buyer fast
- Building a targeted blast list (not mass blast)
- Evaluating whether your buyer list can handle a deal type
- Reactivating cold buyers with a matched deal

## Inputs
- Deal details: address, beds/baths, sqft, ARV, asking price, rehab estimate, area/zip
- Buyer database or profiles (buy-box, markets, price range, rehab tolerance)

## Process

### Step 1: Define Deal Criteria
Extract: zip, property type, price range, rehab level, close timeline.

### Step 2: Match Against Buyer Database
Score each buyer on:
- Market match (do they buy in this zip?) — 30%
- Price range match — 25%
- Property type match — 15%
- Rehab tolerance match — 15%
- Engagement score (recent activity) — 15%

### Step 3: Rank and Segment
- **Tier 1 (90%+ match):** Contact first, personal message
- **Tier 2 (70-89%):** Include in targeted blast
- **Tier 3 (50-69%):** General blast list
- **No match (<50%):** Skip for this deal

### Step 4: Generate Outreach Priority List

## Output Format
```
BUYER MATCH — [Deal Address]
════════════════════════════
Deal: [Beds/Baths] | ARV: $[X] | Ask: $[X] | Rehab: $[X] | Zip: [X]

TIER 1 — Contact First:
| Buyer | Match % | Market | Budget | Last Active | Contact |
|-------|---------|--------|--------|-------------|---------|

TIER 2 — Targeted Blast:
[Similar table]

Total Matches: [X] buyers
Recommended: Contact Tier 1 individually, then blast Tier 2.
```

## Example Prompts
- "I have a deal: 3/2 in 75217, ARV $185K, asking $95K, needs $40K rehab. Who's my best buyer match?"
- "Segment my buyer list for this deal and tell me who to call first."
- "Do I have any buyers who'd want a 12-unit apartment deal in Lubbock?"

## Suggested Next Steps
1. **`/dispositions/offer-blast-email`** — Write the blast email for matched buyers
2. **`/dispositions/dispo-crm-updater`** — Log outreach and track responses
3. **`/transactions/assignment-agreement`** — Ready the assignment when a buyer commits
