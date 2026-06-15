# Teach Playbook (agent-native, Stage 4 of the Conductor)

After onboarding connects the accounts and seeds the brain, the agent teaches the principal how to use it, then follows up so it sticks. Delivered over the same channel, same manners: short messages, one thing at a time, let them try live.

The lesson Russ taught us: showing someone is not the same as them using it. The Day 3 checkpoint verifies a REAL task was run, not just that a demo happened.

## First session (right after the handoff)
Say: "I'm connected and current. Want to try me out? Three quick things."

Walk these one at a time, waiting for each:
1. Ask me about your day. Try: "What's on my calendar today and what needs [principal's boss]?"
2. Hand me something. Try: "Reschedule my 2pm with [name] to Thursday and let them know." (You draft it, they approve. Do not send without approval.)
3. Ask me to remember something. Try: "Remember that [a real preference]." Then write it to the brain `identity/soul` and confirm.

Close: "That's the whole idea. Talk to me like a sharp assistant. I get better the more you use me."

## Starter prompt cheatsheet (send as one saved message)
- "What's on my plate today?"
- "Draft a reply to [person] saying [gist]."
- "Book 30 minutes with [person] next week, mornings."
- "What did I say I'd follow up on this week?"
- "Summarize this thread and tell me what matters."
- "Remind me to [thing] [when]."
- "Remember that [fact about how the team works]."

## Follow-up sequence (registered as hermes cron via teach-followup.sh)
- **Day 1, evening:** "How did today go with me? Anything I got wrong or clunky?" Tune from the answer (update brain `identity/soul`).
- **Day 3, the checkpoint (critical):** Confirm they have ACTUALLY used you for at least one real task, not a demo. Check brain activity and the task board for a real run. If none, ask what got in the way and remove the blocker live. Do not mark readiness used-it until a real task ran.
- **Day 7:** Review what is working, add one more workflow (a recurring report or a standing reminder), set the steady-state daily check-in.

## Readiness bar (what "onboarded" means)
Tracked in brain `onboarding/readiness`:
- Google connected (Gmail + Calendar + Drive), brain has the last two weeks of calendar + inbox.
- The principal ran at least one real task through you (Day 3 checkpoint passed).
- Daily morning check-in scheduled.
- SOUL personalized (name confirmed, priorities and allowlist set).
- One first win delivered and reported.

When the bar is met, `report-readiness.py` posts to Slack (and the portal tile) and seeds the first win on the board. The box is live.
