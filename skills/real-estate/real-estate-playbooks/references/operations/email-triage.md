---
name: Email Triage
description: "Triage inbox — categorize emails by deals, leads, tenants, marketing, and financial. Flag urgent items and draft routine responses. Triggers on: email, inbox, triage, what needs attention, unread."
---

# Email Triage

## Overview
Process your inbox systematically. Categorizes every email by department, flags urgent items, drafts responses for routine messages, and identifies emails that need your personal attention vs. those that can be delegated or archived.

## When to Use
- Morning inbox processing
- Returning from a day away with full inbox
- End of day — clear the inbox before tomorrow
- Feeling overwhelmed by email volume

## Inputs
- **Gmail inbox** via MCP integration
- **Priority rules**: deal-related > lead responses > tenant issues > everything else
- **Response templates**: for common email types

## Process

### Step 1: Scan and Categorize
Read inbox via Gmail MCP and sort into buckets:

| Category | Examples | Priority | Action |
|----------|---------|----------|--------|
| **DEAL** | Title company, buyer/seller, escrow, contracts | URGENT | Respond same day |
| **LEAD** | New lead inquiries, seller responses, form fills | HIGH | Respond within 1 hour |
| **TENANT** | Maintenance requests, rent questions, lease inquiries | HIGH | Respond within 24 hours |
| **AGENT/PARTNER** | Agent referrals, JV partners, vendor communication | MEDIUM | Respond within 24 hours |
| **MARKETING** | Ad platform notifications, content responses | LOW | Batch process |
| **FINANCIAL** | Bank notices, accounting, invoices | MEDIUM | Forward to bookkeeper |
| **NEWSLETTER/PROMO** | Subscriptions, industry news | LOWEST | Archive or batch read |

### Step 2: Flag Urgent Items
Emails flagged URGENT if they contain:
- Closing deadline within 5 days
- EMD or wire transfer requests
- Contract expiration notices
- Tenant emergency (flooding, lockout, safety)
- Buyer ready to commit on a deal blast

### Step 3: Draft Responses
For routine emails, draft responses for your review:
- Lead inquiry → acknowledge + ask qualifying questions
- Maintenance request → acknowledge + create work order
- Title company request → provide requested documents
- Networking/coffee request → suggest Calendly link

### Step 4: Delegation Recommendations
```
DELEGATE TO VA/TEAM:
- [Email] → [Team member] — [Reason]

FORWARD TO:
- [Email] → CPA/Attorney/PM — [Reason]

ARCHIVE (no action needed):
- [Count] newsletters/promos
```

## Output Format
```
EMAIL TRIAGE — [Date]
═════════════════════
Total Unread: [X]
Urgent: [X] | Deal: [X] | Lead: [X] | Tenant: [X] | Other: [X]

🔴 URGENT (respond now):
[List with subject, sender, action needed]

📋 NEEDS YOUR RESPONSE:
[List with drafts prepared]

📤 DELEGATE:
[List with recommended routing]

📁 ARCHIVE:
[Count] — no action needed
```

## Example Prompts
- "Triage my inbox"
- "What emails need my attention?"
- "Process my unread emails and draft responses for the routine ones."

## Suggested Next Steps
1. **`/operations/daily-briefing`** — Full morning briefing
2. **`/lead-generation/lead-auto-qualifier`** — Score any new leads from inbox
3. **`/property-management/work-order`** — Create work orders from tenant emails
