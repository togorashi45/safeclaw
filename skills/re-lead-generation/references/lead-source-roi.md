---
name: Lead Source ROI Calculator
description: "Calculate ROI per lead source — direct mail, PPC, cold calling, SEO, referrals. Compare cost per lead, cost per deal, and conversion rates to optimize marketing spend. Triggers on: lead source ROI, cost per lead, which source is best, marketing ROI, lead source comparison."
---

# Lead Source ROI Calculator

## Overview
Analyze which lead sources are actually making money and which are burning cash. Compare cost per lead, cost per deal, and conversion rates across all marketing channels.

## When to Use
- Monthly or quarterly marketing spend review
- Deciding where to allocate next month's budget
- A lead source feels expensive — need data to confirm
- Scaling up and need to know what to double down on

## Inputs
For each lead source, provide:
- Source name (direct mail, PPC, cold calling, driving for dollars, SEO, referral, etc.)
- Total spend for the period
- Number of leads generated
- Number of appointments set
- Number of offers made
- Number of deals closed
- Total revenue from deals

## Process

### Step 1: Calculate Per-Source Metrics

For each source:
```
Cost Per Lead (CPL) = Total Spend / Leads Generated
Cost Per Appointment = Total Spend / Appointments Set
Cost Per Deal = Total Spend / Deals Closed
Revenue Per Deal = Total Revenue / Deals Closed
ROI = ((Total Revenue - Total Spend) / Total Spend) × 100
Conversion Rate = Deals Closed / Leads Generated × 100
```

### Step 2: Rank Sources

Rank by ROI (highest to lowest), then flag:
- Sources with ROI > 300% = SCALE UP
- Sources with ROI 100-300% = MAINTAIN
- Sources with ROI 0-100% = OPTIMIZE
- Sources with negative ROI = CUT OR FIX

### Step 3: Budget Recommendation

Reallocate budget toward highest-ROI sources. Suggest specific dollar amounts.

## Output Format
```
LEAD SOURCE ROI REPORT — [Period]
═══════════════════════════════════

| Source | Spend | Leads | Deals | CPL | CPD | Revenue | ROI | Action |
|--------|-------|-------|-------|-----|-----|---------|-----|--------|
| [src]  | $X    | X     | X     | $X  | $X  | $X      | X%  | [action] |

RECOMMENDATIONS:
1. Scale: [Source] — [why]
2. Optimize: [Source] — [what to fix]
3. Cut: [Source] — [why it's not working]

BUDGET REALLOCATION:
Current: [breakdown]
Recommended: [new breakdown]
```

## Example Prompts
- "Here's my marketing spend for Q1: Direct mail $3,000 (200 leads, 2 deals, $28K revenue), PPC $2,500 (80 leads, 1 deal, $12K revenue), Cold calling $1,200 (150 leads, 3 deals, $36K revenue). Which source wins?"
- "Compare my lead sources and tell me where to put next month's $5K budget."

## Suggested Next Steps
1. **`/reporting/kpi-tracker`** — Track these metrics ongoing
2. **`/marketing/ad-copy`** — Optimize underperforming PPC campaigns
3. **`/marketing/postcard-mailer`** — Improve direct mail if it's underperforming
