---
name: LOI Generator
description: "Generate Letters of Intent for real estate acquisitions — commercial, multifamily, and large residential deals. Triggers on: LOI, letter of intent, expression of interest."
---

# LOI Generator

## Overview
Generate professional Letters of Intent for property acquisitions. LOIs are non-binding expressions of interest that outline proposed terms before drafting a full purchase agreement. Essential for commercial, multifamily, and larger residential deals where sellers expect LOIs before entering contract negotiations.

## When to Use
- Making initial offers on commercial or multifamily properties
- Expressing interest to a broker-represented seller
- Competing for off-market deals where professionalism matters
- Portfolio acquisitions or multi-property deals

## Inputs
- **Buyer** — name/entity, brief background (credibility builder)
- **Property** — address, type, units/sqft
- **Proposed purchase price** and basis (cap rate, per unit, per sqft)
- **Earnest money** — amount and timeline
- **Due diligence period** — length in days
- **Financing** — cash, bank, agency, seller finance, assumption
- **Closing timeline** — target date
- **Contingencies** — inspection, financing, environmental, survey, zoning
- **Special conditions** — seller carry, lease-back, phased closing

## Process

### Step 1: Structure the LOI
| Section | Content |
|---------|---------|
| Date and addressee | Property owner or broker |
| Opening | Express interest, identify property |
| Buyer profile | Entity, track record, proof of funds reference |
| Purchase price | Amount and pricing basis |
| Earnest money | Amount, hard/soft, timeline |
| Due diligence | Period, scope, access requirements |
| Financing | Source, pre-approval status, timeline |
| Closing | Target date, title company preference |
| Contingencies | All conditions to close |
| Exclusivity | Requested period off-market |
| Non-binding | Standard non-binding language (except exclusivity/confidentiality) |
| Expiration | LOI valid until [date] |

### Step 2: Pricing Justification
```
Offered Price:          $[X]
Price Per Unit:         $[X] (multifamily)
Price Per Sqft:         $[X] (commercial)
Cap Rate at Offer:      [X]%
Basis:                  [Comparable sales / Income approach / Replacement cost]
```

### Step 3: Generate Professional Document

### Step 4: Review for Completeness
- [ ] Buyer entity and signatory identified
- [ ] Property clearly identified (address + legal if available)
- [ ] Price and terms clearly stated
- [ ] Timeline is realistic
- [ ] Non-binding language included
- [ ] Expiration date set
- [ ] Proof of funds / pre-approval referenced

## Output Format
```
LETTER OF INTENT
════════════════
Date: [Date]

To: [Seller/Broker Name]
Re: [Property Address]

Dear [Name],

[Professional opening — express interest, reference how you found the deal]

PROPOSED TERMS:
  Purchase Price:      $[X]
  Earnest Money:       $[X] (deposited within [X] days of execution)
  Due Diligence:       [X] days from effective date
  Financing:           [Type]
  Closing:             [X] days from DD expiration
  Contingencies:       [List]

BUYER PROFILE:
  Entity: [Name]
  [Brief track record — deals closed, assets owned]
  Proof of funds available upon request.

[Non-binding language]

This LOI is valid until [Expiration Date].

Respectfully,
[Buyer Name/Entity]
[Contact Info]
```

## Example Prompts
- "Write an LOI for the 12-unit apartment at 500 Elm St — offering $1.1M, 7% cap, 45-day DD, bank financing."
- "Generate a letter of intent for a strip mall — $2.3M, cash buyer, 30-day close, 21-day DD."
- "Create an LOI for a portfolio of 5 SFRs — $425K total, seller finance requested."

## Suggested Next Steps
1. **`/deal-analysis/mf-underwriter`** — Verify your underwriting before submitting
2. **`/transactions/purchase-agreement`** — Draft the full contract once LOI is accepted
3. **`/creative-finance/lender-package`** — Prepare financing package
