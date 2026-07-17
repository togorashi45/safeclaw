---
name: comping
description: "Comp a property and produce an ARV: pull comparable sales from the connected MLS bridge (or public sources when no MLS), rank the best comps, and return ARV with an executive summary. Two modes: fast campaign-lead qualification and deep stagnant-listing analysis. Triggers on: comp, comps, ARV, what's it worth, run the numbers, comparable sales."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [comps, arv, mls, valuation, acquisitions]
    category: real-estate
---

# Comping / ARV

Input: an address (voice or text; confirm parse-back if spoken). Optional:
beds/baths/sqft/condition if the client knows them.

## Data sources (in order)
1. The box's MLS bridge if installed (e.g. `/opt/recolorado-cli` on Colorado
   boxes) - licensed MLS comps are always preferred.
2. Public records already in the brain / LeadForge parcel data if linked.
3. Public web (Zillow/Redfin/Realtor) via the browse tool as fallback; label
   these estimates, not MLS-grade.

## Process
1. Pull 8-12 recent sales within ~0.5mi (expand if rural), similar sqft
   (+/-20%), beds, age, and condition. Prefer last 6 months.
2. Rank by similarity; present the top 3 with one-line justifications.
3. Compute ARV from the top comps (price/sqft on the best matches, adjusted
   for condition). State the range, not just a point.
4. **Fast mode** (campaign lead): return ARV range + confidence in under a
   minute, one screen.
   **Deep mode** (stagnant listing / offer prep): add DOM analysis, price
   history, rehab-level assumptions, and a suggested MAO using the client's
   offer formula (default 70% ARV minus repairs for wholesale; confirm the
   client's formula in their config/brain).
5. Log the run to the brain against the property so repeat asks are instant.
