#!/usr/bin/env bash
# Hourly email-ingestion cron entrypoint.
#
# Heartbeat: every run appends to the gbrain integrations plane so
# `gbrain integrations status email-to-brain` reflects reality. Without it
# the plane reported AVAILABLE while this ran 24 times a day.
#
# Wraps email-ingest.sh with the two reliability fixes for the remote-MCP
# cold-start problem (Composio gmail is a remote streamable-HTTP server that
# registers its tools a few seconds AFTER the local brain, so a single agent
# run can start before gmail is ready and abort with "gmail MCP tools
# unavailable"):
#   (1) a Composio gmail MCP readiness pre-check (pre-use health check) so we
#       do not burn agent runs while Composio is cold / throttled / down, and
#       so the connection is warm before the agent opens its own, and
#   (2) bounded retries (auto-reconnect with backoff) to beat the agent-side
#       cold-start race when gmail loses the registration race vs the brain.
# Fast-failing aborts keep the whole thing well under the hermes cron
# script_timeout (1800s in the default config).
#
#   usage: email-ingest-cron.sh [WINDOW] [MAXTURNS] [ATTEMPTS]
#     WINDOW    gmail newer_than window per run   (default 3h, overlaps hourly)
#     MAXTURNS  agent turn cap                    (default 60)
#     ATTEMPTS  cold-start retry attempts         (default 4)
set +e
export HERMES_HOME=/root/.hermes
export GBRAIN_HOME=/opt/brain   # the heartbeat path lives under this home; a wrong home writes where nothing reads
export PATH=/usr/local/bin:/root/.bun/bin:/tmp/node-v20.18.1-linux-x64/bin:$PATH

HB=/root/.hermes/scripts/lib/heartbeat.sh
if [ -f "$HB" ]; then
  # shellcheck source=/dev/null
  . "$HB"
else
  hb_ok() { :; }
  hb_fail() { :; }
fi

WINDOW="${1:-3h}"; MAXTURNS="${2:-60}"; ATTEMPTS="${3:-4}"
INGEST=/root/.hermes/scripts/email-ingest.sh
CFG=/root/.hermes/config.yaml

# --- pre-flight: wait for the Composio gmail MCP to answer tools/list ---
# Reads the gmail server url + x-api-key straight from the default profile config so
# it stays generic across boxes (server may be named gmail, gmail_<name>, etc).
read -r URL KEY < <(python3 - "$CFG" <<'PY'
import sys, yaml
try:
    c = yaml.safe_load(open(sys.argv[1])) or {}
except Exception:
    sys.exit(0)
g = c.get("mcp_servers", {}) or {}
names = [n for n in g if "gmail" in n.lower()]
if names:
    s = g[names[0]] or {}
    print(s.get("url", ""), (s.get("headers", {}) or {}).get("x-api-key", ""))
PY
)

gmail_mcp_ready() {
  [ -z "$URL" ] && return 0   # no gmail server configured -> skip the gate
  curl -s -m 20 -X POST "$URL" \
    -H "x-api-key: $KEY" -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' 2>/dev/null | grep -q "GMAIL"
}

ready=0
for w in $(seq 1 6); do
  if gmail_mcp_ready; then ready=1; break; fi
  echo "pre-flight: gmail MCP not answering tools/list (try $w/6), waiting 10s"
  sleep 10
done
if [ -n "$URL" ] && [ "$ready" -ne 1 ]; then
  echo "INGEST ERROR: Composio gmail MCP not reachable after pre-flight (skipping run)"
  hb_fail email-to-brain ingest "gmail MCP not reachable after pre-flight"
  exit 1
fi

# --- run the agent, retrying only on the cold-start abort ---
for try in $(seq 1 "$ATTEMPTS"); do
  bash "$INGEST" "$WINDOW" "$MAXTURNS" > /tmp/ingest.log 2>&1
  if grep -q "INGEST RESULT:" /tmp/ingest.log && ! tail -3 /tmp/ingest.log | grep -q "INGEST ERROR"; then
    RESULT=$(grep -o 'INGEST RESULT:.*' /tmp/ingest.log | tail -1)
    echo "$RESULT"
    hb_ok email-to-brain ingest "$RESULT"
    exit 0
  fi
  echo "attempt $try did not complete cleanly; retrying"
  sleep 12
done
echo "INGEST ERROR: exhausted $ATTEMPTS attempts"
hb_fail email-to-brain ingest "exhausted $ATTEMPTS attempts"
exit 1
