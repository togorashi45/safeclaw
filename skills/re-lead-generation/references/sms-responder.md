---
name: SMS Responder
description: "Generate auto-response templates for inbound seller SMS. Match intent, qualify leads via text, and route to appropriate follow-up. Triggers on: SMS, text response, auto-text, text back, inbound text, seller text."
---

# SMS Responder

## Overview
Create intelligent SMS response templates that qualify sellers via text conversation. Maps inbound message intent and responds with the right message to move toward an appointment.

## When to Use
- Setting up auto-responses for new lead texts
- Building a text-based qualification flow
- Seller responds to a mailer or ad via text
- Need templates for VAs handling text conversations

## Inputs
- Lead source (what campaign triggered the text)
- Business name and contact
- Desired call-to-action (book appointment, get property info, gauge interest)

## Process

### Step 1: Classify Inbound Intent

| Intent | Signal Words | Response Type |
|--------|-------------|---------------|
| HOT — Ready to sell | "yes", "interested", "how much", "make offer", "sell my house" | Immediate qualification |
| WARM — Curious | "tell me more", "what do you do", "how does it work" | Value pitch + soft qualify |
| INFO — Wants details | "what's the offer", "how fast", "who are you" | Answer + ask one question |
| NOT NOW | "not right now", "maybe later", "bad timing" | Acknowledge + long-term nurture |
| STOP | "stop", "unsubscribe", "remove" | Immediate opt-out, confirm removal |

### Step 2: Response Templates

**HOT Response:**
```
That's great to hear! I'd love to learn more about your property 
so I can put together a fair offer. Quick question — what's the 
property address and roughly what condition is it in? 
No pressure, just want to give you an accurate number.
```

**WARM Response:**
```
Happy to explain! I'm a local buyer who purchases homes as-is 
for cash. No agents, no fees, close on your timeline. 
Is there a specific property you're thinking about? 
I can give you a quick estimate.
```

**NOT NOW Response:**
```
No worries at all, [Name]. Timing is everything. 
I'll check back in a couple months — if anything changes 
before then, just text me back. Have a good one!
```

### Step 3: Text Qualification Flow
After initial response, qualify via 3-4 texts max:
1. Get property address
2. Ask about condition/situation
3. Ask about timeline
4. Book appointment or make verbal offer range

## Output Format
Complete SMS response playbook with templates for each intent type, plus a 4-message qualification flow.

## Example Prompts
- "Build SMS response templates for my direct mail campaign. Sellers will text a keyword to my number."
- "A seller just texted 'how much for my house at 123 Main?' — draft the response."
- "Create a text qualification flow that gets to an appointment in 4 messages or less."

## Suggested Next Steps
1. **`/lead-generation/appointment-setter`** — Book the appointment once qualified
2. **`/lead-generation/adaptive-follow-up`** — Set up nurture for "not now" leads
3. **`/transactions/tcpa-compliance`** — Verify text campaign compliance
