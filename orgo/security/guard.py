#!/usr/bin/env python3
"""guard.py: the dangerous-verb gate (Package E). Runs on the box.

The agent calls this BEFORE any action that might leave the building, spend, or
destroy. It classifies the action against config/guardrails.yaml and the box's
autonomy ceiling and returns one of: allow | gate | deny. On `gate` it enqueues
an approval on the review queue (the same surface that approves soul updates) and
the agent must block until a human approves.

Usage:
  guard.py classify --verb external_email_send --boundary actor --count 1 \
           --target "seller@example.com" --summary "reply yes to the seller"
Exit code: 0 allow, 10 gate (approval enqueued), 20 deny. Prints a JSON verdict.

VERIFY on first live run: the review_queue insert columns (action_type, payload,
status) match the box schema, and the notify channels are wired.
"""
from __future__ import annotations
import argparse
import json
import os
import subprocess
import sys

def load_policy(path=None):
    import yaml
    path = path or os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(
        os.path.abspath(__file__)))), "config", "guardrails.yaml")
    with open(path) as f:
        return yaml.safe_load(f) or {}

def enqueue_approval(policy, action):
    """Write an approval request to the review queue. Returns True on success."""
    dburl = os.environ.get("GBRAIN_DATABASE_URL")
    if not dburl and os.path.exists("/opt/brain/.env"):
        for line in open("/opt/brain/.env"):
            if line.startswith("GBRAIN_DATABASE_URL="):
                dburl = line.split("=", 1)[1].strip()
    if not dburl:
        sys.stderr.write("guard: no GBRAIN_DATABASE_URL; cannot enqueue approval\n")
        return False
    payload = json.dumps(action).replace("'", "''")
    action_type = (policy.get("approval", {}) or {}).get("action_type", "dangerous_verb")
    # VERIFY: review_queue columns. Mirrors the soul_update enqueue path.
    sql = (f"INSERT INTO review_queue (action_type, payload, status) "
           f"VALUES ('{action_type}', '{payload}'::jsonb, 'pending');")
    out = subprocess.run(["psql", dburl, "-v", "ON_ERROR_STOP=1", "-c", sql],
                         capture_output=True, text=True)
    if out.returncode != 0:
        sys.stderr.write(f"guard: enqueue failed: {out.stderr.strip()}\n")
        return False
    return True

def classify(args, policy):
    verb = args.verb
    boundary = args.boundary
    deny = set(policy.get("deny_verbs", []))
    gate = set(policy.get("gate_verbs", []))
    threshold = int(policy.get("bulk_threshold", 10))
    bounds = policy.get("boundaries", {})

    # Hard deny.
    if verb in deny:
        return "deny", "hard line in guardrails.yaml deny_verbs"
    # Reader boundary: only its allow-list of verbs.
    if boundary == "reader":
        allowed = set((bounds.get("reader", {}) or {}).get("allow_verbs_only", []))
        if verb not in allowed:
            return "deny", f"reader boundary may not run '{verb}'"
        return "allow", "reader read-only verb"
    # Bulk escalation: a normally-allowed verb on many records gates.
    if args.count and args.count >= threshold and verb not in gate:
        return "gate", f"bulk action ({args.count} >= {threshold})"
    # Gate verbs.
    if verb in gate:
        return "gate", f"'{verb}' is a gated verb"
    # actor free verbs.
    free = set((bounds.get("actor", {}) or {}).get("free_verbs", []))
    if verb in free:
        return "allow", "actor free verb"
    # Unknown verb: gate, do not silently allow.
    return "gate", f"unknown verb '{verb}', gating to be safe"

def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("classify")
    c.add_argument("--verb", required=True)
    c.add_argument("--boundary", default="actor", choices=["actor", "reader"])
    c.add_argument("--count", type=int, default=1)
    c.add_argument("--target", default="")
    c.add_argument("--summary", default="")
    args = ap.parse_args()
    policy = load_policy()
    decision, reason = classify(args, policy)
    verdict = {"decision": decision, "reason": reason, "verb": args.verb,
               "target": args.target, "summary": args.summary}
    if decision == "gate":
        verdict["approval_enqueued"] = enqueue_approval(policy, verdict)
    print(json.dumps(verdict, indent=2))
    return {"allow": 0, "gate": 10, "deny": 20}[decision]

if __name__ == "__main__":
    sys.exit(main())
