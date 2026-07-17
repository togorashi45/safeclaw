---
name: ghl-to-brain
description: Ingest the GoHighLevel CRM working set (open deals, pipeline summary, unreplied conversations, upcoming appointments) into the brain as durable pages. Contact lookup stays live via the GHL MCP.
version: 1.0.0
author: SafeClaw
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [ghl, gohighlevel, crm, ingestion, brain, integration]
    category: integrations
    sources:
      - {kind: gohighlevel, optional: false}
      - {kind: brain, optional: false}
    requires_toolsets: [native-mcp]
---

# GHL to brain ingestion

## When to use

Use this skill when the scheduled GHL routine runs (every 4h), or when the user
asks to refresh the CRM working set in the brain. It mirrors the **active**
working set, not the full contact list: open opportunities, a pipeline summary,
unreplied conversations, and upcoming appointments. Contact LOOKUP stays live
through the GHL MCP, so the brain never mirrors the whole contact database.

> Trust boundary: this is a read/ingest capability. It reads GHL via the REST API
> and writes summary pages to the brain. It does not send SMS, email, or change
> any CRM record.

## Prerequisites

- `GHL_API_KEY` (a GoHighLevel Private Integration Token) and `GHL_LOCATION_ID`
  present in one of: `/opt/ghl-mcp/.env`, `/opt/safeclaw/client.env`, or
  `/root/.hermes/.env` (the collector searches all three).
- The GHL MCP server registered in the **Actor** profile for live contact lookup
  (stdio build, see `orgo/GOLDEN-TEMPLATE.md` → GHL).
- gbrain reachable.

## Quick reference

| Output page | Path | Contents |
|-------------|------|----------|
| Deal pages | `crm/deals/<slug>.md` | one page per open opportunity (pipeline, stage, value, age, id) |
| Pipeline summary | `crm/board/pipeline-summary.md` | open counts + value by pipeline/stage |
| Unreplied | `crm/board/unreplied.md` | threads where the last message is inbound or unread |
| Appointments | `crm/board/appointments.md` | upcoming appointments (next 21 days) |

## Procedure

The deployed implementation is `orgo/routines/ghl-sync.sh`, which runs
`ghl-collect.py` then `gbrain import /opt/brain/repo/crm` and `gbrain embed --stale`.
Register it as a `--no-agent` Hermes cron job on `0 */4 * * *`:

```
hermes cron create '0 */4 * * *' --name ghl-sync --script ghl-sync.sh --no-agent --deliver local
```

The collector emits one verbatim line per run:
`GHL COLLECT DONE: <deals> deals, <pipelines> pipelines, <unreplied> unreplied, <appts> appts`.

## Pitfalls

- **Working set only.** Do not mirror the full contact list (can be tens of
  thousands). Contacts stay live-search via the GHL MCP.
- **GHL is behind Cloudflare** and 403s the default `python-urllib` User-Agent —
  the collector already sends a browser UA. Keep it.
- **Opportunities often have `monetaryValue: 0`.** Show counts; do not present a
  dollar pipeline value unless the records actually carry one.
- **`unreadOnly` query param is ignored** by GHL — the collector filters
  client-side on `lastMessageDirection == inbound` or `unreadCount > 0`.
- **Use the stdio GHL MCP build for live tools, not the SSE/HTTP build** — the
  published HTTP build 500s on the Hermes connection pattern ("Already connected
  to a transport"). The stdio build exposes more tools and is stable.
