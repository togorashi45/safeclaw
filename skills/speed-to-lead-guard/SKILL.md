---
name: speed-to-lead-guard
description: "Watch inbound leads, draft the first response within a minute, and ping the client if nothing has gone out in N minutes. Measures and protects speed-to-lead. Triggers on: speed to lead, lead response, new lead, response time, lead guard."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [leads, response-time, guard, crm]
    category: outreach
    sources:
      - {kind: gohighlevel, optional: false}
      - {kind: brain, optional: false}
      - {kind: gmail, optional: true}
    crons:
      - name: speed-to-lead-sweep
        schedule: "*/10 * * * *"
        command: hermes -z "Run the speed-to-lead-guard sweep" >> /var/log/stl-guard.log 2>&1
---

# Speed-to-Lead Guard

Leads decay by the minute. The guard's contract: every inbound lead gets a
DRAFT response fast and a human nudge if it sits.

## Source discovery
- CRM inbound (new contacts/conversations in lead pipelines), reply webhooks
  where wired.
- Brain email pages for inbound-lead senders.
- The client's channel (Telegram/WhatsApp/Slack) for nudges.

## The sweep (every 10 min)
1. Find leads with NO outbound response since arrival.
2. For each: draft the first-touch reply in the client's voice (short,
   personal, one question) - as a CRM/Gmail DRAFT or a ready-to-send text
   in the nudge. NEVER auto-send; SMS also respects DNC/opt-out state.
3. If a lead has sat > threshold (default 15 min business hours / next
   morning otherwise): ping the client with lead + draft, one tap to act.
4. Log response times to the brain (`metrics/speed-to-lead-<date>`); the
   weekly-operator-report reads the trend. Mission Control dashboards
   (where built, e.g. Jeremiah) read the same numbers.
Escalation: 3 ignored pings on the same lead -> raise it in the daily brief
instead of pinging again. Don't become noise.
