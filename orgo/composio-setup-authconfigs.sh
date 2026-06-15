#!/usr/bin/env bash
# composio-setup-authconfigs.sh: ensure auth configs exist in a box's Composio
# project for the toolkits the agent will connect, and emit the env lines the
# connect MCP needs. Package A (provisioner side).
#
# Uses the PER-BOX PROJECT key (x-api-key), not the org key: auth configs live
# inside the project the connect link draws from.
#
# Usage:
#   COMPOSIO_API_KEY=ak_... ./composio-setup-authconfigs.sh [install.env] [toolkit ...]
#   default toolkits: gmail googlecalendar googledrive slack
#   - prints  COMPOSIO_AUTHCFG_<TOOLKIT>=ac_...  per toolkit to stdout
#   - if install.env given, replaces prior COMPOSIO_AUTHCFG_* lines and appends
#
# VERIFY on first live run: the v3 auth-config endpoints below are the documented
# shape; confirm the exact path + body (Composio-managed auth) and the id field.
set -uo pipefail
ENVOUT=""
case "${1:-}" in *.env) ENVOUT="$1"; shift;; esac
TOOLKITS=("$@"); [ ${#TOOLKITS[@]} -eq 0 ] && TOOLKITS=(gmail googlecalendar googledrive slack)
: "${COMPOSIO_API_KEY:?set COMPOSIO_API_KEY (per-box project key, x-api-key)}"

API="https://backend.composio.dev/api/v3"
hdr=(-H "x-api-key: $COMPOSIO_API_KEY")
out=""

for tk in "${TOOLKITS[@]}"; do
  TKU=$(echo "$tk" | tr '[:lower:]' '[:upper:]')
  # Look for an existing auth config for this toolkit.
  existing=$(curl -s "${hdr[@]}" "$API/auth_configs?toolkit=$tk" \
    | jq -r '(.items // .data // [])[0].id // empty' 2>/dev/null)
  if [ -n "$existing" ]; then
    id="$existing"; echo "# reused auth config for $tk ($id)" >&2
  else
    # Composio-managed auth (no custom OAuth app): toolkit slug + managed auth.
    resp=$(curl -s -X POST "${hdr[@]}" -H "Content-Type: application/json" \
      -d "{\"toolkit\":{\"slug\":\"$tk\"},\"auth_config\":{\"type\":\"use_composio_managed_auth\"}}" \
      "$API/auth_configs")
    id=$(echo "$resp" | jq -r '.id // .auth_config.id // .nano_id // empty')
    if [ -z "$id" ]; then echo "# WARN: could not create auth config for $tk: $(echo "$resp" | jq -c '.error // .' 2>/dev/null)" >&2; continue; fi
    echo "# created auth config for $tk ($id)" >&2
  fi
  out="${out}COMPOSIO_AUTHCFG_${TKU}=${id}"$'\n'
done

printf '%s' "$out"
if [ -n "$ENVOUT" ]; then
  [ -f "$ENVOUT" ] && sed -i.bak -E '/^COMPOSIO_AUTHCFG_/d' "$ENVOUT" && rm -f "$ENVOUT.bak"
  printf '%s' "$out" >> "$ENVOUT"
  echo "# appended auth config ids to $ENVOUT" >&2
fi
