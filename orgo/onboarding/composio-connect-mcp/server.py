#!/usr/bin/env python3
"""composio-connect: a tiny stdio MCP the box agent uses during onboarding.

Two tools the agent calls conversationally over WhatsApp:
  - connect_link(toolkit)        -> a hosted OAuth URL to send the principal
  - connection_status(toolkit)   -> ACTIVE | pending | none, so the agent confirms

Isolation: this uses the per-box PROJECT key (COMPOSIO_API_KEY), never the org
key. The org key stays on the provisioner. Auth config ids are provisioned per
box by orgo/composio-setup-authconfigs.sh and exposed as env vars:
    COMPOSIO_API_KEY        project key (x-api-key)
    COMPOSIO_USER_ID        the principal's user id in this project (e.g. kim)
    COMPOSIO_AUTHCFG_<TOOLKIT_UPPER>   auth_config_id per toolkit
      e.g. COMPOSIO_AUTHCFG_GMAIL=ac_..., COMPOSIO_AUTHCFG_GOOGLECALENDAR=ac_...

VERIFY on first live run: the Composio SDK method names below
(connected_accounts.link / .list) are the documented v3 interface; confirm the
exact attribute on the installed SDK version and the redirect-url field name.
Falls back to a clear error rather than guessing.
"""
from __future__ import annotations
import os
import sys

try:
    from mcp.server.fastmcp import FastMCP
except Exception as e:  # pragma: no cover
    sys.stderr.write(f"composio-connect: missing 'mcp' package: {e}\n")
    raise

mcp = FastMCP("composio-connect")


def _client():
    """Return a Composio client bound to the per-box project key."""
    api_key = os.environ.get("COMPOSIO_API_KEY")
    if not api_key:
        raise RuntimeError("COMPOSIO_API_KEY not set (per-box project key)")
    from composio import Composio  # imported lazily so import errors surface as tool errors
    return Composio(api_key=api_key)


def _auth_config_id(toolkit: str) -> str:
    key = f"COMPOSIO_AUTHCFG_{toolkit.upper()}"
    val = os.environ.get(key)
    if not val:
        raise RuntimeError(
            f"{key} not set. Run composio-setup-authconfigs.sh for toolkit '{toolkit}'."
        )
    return val


@mcp.tool()
def connect_link(toolkit: str) -> str:
    """Create a hosted OAuth connect URL for the principal to tap.

    toolkit: a Composio toolkit slug, e.g. 'gmail', 'googlecalendar', 'googledrive', 'slack'.
    Returns the redirect URL to send over the channel. The principal taps it,
    approves in Google/Slack, and Composio stores the token in this box's project.
    """
    user_id = os.environ.get("COMPOSIO_USER_ID")
    if not user_id:
        return "ERROR: COMPOSIO_USER_ID not set."
    try:
        auth_config_id = _auth_config_id(toolkit)
        client = _client()
        # VERIFY: documented v3 call. Newer SDKs: connected_accounts.link(...).
        conn = client.connected_accounts.link(user_id=user_id, auth_config_id=auth_config_id)
        url = getattr(conn, "redirect_url", None) or getattr(conn, "redirectUrl", None)
        if not url:
            return f"ERROR: no redirect url in response: {conn!r}"
        return url
    except Exception as e:  # surface as a tool error, never crash the gateway
        return f"ERROR creating connect link for '{toolkit}': {e}"


@mcp.tool()
def connection_status(toolkit: str) -> str:
    """Return ACTIVE, pending, or none for the principal's connection to a toolkit."""
    user_id = os.environ.get("COMPOSIO_USER_ID")
    if not user_id:
        return "ERROR: COMPOSIO_USER_ID not set."
    try:
        client = _client()
        # VERIFY: list connected accounts for this user; filter by toolkit.
        accounts = client.connected_accounts.list(user_ids=[user_id])
        items = getattr(accounts, "items", None) or accounts
        tk = toolkit.lower()
        for a in items:
            name = (getattr(a, "toolkit", "") or getattr(a, "app_name", "") or "")
            status = (getattr(a, "status", "") or "").upper()
            if tk in str(name).lower():
                return status or "unknown"
        return "none"
    except Exception as e:
        return f"ERROR checking status for '{toolkit}': {e}"


if __name__ == "__main__":
    mcp.run()
