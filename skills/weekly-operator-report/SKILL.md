---
name: weekly-operator-report
description: "Sunday-night one-pager for the owner: pipeline movement, stuck deals, money in flight, leads ignored, and the one thing to fix this week. Built from whatever this box actually has. Triggers on: weekly report, operator report, how did the week go, weekly summary."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [reporting, weekly, retention, digest]
    category: operations
    crons:
      - name: weekly-operator-report
        schedule: "0 18 * * 0"
        command: hermes -z "Run the weekly-operator-report skill for this week" >> /var/log/weekly-report.log 2>&1
---

# Weekly Operator Report

ONE page, owner-readable on a phone, every Sunday evening. Not a data dump:
five sections, each earns its place. Draft-first: post to the client's
channel as a message + write a brain page (`reports/weekly-<date>`); never
email externally.

## Source discovery (use what the probe finds)
- CRM pipelines -> movement: what entered/left each stage this week, counts
  and dollar values. Stuck = no stage change in 14d+ on an active deal.
- TC board (portal transactions) -> deals in flight, deadlines this week,
  blocked tasks, health flags.
- Brain email/meeting pages -> leads or threads with no reply from us in 3d+.
- Buyer Book (if installed) -> dispo activity: blasts sent, replies, offers.
- Task board -> what the team shipped vs what rolled.

## The five sections
1. **Moved**: deals that advanced (stage, value). One line each.
2. **Stuck**: deals that didn't, with days-stuck and the blocking item.
3. **Money in flight**: contracts + expected fees/spreads, closing dates.
4. **Dropped balls**: unanswered leads/threads, overdue TC tasks. Name them.
5. **The one thing**: the single highest-leverage fix for next week, one
   paragraph, direct. (One, not three.)
End with a two-line scoreboard vs last week. Keep the whole thing under 40
lines. Plain words, no fluff, sounds like a sharp COO.
