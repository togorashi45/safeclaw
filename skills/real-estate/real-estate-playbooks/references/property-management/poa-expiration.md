---
name: POA Expiration Tracker
description: "Track Power of Attorney documents — expiration dates, renewal process, scope verification, and state-specific requirements. Triggers on: POA, power of attorney, POA expiration, POA renewal."
---

# POA Expiration Tracker

## Overview
Track and manage Power of Attorney documents across your deals and portfolio. Monitors expiration dates, verifies scope covers intended transactions, and manages renewal processes. Critical for deals involving absentee sellers, estates, or third-party signers.

## When to Use
- Seller is signing via POA — verify it's valid
- POA approaching expiration on an active deal
- Estate sale or absentee owner situation
- Managing multiple deals with POA-signed documents

## Inputs
- **POA grantor** (person giving authority)
- **POA agent** (person acting on their behalf)
- **POA type** — general, limited/special, durable, springing
- **Execution date** and expiration date
- **Scope** — what transactions are authorized
- **State** of execution and property state
- **Recording status** — recorded with county?

## Process

### Step 1: POA Type Verification
| Type | Scope | Survives Incapacity? | Use Case |
|------|-------|---------------------|----------|
| General | Broad authority | No (unless durable) | Wide-ranging authority |
| Limited/Special | Specific transactions only | No (unless durable) | Single property sale |
| Durable | Broad or limited | Yes | Estate planning, elderly sellers |
| Springing | Activates on condition | Yes | Activates upon incapacity |

### Step 2: Validity Checklist
- [ ] POA is signed and notarized
- [ ] POA has not expired
- [ ] Grantor was competent at time of execution
- [ ] Grantor is still alive (POA dies with grantor)
- [ ] POA has not been revoked
- [ ] Scope covers the specific transaction (property address, sale authority)
- [ ] State requirements met (witnesses, notarization, recording)
- [ ] Title company has reviewed and accepted the POA
- [ ] Lender has accepted the POA (if financing involved)

### Step 3: Expiration Tracking
```
POA EXPIRATION TRACKER
Grantor:         [Name]
Agent:           [Name]
Type:            [General/Limited/Durable/Springing]
Executed:        [Date]
Expires:         [Date]
Days Remaining:  [X]
Status:          [Active/Expiring Soon/Expired]

Transaction:     [Property address / deal reference]
Closing Date:    [Date]
POA Valid Through Closing? [YES/NO]
```

### Step 4: Renewal Process (if expiring)
1. Contact grantor (or guardian) to execute new POA
2. Ensure new POA is notarized per state requirements
3. Record with county clerk if required
4. Provide new POA to title company
5. Update all deal files

## Output Format
```
POA STATUS — [Deal/Property Reference]
══════════════════════════════════════
Grantor: [Name]    Agent: [Name]
Type: [Type]       Expires: [Date]
Status: [Active / Expiring / Expired]

SCOPE COVERS TRANSACTION: [Yes/No]
TITLE COMPANY ACCEPTED: [Yes/No/Pending]

⚠️ ALERTS:
[Any issues or approaching deadlines]

REQUIRED ACTIONS:
[What needs to happen]
```

## Example Prompts
- "Check if the POA on the 123 Main deal is still valid — closing is May 15, POA was signed January 2025."
- "Seller's daughter is signing via POA. What do I need to verify before closing?"
- "The POA expires in 10 days but closing got pushed. What do I do?"

## Suggested Next Steps
1. **`/transactions/wholesale-tc`** — Update closing checklist with POA status
2. **`/transactions/escrow-change-alert`** — Notify title company of POA documents
3. **`/transactions/purchase-agreement`** — Ensure contract reflects POA signer
