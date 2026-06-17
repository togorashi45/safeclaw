#!/usr/bin/env bash
# =============================================================================
# Provision ONE box's AgentMail email identity: create the inbox + mint an
# INBOX-SCOPED key. Runs on the PROVISIONER (Marcus / laptop), NEVER on the box.
#
# The org key (AGENTMAIL_ORG_KEY) stays here and only does two things: create the
# inbox and mint a key scoped to JUST that inbox. Only the scoped key is injected
# into the box, so the box can send/read its own inbox and nothing else (same
# isolation guarantee as the per-box Composio project key).
#
# USAGE:
#   AGENTMAIL_ORG_KEY=am_... ./agentmail-provision.sh <slug> [install.env]
#     <slug>        -> inbox <slug>-rereset@agentmail.to
#     install.env   -> appends AGENTMAIL_INBOX + AGENTMAIL_API_KEY (scoped). The
#                      org key is never written to that file.
# =============================================================================
set -euo pipefail
SLUG="${1:?usage: agentmail-provision.sh <slug> [install.env]}"
ENVOUT="${2:-}"
: "${AGENTMAIL_ORG_KEY:?set AGENTMAIL_ORG_KEY (org key, NOT a scoped key)}"
API="https://api.agentmail.to/v0"
INBOX="${SLUG}-rereset@agentmail.to"
hdr=(-H "Authorization: Bearer $AGENTMAIL_ORG_KEY" -H "Content-Type: application/json")

# 1. Create the inbox (idempotent: a 409/exists is fine).
disp="$(echo "$SLUG" | sed 's/.*/\u&/') RE Reset Agent"
curl -s "${hdr[@]}" -d "{\"username\":\"${SLUG}-rereset\",\"display_name\":\"$disp\"}" "$API/inboxes" >/dev/null || true

# 2. Mint an inbox-scoped key.
resp=$(curl -s "${hdr[@]}" -d "{\"name\":\"${SLUG}-box\",\"inbox_ids\":[\"$INBOX\"]}" "$API/api-keys")
key=$(echo "$resp" | jq -r '.api_key // empty')
[ -n "$key" ] && [ "$key" != null ] || { echo "FAIL: no scoped key in response:" >&2; echo "$resp" | jq -c '.' >&2; exit 1; }

out=$(printf 'AGENTMAIL_INBOX=%s\nAGENTMAIL_API_KEY=%s\n' "$INBOX" "$key")
echo "$out"
echo "# created inbox $INBOX + minted inbox-scoped key (org key NOT written)" >&2

if [ -n "$ENVOUT" ]; then
  [ -f "$ENVOUT" ] && sed -i.bak -E '/^AGENTMAIL_(INBOX|API_KEY)=/d' "$ENVOUT" && rm -f "$ENVOUT.bak"
  echo "$out" >> "$ENVOUT"
fi
