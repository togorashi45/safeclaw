---
name: Work Order Manager
description: "Create and manage maintenance work orders — priority levels, contractor assignment, cost tracking, tenant communication, and completion verification. Triggers on: work order, maintenance request, repair, fix, broken."
---

# Work Order Manager

## Overview
Create, track, and manage property maintenance work orders from request to completion. Assigns priority, routes to contractors, tracks costs, and manages tenant communication throughout the process.

## When to Use
- Tenant submits a maintenance request
- Property inspection reveals needed repairs
- Preventive maintenance scheduling
- Tracking open work orders across portfolio

## Inputs
- **Property address and unit**
- **Issue description** — what's broken/needed
- **Reported by** — tenant, inspection, PM
- **Priority assessment** — see classification below
- **Preferred contractor** (if any)
- **Budget limit** for this repair

## Process

### Step 1: Classify Priority

| Priority | Response Time | Examples |
|----------|-------------|---------|
| EMERGENCY | Immediate (2-4 hrs) | Gas leak, flooding, no heat (<40°F), fire damage, security breach (broken lock/window) |
| URGENT | 24 hours | No hot water, AC out (>95°F), toilet not working (only one), major leak contained |
| ROUTINE | 3-7 days | Minor leak, appliance issue, running toilet, cosmetic damage |
| SCHEDULED | 2-4 weeks | Preventive maintenance, upgrades, non-urgent improvements |

### Step 2: Create Work Order
```
WORK ORDER #[Auto-generated]
Date: [Date]
Priority: [EMERGENCY/URGENT/ROUTINE/SCHEDULED]

Property: [Address/Unit]
Tenant: [Name] — [Phone] — [Access instructions]
Issue: [Detailed description]
Location in property: [Specific room/area]

Assigned to: [Contractor/Handyman]
Contact: [Phone/Email]
Budget limit: $[X]
Scheduled for: [Date/Time]
```

### Step 3: Contractor Coordination
- Notify contractor with work order details
- Confirm scheduling with tenant (access needed?)
- Verify contractor insurance/license current
- Set budget expectations (call before exceeding $[X])

### Step 4: Completion and Closeout
- [ ] Work completed and verified
- [ ] Tenant confirmed satisfaction
- [ ] Invoice received and matched to work order
- [ ] Payment processed
- [ ] Before/after photos filed
- [ ] Work order closed in system

## Output Format
```
WORK ORDER — [Property/Unit]
════════════════════════════
WO#: [Number]     Priority: [Level]
Date: [Date]      Status: [Open/In Progress/Complete]

ISSUE: [Description]
LOCATION: [Room/Area]
REPORTED BY: [Name]

ASSIGNED: [Contractor] — [Phone]
SCHEDULED: [Date/Time]
BUDGET: $[X]

TENANT COMMUNICATION:
[Draft message to tenant about the repair]

ACTUAL COST: $[X] (upon completion)
```

## Example Prompts
- "Tenant reports the kitchen faucet is leaking at 123 Main Unit A. Create a work order."
- "Emergency — no heat at 456 Oak, it's 30 degrees outside. Tenant has a baby."
- "What work orders are open across my portfolio?"
- "Close out the plumbing work order at 789 Elm — Joe's Plumbing fixed it for $275."

## Suggested Next Steps
1. **`/property-management/tenant-communication`** — Notify tenant of repair schedule
2. **`/property-management/materials-list`** — Generate materials list for the repair
3. **`/property-management/portfolio-dashboard`** — View maintenance status across portfolio
