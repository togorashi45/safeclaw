#!/usr/bin/env bash
# gbrain dream (brain compaction / reflection / link-building), every 6 hours.
#
# Cadence, not nightly: gbrain's cycle_freshness check warns once
# last_full_cycle_at is older than 6h and fails at 24h. A brain that dreams once
# a day is fresh 6h out of 24, so doctor reads 100 in the morning and 95 every
# evening. The honest fix is the schedule (see stage_cron: "5 */6 * * *").
# Steady state cost is small because dream phases are incremental.
#
# Profile-agnostic: it drives the gbrain CLI directly, not a hermes profile.
# The golden stack runs the brain on supervised Postgres, which handles
# concurrent access, so unlike the old PGLite path there is NO single-writer
# lock to release and no brain HTTP server to stop first.
#
# Fails LOUD. A dream that errored used to leave one line in a log nobody reads,
# which is how the 2026-08-01 OpenRouter zero balance went unnoticed. Now the
# run exits nonzero so `hermes cron` records a failure, and it writes an error
# heartbeat the integrations plane can see.
set -uo pipefail
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:$PATH
set -a; [ -f /opt/brain/.env ] && . /opt/brain/.env; set +a   # OPENROUTER_API_KEY etc.
# /opt/brain/.env exports GBRAIN_DATABASE_URL. Re-export GBRAIN_HOME after
# sourcing so nothing in the env file can point this run at another brain.
export GBRAIN_HOME=/opt/brain

HB=/root/.hermes/scripts/lib/heartbeat.sh
if [ -f "$HB" ]; then
  # shellcheck source=/dev/null
  . "$HB"
else
  hb_ok() { :; }
  hb_fail() { :; }
fi

LOG=/opt/brain/dream.log
RC=0
{
  echo "=== dream start $(date -u) ==="
  gbrain dream || RC=$?
  echo "=== dream end $(date -u) rc=$RC ==="
} >> "$LOG" 2>&1

if [ "$RC" -eq 0 ]; then
  hb_ok gbrain-dream dream "cycle ok"
  echo "GBRAIN DREAM DONE"
else
  TAIL=$(tail -5 "$LOG" 2>/dev/null | tr '\n' ' ')
  hb_fail gbrain-dream dream "exit $RC: $TAIL"
  echo "GBRAIN DREAM FAILED (exit $RC). See $LOG"
fi
exit "$RC"
