---
name: CRM Sync
description: "CRM cleanup and sync — identify duplicates, stale leads, missing follow-ups, incomplete records, and pipeline issues. GHL is source of truth. Triggers on: sync CRM, update contacts, CRM cleanup, deduplicate."
---

# CRM Sync

## Overview
Audit and clean up your CRM (GoHighLevel). Identifies duplicate contacts, stale leads needing follow-up, incomplete records missing key data, and pipeline stage inconsistencies. GHL is the source-of-truth CRM — mind/ files should reflect GHL state.

## When to Use
- Weekly maintenance (recommended)
- Before a marketing campaign (clean list = better results)
- After importing new leads
- Pipeline feels messy or inaccurate
- Syncing mind/ files with CRM state

## Inputs
- **GHL contact and pipeline data**
- **mind/active-deals.md** — for cross-reference
- **Time since last cleanup**

## Process

### Step 1: Duplicate Detection
```
POTENTIAL DUPLICATES:
| Contact A | Contact B | Match Type | Action |
|-----------|-----------|-----------|--------|
| [Name/Phone] | [Name/Phone] | Phone match | Merge |
| [Name/Email] | [Name/Email] | Email match | Merge |
```
Check for: same phone, same email, same address, similar name + same zip.

### Step 2: Stale Lead Audit
| Lead | Last Contact | Days Since | Stage | Action |
|------|-------------|-----------|-------|--------|
| [Name] | [Date] | [X] days | [Stage] | Re-engage / Archive |

**Thresholds:**
- Hot leads: stale after 3 days no contact
- Warm leads: stale after 7 days
- Nurture leads: stale after 30 days
- Cold leads: archive after 90 days no response

### Step 3: Incomplete Records
```
MISSING DATA:
| Contact | Missing Fields | Priority |
|---------|---------------|----------|
| [Name] | Phone, Property Address | High (active deal) |
| [Name] | Email, Lead Source | Medium |
```

Key fields every lead should have: Name, Phone, Email, Property Address, Lead Source, Stage, Last Contact Date, Notes

### Step 4: Pipeline Consistency
Cross-reference GHL pipeline stages with mind/active-deals.md:
- Deals in mind/ but not in GHL → Add to GHL
- Deals in GHL marked active but closed → Update stage
- Stage mismatches → Reconcile

### Step 5: Lead Source Attribution
```
LEADS WITHOUT SOURCE:
[Count] contacts have no lead source assigned.
Action: Backfill from import date/campaign tags.
```

## Output Format
```
CRM SYNC REPORT — [Date]
═════════════════════════
Total Contacts: [X]
Duplicates Found: [X] → [Merge recommendations]
Stale Leads: [X] → [Re-engage or archive]
Incomplete Records: [X] → [Fields to fill]
Pipeline Mismatches: [X] → [Corrections needed]
No Lead Source: [X] → [Backfill needed]

PRIORITY ACTIONS:
1. [Most impactful cleanup action]
2. [Second priority]
3. [Third priority]
```

## Example Prompts
- "Run a CRM cleanup — find duplicates and stale leads."
- "Sync my active deals between mind/ files and GHL."
- "Which leads haven't been contacted in over 7 days?"
- "How many contacts are missing a lead source?"

## Suggested Next Steps
1. **`/lead-generation/adaptive-follow-up`** — Re-engage stale leads
2. **`/lead-generation/lead-source-roi`** — Analyze lead sources after cleanup
3. **`/operations/daily-briefing`** — Start fresh with clean CRM data
