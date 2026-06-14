---
name: Disposition CRM Updater
description: "Log deal activity, track buyer pipeline stages, and generate follow-up cadences for wholesale dispositions. Triggers on: update dispo, buyer pipeline, log buyer activity, dispo CRM, buyer status."
---

# Disposition CRM Updater

## Overview
Keep your buyer pipeline organized for every active wholesale deal. Log interactions, update stages, and generate follow-up reminders so deals move faster and buyer relationships stay warm.

## When to Use
- After any buyer interaction (call, email, showing, offer)
- When a deal moves from one stage to another
- Running a weekly disposition pipeline review
- Need to know who to follow up with today

## Inputs
- Deal address or deal ID
- Buyer name and contact
- Current stage
- Last interaction (what happened, when)
- Next action needed

## Process

### Step 1: Log the Interaction
Record: deal, buyer, date, what happened, next step, deadline.

### Step 2: Update Pipeline Stage
Stages: BLAST SENT → SHOWN INTEREST → POF RECEIVED → OFFER RECEIVED → OFFER ACCEPTED → UNDER CONTRACT → CLOSED / CANCELLED

### Step 3: Generate Follow-Up Cadence
After blast: Day 1 blast, Day 2 bump, Day 3 call, Day 5 final notice, Day 7 archive.
After interest: Same day confirm + request POF, 24h follow up, 48h nudge, 72h reassign.

### Step 4: Buyer Engagement Score
5 = Submitted offer + POF, responsive. 4 = POF received, engaged. 3 = Interested, no offer. 2 = Replied once, quiet. 1 = No response.

## Output Format
```
DEAL PIPELINE — [Address]
Ask: $[X] | Contract Expires: [Date] | Status: [Stage]

| Buyer | Stage | Last Contact | Next Action | Due | Score |
|-------|-------|-------------|-------------|-----|-------|

FOLLOW-UPS DUE TODAY:
1. [Buyer] — [Action] — [Deal]
```

## Example Prompts
- "Log: Tom Harris replied to the blast on 123 Main St — interested, will send POF tomorrow."
- "Update pipeline: 123 Main St — Tom moved to Offer Received. $91,500, close in 14 days."
- "Who needs follow-up today across all my active deals?"

## Suggested Next Steps
1. **`/dispositions/offer-blast-email`** — Re-blast deal if pipeline is thin
2. **`/dispositions/weekly-pipeline`** — Full pipeline review
3. **`/transactions/assignment-agreement`** — Generate assignment when deal is accepted
