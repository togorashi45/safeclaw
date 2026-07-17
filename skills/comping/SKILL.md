---
name: comping
description: "Comp a property and produce an ARV/rent estimate. Base source on every box: the RentCast API (value + rent comps, budget-capped). Custom add-ons per client: MLS bridge, Reonomy CRE. Two modes: fast campaign-lead qualification and deep offer prep. Triggers on: comp, comps, ARV, what's it worth, rent estimate, run the numbers, comparable sales."
version: 1.1.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [comps, arv, rentcast, mls, valuation, acquisitions]
    category: real-estate
    sources:
      - {kind: brain, optional: false}
      - {kind: cli:recolorado, optional: true}
      - {kind: cli:rentcast-comp, optional: true}
      - {kind: gohighlevel, optional: true}
---

# Comping / ARV

Input: an address (voice or text; confirm parse-back if spoken). Optional:
beds/baths/sqft/condition.

## Data sources
1. **RentCast API (the standard base, every box).** Value estimate + sale
   comps (`/avm/value`), rent estimate + rent comps (`/avm/rent-long-term`),
   property records. Call it ONLY through the box's `rentcast-comp` wrapper,
   never the raw API - the wrapper enforces the budget (below). Key + caps in
   `references/budget-caps.md`.
2. **Client add-ons (custom work, when installed):** licensed MLS bridge
   (e.g. `/opt/recolorado-cli` on Colorado boxes) - always preferred over
   RentCast when present; Reonomy for CRE. Label the source in every answer.
3. Public web (Zillow/Redfin) via browse only as a last resort; label it.

## HARD BUDGET RULES (non-negotiable)
- **One property per request.** This skill comps ONE address at a time. If
  asked to comp a list ("comp these 10,000 records"), REFUSE and explain:
  bulk comping burns the API budget; batch enrichment is a LeadForge/admin
  job Jake approves, not an agent skill.
- The `rentcast-comp` wrapper enforces a per-day cap (default 25 calls/box)
  and a per-month cap tied to the plan. When the cap is hit it returns
  CAP_EXCEEDED: tell the user plainly the daily comp budget is used up and
  when it resets. Never work around it with the raw API or another key.
- Cache-first: check the brain for a recent comp of the same address
  (<30 days) before spending a call, and log every result to the brain.

## Process
1. Resolve the address; check the brain cache first.
2. Pull value + comps (MLS if present, else rentcast-comp). 6-12 sales,
   ~0.5mi, +/-20% sqft, last 6 months preferred.
3. Rank by similarity; top 3 with one-line justifications.
4. ARV as a RANGE from the best comps, adjusted for condition. For rentals,
   include the rent estimate + gross yield.
5. **Fast mode** (campaign lead): ARV range + confidence, one screen, under
   a minute. **Deep mode** (offer prep): DOM, price history, rehab
   assumptions, suggested MAO with the client's formula (default 70% ARV
   minus repairs for wholesale; confirm the client's own formula).
6. Log the run to the brain against the property.
