#!/usr/bin/env bash
# Recurring calendar sync: pull a recent window of Google Calendar via Composio,
# write gbrain daily files, then import + embed. Idempotent (day files overwrite,
# import upserts, embed only touches stale pages).
#   usage: calendar-sync.sh [DAYS_BACK]   (default 45)
#
# Env is sourced EXPLICITLY. This used to rely on `cd /opt/brain` plus Bun's cwd
# .env auto-load to inject the DB url, which is the exact pattern gbrain's
# DATABASE_URL hijack guard exists to police. Source the file, then re-export
# GBRAIN_HOME so nothing inside it can redirect the run at another brain.
set -uo pipefail
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:/tmp/node-v20.18.1-linux-x64/bin:$PATH
set -a; [ -f /opt/brain/.env ] && . /opt/brain/.env; set +a
export GBRAIN_HOME=/opt/brain

HB=/root/.hermes/scripts/lib/heartbeat.sh
if [ -f "$HB" ]; then
  # shellcheck source=/dev/null
  . "$HB"
else
  hb_ok() { :; }
  hb_fail() { :; }
fi

WINDOW="${1:-45}"
RC=0
python3 /opt/brain/scripts/calendar-collect.py "$WINDOW" 2>&1 | tail -1
[ "${PIPESTATUS[0]}" -eq 0 ] || RC=1
gbrain import /opt/brain/repo/daily --no-embed 2>&1 | tail -1
[ "${PIPESTATUS[0]}" -eq 0 ] || RC=1
gbrain embed --stale 2>&1 | tail -1
[ "${PIPESTATUS[0]}" -eq 0 ] || RC=1

if [ "$RC" -eq 0 ]; then
  hb_ok calendar-to-brain sync "window ${WINDOW}d"
  echo "CALENDAR SYNC DONE"
else
  hb_fail calendar-to-brain sync "window ${WINDOW}d, one or more steps failed"
  echo "CALENDAR SYNC FAILED"
fi
exit "$RC"
