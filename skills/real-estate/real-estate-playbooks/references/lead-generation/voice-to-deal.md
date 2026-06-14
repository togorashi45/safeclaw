---
name: Voice to Deal
description: "Transcribe call recordings or voicemails, extract deal details, and create structured lead records from voice notes. Triggers on: voicemail, voice note, transcribe call, call summary, call recording, voice to text."
---

# Voice to Deal

## Overview
Turn raw voice recordings — call recordings, voicemails, or voice memos — into structured deal data. Extracts seller info, property details, motivation signals, and creates a lead record ready for your pipeline.

## When to Use
- After a seller call that needs to be logged
- Processing voicemails from marketing campaigns
- Turning a voice memo (driving for dollars notes) into a lead record
- Batch-processing call recordings from a dialer session

## Inputs
- Voice recording (audio file or transcript text)
- Or: paste raw transcript from call recording software

## Process

### Step 1: Transcribe (if audio)
Use available transcription tools to convert audio to text.

### Step 2: Extract Deal Data
Parse the transcript for:
- **Seller name and contact info**
- **Property address**
- **Property details** (beds, baths, sqft, condition)
- **Asking price or price expectations**
- **Motivation** (why selling — foreclosure, divorce, relocation, tired landlord, estate)
- **Timeline** (how soon they want to close)
- **Mortgage/lien info** (balance, payments current?)
- **Occupancy** (owner-occupied, tenant, vacant)
- **Seller objections or concerns raised**

### Step 3: Score the Lead
Using extracted data, run through lead scoring criteria and assign a 1-10 score.

### Step 4: Generate Lead Record

## Output Format
```
LEAD RECORD — Extracted from [Call/Voicemail/Voice Note]
════════════════════════════════════════════════════════
Seller: [Name] | Phone: [Number] | Email: [if mentioned]
Property: [Address]
Details: [Beds/Baths] | [Sqft] | [Year Built] | [Condition]

DEAL DATA:
Asking Price: $[X] (or "open to offers")
Est. Mortgage: $[X]
Est. Equity: $[X] ([X]%)
Motivation: [Reason]
Timeline: [X days/weeks/months]
Occupancy: [Owner/Tenant/Vacant]

LEAD SCORE: [X]/10 — [Classification]

KEY QUOTES:
- "[Exact quote from seller that shows motivation]"
- "[Any red flags or important statements]"

RECOMMENDED NEXT ACTION:
[Based on score and extracted data]
```

## Example Prompts
- "Transcribe this call recording and extract the deal details: [paste transcript]"
- "I left myself a voice note while driving for dollars. Here's what I said: [paste]. Create a lead record."
- "Process these 5 voicemails from my marketing campaign and score each one."

## Suggested Next Steps
1. **`/lead-generation/lead-auto-qualifier`** — Formally score the extracted lead
2. **`/deal-analysis/comp-pull`** — Pull comps on the property
3. **`/lead-generation/appointment-setter`** — Book appointment if lead is hot
