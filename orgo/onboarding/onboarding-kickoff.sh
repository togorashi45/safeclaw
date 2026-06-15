#!/usr/bin/env bash
# onboarding-kickoff.sh: start Stage 3 on a freshly installed box.
# Fired once by the orchestrator (Package A) after install goes green.
#
# It: records day-0 for the teach follow-ups, registers the daily teach cron,
# and tells the agent to open the WhatsApp interview (ONBOARDING-PLAYBOOK.md).
#
# VERIFY on first live run: the `hermes` agent-invocation flag that makes the
# agent send the first proactive message.
set -uo pipefail
STATE_DIR=/root/.hermes/onboarding
PLAYBOOK=/opt/safeclaw/orgo/onboarding/ONBOARDING-PLAYBOOK.md
mkdir -p "$STATE_DIR"

# Day 0 for the teach sequence + initialize progress.
grep -q '^START_EPOCH=' "$STATE_DIR/teach-state" 2>/dev/null \
  || echo "START_EPOCH=$(date -u +%s)" >> "$STATE_DIR/teach-state"

# Register the daily teaching follow-up cron.
bash /opt/safeclaw/orgo/routines/teach-followup.sh register || echo "VERIFY: teach cron registration"

# Kick the agent into onboarding mode and send the opening message.
PROMPT="You are now in ONBOARDING MODE. Load and follow ONBOARDING-PLAYBOOK.md ($PLAYBOOK). Send the opening message to the principal over WhatsApp and begin Section A. One question at a time. Track state in the brain page onboarding/progress."
if hermes agent run --profile actor --prompt "$PROMPT" 2>/dev/null; then
  echo "onboarding kicked off (agent sent opening message)"
else
  echo "VERIFY: hermes agent invocation. Falling back to a pending instruction."
  echo "$PROMPT" >> "$STATE_DIR/pending-followups.txt"
fi
