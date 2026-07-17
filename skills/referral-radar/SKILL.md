---
name: referral-radar
description: "Spot relationship signals worth acting on - the agent who sent two deals, the buyer who closed fast, the closer who saved a file - and prompt a specific thank-you, gift, or ask. The warm side of outreach. Triggers on: referral, thank you, relationship, who sent us, warm outreach."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [referrals, relationships, outreach, brain]
    category: outreach
    sources:
      - {kind: brain, optional: false}
      - {kind: gohighlevel, optional: true}
---

# Referral Radar

Investors live on repeat relationships; nobody tracks them. The radar reads
what already happened and prompts ONE specific human action at a time.

## Signals (from the brain + CRM + buyer book + deal debriefs)
- A person connected to 2+ deals (sender, agent, buyer, closer, lender).
- A first: first deal from a new agent, first close with a new buyer.
- A save: someone who fixed a problem (title rescue, fast walkthrough).
- A drought: a past repeat-source silent for 90+ days.

## Behaviors
1. Weekly scan (piggybacks the weekly-operator-report run): rank the top 3
   signals. Each becomes a suggested action with WHY and WHAT: "Christi has
   now sent 2 deals that closed - handwritten thank-you + ask for coffee"
   or "Derek closed Ivanhoe in 9 days - add to VIP buyer lane, send first
   look on the next 80207 deal."
2. Every action is a suggestion to the client (draft text included where a
   message fits). Nothing sends itself. Gifts/spend always Jake- or
   client-approved.
3. Log accepted actions to the person's brain page so the relationship
   history compounds; feed VIP status back to buyer-book and cold-outreach
   target scoring.
