---
name: deal-autopsy-intake
description: "When a new contract lands, automatically assemble the 'what you're actually buying' brief: comp + owner + title history + anything our data knows about the parcel, attached to the TC deal before money moves. Triggers on: new contract, deal intake brief, what are we buying, underwrite this."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [intake, underwriting, comps, parcels]
    category: real-estate
    sources:
      - {kind: brain, optional: false}
      - {kind: cli:recolorado, optional: true}
      - {kind: cli:rentcast-comp, optional: true}
      - {kind: portal:transactions, optional: true}
      - {kind: cli:lead-forge, optional: true}
---

# Deal Autopsy on Intake

Turns intake from data entry into underwriting. Fires when a TC deal is
created (the tc-ghl-sync flags a new deal) or on demand for an address.

## Assemble (source-discovery order; label every source)
1. **Comp**: run the comping skill (MLS bridge if present, else
   rentcast-comp - respects the budget cap; skip if cap hit and say so).
2. **The deal's own paper**: contract price, seller, key dates from the TC
   doc + the contract email thread in the brain.
3. **Parcel/owner intel**: brain pages for the address; LeadForge parcel
   data where this box has approved access; county appraisal values if
   already ingested.
4. **People**: brain person pages for seller/buyer/agent - prior history
   with us, other deals, red flags.

## The brief (attach to the deal, message the client)
- **The spread**: contract price vs comp range vs asking. Is the margin real?
- **Red flags**: comp range wider than 25%, contract above comp midpoint,
  seller entity mismatch vs county owner, short option/EMD windows, title
  company not yet identified.
- **Unknowns to close this week**: the 2-3 facts nobody has yet.
Keep it under one screen. This brief plus the deal-debrief later = the
before/after pair that calibrates the client's buying.
