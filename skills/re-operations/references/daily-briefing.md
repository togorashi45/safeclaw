---
name: Daily Briefing
description: "Morning briefing — deals needing action, follow-ups due, appointments, closings this week, and urgent items from all sources. Triggers on: morning briefing, daily summary, start my day, what is happening."
---

# Daily Briefing

## Overview
Your morning command center briefing. Pulls data from mind/ files, Google Calendar, Gmail, ClickUp, and Slack to surface everything that needs attention today. Prioritized by urgency — deal deadlines first, then follow-ups, then everything else.

## When to Use
- First thing every morning
- After being away for a day or more
- Before a planning session
- Any time you need a "what's happening" snapshot

## Inputs
- **mind/active-deals.md** — current deal pipeline
- **mind/active-portfolio.md** — property/note status
- **mind/weekly-goals.md** — this week's priorities
- **Google Calendar** — today's appointments
- **Gmail** — unread/urgent emails
- **ClickUp** — overdue and due-today tasks

## Process

### Step 1: Hot Deals — Action Required Today
Pull from mind/active-deals.md HOT section:
```
🔴 HOT DEALS NEEDING ACTION:
| Deal | Stage | Action Needed | Deadline |
|------|-------|---------------|----------|
```
Flag any deal with a deadline within 48 hours.

### Step 2: Today's Calendar
Pull from Google Calendar:
```
📅 TODAY'S SCHEDULE:
  [Time] — [Event] — [With whom] — [Location/Link]
  [Time] — [Event] — [With whom] — [Location/Link]
```
Flag any meetings needing prep (suggest `/operations/meeting-prep`).

### Step 3: Follow-Ups Due
Pull from mind/weekly-goals.md follow-ups and CRM:
```
📞 FOLLOW-UPS DUE TODAY:
| Who | Re: | Channel | Last Contact | Priority |
|-----|-----|---------|-------------|----------|
```

### Step 4: Closings This Week
```
💰 CLOSINGS THIS WEEK:
| Property | Type | Close Date | Amount | Status | TC Status |
|----------|------|-----------|--------|--------|-----------|
```

### Step 5: Inbox Highlights
Pull from Gmail — flag emails in these categories:
- **DEAL**: offers, counters, title company, earnest money
- **LEAD**: new inbound leads, responses to outreach
- **TENANT**: maintenance requests, rent issues
- **URGENT**: anything time-sensitive

### Step 6: Goal Check-In
Quick pulse from mind/weekly-goals.md:
```
📊 WEEKLY GOAL PROGRESS:
  Priority 1: [status]
  Priority 2: [status]
  Priority 3: [status]
  Revenue MTD: $[X] of $[X] target
```

### Step 7: Prioritized Action List
Synthesize everything into a ranked action list:
```
TODAY'S TOP 5:
1. [Highest priority action] — WHY: [deadline/revenue impact]
2. [Second priority]
3. [Third priority]
4. [Fourth priority]
5. [Fifth priority]
```

## Output Format
```
DAILY BRIEFING — [Date]
═══════════════════════
[Hot Deals section]
[Calendar section]
[Follow-ups section]
[Closings section]
[Inbox highlights]
[Goal check-in]
[Top 5 action list]
```

## Example Prompts
- "Start my day" / "Morning briefing"
- "What's happening today?"
- "What needs my attention right now?"

## Suggested Next Steps
1. **`/operations/meeting-prep`** — Prep for any meetings on today's calendar
2. **`/operations/email-triage`** — Process the inbox
3. **`/operations/daily-planner`** — Block time for today's priorities
