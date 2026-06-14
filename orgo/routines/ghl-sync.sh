#!/usr/bin/env bash
# Recurring GHL -> gbrain sync: collect the working set (deals, pipeline summary,
# unreplied, appointments) then import + embed. Digest pages regenerate each run;
# deal pages update in place. Contact lookup stays live via the GHL MCP.
export GBRAIN_HOME=/opt/brain
export PATH=/usr/local/bin:/root/.hermes/node/bin:$PATH
python3 /opt/brain/scripts/ghl-collect.py 2>&1 | tail -1
cd /opt/brain && gbrain import /opt/brain/repo/crm --no-embed 2>&1 | tail -1
gbrain embed --stale 2>&1 | tail -1
echo "GHL SYNC DONE"
