---
name: Neighborhood Scoring
description: "Score neighborhoods on investability — school ratings, crime, employment, rent growth, population trends, and investor activity. Triggers on: neighborhood score, area grade, location rating, neighborhood analysis, best areas to invest."
---

# Neighborhood Scoring

## Overview
Score and rank neighborhoods for investment potential using data-driven criteria. Helps identify the best areas for your strategy (flip, rental, wholesale).

## When to Use
- Entering a new market and need to pick target neighborhoods
- Comparing areas within a city for deal focus
- Evaluating if a specific deal's location is strong

## Inputs
- City or metro area
- Zip codes or neighborhoods to score
- Investment strategy (flip, rental, wholesale)

## Process

### Step 1: Score on Key Factors

| Factor | Weight (Rental) | Weight (Flip) | Data Source |
|--------|----------------|---------------|-------------|
| School Rating | 15% | 10% | GreatSchools.org |
| Crime Rate | 15% | 10% | CrimeMapping, local PD |
| Employment/Job Growth | 15% | 10% | BLS, Census |
| Population Growth | 10% | 5% | Census |
| Median Income | 10% | 10% | Census |
| Rent Growth (YoY) | 15% | 5% | Zillow, Rentometer |
| Price Appreciation | 10% | 20% | Zillow, Redfin |
| Investor Activity | 5% | 20% | Cash sales %, flip volume |
| Vacancy Rate | 5% | 10% | Census, USPS |

### Step 2: Grade Each Neighborhood
A (90-100), B (75-89), C (60-74), D (40-59), F (<40)

### Step 3: Strategy Match
- A neighborhoods: Appreciation plays, premium rentals
- B neighborhoods: Best for BRRRR, stable rentals
- C neighborhoods: Cash flow plays, higher cap rates, more management
- D neighborhoods: High risk, high potential return, experienced investors only

## Output Format
```
NEIGHBORHOOD SCORES — [City]
════════════════════════════
Strategy: [Rental/Flip/Wholesale]

| Rank | Neighborhood/Zip | Grade | Score | Best For |
|------|-----------------|-------|-------|----------|
| 1    | [area]          | [A-F] | [X]   | [strategy] |

TOP PICK: [Neighborhood] — [why]
AVOID: [Neighborhood] — [why]
```

## Example Prompts
- "Score the top 10 zip codes in Lubbock for rental investing."
- "Compare these 3 neighborhoods in Dallas for flip potential: 75217, 75216, 75215."
- "What grade is the area around 123 Main St for buy-and-hold?"

## Suggested Next Steps
1. **`/deal-analysis/market-snapshot`** — Deep dive on the top-scored area
2. **`/lead-generation/daily-mls-feed`** — Monitor top areas for new listings
3. **`/deal-analysis/cap-rate-tracker`** — Track cap rates in selected neighborhoods
