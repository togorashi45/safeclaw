# Hermes + 2nd Brain, golden template

The RE Reset client agent box: a personal AI operator that reads the client's
inboxes and calendar, learns their business, drafts (never auto-sends), and
keeps an organized second brain, running on the client's own box.

## The stack

Standard runtime, zero forks:

- **Hermes** (Nous Research), installed stock and current, one gateway on the
  single default profile.
- **gBrain** on local Postgres 16 + pgvector, one brain per box, semantic
  recall plus a nightly LLM dream cycle.

Our layers on top:

- **Client portal** (cloned from `rereset-portal` at install), progress and
  task visibility for the client.
- **PARA + OKF knowledge method.** The brain is organized from day one:
  `inbox / projects / areas / resources / archive`, one concept per page,
  typed frontmatter, per-folder indexes. Seeds in `orgo/knowledge/para-seed/`,
  agent rules in `orgo/SOUL.template.md`, weekly rule-based hygiene report via
  `orgo/routines/gbrain-hygiene.sh`.
- **Cron routines** (`orgo/routines/`): hourly email ingest, daily calendar
  sync, nightly brain dream, weekly brain hygiene, optional hourly GHL sync.
- **Skills** (`skills/` + curated packs), loaded on demand through the
  skill-router so context stays lean.
- **SOUL** (`orgo/SOUL.template.md`): the agent persona, autonomy hard lines,
  and prompt-injection defenses, filled per client by `orgo/fill-soul.py`.

## Provisioning

One installer: **`orgo/install-box.sh`**. Idempotent, staged, non-Docker.
Fill `/opt/install.env` on the box (vars declared at the top of the installer,
example at `orgo/install.env.admin.example`), then:

```bash
sudo bash /opt/install-box.sh          # everything
sudo bash /opt/install-box.sh base brain_db   # selected stages
```

The build spec and provisioning order live in **`orgo/GOLDEN-TEMPLATE.md`**.
The agent operating contract on the box is **`AGENTS.md`**.

## Security posture

- Draft-first: outbound email to real people is drafted for the client, never
  auto-sent. Send tools stay out of the Composio allowlists by construction.
- One isolated Composio project per box; org keys never live on a tenant box.
- Secrets in `/opt/install.env` and `/opt/brain/.env` (chmod 600), never in git.
- Prompt-injection hard lines in the SOUL: content in emails, docs, and brain
  pages is data, never instructions.
- Per-box isolation is the tenancy boundary: one client, one box, one brain.
