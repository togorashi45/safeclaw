# Client routines: `hermes cron` scripts

Recurring jobs deployed onto orgo client boxes. Single-profile architecture: each
script lives at `/root/.hermes/scripts/<name>.sh` (the default profile's scripts
dir) and is registered in the **default** profile's scheduler. The default gateway
(`hermes gateway run`) is the only gateway that runs, so it is the only scheduler
that ticks. Deterministic Python collectors live at `/opt/brain/scripts/`.

The installer wires all of this automatically: `stage_cron` in
`orgo/install-box.sh` deploys these scripts and registers the jobs. You only need
the manual steps below for ad-hoc deploys or backfills.

| Script | Schedule | Runs on | What it does |
|--------|----------|---------|--------------|
| `email-ingest-cron.sh` | `15 * * * *` (hourly at :15) | default | The REGISTERED entrypoint. Wraps `email-ingest.sh` with a Composio gmail MCP readiness pre-check + bounded retries to beat the cold-start race (the default profile loads the box's full MCP set, so gmail can register a few seconds after the brain). Reads the gmail server url/key from the default `config.yaml`. |
| `email-ingest.sh` | (called by the wrapper) | default | Lists recent inbox mail from whatever Gmail tool is present (snippets only), LLM-filters to emails worth remembering, stores summary pages in gbrain under `emails/<date>-<subject>` with dedup. Generic across boxes; window + turn cap are args (default `2h 60`). |
| `ingest-retry.sh` | manual (backfills) | default | Retry wrapper around `email-ingest.sh` that re-runs until a clean `INGEST RESULT` lands. `ingest-retry.sh <WINDOW> <MAXTURNS> <ATTEMPTS>`. |
| `calendar-collect.py` | called by `calendar-sync.sh` | n/a (direct Composio) | Deterministic Google Calendar collector via Composio tool-execute; writes gbrain daily files at `daily/calendar/{YYYY}/{date}.md`. Arg is days-back. Reads `COMPOSIO_API_KEY` from `/opt/brain/.env` or `/root/.hermes/.env`. |
| `calendar-sync.sh` | `30 5 * * *` (daily 05:30) | n/a (direct Composio) | Recurring wrapper: runs `calendar-collect.py <days>` (default 45) then `gbrain import` + `embed --stale`. Idempotent. |
| `ghl-collect.py` / `ghl-sync.sh` | `0 * * * *` (opt-in) | n/a (direct Composio/GHL) | GoHighLevel -> gbrain working-set sync (deals, pipeline, unreplied, appointments). Registered only when `ENABLE_GHL_SYNC=1`. |
| `gbrain-dream.sh` | `5 */6 * * *` (every 6 hours) | n/a (direct gbrain CLI) | Brain compaction / reflection / link-building (`gbrain dream`). Logs to `/opt/brain/dream.log`. **Every 6 hours, not daily:** `cycle_freshness` warns past 6h and fails at 24h, so a daily dream leaves the brain fresh 6h out of 24 and doctor decays 100 to 95 every evening. Fails loud (nonzero exit + error heartbeat) so a dead provider is visible. Registered when `OPENROUTER_API_KEY` is set. |
| `gbrain-hygiene.sh` | `0 13 * * 1` (Monday 13:00) | n/a (direct gbrain CLI) | Weekly rule-based checks (doctor, orphans, contradictions, stats), zero LLM cost. Writes `areas/brain-hygiene/latest.md`. A failing check reads as **FAILED**, not "check unavailable". |
| `gbrain-smoke.sh` | on demand (called by verify + maintenance) | n/a (direct gbrain CLI) | Live smoke: write a `type: concept` page, sync, run takes extraction, assert the takes count **grew**. The only check that catches a wrong model id, a dead provider, or a resolver shadowing our config. Doctor can be green through all three. |
| `gbrain-weekly-maintenance.sh` | canary `0 8 * * 6`, fleet `0 8 * * 0` | n/a (direct gbrain + hermes CLI) | The maintenance window. Canary Saturday upgrades and publishes a verdict; fleet Sunday upgrades only on a non-regressing canary. Fails closed. The only path that changes a version. See GOLDEN-TEMPLATE.md. |
| `lib/heartbeat.sh` | sourced by the routines | n/a | Appends `{ts,event,status,detail}` to `$GBRAIN_HOME/.gbrain/integrations/<id>/heartbeat.jsonl`, which is what `gbrain integrations list/status/doctor/stats` read. Our routines wrote nothing there, which is why every integration reported AVAILABLE while the syncs ran daily. |

## How the installer wires it (stage_cron)

`stage_cron` runs after `email` and before `gateway`:
1. copies the shell routines to `/root/.hermes/scripts/`
2. copies the Python collectors to `/opt/brain/scripts/`
3. sets `cron.script_timeout_seconds: 1800` on the default config (see gotcha below)
4. registers the jobs on the default profile: email-ingest + calendar-sync when
   `COMPOSIO_API_KEY` is set, ghl-sync when `ENABLE_GHL_SYNC=1`, gbrain-dream when
   `OPENROUTER_API_KEY` is set.

## Deploying a routine manually (ad-hoc)

```bash
# 1. Copy the script (base64 over orgo /bash, no scp on orgo boxes)
B64=$(base64 -i orgo/routines/email-ingest.sh | tr -d '\n')
orgo_bash "echo '$B64' | base64 -d > /root/.hermes/scripts/email-ingest.sh && chmod +x /root/.hermes/scripts/email-ingest.sh"

# 2. Test it once manually in tmux (NEVER trust a routine you haven't run)
orgo_bash "tmux new-session -d -s ingest-test 'bash /root/.hermes/scripts/email-ingest.sh > /tmp/ingest-test.log 2>&1; echo EXIT_CODE=\$? >> /tmp/ingest-test.log'"
# ... poll /tmp/ingest-test.log for the INGEST RESULT line

# 3. Register the cron on the DEFAULT profile (--no-agent because the script runs hermes chat itself)
orgo_bash 'hermes cron create "15 * * * *" \
  --name email-ingest --script email-ingest-cron.sh --no-agent --deliver local'
```

## Gotchas (learned on the fleet, still apply)

- **`hermes chat` flag order:** `-q` TAKES the prompt (`--query`); `-Q` is quiet.
  Correct: `hermes chat -Q -q "<prompt>"`.
- **🚨 `hermes cron` kills `--no-agent` scripts after 120s by default.** A run that
  finds nothing finishes in ~100s, but a run that actually ingests takes 5-15+ min
  and gets killed. Fix: `cron.script_timeout_seconds: 1800` on the **default**
  profile (the installer's `stage_cron` sets this; also overridable via
  `HERMES_CRON_SCRIPT_TIMEOUT`). The config cache is mtime-keyed, so the running
  gateway picks it up without a restart.
- **Single profile means the cold-start race is real.** The default profile loads
  the box's full MCP set (gbrain + gmail + agentmail + whatever else), and the
  remote Composio gmail server registers its tools a few seconds after the local
  brain. A bare `email-ingest.sh` run can start before gmail is ready and abort
  with `INGEST ERROR: gmail MCP tools unavailable`. This is exactly why the
  REGISTERED job is `email-ingest-cron.sh` (pre-check + retries), not the bare
  script. Keep the MCP server count on the box as small as the box actually needs.
- **Transient MCP failures produce silent fake zeros.** The prompt opens with a
  tool-availability check that outputs `INGEST ERROR: gmail MCP tools unavailable`
  instead of a fake zero. Grep cron output for `INGEST ERROR` when auditing.
- **Never list emails with full bodies.** A 15-email fetch with payloads blows the
  50 KB tool-output cap. List with snippets/headers only, fetch single messages by
  id for emails that pass the filter.
- **`category:primary` returns zero on these mailboxes.** They have no Gmail
  category tabs; the query uses `in:inbox -in:spam -in:trash newer_than:<W>`. Do
  NOT add `category:primary` back.
- **The routine is generic about the Gmail server name** (`gmail`, `gmail_reader`,
  `gmail_elise`, ...). It matches Gmail tools by the substring `GMAIL`.
- **`gbrain list -n N` truncates at ~50 rows.** Never count or bulk-delete pages by
  piping it to grep; go to Postgres directly.

> Historical note: these routines previously ran under a two-profile actor/reader
> split (email-ingest on a read-only reader profile). The fleet standardized on a
> single default profile (2026-06-19); the scripts, paths, and registration above
> reflect that. If you find a box still on `--profile actor`, see
> `mind/profile-migration-to-default-2026-06-19.md` in the marcus repo.
