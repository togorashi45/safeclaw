---
name: Lead Paint Certification
description: "Lead paint disclosure and certification tracking — pre-1978 property requirements, EPA RRP rule compliance, disclosure forms, and contractor certification. Triggers on: lead paint, lead cert, lead disclosure, lead-based paint."
---

# Lead Paint Certification

## Overview
Manage lead-based paint compliance for pre-1978 properties. Federal law requires specific disclosures, contractor certifications, and work practices when renovating or renting properties built before 1978. Non-compliance penalties reach $37,500+ per violation per day.

## When to Use
- Renting a pre-1978 property — disclosure required
- Renovating a pre-1978 property — EPA RRP Rule applies
- Selling a pre-1978 property — disclosure required
- Verifying contractor certifications for lead-safe work

## Inputs
- **Property address and year built**
- **Activity** — renting, selling, renovating
- **Known lead paint status** — tested? results?
- **Renovation scope** (if applicable)
- **Contractor info** (if applicable)

## Process

### Step 1: Determine If Requirements Apply
```
Property built before 1978? → YES → Requirements apply
Property built 1978 or later? → NO → No lead paint requirements
```

Exemptions: housing for elderly (no children under 6), 0-bedroom units, property certified lead-free by inspector

### Step 2: Disclosure Requirements (Rental and Sale)
- [ ] Provide EPA pamphlet "Protect Your Family From Lead in Your Home"
- [ ] Disclose known lead paint and hazards
- [ ] Provide any available lead inspection reports
- [ ] Include lead paint disclosure addendum in lease/contract
- [ ] Tenant/buyer signs acknowledgment of receipt
- [ ] Retain signed disclosure for 3 years

### Step 3: EPA RRP Rule (Renovation)
If disturbing more than 6 sqft interior or 20 sqft exterior paint:
- [ ] Firm must be EPA-certified (or state-certified)
- [ ] Renovator must have EPA RRP certification
- [ ] Lead-safe work practices required (containment, HEPA, wet methods)
- [ ] Post-renovation cleaning verification
- [ ] Provide pre-renovation education pamphlet to occupants
- [ ] Retain records for 3 years

### Step 4: Compliance Checklist

| Requirement | Rental | Sale | Renovation |
|-------------|--------|------|------------|
| EPA pamphlet provided | Required | Required | Required |
| Known hazards disclosed | Required | Required | N/A |
| Lead inspection reports shared | Required | Required | N/A |
| Disclosure form signed | Required | Required | N/A |
| 10-day inspection period (buyer) | N/A | Required | N/A |
| EPA-certified firm | N/A | N/A | Required |
| Certified renovator on-site | N/A | N/A | Required |
| Lead-safe work practices | N/A | N/A | Required |

## Output Format
```
LEAD PAINT COMPLIANCE — [Property Address]
══════════════════════════════════════════
Year Built: [Year]
Activity: [Rental/Sale/Renovation]
Lead Paint Status: [Known/Unknown/Tested Negative]

REQUIREMENTS:
[Checklist with completion status]

COMPLIANCE STATUS: [Compliant / Action Needed]

MISSING ITEMS:
⚠️ [Item needed]

PENALTIES FOR NON-COMPLIANCE:
Up to $37,500 per violation per day (EPA)
Triple damages in private lawsuits
```

## Example Prompts
- "My rental was built in 1965 — what lead paint disclosures do I need?"
- "I'm renovating a 1972 house — do I need EPA RRP certified contractors?"
- "Generate the lead paint disclosure for my lease at 123 Main."

## Suggested Next Steps
1. **`/property-management/lease-generator`** — Include lead paint addendum in lease
2. **`/property-management/permit-tracker`** — Track renovation permits
3. **`/transactions/seller-disclosure-review`** — Review full disclosure requirements
