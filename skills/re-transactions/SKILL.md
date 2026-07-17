---
name: re-transactions
description: "Transactions Playbooks: LOIs, assignments, double closes, wholesale TC checklists, and contract-to-close mechanics. Installable category pack split from the real-estate playbook library so a box only carries what the client uses."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: ['transactions', 'contracts', 'closing']
    category: real-estate
    sources:
      - {kind: brain, optional: false}
      - {kind: gohighlevel, optional: true}
      - {kind: gmail, optional: true}
      - {kind: googlecalendar, optional: true}
---

# Transactions Playbooks

LOIs, assignments, double closes, wholesale TC checklists, and contract-to-close mechanics.

11 playbooks. Do not load them all. Pick the closest play by its
description, read ONLY that file, then follow it. Pull live data from the
connected CRM, email, calendar, and the brain as the play directs.

## Plays

- `references/addendum-builder.md` - Create contract addenda and amendments to modify existing purchase agreements — price changes, deadline extensions, repair credits, and special terms
- `references/assignment-agreement.md` - Generate wholesale assignment of contract agreements with all required clauses, fee structure, and buyer/seller details
- `references/double-close-compliance.md` - Structure and manage double (simultaneous) closings with compliance checklists, transactional funding requirements, and A-B / B-C coordination
- `references/escrow-change-alert.md` - Monitor and manage escrow changes, EMD tracking, title commitment review, and wire fraud prevention for active deals
- `references/fair-housing.md` - Review communications, listings, and tenant interactions for Fair Housing Act compliance — protected classes, advertising guidelines, and documentation
- `references/loi-generator.md` - Generate Letters of Intent for real estate acquisitions — commercial, multifamily, and large residential deals
- `references/purchase-agreement.md` - Generate real estate purchase agreements with investor-friendly terms, contingencies, and closing provisions
- `references/seller-disclosure-review.md` - Systematically review seller property disclosures for red flags, hidden costs, and negotiation leverage points
- `references/tcpa-compliance.md` - Telephone Consumer Protection Act compliance for cold calling, texting, and ringless voicemail campaigns — consent requirements, DNC management, and penalty awa
- `references/trec-contract.md` - Texas-specific TREC 1-4 Family Residential Contract guidance — section-by-section walkthrough with investor-friendly modifications
- `references/wholesale-tc.md` - Step-by-step closing checklist for wholesale deals from contract to close — document tracking, deadline management, and coordination
