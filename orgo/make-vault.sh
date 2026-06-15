#!/usr/bin/env bash
# make-vault.sh: create a per-principal 1Password vault and share it.
# Package A (runs on the provisioner where `op` is authed, never on the box).
#
# Usage: ./make-vault.sh "Kim" [share-group-or-email ...]
#   Creates vault "Kim - RE Reset" (idempotent) and shares with the given
#   groups/people. Prints the vault id on stdout.
#
# Every credential collected during onboarding goes here via `op item create`,
# never into chat or the brain in plaintext.
set -euo pipefail
NAME="${1:?usage: make-vault.sh <PrincipalName> [share-target ...]}"; shift || true
VAULT="${NAME} - RE Reset"

command -v op >/dev/null 2>&1 || { echo "FAIL: 1Password CLI 'op' not found / not authed" >&2; exit 1; }

# Idempotent: reuse if it exists.
if id=$(op vault get "$VAULT" --format json 2>/dev/null | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])' 2>/dev/null); then
  echo "# vault '$VAULT' already exists ($id)" >&2
else
  id=$(op vault create "$VAULT" --format json | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
  echo "# created vault '$VAULT' ($id)" >&2
fi

for target in "$@"; do
  op vault group grant --vault "$VAULT" --group "$target" --permissions view_items,create_items 2>/dev/null \
    && echo "# shared with group $target" >&2 \
    || op vault user grant --vault "$VAULT" --user "$target" --permissions view_items,create_items 2>/dev/null \
    && echo "# shared with user $target" >&2 \
    || echo "# WARN: could not share with $target (grant by hand)" >&2
done

echo "$id"
