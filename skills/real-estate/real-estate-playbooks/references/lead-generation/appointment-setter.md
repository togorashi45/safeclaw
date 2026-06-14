---
name: Appointment Setter
description: "Book appointments with qualified sellers. Includes confirmation sequences, reminder flows, no-show recovery scripts, and scheduling logistics. Triggers on: set appointment, book appointment, schedule showing, appointment bot, book a call."
---

# Appointment Setter

## Overview
Convert qualified leads into booked appointments. Handles the full appointment lifecycle: booking, confirmation, reminders, and no-show recovery to maximize show rates.

## When to Use
- Lead is qualified and ready for an appointment
- Need to set up automated appointment reminders
- Seller no-showed and needs re-engagement
- Batch-booking appointments from a qualified lead list

## Inputs
- Lead name, phone, email
- Property address
- Preferred days/times for the appointment
- Appointment type (phone call, property walkthrough, virtual meeting)
- Seller's timezone

## Process

### Step 1: Booking Message
```
"[Name], I'd love to come take a quick look at [address] 
so I can put together a fair offer for you. 
Would [Day1] or [Day2] work better? 
I just need about 15 minutes."
```

### Step 2: Confirmation Sequence
Once booked:
- **Immediately:** "Got it — [Day, Date] at [Time] at [Address]. Looking forward to it. I'll send a reminder the day before. — [Your Name]"
- **24 hours before:** "Hey [Name], just confirming our appointment tomorrow at [Time] at [Address]. See you there!"
- **2 hours before:** "On my way shortly — see you at [Time]. If anything comes up, just text me."

### Step 3: No-Show Recovery
If seller doesn't show:
- **15 min after:** "Hey [Name], I'm here at [Address] — are you still able to make it today?"
- **Same day evening:** "No worries about today. Would you like to reschedule? I'm flexible this week."
- **48 hours later:** "Hey [Name], still interested in getting an offer on [Address]? Happy to work around your schedule."

### Step 4: Post-Appointment
After the meeting:
- Log meeting notes
- Score/update lead
- Generate offer or next steps

## Output Format
```
APPOINTMENT BOOKED
══════════════════
Seller: [Name] | Phone: [Number]
Property: [Address]
Date/Time: [Day, Date at Time]
Type: [In-person walkthrough / Phone / Virtual]

REMINDER SCHEDULE:
☐ 24h before — confirmation text
☐ 2h before — "on my way" text
☐ 15m after no-show — check-in text
☐ 48h after no-show — reschedule text
```

## Example Prompts
- "Book an appointment with John Smith at 456 Oak Ave for Thursday afternoon."
- "My seller no-showed today's appointment at 2pm. Send the recovery sequence."
- "Set up appointment reminders for all 5 of my appointments this week."

## Suggested Next Steps
1. **`/deal-analysis/comp-pull`** — Pull comps before the appointment
2. **`/operations/meeting-prep`** — Prep for the seller meeting
3. **`/deal-analysis/arv-calculator`** — Calculate ARV to prepare your offer
