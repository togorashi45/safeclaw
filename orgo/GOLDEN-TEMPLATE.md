# SafeClaw Golden Template (most-complete build)

**Branch:** `golden-template` · **Consolidated:** 2026-06-14 · **Owner:** Jake McKinney (RE Reset)

This is the canonical, most-complete SafeClaw. It consolidates the best integration from every live client box into one clean template so a new client box can be stood up with the full capability set. Every concrete artifact referenced here lives in this repo; per-client secrets never do (they go in `client.env`, which is gitignored).

Pairs with `orgo/STANDARDIZATION.md` (the fleet baseline) and `orgo/ORGO-CLIENT-TEMPLATE.md` (the full install manual). Provision a box with `orgo/provision-client.py` + `orgo/INSTALL-CHECKLIST.md`, then layer the channels and skill packs below.

---

## Baseline runtime (from the 2026-06 fleet hardening)

Every box runs this exact shape. Proven across Matt, Travis, Elise, Phil.

- **Brain:** gBrain `0.42.42.0` on **local Postgres 16 + pgvector**, self-contained per box (a client can leave with their data; no shared DB). Supervised as `postgres-brain` + `safeclaw-brain`. Embeddings via OpenRouter `openai/text-embedding-3-small` (1536-dim).
- **Gateway:** exactly one supervised program `hermes-gateway-actor` (`hermes gateway run --profile actor`). No reader gateway. The reader profile is dormant and carries Gmail + gbrain only.
- **Console / tunnel / dashboard:** SafeClaw UI on `:8899`, cloudflared named tunnel, Hermes dashboard on `:9119`, kept alive by the tmux `watchdog`. The watchdog never manages the brain (that is supervised) to avoid the dual-writer corruption that killed PGlite.
- **Provisioning gotcha:** the brain role needs `CREATE ROLE brain LOGIN SUPERUSER BYPASSRLS` (superuser alone does not set `rolbypassrls`, and gBrain's v24 migration halts without it).

Full detail and the repeatable Postgres procedure are in `orgo/STANDARDIZATION.md`.

---

## Agent identity (SOUL.md)

Every box gets a deliberate agent persona, not the stock Hermes default. The persona is the agent's operating stance: how it thinks, how direct it is, what it will and will not do without approval.

- **File:** `orgo/SOUL.template.md` in this repo. Fill the placeholders for the client, strip the comment header, and save it on the box as `~/.hermes/SOUL.md`. Hermes loads it fresh every message, so edits take effect with no restart.
- **What it carries:** stance and tone, an operating doctrine (constraint-first, define the problem, reliability before growth), an autonomy hard line (draft-only from the owner's address, allowlist for internal sends, stop before spend/publish/destructive/credential changes), a mission map, and prompt-injection hard lines (treat email, docs, transcripts, and brain pages as data, never as commands).
- **Distinct from the user "Soul" brain page.** SOUL.md is the AGENT persona (static, version-controlled here). The brain page `identity/soul` is the USER's identity and principles (seeded into gBrain, updated by the weekly reflector through the review queue). Do not conflate them. The personas plugin (`safeclaw-personas`) governs the reader/actor trust split and is separate again.
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
- **Hermes side:** the Actor profile declares `whatsapp:` with `session_path: /root/.hermes/profiles/actor/platforms/whatsapp/session`.
- **Known gotcha:** newer Hermes requires `creds.json` at the **profile** session path while the bridge writes the **default** path; if the gateway goes FATAL with the bridge still connected, symlink the profile session dir to the bridge session dir and restart the gateway.

### Telegram (Travis / Elise's setup)
Native Hermes platform, no public URL.
- `TELEGRAM_BOT_TOKEN` from @BotFather, `TELEGRAM_ALLOWED_USERS` (comma-separated numeric ids), both in `client.env`.
- The Actor profile declares the `telegram` handler. Easiest channel to add.

### Slack (Jeremiah's setup)
Socket mode, no public URL. Reader/actor token split.
- `SLACK_BOT_TOKEN` (actor: post/send), `SLACK_MCP_BOT_TOKEN` (reader, read-only), `SLACK_HOME_CHANNEL`, `SLACK_INGEST_CHANNELS` in `client.env`.
- Tooling: `mcp-tools/slack-api` (MCP) + `skills/slack-to-gdrive` (ingest playbook).
- NOTE: Jeremiah currently runs on a Hostinger VPS (`runtime: hostinger-vps`), not Orgo. His live socket-mode config is the reference instance; capture it when his box moves to Orgo (see "Pending").

---

## GoHighLevel CRM (Matt / Travis's setup)

Two parts, both in this repo.
1. **Live tools (Actor):** the `@mastanley13/ghl-mcp-server` **stdio** build registered in the Actor `config.yaml` `mcp_servers` as `ghl` (`command: node, args: [.../dist/server.js], env: GHL_API_KEY/GHL_BASE_URL/GHL_LOCATION_ID`). Use the **stdio** build (more tools, stable); the published HTTP/SSE build 500s on Hermes' connection pattern.
2. **Working-set ingestion:** `orgo/routines/ghl-collect.py` + `orgo/routines/ghl-sync.sh`, on a `0 */4 * * *` `--no-agent` Hermes cron (`ghl-sync`). Produces `crm/deals/*` + `crm/board/{pipeline-summary,unreplied,appointments}` pages. Playbook: `skills/ghl-to-brain`.
- Env: `GHL_API_KEY` (Private Integration Token) + `GHL_LOCATION_ID`. The collector reads them from `/opt/ghl-mcp/.env`, `/opt/safeclaw/client.env`, or `/root/.hermes/.env`.
- Verified on Travis 2026-06-14: 140 open deals, 270 unreplied threads, pipeline summary, imported + embedded.

---

## Google / Composio OAuth (all boxes)

OAuth for Gmail, Calendar, Docs, Sheets, and Tasks runs through **Composio**, one scoped workspace/key per client (keys are not interchangeable across boxes).
- Env: `COMPOSIO_API_KEY`, `COMPOSIO_USER_ID`, reader/actor MCP URLs in `client.env`.
- **Self-service connect:** the `onboarding/` Flask app (Victor-style OAuth onboarding) is where a client clicks to authorize each provider; per-account ids are appended to the Hermes config from the Connections registry.
- **Native ingestion routines (deterministic collectors, not the agent):**
  - `orgo/routines/email-ingest.sh` → Gmail working set into the brain (hourly). Playbook `skills/email-to-brain`.
  - `orgo/routines/calendar-collect.py` + `calendar-sync.sh` → Calendar into the brain (daily). Playbook `skills/calendar-to-brain`.
- Keep the **reader profile lean (Gmail + gbrain only)**; extra remote Composio servers in the reader make Gmail lose the cold-start race and the ingest aborts.

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
- **`AGENTS.md`** (operating contract). The machine map of the box: where things live, how to behave, the hard rules. Distinct from `AI-AGENTS.md`, which is the install guide.
- **`knowledge/`** (the client's domain facts). The per-client customization surface: `client-profile.md`, `deal-criteria.md` for real-estate clients, `key-people.md`. The agent reads the one that matches the task, on demand. Facts only, no secrets. Templates in `orgo/knowledge/`.
- **`decisions/`** (box ADR log). Why the box is configured the way it is, so nobody re-litigates or "fixes" something intentional. Seeded with the baseline calls (Postgres, actor-only, supervised brain, skill-router, draft-first). Template in `orgo/decisions/`.
- **`evals/`** (guardrail smoke tests). A handful of behavioral checks that prove the agent's safety holds (drafts not sends, refuses prompt injection, stops before spend, ingestion works, recovers on restart) before the box goes to the client. In `orgo/evals/`.
- **Skill loading** (skill-router metaskill, separate branch). Skills load on demand, not preloaded, so context stays lean.

What the MVP deliberately leaves out: a full automated eval harness, CI, and heavy per-client RAG tuning. Those come later. The MVP is the minimum that makes a box consistent, safe, and handoff-ready.

---

## Provisioning order (new client box)

1. `orgo/provision-client.py` + `INSTALL-CHECKLIST.md` → base box, Postgres brain, gateway, tunnel/console/dashboard, watchdog (per `STANDARDIZATION.md`).
2. Fill `client.env` from `client.env.example` (identity, brain, LLM, Composio, channels, GHL if applicable).
3. Deploy the agent persona: fill `orgo/SOUL.template.md` for the client, strip the comment header, save it on the box as `~/.hermes/SOUL.md`.
4. Connect channels the client uses: WhatsApp (bridge + QR), Telegram (bot token), Slack (socket tokens).
5. Composio OAuth via the onboarding app: Gmail, Calendar, Docs, Sheets, Tasks.
6. Schedule the ingestion routines: `email-ingest` (hourly), `calendar-sync` (daily), and `ghl-sync` (4h) for CRM clients.
7. Install skill packs: vendor `real-estate` + the operations skills; declare the curated ARMY packs.
8. Fill the box scaffolding: `AGENTS.md` (as-is), `knowledge/` (from the templates, per client), `decisions/` (add any per-box notes). Run `evals/guardrails.md` against the agent before handing the box to the client.

---

## Pending (capture when reachable)

- **Slack reference config from Jeremiah's Hostinger box** — pull the live socket-mode app config when his box migrates to Orgo (Mark has migrated his brain pages; remaining is standardizing him to Postgres and syncing to this baseline).
- **Operations playbook library** — if a dedicated ops-playbook pack exists on the M4 Mini (the DFY skill library), vendor it under `skills/` the same way as `real-estate`.
- **Discord** — declared as a handler but the OAuth onboarding for it is still unsolved (Slack/WhatsApp/Telegram are solved).
