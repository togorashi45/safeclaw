---
type: decision
description: Why the box installs gbrain from our fork with a version floor, wires the brain MCP over HTTP, dreams every 6 hours, and changes versions only in a weekly window.
---

# Brain plane decisions, 2026-08-02

Recorded so nobody re-litigates these or "fixes" something deliberate. Source:
the golden installer audit, `mind/reports/2026-08-02-golden-installer-audit.md`
in the marcus repo.

## 1. gbrain comes from `rspur-hq/gbrain`, latest, with a floor

The installer used to clone upstream `garrytan/gbrain` at HEAD. The fixes our own
fleet found live in our fork, not upstream, so every box shipped without them.
That is how the fleet ran a brain that produced zero takes for weeks.

We install the **latest** from the fork and assert a **minimum version floor**
(`GBRAIN_MIN_VERSION`, currently `0.42.69.0`). Below the floor the install fails
loudly and never continues. We do not hard pin: pinning freezes us on an old
build and the whole point of the fork is that fixes land there fast.

Raise the floor when the box depends on something newer. Never lower it to make
an install pass.

## 2. The brain MCP is HTTP with a bearer token, not stdio

The product's own setup script registers gbrain as a stdio MCP server. Our live
boxes run the native HTTP endpoint on `127.0.0.1:3131/mcp` with an
`Authorization: Bearer` header, timeout 120, connect timeout 30, alongside a
supervised `gbrain serve --http` process. That is what is proven here, so that is
what we provision. The vendored script registers stdio first and our installer
overwrites the entry.

The token is minted with `gbrain auth create` and persisted in `/opt/brain/.env`,
so it survives a restart and never has to be read out of a log.

## 3. Composio per-project isolation stays the auth model

We did not move to gbrain's `credential-gateway`. One Composio project per box is
a hard fleet requirement for identity isolation and the recipe does not provide
it. The audit specifically refuted the theory that our senses were hand rolled
because credential-gateway was missing. What we forfeited was the health plane,
and heartbeats close that without changing the auth model.

## 4. Dream runs every 6 hours

`cycle_freshness` warns once the last full cycle is older than 6h and fails at
24h. A daily dream leaves the brain fresh 6h out of 24 and doctor decays from 100
to 95 every evening. The check is honest and staleness compounds, so the fix is
the cadence, not the threshold. Dream phases are incremental, so the steady-state
cost is small.

## 5. Spend gates are set explicitly

`spend.posture=gated`, `sync.cost_gate_min_usd=0.50`,
`embed.backfill_max_usd=5`, `embed.backfill_max_usd_per_source_24h=10`.

Two of these match the product default. Setting them anyway is the point: a
stated posture is auditable, and it does not move when a product default changes.
All four were unset when the OpenRouter balance hit zero on 2026-08-01 and the
only trace was a log file nothing reads.

Per box class: a client box gets the numbers above. If a box genuinely needs a
larger corpus embedded, raise `embed.backfill_max_usd` for that box and note it
here. Never set `spend.posture=tokenmax` on a client box.

## 6. Versions change only in the weekly maintenance window

`self_upgrade.mode=off` on every box. Canary Saturday, fleet Sunday, and the
Sunday run is gated on the canary's doctor score not regressing. A box that
cannot read the canary verdict runs its checks and does not upgrade.

## 7. Verification asserts live data, not exit codes

The install is gated on `gbrain doctor` clearing a score threshold AND a live
smoke test that writes a page, runs extraction, and asserts the takes count grew.
Doctor can be green while a model id is a typo, and an exit code is not proof.
