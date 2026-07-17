---
name: Follow-Up Sequence Manager
description: "Manage multi-channel follow-up cadences across SMS, email, voicemail, and direct mail with timing rules and escalation logic. Triggers on: follow-up cadence, sequence manager, touchpoint schedule, contact schedule, outreach plan."
---

# Follow-Up Sequence Manager

## Overview
Design and manage structured follow-up sequences across all channels. Ensures consistent touchpoints with proper spacing, channel rotation, and escalation when leads don't respond.

## When to Use
- Setting up a new campaign's follow-up flow
- Auditing existing sequences for gaps
- Lead needs a custom multi-touch plan
- Training team on follow-up timing and messaging

## Inputs
- Campaign type (cold outreach, warm follow-up, re-engagement)
- Available channels (SMS, email, voicemail, direct mail, phone)
- Number of touches desired
- Timeframe for the sequence
- Lead list size

## Process

### Step 1: Design the Cadence
Standard sequences by campaign type:

**New Lead — Speed to Lead + Nurture (21 days):**
| Touch | Timing | Channel | Purpose |
|-------|--------|---------|---------|
| 1 | 0 min | SMS | Speed-to-lead, immediate response |
| 2 | 5 min | Phone call | Live connection attempt |
| 3 | 5 min (VM) | Voicemail | If no answer, leave VM |
| 4 | Day 1 | Email | Intro + value prop |
| 5 | Day 3 | SMS | Follow-up bump |
| 6 | Day 5 | Phone | Second call attempt |
| 7 | Day 7 | Email | Case study / social proof |
| 8 | Day 10 | SMS | "Still interested?" |
| 9 | Day 14 | Email | Market update for their area |
| 10 | Day 21 | SMS | Final touch |

### Step 2: Set Rules
- Max 1 touch per day per channel
- No texts before 8 AM or after 8 PM local time
- If lead replies → exit sequence, route to live conversation
- If lead opts out → immediately remove from all sequences
- Track delivery and open rates per channel

### Step 3: Generate Sequence Document

## Output Format
```
FOLLOW-UP SEQUENCE — [Campaign Name]
═════════════════════════════════════
Total Touches: [X] | Duration: [X] days | Channels: [list]

| # | Day | Time | Channel | Message Summary | Status |
|---|-----|------|---------|----------------|--------|
| 1 | 0   | ASAP | SMS     | Speed-to-lead  | ☐      |

RULES:
- Opt-out handling: [process]
- Reply routing: [process]
- Escalation: [when to hand to live caller]
```

## Example Prompts
- "Design a 10-touch follow-up sequence for my direct mail respondents over 21 days."
- "What's the best follow-up cadence for PPC leads? They filled out a form."
- "Audit my current sequence — I'm only getting 3% response rate after 5 touches."

## Suggested Next Steps
1. **`/lead-generation/cold-caller`** — Scripts for the phone call touches
2. **`/lead-generation/voicemail-drop`** — Scripts for voicemail drops
3. **`/marketing/email-sequences`** — Full email content for email touches
