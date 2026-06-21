#!/usr/bin/env bash
# Nightly gbrain dream (brain compaction / reflection / link-building).
# Profile-agnostic: it drives the gbrain CLI directly, not a hermes profile.
# The golden stack runs the brain on supervised Postgres, which handles concurrent
# access, so unlike the old PGLite path there is NO single-writer lock to release
# and no brain HTTP server to stop first.
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.bun/bin:$PATH
set -a; [ -f /opt/brain/.env ] && . /opt/brain/.env; set +a   # OPENROUTER_API_KEY etc.
{
  echo "=== dream start $(date -u) ==="
  gbrain dream
  echo "=== dream end $(date -u) ==="
} >> /opt/brain/dream.log 2>&1
echo "GBRAIN DREAM DONE"
