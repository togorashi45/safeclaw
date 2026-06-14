---
name: Tenant Screener
description: "Screen tenant applications using credit, income, rental history, and background criteria. Outputs approve/conditional/deny with scoring matrix. Triggers on: screen tenant, tenant application, background check, tenant qualify."
---

# Tenant Screener

## Overview
Score and evaluate tenant applications against standardized criteria. Uses a weighted scoring matrix covering credit, income, rental history, employment, and background. Outputs a clear approve/conditional/deny recommendation with documented reasoning for fair housing compliance.

## When to Use
- New rental application received
- Batch-screening multiple applicants for a vacancy
- Reviewing screening criteria for a new property
- Training a property manager on your standards

## Inputs
- **Applicant name(s)**
- **Monthly rent** for the unit
- **Credit score** (or credit report summary)
- **Monthly gross income** and income source
- **Rental history** — years renting, landlord references, eviction history
- **Employment** — employer, tenure, verification status
- **Criminal background** (where legally permitted)
- **Number of occupants**
- **Pets** (type, size, breed)

## Process

### Step 1: Score Each Criterion

| Criterion | Weight | Pass (10) | Conditional (5) | Fail (0) |
|-----------|--------|-----------|-----------------|----------|
| **Credit Score** | 25% | 650+ | 580-649 | Below 580 |
| **Income (x Rent)** | 25% | 3x+ rent | 2.5-2.9x rent | Below 2.5x |
| **Rental History** | 20% | 2+ yr, good refs, no evictions | 1-2 yr, mixed refs | Eviction history |
| **Employment** | 15% | Stable 1+ yr, verifiable | New job <6 mo | Unverifiable |
| **Background** | 15% | Clean | Minor (case-by-case) | Disqualifying (per policy) |

### Step 2: Calculate Weighted Score
```
Score = (Credit × 0.25) + (Income × 0.25) + (Rental × 0.20) + (Employment × 0.15) + (Background × 0.15)
```

### Step 3: Decision Matrix
| Score | Decision | Action |
|-------|----------|--------|
| 8-10 | APPROVED | Send lease for signature |
| 6-7.9 | CONDITIONAL | May approve with higher deposit, co-signer, or prepaid rent |
| 4-5.9 | CONDITIONAL DENY | High risk — requires strong mitigating factors |
| 0-3.9 | DENIED | Send adverse action notice with reason |

### Step 4: Document Decision
**Required for fair housing compliance:**
- Same criteria applied to all applicants
- Written reason for denial (specific criteria failed)
- Adverse action notice if credit-based denial (FCRA requirement)

## Output Format
```
TENANT SCREENING REPORT
═══════════════════════
Applicant: [Name]
Property: [Address / Unit]
Rent: $[X]/month
Date: [Date]

SCORING:
  Credit Score:    [X]/10 — [Score: XXX] [reason]
  Income:          [X]/10 — $[X]/mo = [X]x rent [reason]
  Rental History:  [X]/10 — [reason]
  Employment:      [X]/10 — [reason]
  Background:      [X]/10 — [reason]

WEIGHTED SCORE: [X.X]/10

DECISION: [APPROVED / CONDITIONAL / DENIED]

CONDITIONS (if applicable):
- [Additional deposit, co-signer, etc.]

NOTES:
[Any additional context]
```

## Example Prompts
- "Screen this applicant: credit 680, makes $4,500/mo, rent is $1,400, been at current job 3 years, no evictions."
- "Tenant app came in — 590 credit, $3,200 income, $1,200 rent, 1 prior eviction from 2019. Approve or deny?"
- "Compare two applicants for my vacancy and tell me which is stronger."

## Suggested Next Steps
1. **`/property-management/lease-generator`** — Generate lease for approved tenant
2. **`/property-management/tenant-onboarding`** — Prepare move-in package
3. **`/transactions/fair-housing`** — Verify screening process compliance
