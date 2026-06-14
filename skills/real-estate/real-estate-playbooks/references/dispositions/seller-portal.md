---
name: Seller Portal Generator
description: "Generate seller-facing status pages showing deal progress, next steps, timeline, and contact info. Builds trust and reduces seller anxiety. Triggers on: seller portal, seller dashboard, seller status, deal status page."
---

# Seller Portal Generator

## Overview
Create a simple, clear status page for sellers to see where their deal stands. Reduces inbound calls asking "what's going on?" and builds professionalism.

## When to Use
- Deal goes under contract — send seller their status page
- After each milestone, update the status
- Seller is anxious or calling frequently

## Inputs
- Seller name and property address
- Current deal stage and milestone dates
- Next steps and who's responsible
- Your contact information

## Process

### Step 1: Generate Status Page Content
Include: property info, deal timeline with milestones (color-coded green/yellow/pending), current status, next steps, FAQ, contact info.

### Step 2: Timeline Milestones
- Contract Signed ✅
- Title Search Ordered ✅
- Inspection Complete ✅/⏳
- Financing Confirmed ✅/⏳
- Closing Scheduled ⏳
- CLOSED ⏳

## Output Format
```
DEAL STATUS — [Address]
═══════════════════════
Seller: [Name] | Buyer: [Your Company]
Status: [ON TRACK / ATTENTION NEEDED]

TIMELINE:
✅ Contract Signed — [Date]
✅ Title Ordered — [Date]
⏳ Inspection — Scheduled [Date]
☐ Closing — Target [Date]

NEXT STEP: [What's happening next and when]
YOUR ACTION NEEDED: [Anything seller needs to do]

Questions? Contact [Name] at [Phone/Email]
```

## Example Prompts
- "Create a seller status page for the Johnson deal at 123 Main St. We signed March 1, closing target March 28."
- "Update the seller portal — title came back clean, inspection is Thursday."

## Suggested Next Steps
1. **`/transactions/wholesale-tc`** — Track the full closing checklist internally
2. **`/operations/meeting-notes`** — Document seller check-in calls
