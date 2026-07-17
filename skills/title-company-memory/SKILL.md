---
name: title-company-memory
description: "Learn the client's title companies, closers, and escrow contacts from their real email threads; keep a roster in the brain; route each deal's title emails to the right closer instead of a default. Triggers on: title company, closer, escrow contact, who closes, title roster."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [title, escrow, tc, brain]
    category: real-estate
---

# Title Company Memory

Why this exists: deals default to one title company and reality doesn't (a
live example: a deal record said Land Title Guarantee while the actual file
was at Chicago Title). Wrong-title emails burn days.

## The roster
One brain page per title company (`title-companies/<slug>`): company, offices,
closers (name/email/phone), processors, which deal types/counties they get,
fee notes, and evidence links (the email pages the facts came from).

## Behaviors
1. **Harvest**: scan brain email pages for title-company signals (domains
   like @ltgc.com, @ctt.com, "closer", "escrow officer", "New Order",
   "earnest money receipt"). Create/update roster pages with provenance.
   Re-run on demand or when a new title thread appears.
2. **Bind deals**: when a TC deal is created or a title thread references a
   deal address, set that deal's title_company/title_contact/title_email
   from EVIDENCE (the thread), not the default. Flag mismatches ("deal says
   X, thread says Y") to the client instead of silently switching.
3. **Answer**: "who's our closer at Chicago Title?" from the roster, with
   the last-seen date so stale contacts are visible.
4. **Feed TC**: the transaction-coordination Leg A/Leg B drafts pull To/CC
   from the roster for the deal's ACTUAL title company.
