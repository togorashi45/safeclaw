---
name: deal-debrief
description: "When a deal closes or dies, write the one-page autopsy: what it made vs plan, where days were lost, whether the intake comp was right, and what to change. Builds the client's own deal dataset over time. Triggers on: deal debrief, post mortem, deal closed, what did we make, deal review."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [debrief, deals, learning, reporting]
    category: real-estate
---

# Deal Debrief

Fires when a TC deal hits CLOSED or CANCELLED (watch the transactions table /
CRM stage). Output: a brain page `debriefs/<address-slug>` + a short message
to the client. Reality over narrative: numbers first.

## Pull (whatever exists on this box)
- The TC deal doc: dates, tasks (which ran late), deadlines hit/missed,
  flags raised, activity log.
- The intake comp (brain comp cache): predicted ARV/range vs actual sale or
  assignment price.
- Money: contract price, assignment fee/spread, EMD outcomes.
- Comms: days-to-first-response, gaps where the file sat silent.

## The page
1. **Result**: made $X on $Y in Z days (or died at stage S after Z days,
   reason). One line.
2. **Timeline**: contract -> assigned -> closed with day counts per stage;
   flag the longest gap and what caused it.
3. **Comp accuracy**: predicted vs actual, in % - this is how the client's
   comp formula gets calibrated over time.
4. **What to change**: one process fix, tied to evidence above.
After ~10 debriefs, the aggregate answers "what does our average deal look
like" - surface that in the weekly-operator-report scoreboard.
