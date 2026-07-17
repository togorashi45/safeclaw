---
name: TCPA Compliance
description: "Telephone Consumer Protection Act compliance for cold calling, texting, and ringless voicemail campaigns — consent requirements, DNC management, and penalty awareness. Triggers on: TCPA, text compliance, call compliance, do not call, opt-out."
---

# TCPA Compliance

## Overview
Ensure your cold calling, SMS, and ringless voicemail campaigns comply with the Telephone Consumer Protection Act (TCPA) and state telemarketing laws. TCPA violations carry penalties of $500-$1,500 PER VIOLATION (per call/text), making non-compliance extremely expensive.

## When to Use
- Before launching any cold calling or SMS campaign
- Setting up auto-dialers or mass texting systems
- Reviewing your DNC (Do Not Call) list management
- Training VAs or callers on compliance
- Someone threatens a TCPA lawsuit

## Inputs
- **Campaign type** — cold call, warm call, SMS, RVM, auto-dialer
- **Lead source** — skip trace, list purchase, opt-in, referral
- **Volume** — number of contacts
- **Technology** — manual dial, power dialer, predictive dialer, mass text platform
- **Current consent documentation** — what do you have on file?

## Process

### Step 1: Consent Requirements by Channel

| Channel | Consent Required | Type of Consent |
|---------|-----------------|-----------------|
| Manual cold call (cell) | None (but check DNC) | N/A |
| Manual cold call (landline) | None (but check DNC) | N/A |
| Auto-dialed call (cell) | Prior Express Consent | Written or verbal |
| Pre-recorded/RVM (cell) | Prior Express Written Consent | Written |
| SMS (marketing) | Prior Express Written Consent | Written |
| SMS (informational) | Prior Express Consent | Written or verbal |

### Step 2: Do Not Call (DNC) Compliance
- [ ] Scrub against National DNC Registry (updated every 31 days)
- [ ] Maintain internal DNC list (anyone who says "stop calling")
- [ ] State DNC registries checked (some states have separate lists)
- [ ] DNC requests honored within 30 days (internal) / immediately (best practice)
- [ ] DNC list retained for 5+ years

### Step 3: Calling/Texting Rules
```
CALLING HOURS:
  Federal: 8:00 AM - 9:00 PM (recipient's local time)
  Some states more restrictive — check state laws

CALLER ID:
  Must display valid phone number
  Cannot spoof or block caller ID

AUTO-DIALER RULES:
  Cannot auto-dial cell phones without prior express consent
  Must have opt-out mechanism
  Predictive dialers = auto-dialers under TCPA

SMS RULES:
  Must identify sender in message
  Must include opt-out instruction ("Reply STOP to unsubscribe")
  Must honor opt-out immediately
  Cannot send to reassigned numbers (safe harbor: check)
```

### Step 4: Compliance Checklist
- [ ] Lead list scrubbed against national and state DNC
- [ ] Internal DNC list maintained and checked
- [ ] Consent documented for any auto-dialed or pre-recorded messages
- [ ] Calling hours restricted to 8AM-9PM local time
- [ ] Caller ID displays valid callback number
- [ ] SMS messages include opt-out language
- [ ] Opt-outs processed immediately
- [ ] All consent records retained
- [ ] Callers/VAs trained on TCPA basics
- [ ] Written TCPA policy in place

### Step 5: Penalty Awareness
```
TCPA Penalties:
  Standard violation:    $500 per call/text
  Willful violation:     $1,500 per call/text
  
Example exposure:
  1,000 texts without consent = $500,000 - $1,500,000 liability
  
Class action risk: TCPA is a favorite for class action attorneys
```

## Output Format
```
TCPA COMPLIANCE REVIEW
══════════════════════
Campaign: [Type]
Volume: [X] contacts
Technology: [Manual/Auto-dialer/Mass text]

COMPLIANCE STATUS:
✅ [Compliant items]
⚠️ [Items needing attention]
🔴 [Violations / high-risk items]

REQUIRED ACTIONS BEFORE LAUNCH:
1. [Action item]
2. [Action item]

ESTIMATED RISK EXPOSURE: $[X] if non-compliant
```

## Example Prompts
- "Check TCPA compliance for my cold calling campaign — 2,000 skip-traced numbers, using a power dialer."
- "Is ringless voicemail legal? I want to send 500 RVMs to my seller list."
- "Someone replied STOP to my text. What do I do and how fast?"
- "Review my SMS campaign setup — mass text to 1,000 numbers with opt-in from website form."

## Suggested Next Steps
1. **`/lead-generation/cold-caller`** — Generate compliant cold call scripts
2. **`/lead-generation/sms-responder`** — Set up compliant SMS auto-responses
3. **`/transactions/fair-housing`** — Also review for fair housing compliance
