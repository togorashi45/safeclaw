#!/usr/bin/env bash
# Weekly brain hygiene: rule-based checks, zero LLM cost. Complements the
# 6-hourly gbrain dream (which is LLM-driven); this pass catches structural rot:
# doctor findings, orphan pages (nothing links to them), and contradictions.
# Writes a report page into the brain repo under areas/brain-hygiene/ so the
# agent (and the morning brief) can surface anything that needs a human.
#
# Profile-agnostic: drives the gbrain CLI directly against supervised Postgres,
# same pattern as gbrain-dream.sh.
#
# A FAILING CHECK NOW READS AS FAILED. The old run_check printed
# "(check unavailable on this gbrain version)" for ANY nonzero exit, so a broken
# doctor and a missing subcommand looked identical and both got buried in a page
# nobody gates on. That is a silent-failure generator. run_check now separates
# three states: OK, FAILED (nonzero with real output, surfaced and counted), and
# UNAVAILABLE (the CLI genuinely does not have the subcommand).
set -uo pipefail
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:$PATH
set -a; [ -f /opt/brain/.env ] && . /opt/brain/.env; set +a
# Re-export after sourcing: /opt/brain/.env carries GBRAIN_DATABASE_URL and must
# never be able to redirect this run at a different brain.
export GBRAIN_HOME=/opt/brain

HB=/root/.hermes/scripts/lib/heartbeat.sh
if [ -f "$HB" ]; then
  # shellcheck source=/dev/null
  . "$HB"
else
  hb_ok() { :; }
  hb_fail() { :; }
fi

REPO_DIR=/opt/brain/repo
OUT_DIR="$REPO_DIR/areas/brain-hygiene"
LOG=/opt/brain/hygiene.log
DATE=$(date -u +%Y-%m-%d)
mkdir -p "$OUT_DIR"

FAILED_CHECKS=""
DOCTOR_SCORE=""

run_check() { # run_check <label> <cmd...>
  local label="$1"; shift
  local out rc
  out=$("$@" 2>&1); rc=$?
  echo "## $label"
  if [ "$rc" -eq 0 ]; then
    echo "Status: OK"
  elif [ "$rc" -eq 127 ] || printf '%s' "$out" | grep -q "Unknown command"; then
    # 127 = binary missing from PATH; "Unknown command" = this gbrain build does
    # not ship the subcommand. Neither is a brain problem.
    echo "Status: UNAVAILABLE (this gbrain build has no \`$*\`)"
    echo
    return 0
  else
    echo "Status: **FAILED** (exit $rc)"
    FAILED_CHECKS="$FAILED_CHECKS $label"
  fi
  echo '```'
  printf '%s\n' "$out" | head -40
  echo '```'
  echo
}

{
  echo "=== hygiene start $(date -u) ==="
  {
    echo "---"
    echo "type: log"
    echo "description: Weekly automated brain hygiene report for $DATE (doctor, orphans, contradictions)."
    echo "---"
    echo
    echo "# Brain hygiene report, $DATE"
    echo
    run_check "Doctor"          gbrain doctor
    run_check "Orphan pages"    gbrain orphans
    run_check "Contradictions"  gbrain contradictions
    run_check "Stats"           gbrain stats
    echo "## Summary"
    if [ -n "$FAILED_CHECKS" ]; then
      echo "FAILED checks:$FAILED_CHECKS. A human needs to look at this."
    else
      echo "All checks passed or were unavailable on this build."
    fi
  } > "$OUT_DIR/latest.md"
  # index for the folder (OKF rule: every folder has an index)
  if [ ! -f "$OUT_DIR/index.md" ]; then
    printf -- '---\ntype: index\ndescription: Automated weekly brain hygiene reports.\n---\n\n# Brain hygiene\n\n- [latest report](latest.md)\n' > "$OUT_DIR/index.md"
  fi
  ( cd "$REPO_DIR" && git add areas/brain-hygiene && git commit -q -m "hygiene report $DATE" 2>/dev/null || true )
  gbrain sync 2>/dev/null || echo "NOTE: gbrain sync failed; the report page indexes on the next sync/dream"
  echo "=== hygiene end $(date -u) ==="
} >> "$LOG" 2>&1

# Score the doctor separately so the heartbeat carries a number, not a mood.
DOCTOR_SCORE=$(GBRAIN_HOME=/opt/brain gbrain doctor 2>/dev/null \
  | sed -n 's/^Overall health score: \([0-9][0-9]*\)\/100.*/\1/p' | tail -1)

if [ -n "$FAILED_CHECKS" ]; then
  hb_fail gbrain-hygiene hygiene "failed:$FAILED_CHECKS score=${DOCTOR_SCORE:-unknown}"
  echo "GBRAIN HYGIENE FAILED CHECKS:$FAILED_CHECKS (doctor ${DOCTOR_SCORE:-unknown}/100). See $OUT_DIR/latest.md"
  exit 1
fi
hb_ok gbrain-hygiene hygiene "doctor ${DOCTOR_SCORE:-unknown}/100"
echo "GBRAIN HYGIENE DONE (doctor ${DOCTOR_SCORE:-unknown}/100)"
