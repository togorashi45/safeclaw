---
name: Adaptive Follow-Up
description: "Dynamic follow-up sequences that adjust based on lead behavior — opened, replied, went silent, said not now. Multi-channel cadence optimization. Triggers on: follow up, follow-up sequence, nurture, drip, re-engage, lead went cold."
---

# Adaptive Follow-Up

## Overview
Build follow-up sequences that adapt based on how the lead responds. Unlike static drips, this adjusts channel, timing, and messaging based on behavior signals.

## When to Use
- Lead hasn't responded to initial outreach
- Lead said "not now" or "maybe later"
- Need to re-engage a cold lead list
- Building an evergreen nurture system

## Inputs
- Lead name, phone, email, property address
- Current status (no response, said not now, went silent after engagement)
- Channels available (SMS, email, voicemail, direct mail)
- Days since last contact

## Process

### Step 1: Classify Lead Behavior
| Behavior | Classification | Strategy |
|----------|---------------|----------|
| Never responded | COLD | Multi-channel blitz (5 touches, 14 days) |
| Responded then went silent | WARM-GONE | Re-engagement (different angle) |
| Said "not now" / "maybe later" | TIMING | Calendar-based check-ins (30/60/90 days) |
| Engaged but no appointment | STUCK | Overcome specific objection |
| No-showed appointment | FLAKY | High-value re-book attempt |

### Step 2: Generate Sequence by Classification

**COLD — 14-Day Blitz:**
| Day | Channel | Message Angle |
|-----|---------|--------------|
| 0 | SMS | Initial outreach |
| 2 | Voicemail | Personal introduction |
| 4 | SMS | Different angle (mention convenience) |
| 7 | Email | Value content (market report or case study) |
| 10 | SMS | Social proof ("just bought a house in your area") |
| 14 | SMS | Final touch ("last one from me") |

**TIMING — Long-Term Nurture:**
| Interval | Channel | Message |
|----------|---------|---------|
| 30 days | SMS | "Hey [Name], just checking in on [Address]. Any changes?" |
| 60 days | Email | Market update for their area |
| 90 days | SMS | "Things change — still here if you want to chat" |
| 120 days | Direct mail | Postcard with recent deal case study |

### Step 3: Adjust Based on Response
- If they reply at any point → exit sequence, route to live conversation
- If they open email but don't reply → try SMS next
- If SMS delivered but not replied → try different time of day

## Output Format
```
ADAPTIVE FOLLOW-UP PLAN — [Lead Name]
══════════════════════════════════════
Classification: [COLD/WARM-GONE/TIMING/STUCK/FLAKY]
Strategy: [Description]

SEQUENCE:
| Day | Channel | Message | Status |
|-----|---------|---------|--------|
| [X] | [channel] | [summary] | ☐ Pending |
```

## Example Prompts
- "This seller said 'not right now' 3 weeks ago. Set up a follow-up plan."
- "I have 50 leads who never responded to my first text. Build a re-engagement sequence."
- "Seller no-showed twice. What's my recovery play?"

## Suggested Next Steps
1. **`/lead-generation/sms-responder`** — Set up auto-responses for when they reply
2. **`/marketing/postcard-mailer`** — Add direct mail touch for long-term nurture
3. **`/lead-generation/voicemail-drop`** — Record voicemails for the sequence
