---
name: Permit Tracker
description: "Track building permits — application status, inspection scheduling, required permits by project type, deadline tracking, and compliance. Triggers on: permit, building permit, permit status, permit application."
---

# Permit Tracker

## Overview
Track building permit applications, inspections, and compliance for rehab and construction projects. Identifies which permits are needed by project type and manages the process from application to final inspection.

## When to Use
- Starting a rehab — need to determine which permits are required
- Tracking permit application status
- Scheduling or tracking inspections
- Ensuring compliance before listing or closing

## Inputs
- **Property address** and jurisdiction (city/county)
- **Scope of work** — what's being done
- **Contractor info** — licensed? pulling permits?
- **Timeline** — project start and target completion

## Process

### Step 1: Determine Required Permits

| Work Type | Permit Usually Required? | Notes |
|-----------|------------------------|-------|
| Electrical (new circuits, panel) | Yes | Must be licensed electrician in most jurisdictions |
| Plumbing (new lines, water heater) | Yes | Licensed plumber required |
| HVAC (new system, ductwork) | Yes | Licensed HVAC contractor |
| Structural (load-bearing walls, foundation) | Yes | Engineer plans may be required |
| Roofing | Varies | Required in most cities |
| Windows/Doors (new openings) | Yes | Especially if changing structural openings |
| Addition/ADU | Yes | Full building permit + plans |
| Cosmetic (paint, flooring, fixtures) | No | No permit needed |
| Fencing | Varies | Check local code, height limits |
| Demolition | Yes | Especially for asbestos-era buildings |

### Step 2: Track Permit Status

| Permit | Type | App Date | Status | Inspector | Inspection Date | Result |
|--------|------|----------|--------|-----------|----------------|--------|
| | | | Applied/Approved/Inspected/Final | | | Pass/Fail/Corrections |

### Step 3: Inspection Sequence
1. Foundation (if applicable)
2. Rough framing
3. Rough plumbing / electrical / HVAC
4. Insulation
5. Drywall (before finishing)
6. Final inspections (each trade)
7. Certificate of Occupancy (if applicable)

## Output Format
```
PERMIT TRACKER — [Property Address]
═══════════════════════════════════
Jurisdiction: [City/County]
Project: [Scope]
Contractor: [Name] — License #[X]

PERMITS NEEDED:
[Table of required permits and status]

UPCOMING INSPECTIONS:
[Scheduled inspections with dates]

COMPLIANCE STATUS: [All clear / Pending items]
```

## Example Prompts
- "What permits do I need for a full rehab at 123 Main — new HVAC, electrical panel upgrade, moving a wall?"
- "Track permit status — electrical approved, plumbing still pending, rough inspection next Tuesday."
- "Do I need a permit to replace windows in Dallas? Same size openings."

## Suggested Next Steps
1. **`/property-management/punch-list`** — Track project items alongside permits
2. **`/property-management/materials-list`** — Generate materials for permitted work
3. **`/deal-analysis/deal-pnl`** — Factor permit costs into deal analysis
