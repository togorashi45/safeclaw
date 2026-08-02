#!/usr/bin/env bash
# Weekly maintenance window for the brain plane. Covers BOTH gbrain and Hermes.
#
# THE SHAPE: canary Saturday, fleet Sunday.
#   One canary box upgrades first and soaks about 24h. The Sunday fleet run is
#   GATED on the canary's doctor score not regressing. Sunday-night-only was
#   rejected: a bad upgrade would land with no buffer before Monday.
#
# THIS WINDOW IS THE ONLY PATH THAT CHANGES A VERSION. gbrain self-upgrade stays
# OFF on every box (self_upgrade.mode=off, asserted below and re-set if it
# drifts). Nothing else on a box is allowed to move gbrain or Hermes.
#
# Role comes from MAINT_ROLE in /opt/brain/.env:
#   canary  upgrade, verify, publish the gate verdict
#   fleet   read the gate, upgrade only on a go, verify         (default)
#
# The gate. A fleet box has to learn the canary's result somehow. MAINT_GATE_URL
# points at a JSON document the canary publishes. When it is unset or
# unreachable the fleet run FAILS CLOSED: it still runs every read-only check,
# it just does not upgrade. A maintenance window that cannot prove the canary is
# healthy does not get to change a version.
#
# Every run, every box: doctor with the score recorded, stale locks cleared,
# embed --stale, dream cadence still 6-hourly, DB-plane model keys still set,
# spend gates still configured, and the live smoke test.
set -uo pipefail
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:/root/.local/bin:$PATH
set -a; [ -f /opt/brain/.env ] && . /opt/brain/.env; set +a
export GBRAIN_HOME=/opt/brain

# Keep this in sync with GBRAIN_MIN_VERSION in orgo/install-box.sh.
GBRAIN_MIN_VERSION="${GBRAIN_MIN_VERSION:-0.42.69.0}"
GBRAIN_PKG="${GBRAIN_PKG:-github:rspur-hq/gbrain}"
MAINT_ROLE="${MAINT_ROLE:-fleet}"
MAINT_GATE_URL="${MAINT_GATE_URL:-}"
MAINT_GATE_FILE="${MAINT_GATE_FILE:-/opt/brain/maintenance-gate.json}"
MAINT_SCORE_TOLERANCE="${MAINT_SCORE_TOLERANCE:-0}"
MAINT_GATE_MAX_AGE_HOURS="${MAINT_GATE_MAX_AGE_HOURS:-48}"
LOG=/opt/brain/maintenance.log
SMOKE=/root/.hermes/scripts/gbrain-smoke.sh

HB=/root/.hermes/scripts/lib/heartbeat.sh
if [ -f "$HB" ]; then
  # shellcheck source=/dev/null
  . "$HB"
else
  hb_ok() { :; }
  hb_fail() { :; }
fi

PROBLEMS=""
note()    { echo "[maint] $*"; }
problem() { echo "[maint] PROBLEM: $*"; PROBLEMS="$PROBLEMS; $*"; }

# 0.42.69.0 sorts correctly with sort -V. Never use string compare on versions.
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

doctor_score() {
  GBRAIN_HOME=/opt/brain gbrain doctor 2>/dev/null \
    | sed -n 's/^Overall health score: \([0-9][0-9]*\)\/100.*/\1/p' | tail -1
}

# --- gate ---------------------------------------------------------------------
read_gate() { # prints the gate json, or nothing
  if [ -n "$MAINT_GATE_URL" ]; then
    curl -fsS --max-time 20 "$MAINT_GATE_URL" 2>/dev/null && return 0
  fi
  [ -f "$MAINT_GATE_FILE" ] && cat "$MAINT_GATE_FILE"
}

gate_says_go() {
  local gate; gate="$(read_gate)"
  [ -n "$gate" ] || { note "gate unreadable (MAINT_GATE_URL='${MAINT_GATE_URL:-unset}')"; return 1; }
  # Values go in as argv, never interpolated into the source. Quoting bugs in a
  # gate that decides whether to upgrade a fleet are not a risk worth taking.
  # The gate goes through a temp file, not stdin: stdin is taken by the heredoc.
  local gf; gf="$(mktemp)"
  printf '%s' "$gate" > "$gf"
  python3 - "$gf" "$MAINT_GATE_MAX_AGE_HOURS" "$MAINT_SCORE_TOLERANCE" <<'PY'
import json, sys, datetime
gate_path, max_age, tol = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
try:
    g = json.load(open(gate_path))
except Exception:
    print("gate is not valid json"); sys.exit(1)
if g.get("verdict") != "go":
    print("canary verdict is %r, not go" % g.get("verdict")); sys.exit(1)
if g.get("smoke") != "pass":
    print("canary smoke did not pass"); sys.exit(1)
try:
    ts = datetime.datetime.strptime(g["ts"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=datetime.timezone.utc)
except Exception:
    print("gate has no usable ts"); sys.exit(1)
age_h = (datetime.datetime.now(datetime.timezone.utc) - ts).total_seconds() / 3600
if age_h > max_age:
    print("gate is %.1fh old (max %.0fh)" % (age_h, max_age)); sys.exit(1)
before, after = g.get("score_before"), g.get("score_after")
if not isinstance(before, int) or not isinstance(after, int):
    print("gate has no numeric scores"); sys.exit(1)
if after < before - tol:
    print("canary doctor regressed %d -> %d" % (before, after)); sys.exit(1)
print("canary go: %d -> %d, %s" % (before, after, g.get("version", "?")))
PY
  local rc=$?
  rm -f "$gf"
  return $rc
}

publish_gate() { # publish_gate <before> <after> <smoke> <version>
  python3 - "$MAINT_GATE_FILE" "$1" "$2" "$3" "$4" <<'PY'
import json, sys, datetime
path, before, after, smoke, version = sys.argv[1:6]
verdict = "go" if (smoke == "pass" and int(after) >= int(before)) else "no-go"
json.dump({
    "ts": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "role": "canary",
    "version": version,
    "score_before": int(before),
    "score_after": int(after),
    "smoke": smoke,
    "verdict": verdict,
}, open(path, "w"), indent=2)
print("[maint] gate written: %s (%s -> %s, smoke %s)" % (verdict, before, after, smoke))
PY
  # Publishing off-box is deliberately left to whatever serves MAINT_GATE_URL
  # (the admin portal). The file is always written so the canary's own history
  # is on the box even when the publish path is down.
  if [ -n "${MAINT_GATE_PUBLISH_URL:-}" ]; then
    curl -fsS --max-time 20 -X POST -H 'Content-Type: application/json' \
      ${MAINT_GATE_PUBLISH_SECRET:+-H "x-maint-secret: $MAINT_GATE_PUBLISH_SECRET"} \
      --data-binary @"$MAINT_GATE_FILE" "$MAINT_GATE_PUBLISH_URL" >/dev/null \
      || note "gate publish failed (file still written locally)"
  fi
}

# --- upgrade ------------------------------------------------------------------
do_upgrade() {
  note "upgrading gbrain from $GBRAIN_PKG"
  # Same DependencyLoop dance as the product's setup script: bun's global
  # resolver trips when the same package name comes from two sources.
  bun remove -g gbrain >/dev/null 2>&1 || true
  bun install -g "$GBRAIN_PKG" >/dev/null 2>&1 || note "bun install returned nonzero (continuing to the floor check)"
  bun pm -g trust gbrain >/dev/null 2>&1 || true
  local v; v="$(gbrain --version 2>/dev/null | awk '{print $NF}')"
  if [ -z "$v" ] || ! version_ge "$v" "$GBRAIN_MIN_VERSION"; then
    problem "gbrain is ${v:-missing}, below the floor $GBRAIN_MIN_VERSION"
    return 1
  fi
  note "gbrain now $v (floor $GBRAIN_MIN_VERSION)"

  note "upgrading hermes"
  hermes update >/dev/null 2>&1 || note "hermes update returned nonzero"
  note "hermes now $(hermes --version 2>/dev/null | head -1)"
  # A version change means the gateway must rebind its MCP servers.
  supervisorctl restart hermes-gateway >/dev/null 2>&1 || true
  supervisorctl restart gbrain-http >/dev/null 2>&1 || true
  return 0
}

# --- checks -------------------------------------------------------------------
run_checks() {
  note "clearing stale locks"
  gbrain doctor --locks 2>&1 | tail -3 || note "idle-in-transaction backends reported, see above"

  note "embedding stale pages"
  gbrain embed --stale 2>&1 | tail -2 || problem "embed --stale failed"

  note "asserting dream cadence is 6-hourly"
  if hermes cron list 2>/dev/null | grep -A3 'gbrain-dream' | grep -q '\*/6'; then
    note "dream cadence ok"
  else
    problem "gbrain-dream is not on a */6 hour schedule"
  fi

  note "asserting the DB-plane model keys are set"
  for k in models.chat models.tier.reasoning models.dream.extract_atoms; do
    v="$(gbrain config get "$k" 2>/dev/null | tail -1)"
    case "$v" in
      *openrouter:*) : ;;
      *) problem "$k is '${v:-unset}', expected an openrouter model" ;;
    esac
  done

  note "asserting the spend gates are configured"
  for k in spend.posture sync.cost_gate_min_usd embed.backfill_max_usd embed.backfill_max_usd_per_source_24h; do
    v="$(gbrain config get "$k" 2>/dev/null | tail -1)"
    [ -n "$v" ] || problem "$k is unset"
  done

  note "asserting self-upgrade is off"
  if grep -q '"mode": *"off"' /opt/brain/.gbrain/config.json 2>/dev/null; then
    note "self_upgrade.mode off"
  else
    problem "self_upgrade.mode is not off; this window is the only path that changes a version"
    python3 - /opt/brain/.gbrain/config.json <<'PY' || true
import json, sys
p = sys.argv[1]
cfg = json.load(open(p))
cfg.setdefault("self_upgrade", {})["mode"] = "off"
json.dump(cfg, open(p, "w"), indent=2)
print("[maint] self_upgrade.mode reset to off")
PY
  fi

  note "live smoke test"
  if [ -x "$SMOKE" ] && bash "$SMOKE"; then
    SMOKE_RESULT=pass
  else
    SMOKE_RESULT=fail
    problem "live smoke test failed (page -> extract -> takes did not grow)"
  fi
}

# --- main ---------------------------------------------------------------------
# tee via process substitution, NOT a pipeline: a `{ ... } | tee` block runs in a
# subshell, so PROBLEMS and the scores would be lost before the exit gate below.
exec > >(tee -a "$LOG") 2>&1

echo "=== maintenance start $(date -u) role=$MAINT_ROLE ==="
SCORE_BEFORE="$(doctor_score)"
note "doctor before: ${SCORE_BEFORE:-unknown}/100"
SMOKE_RESULT=fail
UPGRADED=no

case "$MAINT_ROLE" in
  canary)
    if do_upgrade; then UPGRADED=yes; fi
    ;;
  *)
    if gate_says_go; then
      note "canary gate is go"
      if do_upgrade; then UPGRADED=yes; fi
    else
      problem "canary gate is not go; running checks only, NOT upgrading"
    fi
    ;;
esac

run_checks
SCORE_AFTER="$(doctor_score)"
note "doctor after: ${SCORE_AFTER:-unknown}/100"

if [ "$MAINT_ROLE" = "canary" ]; then
  case "${SCORE_BEFORE:-}${SCORE_AFTER:-}" in
    ''|*[!0-9]*) note "cannot publish a gate without two numeric scores" ;;
    *) publish_gate "$SCORE_BEFORE" "$SCORE_AFTER" "$SMOKE_RESULT" "$(gbrain --version 2>/dev/null | awk '{print $NF}')" ;;
  esac
fi
echo "=== maintenance end $(date -u) upgraded=$UPGRADED ==="

if [ -n "$PROBLEMS" ]; then
  hb_fail gbrain-maintenance maintenance "role=$MAINT_ROLE score=${SCORE_AFTER:-unknown}${PROBLEMS}"
  echo "GBRAIN MAINTENANCE PROBLEMS:$PROBLEMS"
  exit 1
fi
hb_ok gbrain-maintenance maintenance "role=$MAINT_ROLE doctor ${SCORE_AFTER:-unknown}/100 upgraded=$UPGRADED"
echo "GBRAIN MAINTENANCE DONE (doctor ${SCORE_AFTER:-unknown}/100)"
