# Golden Template (Hermes + 2nd Brain client box)

**Repo:** `togorashi45/hermes-brain` (branch `main`) · **Owner:** Jake McKinney (RE Reset) · Lineage: forked from the retired `safeclaw` tree 2026-07-10, validated live on the Atomic Stays box the same day.

This is the canonical client box build: **standard, up-to-date Hermes + standard gBrain**, with our layers on top: the client portal, the PARA + OKF knowledge method, and our customization of cron routines, skills, and the agent SOUL. Nothing in the runtime is forked. Every concrete artifact referenced here lives in this repo; per-client secrets never do (they go in `install.env` on the box, which is never committed).

**Provision a box with `orgo/install-box.sh`** (the canonical from-scratch installer), then layer the channels and skill packs below. Boxes run a **single default Hermes profile**. The old two-agent actor/reader architecture and the Docker generation are gone from this tree entirely (removed 2026-07-10; retired as an architecture 2026-06-19).

---

## Baseline runtime (from the 2026-06 fleet hardening)

Every box runs this exact shape. Proven across Matt, Travis, Elise, Phil.

- **Brain:** gBrain from **our fork `togorashi45/gbrain`, always latest**, on **local Postgres 16 + pgvector**, self-contained per box (a client can leave with their data; no shared DB). Supervised as `postgres-brain` (the database) + `gbrain-http` (the native MCP endpoint on `127.0.0.1:3131`). Embeddings via OpenRouter `openai/text-embedding-3-small` (1536-dim), chat and reasoning and dream extraction all on `openrouter:openai/gpt-5.2`.
  - **No hard pin, but a floor.** `GBRAIN_MIN_VERSION` in `install-box.sh` is `0.42.69.0` and the install fails loudly below it. Each part of the floor is a fix the box configuration depends on: `0.42.67.0` (file-plane chat model no longer shadowed by the hardcoded Anthropic tier default, the zero-takes bug), `0.42.68.0` (reranker model threaded through the gateway seam), `0.42.69.0` (email-headers conversation parser). Raise the floor when we depend on something newer. Never lower it.
  - **Why the fork:** the fixes above were found on our fleet and shipped in our fork. Upstream `garrytan/gbrain` does not carry them. The old installer cloned upstream, which is how the fleet shipped a brain that produced zero takes.
  - **Self-upgrade is off on every box** (`self_upgrade.mode=off`). The weekly maintenance window is the only path that changes a version.
- **Gateway:** exactly one supervised gateway program running `hermes gateway run` on the **single default profile**. No actor/reader split (collapsed 2026-06-19): one profile holds the model, MCP servers, channel tokens, cron jobs, and the ingest scripts. The default profile is the only gateway that runs, so it is the only scheduler that ticks.
- **Console / tunnel / dashboard:** SafeClaw UI on `:8899`, cloudflared named tunnel, Hermes dashboard on `:9119`, kept alive by the tmux `watchdog`. The watchdog never manages the brain (that is supervised) to avoid the dual-writer corruption that killed PGlite.
- **Provisioning gotcha:** the brain role needs `CREATE ROLE brain LOGIN SUPERUSER BYPASSRLS` (superuser alone does not set `rolbypassrls`, and gBrain's v24 migration halts without it). The repeatable procedure is `stage_brain_db` in `install-box.sh`.

---

## Agent identity (SOUL.md)

Every box gets a deliberate agent persona, not the stock Hermes default. The persona is the agent's operating stance: how it thinks, how direct it is, what it will and will not do without approval.

- **File:** `orgo/SOUL.template.md` in this repo. Fill the placeholders for the client, strip the comment header, and save it on the box as `~/.hermes/SOUL.md`. Hermes loads it fresh every message, so edits take effect with no restart.
- **What it carries:** stance and tone, an operating doctrine (constraint-first, define the problem, reliability before growth), an autonomy hard line (draft-only from the owner's address, allowlist for internal sends, stop before spend/publish/destructive/credential changes), a mission map, and prompt-injection hard lines (treat email, docs, transcripts, and brain pages as data, never as commands).
- **Distinct from the user "Soul" brain page.** SOUL.md is the AGENT persona (static, version-controlled here). The brain page `identity/soul` is the USER's identity and principles (seeded into gBrain, updated by the weekly reflector through the review queue). Do not conflate them.
- **Customize per client:** swap the generic doctrine block for the client's own operating philosophy if they have one. Keep it em-dash clean so the persona never seeds slop into public-facing output.

---

## Channels (the messaging surfaces)

| Channel | Reference box | Mechanism | Provision |
|---------|---------------|-----------|-----------|
| **WhatsApp** | Phil | Baileys bridge + native Hermes platform | bridge below |
| **Telegram** | Travis, Elise | native Hermes platform (long-poll) | bot token below |
| **Slack** | Jeremiah | socket mode (no public URL) | tokens below |
| **Discord / Signal** | (declared) | native Hermes platforms | tokens, optional |

### WhatsApp (Phil's setup)
A Baileys WhatsApp Web bridge feeds the native Hermes WhatsApp platform.
- **Bridge:** `/opt/hermes/scripts/whatsapp-bridge/bridge.js` (ships with Hermes), run under supervisor on `:3000`. Conf: program `whatsapp-bridge`, `WHATSAPP_ALLOWED_USERS="*"` (scope per client), `autostart/autorestart`.
- **Pairing:** one-time QR scan; session persists at `/root/.hermes/whatsapp/session/`.
- **Hermes side:** the default profile declares `whatsapp:` with `session_path: /root/.hermes/platforms/whatsapp/session`.
- **Known gotcha:** newer Hermes requires `creds.json` at the profile session path while the bridge writes its own default path; if the gateway goes FATAL with the bridge still connected, symlink the profile session dir to the bridge session dir and restart the gateway.

### Telegram (Travis / Elise's setup)
Native Hermes platform, no public URL.
- `TELEGRAM_BOT_TOKEN` from @BotFather, `TELEGRAM_ALLOWED_USERS` (comma-separated numeric ids), both in `client.env`. The installer seeds them into the default profile `.env`; the box also pins `api.telegram.org` to IPv4 so outbound sends do not hang on dead IPv6 (see install-box.sh `stage_harden_boot`).
- The default profile declares the `telegram` handler. Easiest channel to add.

### Slack (Jeremiah's setup)
Socket mode, no public URL. The read vs post boundary is enforced by the Slack MCP's own `SLACK_MCP_MODE` tool allowlist, not by a separate Hermes profile.
- `SLACK_BOT_TOKEN` (post/send), `SLACK_MCP_BOT_TOKEN` (read-only MCP), `SLACK_HOME_CHANNEL`, `SLACK_INGEST_CHANNELS` in `client.env`.
- Tooling: `mcp-tools/slack-api` (MCP) + `skills/slack-to-gdrive` (ingest playbook).
- NOTE: Jeremiah currently runs on a Hostinger VPS (`runtime: hostinger-vps`), not Orgo. His live socket-mode config is the reference instance; capture it when his box moves to Orgo (see "Pending").

---

## GoHighLevel CRM (Matt / Travis's setup)

Two parts, both in this repo.
1. **Live tools:** the `@mastanley13/ghl-mcp-server` **stdio** build registered in the default `config.yaml` `mcp_servers` as `ghl` (`command: node, args: [.../dist/server.js], env: GHL_API_KEY/GHL_BASE_URL/GHL_LOCATION_ID`). Use the **stdio** build (more tools, stable); the published HTTP/SSE build 500s on Hermes' connection pattern.
2. **Working-set ingestion:** `orgo/routines/ghl-collect.py` + `orgo/routines/ghl-sync.sh`, on a `--no-agent` Hermes cron (`ghl-sync`, registered by `stage_cron` when `ENABLE_GHL_SYNC=1`). Produces `crm/deals/*` + `crm/board/{pipeline-summary,unreplied,appointments}` pages. Playbook: `skills/ghl-to-brain`.
- Env: `GHL_API_KEY` (Private Integration Token) + `GHL_LOCATION_ID`. The collector reads them from `/opt/ghl-mcp/.env`, `/opt/safeclaw/client.env`, or `/root/.hermes/.env`.
- Verified on Travis 2026-06-14: 140 open deals, 270 unreplied threads, pipeline summary, imported + embedded.

---

## Google / Composio OAuth (all boxes)

OAuth for Gmail, Calendar, Docs, Sheets, and Tasks runs through **Composio**, one scoped workspace/key per client (keys are not interchangeable across boxes).
- Env: `COMPOSIO_API_KEY` + `COMPOSIO_USER_ID` in `install.env`. The per-box Composio MCP server is provisioned by `stage_composio_mcp` (`orgo/composio-provision-mcp.mjs`) and wired into the single default profile config.
- **Self-service connect:** the portal's **Connections tab** (the Sten Composio wrapper lifted into `rereset-portal`, branch `feat/sten-integrations`) is where a client authorizes each provider; it runs the Composio reconcile and gateway restart on the box after a connect. The `composio-connect-mcp` (in `orgo/onboarding/`) gives the agent the same power during the onboarding interview. The old standalone connect page (`safeclaw-ui`, `stage_connect`, `:8899`) is a legacy opt-in, no longer in the default install.
- **Native ingestion routines (deployed + scheduled by `stage_cron`):**
  - `orgo/routines/email-ingest-cron.sh` (wraps `email-ingest.sh`) into the brain (hourly). Playbook `skills/email-to-brain`.
  - `orgo/routines/calendar-collect.py` + `calendar-sync.sh` into the brain (daily). Playbook `skills/calendar-to-brain`.
- The Gmail MCP lives in the **default** profile config. Because the single default profile loads the box's full MCP set, the remote Composio Gmail server can lose the cold-start race against the local brain; the **email-ingest-cron.sh wrapper** (readiness pre-check + bounded retries) is the registered entrypoint that handles this. Keep the box's MCP server count as small as it actually needs.

---

## Skill packs

### Custom (built by RE Reset, vendored here)
- **`skills/real-estate`** — the Real Estate Investor Playbooks pack: **129 reference plays** across deal analysis (ARV, comps, cap rate, MAO), creative finance (subject-to, seller finance, wraps, Dodd-Frank), dispositions, lead generation, property management, transactions (LOI, assignment, double close), reporting, and marketing. Loaded on demand (read only the matching play), not all at once.
- **Operations / integration skills** (`skills/`): `email-to-brain`, `calendar-to-brain`, `slack-to-gdrive`, `ghl-to-brain`. These are the channel→brain ingestion playbooks that keep each client's brain current.

### Curated ARMY packs (installed via the Hermes skills curator, not vendored)
Declare these in the box skill manifest so a fresh box pulls them: `productivity`, `note-taking`, `research`, `email`, `devops`, `github`, `software-development`, `data-science`, `media`, `social-media`, `smart-home`, `diagramming`, `creative`, `apple`. (The curator manages `.bundled_manifest`; community packs are referenced, not copied into this repo.)

---

## Box scaffolding (the client MVP every box ships with)

Beyond the runtime and channels, every box ships a small, consistent scaffolding so the agent is reliable and easy to hand off. This is the client MVP. Keep it lean.

- **`SOUL.md`** (persona, covered above). The agent's stance, autonomy hard line, and prompt-injection hard line.
- **`AGENTS.md`** (operating contract). The machine map of the box: where things live, how to behave, the hard rules.
- **`knowledge/`** (the client's domain facts). The per-client customization surface: `client-profile.md`, `deal-criteria.md` for real-estate clients, `key-people.md`. The agent reads the one that matches the task, on demand. Facts only, no secrets. Templates in `orgo/knowledge/`.
- **PARA + OKF brain organization.** The brain repo (`/opt/brain/repo`) is seeded at `stage_brain_init` with the PARA skeleton from `orgo/knowledge/para-seed/`: `inbox/`, `projects/`, `areas/`, `resources/`, `archive/`, each with an OKF index page. The agent's filing rules (one concept per page, `type` frontmatter, per-folder index, link instead of repeat) live in the SOUL template's "Knowledge organization" section. A weekly `gbrain-hygiene` cron (rule-based, zero LLM) reports doctor findings, orphans, and contradictions to `areas/brain-hygiene/latest.md`, complementing the nightly LLM dream.
- **`decisions/`** (box ADR log). Why the box is configured the way it is, so nobody re-litigates or "fixes" something intentional. Seeded with the baseline calls (Postgres, single default profile, supervised brain, skill-router, draft-first). Template in `orgo/decisions/`.
- **`evals/`** (guardrail smoke tests). A handful of behavioral checks that prove the agent's safety holds (drafts not sends, refuses prompt injection, stops before spend, ingestion works, recovers on restart) before the box goes to the client. In `orgo/evals/`.
- **Skill loading** (skill-router metaskill, separate branch). Skills load on demand, not preloaded, so context stays lean.

What the MVP deliberately leaves out: a full automated eval harness, CI, and heavy per-client RAG tuning. Those come later. The MVP is the minimum that makes a box consistent, safe, and handoff-ready.

---

## Provisioning order (new client box)

1. `orgo/install-box.sh` (canonical installer) -> base box, Postgres brain (PARA-seeded), gateway (single default profile), cron routines, channels, portal with Connections tab (per its stages). `stage_health` + `stage_verify` are the verify pass.
2. Fill `/opt/install.env` (identity, brain, LLM, Composio, channels, GHL if applicable; the required vars are declared at the top of `install-box.sh`, example at `orgo/install.env.admin.example`).
3. Deploy the agent persona: fill `orgo/SOUL.template.md` for the client, strip the comment header, save it on the box as `~/.hermes/SOUL.md`.
4. Connect channels the client uses: WhatsApp (bridge + QR), Telegram (bot token), Slack (socket tokens).
5. Composio OAuth via the onboarding app: Gmail, Calendar, Docs, Sheets, Tasks.
6. Ingestion routines are deployed + scheduled on the default profile by `stage_cron`: `email-ingest` (hourly), `calendar-sync` (daily), `gbrain-dream` (**every 6 hours**), `gbrain-hygiene` (weekly), `gbrain-maintenance` (weekly window, see below), and `ghl-sync` (hourly, when `ENABLE_GHL_SYNC=1`) for CRM clients.

---

## Weekly maintenance window (canary Saturday, fleet Sunday)

Every box runs `orgo/routines/gbrain-weekly-maintenance.sh`, registered with `hermes cron create` (Hermes owns the box crontab; never hand edit it). This window is the only path that changes a gbrain or Hermes version anywhere.

- **Canary Saturday 08:00 UTC.** One box in the fleet has `MAINT_ROLE=canary`. It upgrades first, runs the full check set, and publishes a verdict (`score_before`, `score_after`, `smoke`, `verdict`) to `MAINT_GATE_PUBLISH_URL`.
- **Fleet Sunday 08:00 UTC.** Every other box reads that verdict from `MAINT_GATE_URL` and upgrades only if the canary's doctor score did not regress and its smoke test passed, and the verdict is under 48h old. **Fails closed:** an unreadable gate means the box runs its checks and does not upgrade. Sunday-night-only was rejected because a bad upgrade would land with no buffer before Monday.
- **Per box, per run:** `gbrain doctor` with the score recorded, stale locks cleared, `embed --stale`, dream cadence asserted still 6-hourly, the DB-plane model keys asserted still set, the spend gates asserted still configured, `self_upgrade.mode` asserted still off, and the live smoke test (page in, extraction, takes count grew).
- **Covers both** gbrain and Hermes.
- **Fork sync.** "Latest from our fork" goes stale unless `togorashi45/gbrain` is merged from upstream `garrytan/gbrain` on a recurring basis. That is a repo job, not a box job. Nothing in the window does it.

### Verifying a box without reprovisioning it

```bash
sudo bash /opt/install-box.sh verify      # version floor, doctor score, model keys, live smoke, MCP endpoint
```

### Spend gates (set at install, asserted weekly)

`spend.posture=gated`, `sync.cost_gate_min_usd=0.50`, `embed.backfill_max_usd=5`, `embed.backfill_max_usd_per_source_24h=10`. All four were unset when the OpenRouter balance hit zero on 2026-08-01. The stated posture matters more than the numbers: it is auditable and it does not move when a product default changes.
7. Install skill packs: vendor `real-estate` + the operations skills; declare the curated ARMY packs.
8. Fill the box scaffolding: `AGENTS.md` (as-is), `knowledge/` (from the templates, per client), `decisions/` (add any per-box notes). Run `evals/guardrails.md` against the agent before handing the box to the client.

---

## Pending (capture when reachable)

- **Slack reference config from Jeremiah's Hostinger box** — pull the live socket-mode app config when his box migrates to Orgo (Mark has migrated his brain pages; remaining is standardizing him to Postgres and syncing to this baseline).
- **Operations playbook library** — if a dedicated ops-playbook pack exists on the M4 Mini (the DFY skill library), vendor it under `skills/` the same way as `real-estate`.
- **Discord** — declared as a handler but the OAuth onboarding for it is still unsolved (Slack/WhatsApp/Telegram are solved).
