#!/usr/bin/env python3
"""agentmail: the box agent's own email identity (send + read).

This is the MECHANISM. The agent sends from its OWN AgentMail inbox
(<slug>-rereset@agentmail.to) using an INBOX-SCOPED key (it can only touch this
one inbox; the org key never comes near a box). WHEN to send directly vs draft
in the principal's inbox is governed by the SOUL (AGENT-EMAIL-RULES): agent to
its own people -> send here; principal/business to the outside world -> draft in
the principal's Gmail (Composio) for the human.

Env (injected per box, off-box minted):
  AGENTMAIL_API_KEY   inbox-scoped key (am_us_...), NOT the org key
  AGENTMAIL_INBOX     this box's address, e.g. elgine-rereset@agentmail.to
"""
from __future__ import annotations
import os, sys, requests

try:
    from mcp.server.fastmcp import FastMCP
except Exception as e:  # pragma: no cover
    sys.stderr.write(f"agentmail: missing 'mcp' package: {e}\n")
    raise

mcp = FastMCP("agentmail")
BASE = os.environ.get("AGENTMAIL_BASE", "https://api.agentmail.to/v0")


def _key() -> str:
    k = os.environ.get("AGENTMAIL_API_KEY")
    if not k:
        raise RuntimeError("AGENTMAIL_API_KEY not set (inbox-scoped key)")
    return k


def _inbox() -> str:
    ib = os.environ.get("AGENTMAIL_INBOX")
    if not ib:
        raise RuntimeError("AGENTMAIL_INBOX not set (this box's address)")
    return ib


def _h() -> dict:
    return {"Authorization": f"Bearer {_key()}", "Content-Type": "application/json"}


@mcp.tool()
def send_email(to: str, subject: str, text: str, cc: str = "", bcc: str = "") -> str:
    """Send an email FROM this agent's own address. Use only for the agent
    speaking as itself to its own people (the principal + internal allowlist),
    or when the principal explicitly told you to send from your account. For
    anything external, client-facing, or that represents the principal, DRAFT in
    the principal's Gmail instead. 'to' may be a comma-separated list.
    """
    try:
        body = {"to": [a.strip() for a in to.split(",") if a.strip()],
                "subject": subject, "text": text}
        if cc:
            body["cc"] = [a.strip() for a in cc.split(",") if a.strip()]
        if bcc:
            body["bcc"] = [a.strip() for a in bcc.split(",") if a.strip()]
        r = requests.post(f"{BASE}/inboxes/{_inbox()}/messages/send",
                          headers=_h(), json=body, timeout=30)
        if r.status_code in (200, 201):
            mid = (r.json() or {}).get("message_id", "sent")
            return f"SENT from {_inbox()} to {to} ({mid})"
        return f"ERROR {r.status_code}: {r.text[:300]}"
    except Exception as e:
        return f"ERROR sending: {e}"


@mcp.tool()
def list_messages(limit: int = 15) -> str:
    """List recent messages in this agent's own inbox (newest first)."""
    try:
        r = requests.get(f"{BASE}/inboxes/{_inbox()}/messages?limit={limit}",
                         headers=_h(), timeout=20)
        if r.status_code != 200:
            return f"ERROR {r.status_code}: {r.text[:200]}"
        msgs = (r.json() or {}).get("messages", [])
        if not msgs:
            return "inbox empty"
        out = []
        for m in msgs[:limit]:
            out.append(f"{m.get('message_id','?')[:10]} | {m.get('from','?')} | {m.get('subject','(no subject)')} | {m.get('created_at','')[:16]}")
        return "\n".join(out)
    except Exception as e:
        return f"ERROR listing: {e}"


@mcp.tool()
def read_message(message_id: str) -> str:
    """Read one message from this agent's own inbox by id."""
    try:
        r = requests.get(f"{BASE}/inboxes/{_inbox()}/messages/{message_id}",
                         headers=_h(), timeout=20)
        if r.status_code != 200:
            return f"ERROR {r.status_code}: {r.text[:200]}"
        m = r.json() or {}
        return f"From: {m.get('from')}\nSubject: {m.get('subject')}\nDate: {m.get('created_at')}\n\n{m.get('text') or m.get('html') or ''}"[:3000]
    except Exception as e:
        return f"ERROR reading: {e}"


if __name__ == "__main__":
    mcp.run()
