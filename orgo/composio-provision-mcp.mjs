#!/usr/bin/env node
// Composio MCP server provisioner, ported from Sten (Vasanth19/sten,
// apps/control-plane/lib/integrations/composio-mcp-server.ts + composio-initiate.ts
// @ 3f2f3f5, live-proven 2026-07-02: 219 tools bound, zero boot errors).
//
// One box == one Composio entity (COMPOSIO_USER_ID) == ONE MCP server bound to the
// box's toolkits. Idempotent and safe to re-run any time; re-running is the
// reconcile path after adding a toolkit or reconnecting an account.
//
// What it does, in order:
//   1. For each toolkit slug: resolve its managed auth config (list -> first),
//      creating one (use_composio_managed_auth) if missing.
//   2. Look up the MCP server by deterministic name; reuse if found, else create
//      it passing BOTH toolkit slugs and auth config ids (a server created with
//      only auth_config_ids serves ZERO tools; live -32601).
//   3. Project the CONNECTABLE url: <origin>/v3/mcp/<id>/mcp?user_id=<entity>.
//      The raw url Composio returns is /v3.1/... which 307-redirects and DROPS
//      query params; user_id must be a query param, a header is ignored.
//   4. Upsert COMPOSIO_MCP_URL / COMPOSIO_MCP_SERVER_ID / COMPOSIO_USER_ID /
//      COMPOSIO_AUTHCFG_<TOOLKIT> into each env file given.
//   5. Optionally write composio-services.json for the connect page, with every
//      service under the SAME entity (user_id) the MCP server queries. Accounts
//      connected under a different user_id are invisible to the agent.
//
// Env in: COMPOSIO_API_KEY (per-box project key; never printed),
//         COMPOSIO_USER_ID (default client:<CLIENT_SLUG>),
//         COMPOSIO_TOOLKITS (csv, default gmail,googlecalendar,googledrive,slack),
//         COMPOSIO_ENV_FILES (csv of env files to upsert),
//         COMPOSIO_SERVICES_JSON (optional out path for the connect page map).
// Run from a directory whose node_modules has @composio/core (^0.13.1).

import { createHash } from "node:crypto";
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { Composio } from "@composio/core";

const apiKey = process.env.COMPOSIO_API_KEY || "";
if (!apiKey.trim()) {
  console.error("FAIL: COMPOSIO_API_KEY is required (per-box project key).");
  process.exit(1);
}
const slug = process.env.CLIENT_SLUG || "";
const userId = process.env.COMPOSIO_USER_ID || (slug ? `client:${slug}` : "");
if (!userId) {
  console.error("FAIL: set COMPOSIO_USER_ID or CLIENT_SLUG.");
  process.exit(1);
}
const toolkits = (process.env.COMPOSIO_TOOLKITS || "gmail,googlecalendar,googledrive,slack")
  .split(",").map((s) => s.trim().toLowerCase()).filter(Boolean);
const envFiles = (process.env.COMPOSIO_ENV_FILES || "")
  .split(",").map((s) => s.trim()).filter(Boolean);
const servicesJsonPath = process.env.COMPOSIO_SERVICES_JSON || "";

const composio = new Composio({ apiKey });

// Deterministic name, always 29 chars ("safeclaw-" + 20 hex). Composio hard-caps
// server names at 30 chars and the create 400s past that (Sten shipped weeks of
// silent failures on a 40-char name; the error was swallowed by a fail-soft catch).
const serverName = "safeclaw-" + createHash("sha256").update(userId).digest("hex").slice(0, 20);

function connectableUrl(rawUrl, serverId) {
  const origin = new URL(rawUrl).origin;
  return `${origin}/v3/mcp/${serverId}/mcp?user_id=${encodeURIComponent(userId)}`;
}

async function ensureAuthConfig(toolkit) {
  const existing = await composio.authConfigs.list({ toolkit });
  const found = existing.items?.[0]?.id;
  if (found) return found;
  const meta = await composio.toolkits.get(toolkit);
  if (!meta?.authConfigDetails || meta.authConfigDetails.length === 0) {
    throw new Error(`Composio has no auth config available for toolkit "${toolkit}".`);
  }
  const created = await composio.authConfigs.create(toolkit, {
    type: "use_composio_managed_auth",
    name: `${meta.name ?? toolkit} Auth Config`,
  });
  if (!created?.id) throw new Error(`No auth config id returned for "${toolkit}".`);
  return created.id;
}

async function ensureMcpServer(authConfigIds) {
  // Lookup-by-name FIRST (restart/re-run idempotency): reuse, never duplicate.
  // Fail-soft on the list itself; a lookup failure must never abort provisioning.
  let listed;
  try {
    listed = await composio.mcp.list({ page: 1, limit: 100, toolkits: [], authConfigs: [] });
  } catch (err) {
    console.error(`WARN: mcp.list failed (${err?.message ?? err}); falling through to create.`);
  }
  const hit = (listed?.items ?? []).find((s) => s.name === serverName);
  if (hit) {
    const raw = String(hit.MCPUrl ?? hit.url ?? "");
    if (!raw.startsWith("https://")) throw new Error("Existing server has a non-https url; refusing.");
    return { serverId: hit.id, url: connectableUrl(raw, hit.id), reused: true };
  }
  // Slugs AND {authConfigId} objects ride in the same toolkits array; the SDK
  // splits them apart (verified against @composio/core@0.13.1 MCP.create).
  const created = await composio.mcp.create(serverName, {
    toolkits: [...toolkits, ...authConfigIds.map((id) => ({ authConfigId: id }))],
  });
  const raw = String(created.MCPUrl ?? created.url ?? "");
  if (!raw.startsWith("https://")) throw new Error("Composio returned a non-https url; refusing.");
  return { serverId: created.id, url: connectableUrl(raw, created.id), reused: false };
}

function upsertEnvLine(file, key, value) {
  let text = existsSync(file) ? readFileSync(file, "utf8") : "";
  const line = `${key}=${value}`;
  const re = new RegExp(`^${key}=.*$`, "m");
  text = re.test(text) ? text.replace(re, line) : text + (text.endsWith("\n") || text === "" ? "" : "\n") + line + "\n";
  if (!text.endsWith("\n")) text += "\n";
  writeFileSync(file, text, { mode: 0o600 });
}

const authcfg = {};
for (const t of toolkits) {
  authcfg[t] = await ensureAuthConfig(t);
  console.error(`authconfig ${t}: ${authcfg[t]}`);
}

const server = await ensureMcpServer(Object.values(authcfg));
console.error(`mcp server ${serverName}: ${server.serverId} (${server.reused ? "reused" : "created"})`);

for (const f of envFiles) {
  upsertEnvLine(f, "COMPOSIO_USER_ID", userId);
  upsertEnvLine(f, "COMPOSIO_MCP_SERVER_ID", server.serverId);
  upsertEnvLine(f, "COMPOSIO_MCP_URL", server.url);
  for (const [t, id] of Object.entries(authcfg)) {
    upsertEnvLine(f, `COMPOSIO_AUTHCFG_${t.toUpperCase()}`, id);
  }
  console.error(`env upserted: ${f}`);
}

if (servicesJsonPath) {
  const labels = { gmail: "Gmail", googlecalendar: "Google Calendar", googledrive: "Google Drive", slack: "Slack" };
  const services = {};
  for (const t of toolkits) {
    services[t] = {
      label: labels[t] || t,
      auth_config_id: authcfg[t],
      user_id: userId, // MUST match the MCP server entity or the agent sees zero accounts
      alias: `${slug || userId}-${t}`,
    };
  }
  writeFileSync(servicesJsonPath, JSON.stringify(services, null, 2) + "\n");
  console.error(`services json written: ${servicesJsonPath}`);
}

// stdout is the machine-readable result (stderr carries progress). No key ever prints.
console.log(JSON.stringify({ serverName, serverId: server.serverId, url: server.url, userId, toolkits, reused: server.reused }));
