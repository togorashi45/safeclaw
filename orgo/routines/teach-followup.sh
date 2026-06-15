#!/usr/bin/env bash
# teach-followup.sh: drive the Stage 4 day 1/3/7 teaching follow-ups.
#
# Registered as ONE daily hermes cron. Each run computes days-since-onboarding
# from a state file, and on day 1, 3, and 7 (once each) it has the agent send
# the matching follow-up from TEACH-PLAYBOOK.md. Idempotent: a fired day is
# marked done so it never repeats.
#
#   onboarding-kickoff.sh writes START_EPOCH on day 0.
#   register:  teach-followup.sh register   -> registers the daily cron
#   run (cron): teach-followup.sh            -> fires the due follow-up, if any
#
# VERIFY on first live run: the `hermes` agent-invocation flag that makes the
# agent proactively message the principal (shown as `hermes agent run --prompt`
# below). Confirm against the installed Hermes; falls back to writing a task the
# agent picks up on its next turn.
set -uo pipefail
STATE_DIR=/root/.hermes/onboarding
STATE="$STATE_DIR/teach-state"
PLAYBOOK=/opt/safeclaw/orgo/onboarding/TEACH-PLAYBOOK.md
mkdir -p "$STATE_DIR"

DAY1='Day 1 check-in. Ask: "How did today go with me? Anything I got wrong or clunky?" Tune from the answer and update the brain identity/soul page.'
DAY3='Day 3 checkpoint (the critical one). Confirm the principal has actually used you for at least one REAL task, not a demo. Check brain activity and the task board. If none, ask what got in the way and remove the blocker live. Do not mark readiness used-it until a real task ran.'
DAY7='Day 7. Review what is working, add one recurring workflow (a standing report or reminder), and set the steady-state daily check-in.'

fire() { # $1 = day label, $2 = instruction
  local day="$1" instr="$2"
  if grep -q "^done_${day}=" "$STATE" 2>/dev/null; then return 0; fi
  # VERIFY: agent-driven invocation. Make the agent run this instruction and message the principal.
  if hermes agent run --profile actor --prompt "ONBOARDING TEACH FOLLOWUP. $instr Use TEACH-PLAYBOOK.md ($PLAYBOOK)." 2>/dev/null; then
    :
  else
    # Fallback: drop a task page the agent will pick up next turn.
    echo "TEACH FOLLOWUP ($day): $instr" >> "$STATE_DIR/pending-followups.txt"
  fi
  echo "done_${day}=$(date -u +%s)" >> "$STATE"
  echo "fired teach followup: $day"
}

case "${1:-run}" in
  register)
    # VERIFY: cron registration flags match the routines/ pattern.
    HERMES_HOME=/root/.hermes/profiles/actor hermes cron create "0 23 * * *" \
      --name teach-followup --script teach-followup.sh --no-agent --deliver local \
      || echo "VERIFY: hermes cron create flags for teach-followup"
    echo "registered daily teach-followup cron (23:00)"
    ;;
  run)
    [ -f "$STATE" ] || { echo "no teach-state yet (onboarding-kickoff writes START_EPOCH)"; exit 0; }
    START=$(sed -n 's/^START_EPOCH=//p' "$STATE" | head -1)
    [ -n "$START" ] || { echo "no START_EPOCH in state"; exit 0; }
    DAYS=$(( ( $(date -u +%s) - START ) / 86400 ))
    echo "days since onboarding: $DAYS"
    case "$DAYS" in
      1) fire day1 "$DAY1" ;;
      3) fire day3 "$DAY3" ;;
      7) fire day7 "$DAY7" ;;
      *) echo "no follow-up due on day $DAYS" ;;
    esac
    ;;
  *) echo "usage: teach-followup.sh [register|run]"; exit 1 ;;
esac
