#!/usr/bin/env bash
# Live-data smoke test for the brain: write a page, run extraction, assert the
# takes count GREW.
#
# Why this exists: the installer used to "verify" with `gbrain query | head -3`
# and a `|| echo not ready`. An exit code is not proof and a returned count is
# not data. The failure that shipped to the fleet (dream/extract producing zero
# takes on an OpenRouter-only brain) passed every check we had, because nothing
# ever asserted that a real write turned into real extracted content.
#
# This is the one check that exercises the whole paid path end to end: sync ->
# page in Postgres -> chat model call -> takes rows. If the model id is a typo,
# the provider is out of balance, or the resolver is shadowing our config, this
# fails. Doctor can be green through all three.
#
# Exit 0 = takes grew. Exit 1 = anything else. Callers gate on it.
set -uo pipefail
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:$PATH
set -a; [ -f /opt/brain/.env ] && . /opt/brain/.env; set +a
export GBRAIN_HOME=/opt/brain

REPO_DIR=/opt/brain/repo
STAMP=$(date -u +%Y%m%d-%H%M%S)
SLUG="areas/brain-smoke/smoke-$STAMP"
PAGE="$REPO_DIR/$SLUG.md"

takes_count() {
  sudo -u postgres psql -d brain -tAc "SELECT count(*) FROM takes;" 2>/dev/null | tr -d '[:space:]'
}

BEFORE=$(takes_count)
case "$BEFORE" in
  ''|*[!0-9]*) echo "SMOKE FAIL: cannot read the takes table (got '${BEFORE:-empty}')"; exit 1 ;;
esac
echo "smoke: takes before = $BEFORE"

mkdir -p "$(dirname "$PAGE")"
# type MUST be one of concept|atom|lore|briefing|writing|originals: takes
# extraction is gated on the page type, and a `note` page can never yield takes.
cat >"$PAGE" <<EOF
---
type: concept
description: Install smoke test page. Written by gbrain-smoke.sh to prove extraction produces takes.
---

# Install smoke test, $STAMP

This page exists to prove the extraction path works on this box.

The single constraint on an operator's throughput is decision quality, not deal
flow. Systems that raise the floor beat systems that chase upside. A brain that
cannot extract a claim from a page is not a brain, it is a filing cabinet.

Reliability comes before growth. An unverified install is an install that fails
later, in front of a client, on a day nobody is watching.
EOF

if [ ! -f "$REPO_DIR/areas/brain-smoke/index.md" ]; then
  printf -- '---\ntype: index\ndescription: Install and maintenance smoke test pages.\n---\n\n# Brain smoke tests\n' \
    > "$REPO_DIR/areas/brain-smoke/index.md"
fi

( cd "$REPO_DIR" && git add areas/brain-smoke && git commit -q -m "smoke page $STAMP" 2>/dev/null || true )

echo "smoke: syncing the page in"
gbrain sync 2>&1 | tail -2 || { echo "SMOKE FAIL: gbrain sync"; exit 1; }

# takes extraction is opt-in by design (it sends page content to the chat model).
# Enabling it is a deliberate, documented choice for our boxes: it is the only
# recurring producer of takes outside dream, and it is what we are testing.
gbrain config set takes.bootstrap_enabled true >/dev/null 2>&1 || true

echo "smoke: extracting takes"
gbrain takes extract --from-pages --yes --max-pages 10 --holder smoke 2>&1 | tail -3 \
  || { echo "SMOKE FAIL: takes extract exited nonzero"; exit 1; }

AFTER=$(takes_count)
case "$AFTER" in
  ''|*[!0-9]*) echo "SMOKE FAIL: cannot re-read the takes table"; exit 1 ;;
esac
echo "smoke: takes after = $AFTER"

if [ "$AFTER" -gt "$BEFORE" ]; then
  echo "SMOKE PASS: takes grew $BEFORE -> $AFTER"
  exit 0
fi
echo "SMOKE FAIL: takes did not grow ($BEFORE -> $AFTER)."
echo "  Check, in order:"
echo "   1. gbrain config get models.chat  (must be the OpenRouter model, not an Anthropic default)"
echo "   2. gbrain --version               (must clear the floor in install-box.sh)"
echo "   3. the provider balance for OPENROUTER_API_KEY"
exit 1
