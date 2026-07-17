# AGENTS.md, SafeClaw operating contract

This repo is SafeClaw (`Vasanth19/safeclaw`), a security-hardened single-user AI email assistant. Hermes uses trust-split reader and actor agents with a GBrain knowledge layer. The Composio MCP layer enforces that readers cannot send and actors cannot see raw email. Read `ARCHITECTURE.md` before changing those boundaries.

## Active Suffolk Deployment

Start with `SUFFOLK-DEPLOYMENT-GUIDE.md`, especially `CURRENT STATUS - START HERE`. Keep its status block and update log current whenever the deployment moves or a new constraint is discovered.

- The GBrain swap is merged to `main`.
- New client deployments track `main` through `CLIENT-DEPLOYMENT-PLAYBOOK.md`.
- Keep `feat/safeclaw-brain-gbrain` for in-flight Suffolk fixes.
- Suffolk's `/opt/safeclaw` clone still tracks that feature branch. Do not repoint it while the deployment is active.
- The Suffolk box also hosts the client's live Brookhaven Solds app on nginx 80/443, uvicorn 8001, and Postgres 5432. Do not disturb it.
- Keep SafeClaw isolated on port 8443 and its internal Docker network. Verify the Brookhaven `/health` endpoint after every VPS change.
- Secrets live in gitignored `suffolk.env`. Never commit or paste them into docs, guidance, logs, or the brain.
- Deployment state is mirrored in the 2nd Brain and `.claude/knowledge/decisions/suffolk-deployment-tracker.md`. Current source files and the running guide win if they disagree with older memory.

## Required References

- `SUFFOLK-DEPLOYMENT-GUIDE.md`: live deployment state.
- `CLIENT-DEPLOYMENT-PLAYBOOK.md`: future-client preflight and distilled gotchas.
- `SUFFOLK-DEPLOY-PLAN.md`: detailed Suffolk runbook.
- `ARCHITECTURE.md`: trust split, tiers, and brain design.
- `DEPLOY-RUNBOOK.md`, `INSTALL.md`, `FIRST-RUN.md`, `HOSTINGER-DEPLOY.md`: general deployment references.

## Verification

- Validate Compose with `docker compose --env-file .env.example config`.
- Validate shell scripts with `bash -n`.
- Validate Python scripts with `python3 -m py_compile`.
- Verify brain retrieval with `bash scripts/smoke-brain.sh`.
- After any Suffolk VPS change, verify Brookhaven health as well as the changed SafeClaw service.
