---
name: meeting-intelligence
description: "Meeting prep and post-meeting intelligence: before a meeting, build a one-page brief (who, history, open items, suggested agenda) from the brain, CRM, email, and calendar; after, capture decisions, action items, and new people back into the brain and task board. Triggers on: meeting prep, prep me for, who am I meeting, meeting notes, action items, debrief, follow-ups."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [meetings, prep, notes, brain, calendar]
    category: operations
    requires_toolsets: [native-mcp]
---

# Meeting Intelligence

## Before a meeting (prep)
1. Pull the event from the calendar (attendees, time, description).
2. Search the brain for each attendee: person pages, past meetings, deals,
   recent email threads. Pull the CRM record if they are a contact.
3. Output ONE short brief: who they are, relationship history, open
   items/promises from last time, what they likely want, 3-5 talking points,
   and a suggested agenda. Mobile-readable, under one screen.

## After a meeting (intelligence)
1. Get the transcript/recording summary (Zoom ingest, Granola, or notes the
   client pastes).
2. Extract: decisions made, action items (owner + due), new people mentioned,
   facts worth remembering, and anything promised to the other side.
3. Write it back: brain page for the meeting, person-page updates, task board
   entries for action items, and a follow-up draft if one was promised
   (draft only, client sends).
4. Flag anything time-sensitive to the client directly.

Runs well as a daily routine: prep briefs for tomorrow's calendar each
evening; sweep today's recordings each night.
