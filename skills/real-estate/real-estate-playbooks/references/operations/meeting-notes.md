---
name: Meeting Notes
description: "Process meeting notes and transcripts — extract action items, decisions, follow-ups, key numbers, and next meeting date. Triggers on: meeting notes, transcript, summarize meeting, action items."
---

# Meeting Notes

## Overview
Process raw meeting notes or Granola transcripts into structured, actionable output. Extracts decisions made, action items with owners, follow-ups needed, key numbers discussed, and next meeting date. Updates mind/ files if deal state changed.

## When to Use
- After any meeting — process notes immediately
- Processing a Granola transcript from a recorded meeting
- Catching up on a meeting you missed (from someone else's notes)
- Weekly — batch process all meeting notes

## Inputs
- **Meeting transcript** (from Granola via MCP) or raw notes
- **Attendees**: who was there
- **Meeting type**: seller appointment, buyer meeting, team meeting, investor call, etc.

## Process

### Step 1: Meeting Summary
```
MEETING: [Type/Topic]
DATE: [Date] | DURATION: [X] min
ATTENDEES: [Names]
CONTEXT: [What was this meeting about — 1-2 sentences]
```

### Step 2: Key Decisions Made
```
DECISIONS:
1. [Decision] — Decided by [Who]
2. [Decision] — Decided by [Who]
```

### Step 3: Action Items
```
ACTION ITEMS:
| # | Action | Owner | Due Date | Priority |
|---|--------|-------|----------|----------|
| 1 | [Task] | [Who] | [When] | [H/M/L] |
| 2 | [Task] | [Who] | [When] | [H/M/L] |
```

### Step 4: Key Numbers Discussed
```
NUMBERS:
- Property value: $[X]
- Offer price: $[X]
- Rehab estimate: $[X]
- [Any other numbers mentioned]
```

### Step 5: Follow-Ups Needed
```
FOLLOW-UPS:
| Who | What | When | Channel |
|-----|------|------|---------|
| [Name] | [Follow-up item] | [Date] | [Call/Email/Text] |
```

### Step 6: Next Meeting
```
NEXT MEETING: [Date/Time] — [Topic/Agenda]
```

### Step 7: State Changes
If the meeting changed deal status, property status, or pipeline:
- Update mind/active-deals.md
- Update mind/active-portfolio.md
- Log in CRM (GHL)

## Output Format
```
MEETING NOTES — [Topic] | [Date]
════════════════════════════════
[Summary]
[Decisions]
[Action Items table]
[Key Numbers]
[Follow-ups]
[Next Meeting]

MIND FILE UPDATES: [What changed]
```

## Example Prompts
- "Process my meeting notes — just met with seller at 123 Main, they agreed to $85K, close in 30 days."
- "Summarize the Granola transcript from my team meeting this morning."
- "What were the action items from yesterday's call with the title company?"

## Suggested Next Steps
1. **`/operations/task-prioritizer`** — Prioritize action items from the meeting
2. **`/lead-generation/adaptive-follow-up`** — Set up follow-ups from the meeting
3. **`/operations/daily-planner`** — Block time for action items
