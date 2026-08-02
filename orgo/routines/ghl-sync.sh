#!/usr/bin/env bash
# Recurring GHL -> gbrain sync: collect the working set (deals, pipeline summary,
# unreplied, appointments) then import + embed. Digest pages regenerate each run;
# deal pages update in place. Contact lookup stays live via the GHL MCP.
#
# Same env discipline as calendar-sync.sh: source /opt/brain/.env explicitly,
# then re-export GBRAIN_HOME so the env file cannot redirect the run.
#
# Heartbeat id note: there is no shipped `ghl-to-brain` recipe, so
# `gbrain integrations list` will not render this one. The JSONL is still written
# for local observability and for the weekly maintenance run to read.
set -uo pipefail
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:/root/.hermes/node/bin:$PATH
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

RC=0
python3 /opt/brain/scripts/ghl-collect.py 2>&1 | tail -1
[ "${PIPESTATUS[0]}" -eq 0 ] || RC=1
gbrain import /opt/brain/repo/crm --no-embed 2>&1 | tail -1
[ "${PIPESTATUS[0]}" -eq 0 ] || RC=1
gbrain embed --stale 2>&1 | tail -1
[ "${PIPESTATUS[0]}" -eq 0 ] || RC=1

if [ "$RC" -eq 0 ]; then
  hb_ok ghl-to-brain sync "working set refreshed"
  echo "GHL SYNC DONE"
else
  hb_fail ghl-to-brain sync "one or more steps failed"
  echo "GHL SYNC FAILED"
fi
exit "$RC"
