---
name: Tenant Communication Drafter
description: "Draft professional, legally compliant tenant communications — late rent notices, lease violations, maintenance updates, rent increases, and general announcements. Triggers on: message tenant, tenant email, tenant notice, communicate tenant."
---

# Tenant Communication Drafter

## Overview
Draft professional tenant communications for any situation. Templates cover late rent, lease violations, maintenance updates, rent increases, and general notices. All drafts are reviewed for legal compliance before sending.

## When to Use
- Tenant is late on rent — need a notice
- Lease violation needs to be addressed
- Maintenance update or scheduling communication
- Rent increase notification (with proper notice period)
- General property announcements

## Inputs
- **Tenant name** and property address/unit
- **Communication type** — late rent, violation, maintenance, rent increase, general
- **Specific details** — what happened, what's needed, deadlines
- **Delivery method** — email, text, certified mail, posted on door
- **State** — for state-specific notice requirements

## Process

### Step 1: Identify Communication Type and Requirements

| Type | Notice Period | Delivery Method | Tone |
|------|-------------|-----------------|------|
| Late Rent (friendly) | Day 1-3 past due | Email/text | Friendly reminder |
| Late Rent (formal) | Day 4+ / pre-legal | Certified mail | Firm, professional |
| Pay or Quit | State-specific (3-30 days) | Certified mail + posted | Legal notice |
| Lease Violation | Per lease terms | Written notice | Professional, specific |
| Maintenance Update | N/A | Email/text | Helpful, informative |
| Rent Increase | 30-90 days (state varies) | Written notice | Professional |
| Lease Non-Renewal | 30-60 days (state varies) | Written notice | Professional |
| General Announcement | N/A | Email/posted | Friendly |

### Step 2: Draft Communication
- Professional header with property address, date, tenant name
- Clear statement of purpose
- Specific details (amounts, dates, violations)
- Required action and deadline
- Consequences of non-compliance (where applicable)
- Contact information for questions

### Step 3: Compliance Review
- [ ] Proper notice period for state/jurisdiction
- [ ] No fair housing violations in language
- [ ] Specific and factual (no emotional language)
- [ ] Required legal language included (pay-or-quit, etc.)
- [ ] Delivery method appropriate for notice type

## Output Format
```
TENANT COMMUNICATION DRAFT
═══════════════════════════
Type: [Communication Type]
To: [Tenant Name]
Property: [Address/Unit]
Date: [Date]
Via: [Delivery Method]

---

[Full communication text]

---

⚠️ REVIEW BEFORE SENDING — Confirm with user before any outbound communication
Delivery notes: [Any special instructions]
```

## Example Prompts
- "Draft a friendly late rent reminder — tenant John at Unit 4B, rent was due April 1, today is April 5."
- "Write a lease violation notice — tenant's dog has been off-leash in common areas, second occurrence."
- "Create a rent increase letter — raising rent from $1,200 to $1,275, effective July 1, 60-day notice."
- "Draft a maintenance notification — plumber coming Thursday 10AM-2PM to fix the leak in unit 3."

## Suggested Next Steps
1. **`/transactions/fair-housing`** — Verify communication is compliant
2. **`/property-management/eviction-process`** — If tenant non-responsive to notices
3. **`/property-management/lease-renewal`** — If approaching renewal and communicating terms
