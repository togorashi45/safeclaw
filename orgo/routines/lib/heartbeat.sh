#!/usr/bin/env bash
# Shared heartbeat helper for box routines.
#
# gbrain's integrations plane (`gbrain integrations list/status/doctor/stats`)
# reads one JSONL file per integration id:
#
#   $GBRAIN_HOME/.gbrain/integrations/<id>/heartbeat.jsonl
#
# Our routines wrote nothing there, so every integration on every box reported
# AVAILABLE (never installed) while email, calendar and GHL syncs ran daily.
# The status was not lying. We never joined the plane. Source this file and call
# hb_ok / hb_fail at the end of a routine and the plane sees the run.
#
#   source /root/.hermes/scripts/lib/heartbeat.sh
#   hb_ok   calendar-to-brain sync "42 events"
#   hb_fail calendar-to-brain sync "composio 401"
#
# GBRAIN_HOME must be exported before sourcing. Writing under the wrong home is
# the same class of bug as pitfall 1: the file exists, nothing reads it.

hb_write() { # hb_write <id> <event> <status> [detail]
  local id="$1" event="$2" status="$3" detail="${4:-}"
  local home="${GBRAIN_HOME:-/opt/brain}"
  local dir="$home/.gbrain/integrations/$id"
  mkdir -p "$dir" 2>/dev/null || return 0
  python3 - "$dir/heartbeat.jsonl" "$event" "$status" "$detail" <<'PY' 2>/dev/null || true
import json, sys, datetime
path, event, status, detail = sys.argv[1:5]
row = {
    "ts": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "event": event,
    "status": status,
}
if detail:
    row["detail"] = detail[:500]
with open(path, "a") as f:
    f.write(json.dumps(row) + "\n")
PY
}

hb_ok()   { hb_write "$1" "${2:-run}" ok   "${3:-}"; }
hb_fail() { hb_write "$1" "${2:-run}" error "${3:-}"; }
