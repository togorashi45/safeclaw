---
name: re-property-management
description: "Property Management Playbooks: Leasing, tenants, evictions, maintenance, and portfolio dashboards for holds and rentals. Installable category pack split from the real-estate playbook library so a box only carries what the client uses."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: ['property-management', 'rentals', 'tenants']
    category: real-estate
    sources:
      - {kind: brain, optional: false}
      - {kind: gohighlevel, optional: true}
      - {kind: gmail, optional: true}
      - {kind: googlecalendar, optional: true}
---

# Property Management Playbooks

Leasing, tenants, evictions, maintenance, and portfolio dashboards for holds and rentals.

16 playbooks. Do not load them all. Pick the closest play by its
description, read ONLY that file, then follow it. Pull live data from the
connected CRM, email, calendar, and the brain as the play directs.

## Plays

- `references/eviction-process.md` - Guide the eviction process — state-specific timelines, notice requirements, court filing steps, documentation checklist, and cost estimation
- `references/insurance-gap-detector.md` - Identify insurance coverage gaps — policy review, replacement cost analysis, liability adequacy, flood/wind requirements, and umbrella policy needs
- `references/lead-paint-cert.md` - Lead paint disclosure and certification tracking — pre-1978 property requirements, EPA RRP rule compliance, disclosure forms, and contractor certification
- `references/lease-generator.md` - Generate residential lease agreements with state-aware clauses, pet addenda, late fee structures, security deposit terms, and maintenance responsibilities
- `references/lease-renewal.md` - Manage lease renewals — market rent comparison, rent increase calculation, renewal letter generation, and counter-offer handling
- `references/market-rent.md` - Determine market rent using comparable rental analysis — nearby rental comps, amenity adjustments, seasonal factors, and rent positioning strategy
- `references/materials-list.md` - Generate materials and supplies lists for rehabs — bill of materials by room, quantity calculator, budget tracking, and vendor recommendations
- `references/move-in-out-inspection.md` - Generate property condition inspection reports — room-by-room checklist, condition ratings, damage assessment, and deposit deduction calculations
- `references/permit-tracker.md` - Track building permits — application status, inspection scheduling, required permits by project type, deadline tracking, and compliance
- `references/poa-expiration.md` - Track Power of Attorney documents — expiration dates, renewal process, scope verification, and state-specific requirements
- `references/portfolio-dashboard.md` - Generate portfolio overview — all properties, occupancy rates, rent roll, maintenance status, lease expirations, cash flow summary, and equity position
- `references/punch-list.md` - Generate renovation/turnover punch lists — room-by-room items, contractor assignment, cost estimates, completion tracking, and quality verification
- `references/tenant-communication.md` - Draft professional, legally compliant tenant communications — late rent notices, lease violations, maintenance updates, rent increases, and general announcement
- `references/tenant-onboarding.md` - Generate new tenant move-in packages — welcome letter, move-in checklist, utility transfer guide, emergency contacts, house rules, and maintenance request proce
- `references/tenant-screener.md` - Screen tenant applications using credit, income, rental history, and background criteria. Outputs approve/conditional/deny with scoring matrix
- `references/work-order.md` - Create and manage maintenance work orders — priority levels, contractor assignment, cost tracking, tenant communication, and completion verification
