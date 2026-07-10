#!/usr/bin/env bash
# Weekly brain hygiene: rule-based checks, zero LLM cost. Complements the
# nightly gbrain dream (which is LLM-driven); this pass catches structural rot:
# doctor findings, orphan pages (nothing links to them), and contradictions.
# Writes a report page into the brain repo under areas/brain-hygiene/ so the
# agent (and the morning brief) can surface anything that needs a human.
#
# Profile-agnostic: drives the gbrain CLI directly against supervised Postgres,
# same pattern as gbrain-dream.sh. Every check is best-effort; the CLI surface
# varies by gbrain version, so a missing subcommand degrades to a note instead
# of failing the run.
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:$PATH
set -a; [ -f /opt/brain/.env ] && . /opt/brain/.env; set +a

REPO_DIR=/opt/brain/repo
OUT_DIR="$REPO_DIR/areas/brain-hygiene"
LOG=/opt/brain/hygiene.log
DATE=$(date -u +%Y-%m-%d)
mkdir -p "$OUT_DIR"

run_check() { # run_check <label> <cmd...>
  local label="$1"; shift
  echo "## $label"
  if out=$("$@" 2>&1); then
    echo '```'
    echo "$out" | head -40
    echo '```'
  else
    echo "(check unavailable on this gbrain version: \`$*\`)"
  fi
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
  } > "$OUT_DIR/latest.md"
  # index for the folder (OKF rule: every folder has an index)
  if [ ! -f "$OUT_DIR/index.md" ]; then
    printf -- '---\ntype: index\ndescription: Automated weekly brain hygiene reports.\n---\n\n# Brain hygiene\n\n- [latest report](latest.md)\n' > "$OUT_DIR/index.md"
  fi
  ( cd "$REPO_DIR" && git add areas/brain-hygiene && git commit -q -m "hygiene report $DATE" 2>/dev/null || true )
  gbrain sync 2>/dev/null || echo "VERIFY: gbrain sync subcommand (report page will index on next sync/dream)"
  echo "=== hygiene end $(date -u) ==="
} >> "$LOG" 2>&1
echo "GBRAIN HYGIENE DONE"
