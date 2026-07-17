---
name: Tenant Onboarding Package
description: "Generate new tenant move-in packages — welcome letter, move-in checklist, utility transfer guide, emergency contacts, house rules, and maintenance request process. Triggers on: new tenant, onboard tenant, move-in package, tenant welcome."
---

# Tenant Onboarding Package

## Overview
Create a comprehensive move-in package for new tenants. Sets expectations from day one, reduces future issues, and creates a professional landlord experience. Covers everything from key handoff to utility setup to maintenance procedures.

## When to Use
- New tenant approved and lease signed
- Preparing for move-in day
- Updating your standard onboarding package
- Onboarding a tenant at a newly acquired property

## Inputs
- **Tenant name(s)**
- **Property address and unit**
- **Move-in date**
- **Rent amount and due date**
- **Payment method** — portal, Zelle, check, etc.
- **Property specifics** — parking, laundry, storage, trash days, HOA rules
- **Emergency maintenance contact**
- **Utility information** — what tenant pays vs landlord pays

## Process

### Step 1: Welcome Letter
- Warm welcome and congratulations
- Key contacts (landlord/PM, emergency maintenance, office hours)
- Quick reference: rent amount, due date, payment method
- Move-in date and key pickup details

### Step 2: Move-In Checklist
- [ ] Lease signed and filed
- [ ] Security deposit received ($[X])
- [ ] First month's rent received ($[X])
- [ ] Keys issued (house, mailbox, gate, garage — count: [X])
- [ ] Move-in inspection completed and signed
- [ ] Utility transfer confirmed
- [ ] Renter's insurance verified (if required)
- [ ] Parking assignment confirmed
- [ ] Emergency contact form completed
- [ ] Pet addendum signed (if applicable)

### Step 3: Utility Transfer Guide
| Utility | Provider | Phone | Account Setup | Tenant/Landlord Pays |
|---------|----------|-------|---------------|---------------------|
| Electric | [Provider] | [Phone] | [Instructions] | Tenant |
| Gas | [Provider] | [Phone] | [Instructions] | Tenant |
| Water | [Provider] | [Phone] | [Instructions] | [Who] |
| Trash | [Provider] | [Details] | [Instructions] | [Who] |
| Internet | [Options] | — | Tenant choice | Tenant |

### Step 4: House Rules and Property Guide
- Quiet hours
- Parking rules
- Guest policy
- Pet rules (if pets allowed)
- Trash/recycling schedule and procedures
- Common area expectations
- Smoking policy
- Maintenance request process (how to submit, emergency vs routine)
- What's an emergency (flooding, fire, gas leak, no heat in winter, lockout)

### Step 5: Generate Package

## Output Format
```
TENANT ONBOARDING PACKAGE
═════════════════════════
Tenant: [Name]
Property: [Address/Unit]
Move-In: [Date]

📋 WELCOME LETTER
[Full welcome letter text]

📋 MOVE-IN CHECKLIST
[Checklist with status]

📋 UTILITY SETUP GUIDE
[Utility table]

📋 PROPERTY GUIDE & HOUSE RULES
[Rules and procedures]

📋 EMERGENCY CONTACTS
Property Manager: [Name] — [Phone]
Emergency Maintenance: [Number]
Police Non-Emergency: [Number]
Fire/Ambulance: 911
```

## Example Prompts
- "Create a move-in package for new tenant Sarah at 123 Main St Unit A, moving in May 1, rent $1,350."
- "Generate a welcome letter and house rules for my duplex tenant."
- "What should I include in my tenant onboarding checklist?"

## Suggested Next Steps
1. **`/property-management/move-in-out-inspection`** — Complete move-in inspection
2. **`/property-management/lease-generator`** — Finalize lease if not done
3. **`/property-management/tenant-communication`** — Send welcome communication
