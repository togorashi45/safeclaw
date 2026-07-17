---
name: Lead Orchestrator
description: "Route leads through pipeline stages, assign actions, and manage lead workflow from new lead to appointment to offer. Triggers on: lead workflow, lead routing, assign lead, lead pipeline, move lead, lead status."
---

# Lead Orchestrator

## Overview
Manages the full lead lifecycle from first contact to offer. Routes leads to the right stage, assigns follow-up actions, and ensures no lead falls through the cracks.

## When to Use
- New lead enters the system and needs routing
- Lead status changes (replied, no-showed, made counter)
- Weekly pipeline review to catch stalled leads
- Batch-updating lead statuses after a calling session

## Inputs
- Lead name, contact info, property address
- Current pipeline stage
- Last action taken and date
- Next action needed

## Process

### Step 1: Identify Current Stage

| Stage | Definition | Auto-Actions |
|-------|-----------|--------------|
| **New Lead** | Just entered system, uncontacted | Trigger speed-to-lead (SMS + call within 5 min) |
| **Contacted** | First touch made, awaiting response | Start follow-up sequence (Day 1, 3, 5, 7) |
| **Engaged** | Lead responded, conversation active | Qualify with scoring criteria |
| **Qualified** | Meets buying criteria (score 6+) | Schedule appointment |
| **Appointment Set** | Meeting scheduled | Send confirmation + reminder sequence |
| **Appointment Complete** | Meeting happened | Generate offer or follow-up |
| **Offer Made** | Offer presented | Track response, follow up in 48h |
| **Under Contract** | Signed agreement | Hand off to transaction coordinator |
| **Dead** | Not moving forward | Tag reason, add to long-term nurture |

### Step 2: Assign Next Action
Based on current stage and last activity, recommend the specific next action with a deadline.

### Step 3: Flag Stalled Leads
Any lead sitting in one stage for longer than the stage threshold:
- New Lead: >24 hours = STALLED
- Contacted: >7 days no response = STALLED
- Qualified: >3 days no appointment = STALLED
- Offer Made: >5 days no response = STALLED

### Step 4: Generate Pipeline Report

## Output Format
```
PIPELINE STATUS — [Date]
═══════════════════════
New Leads: [X] | Contacted: [X] | Qualified: [X]
Appointments: [X] | Offers Out: [X] | Under Contract: [X]

NEEDS ACTION NOW:
1. [Lead] — [Stage] — [What's needed] — [Deadline]
2. [Lead] — [Stage] — [What's needed] — [Deadline]

STALLED (Overdue):
1. [Lead] — stuck in [Stage] for [X] days — [Recommended action]
```

## Example Prompts
- "I just got a new lead from my PPC campaign — John Smith, 555-1234, 456 Oak Ave. Route it."
- "Move Sarah Johnson to Offer Made — I sent the offer today at $95K."
- "Show me all stalled leads that need attention."

## Suggested Next Steps
1. **`/lead-generation/lead-auto-qualifier`** — Score any unqualified leads
2. **`/lead-generation/appointment-setter`** — Book appointments for qualified leads
3. **`/dispositions/weekly-pipeline`** — Full pipeline review with financials
