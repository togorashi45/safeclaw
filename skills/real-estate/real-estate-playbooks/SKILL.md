---
name: real-estate-playbooks
description: "DEPRECATED router: the 127-playbook library now ships as installable category packs (re-creative-finance, re-deal-analysis, re-dispositions, re-lead-generation, re-marketing, re-operations, re-property-management, re-reporting, re-transactions). Install only the packs the client uses. Triggers on: ARV, comps, MAO, wholesale, subject to, seller finance, assignment, disposition, cap rate, LOI, double close."
version: 2.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [real-estate, router, deprecated]
    category: real-estate
---

# Real Estate Playbooks (now category packs)

This library was split so a box only carries what the client uses. Each former
category is its own installable pack: `skills/re-<category>/`. If a play you
need is not on this box, it lives in a pack that is not installed; tell the
user which pack to turn on from the portal Skills page.

For Hermes lead intake (Kanban + GHL), see
`../safeclaw-deployment/references/real-estate-lead-intake-kanban-ghl.md`.
