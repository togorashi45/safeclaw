#!/usr/bin/env bash
# =============================================================================
# Mint (or reuse) an isolated Composio project + project-level key for ONE box.
#
# Runs on the PROVISIONER (Marcus / the laptop), NEVER on the box. The org/owner
# key (x-org-api-key) stays here; only the resulting PROJECT key is injected into
# the box. That is the isolation guarantee: one Composio project per box, no
# shared key, and the high-privilege org key never transits a tenant box.
#
# USAGE:
#   COMPOSIO_ORG_API_KEY=oak_... ./composio-mint-project.sh <project-name> [install.env]
#     - prints  COMPOSIO_API_KEY=<key>  (+ _PROJECT_ID / _PROJECT_NAME) to stdout
#     - if install.env is given, replaces any prior COMPOSIO_* project lines in it
#       and appends the new ones (ready to push to the box). The org key is never
#       written to that file.
#
# Idempotent: if a project with <project-name> already exists, its key is
# regenerated (the old one is invalidated) rather than creating a duplicate.
# =============================================================================
set -euo pipefail
NAME="${1:?usage: composio-mint-project.sh <project-name> [install.env]}"
ENVOUT="${2:-}"
: "${COMPOSIO_ORG_API_KEY:?set COMPOSIO_ORG_API_KEY (org/owner key, x-org-api-key)}"

API="https://backend.composio.dev/api/v3.1/org/owner"
hdr=(-H "x-org-api-key: $COMPOSIO_ORG_API_KEY")
# config is REQUIRED on create (verified live). log_visibility_setting enum is
# 'show_all' | 'dont_store_data'. Secrets masked in connected accounts.
CONFIG='{"is_2FA_enabled":false,"mask_secret_keys_in_connected_account":true,"log_visibility_setting":"show_all"}'

# A project key is shown ONLY at creation, and key regeneration is DISABLED for
# this org, so an existing project's key cannot be retrieved here. If the project
# already exists, stop and tell the operator (reuse the stashed key, or delete + rerun).
existing=$(curl -s "${hdr[@]}" "$API/project/list" \
           | jq -r --arg n "$NAME" '(.data // [])[] | select(.name==$n) | .id' | head -1)
if [ -n "$existing" ] && [ "$existing" != null ]; then
  cat >&2 <<MSG
FAIL: Composio project '$NAME' already exists ($existing).
Its key cannot be fetched (shown only at creation; regeneration disabled for this org).
Reuse the key you stashed at creation, or delete the project and re-run:
  curl -s -X DELETE -H "x-org-api-key: \$COMPOSIO_ORG_API_KEY" "$API/project/$existing"
MSG
  exit 1
fi

resp=$(curl -s "${hdr[@]}" -H "Content-Type: application/json" \
       -d "{\"name\":\"$NAME\",\"should_create_api_key\":true,\"config\":$CONFIG}" \
       "$API/project/new")
pid=$(echo "$resp" | jq -r '.id // .nano_id // empty')
# api_key may be a bare string OR an object {key:...}; handle both.
key=$(echo "$resp" | jq -r '(.api_key | if type=="object" then .key else . end) // empty')
echo "# created Composio project '$NAME' ($pid)" >&2

[ -n "${key:-}" ] && [ "$key" != null ] || { echo "FAIL: no project key in create response:" >&2; echo "$resp" | jq -c '.error // .' >&2; exit 1; }

out=$(printf 'COMPOSIO_API_KEY=%s\nCOMPOSIO_PROJECT_ID=%s\nCOMPOSIO_PROJECT_NAME=%s\n' "$key" "$pid" "$NAME")
echo "$out"

if [ -n "$ENVOUT" ]; then
  [ -f "$ENVOUT" ] && sed -i.bak -E '/^COMPOSIO_(API_KEY|PROJECT_ID|PROJECT_NAME)=/d' "$ENVOUT" && rm -f "$ENVOUT.bak"
  echo "$out" >> "$ENVOUT"
  echo "# appended project key to $ENVOUT (org key NOT written)" >&2
fi
