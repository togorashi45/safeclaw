---
name: Lease Generator
description: "Generate residential lease agreements with state-aware clauses, pet addenda, late fee structures, security deposit terms, and maintenance responsibilities. Triggers on: lease, rental agreement, generate lease, lease template."
---

# Lease Generator

## Overview
Generate comprehensive residential lease agreements customized for investment properties. Includes standard protective clauses, state-specific considerations, and common addenda. Designed to protect the landlord while maintaining fair housing compliance.

## When to Use
- New tenant approved — need a lease
- Updating lease template for a new property
- Adding addenda to existing lease (pet, parking, etc.)
- Converting month-to-month to fixed-term

## Inputs
- **Landlord** — name/entity
- **Tenant(s)** — all adult occupants
- **Property** — address, unit, type
- **Lease term** — start date, end date, month-to-month option
- **Rent** — amount, due date, grace period
- **Security deposit** — amount (check state limits)
- **Late fee** — amount and when it kicks in (check state limits)
- **Pet policy** — allowed? deposit? restrictions?
- **Utilities** — who pays what
- **State** — for state-specific requirements

## Process

### Step 1: Core Lease Sections
1. **Parties** — Landlord and all tenants (joint and several liability)
2. **Property Description** — Address, unit, included spaces (parking, storage)
3. **Lease Term** — Start/end dates, renewal terms, holdover provisions
4. **Rent** — Amount, due date, grace period, accepted payment methods
5. **Security Deposit** — Amount, conditions for deductions, return timeline (state-specific)
6. **Late Fees** — Amount, when assessed, NSF fee
7. **Utilities and Services** — Who pays each utility
8. **Maintenance** — Landlord vs tenant responsibilities
9. **Alterations** — What tenant can/cannot modify
10. **Entry/Access** — Notice requirements (typically 24-48 hours, state-specific)
11. **Subletting** — Prohibited without written consent
12. **Pets** — Policy, deposit, restrictions
13. **Insurance** — Renter's insurance requirement
14. **Default and Remedies** — Cure periods, eviction process reference
15. **Termination** — Early termination fee, notice requirements
16. **Move-Out** — Condition requirements, cleaning standards, forwarding address

### Step 2: State-Specific Considerations
| Item | Common State Variations |
|------|------------------------|
| Security Deposit Limit | 1-3 months rent (varies by state) |
| Deposit Return Timeline | 14-60 days after move-out |
| Late Fee Cap | Some states cap at 5-10% of rent |
| Required Disclosures | Lead paint (pre-1978), mold, flood zone, sex offenders |
| Habitability Standards | Implied warranty of habitability requirements |
| Entry Notice | 24-48 hours (varies) |
| Rent Increase Notice | 30-90 days (varies) |

### Step 3: Common Addenda
- Pet addendum (deposit, weight/breed restrictions, liability)
- Parking addendum
- Lead paint disclosure (required for pre-1978 properties)
- Mold disclosure
- Crime-free / nuisance addendum
- HOA rules acknowledgment
- Appliance inventory

### Step 4: Generate Lease Document

## Output Format
```
RESIDENTIAL LEASE AGREEMENT
═══════════════════════════
LANDLORD: [Name/Entity]
TENANT(S): [Names]
PROPERTY: [Address/Unit]

TERM: [Start] to [End]
RENT: $[X]/month, due [1st/other] of each month
DEPOSIT: $[X]
LATE FEE: $[X] after [X]-day grace period

[Full lease text organized by section]

ADDENDA:
☐ Pet Addendum
☐ Lead Paint Disclosure
☐ [Other applicable addenda]

SIGNATURES:
Landlord: _____________ Date: _______
Tenant:   _____________ Date: _______
Tenant:   _____________ Date: _______
```

## Example Prompts
- "Generate a 1-year lease for my rental at 123 Main St — $1,400/month, 2 tenants, 1 small dog, in Texas."
- "Create a lease with no-pet clause, $50 late fee after 5-day grace, $1,400 deposit."
- "Draft a month-to-month lease agreement for a furnished unit at $1,800."

## Suggested Next Steps
1. **`/property-management/tenant-onboarding`** — Prepare move-in package
2. **`/property-management/move-in-out-inspection`** — Schedule move-in inspection
3. **`/property-management/lead-paint-cert`** — Lead paint disclosure if pre-1978
