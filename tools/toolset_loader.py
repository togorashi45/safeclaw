#!/usr/bin/env python3
"""toolset_loader.py: Part C of the lean loader (lazy tool-schema defer).

Answers, from config/toolset-policy.yaml:
  - what MCP toolsets are hot (always live) vs deferred (load on demand)
  - which deferred toolset a chosen skill's declared `tools:` resolve to
  - the activation note for a toolset (so the agent/router loads it on demand)

Usage:
  toolset_loader.py audit                      # list hot + deferred
  toolset_loader.py resolve gmail crm          # map skill tool names -> toolsets to activate
  toolset_loader.py for-skill <skills.index.json> <skill-name>   # toolsets a skill needs

VERIFY on first live run: the actual hot-load of a deferred MCP server into a
running Hermes gateway. This emits WHAT to activate; wiring it into the live
gateway (config reload vs restart) is confirmed on the box.
"""
from __future__ import annotations
import json
import os
import sys

def _load_policy(path=None):
    import yaml
    path = path or os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                                "config", "toolset-policy.yaml")
    with open(path) as f:
        return yaml.safe_load(f) or {}

def resolve(names, policy):
    """Map skill tool names to the set of deferred toolset keys to activate."""
    aliases = policy.get("aliases", {})
    deferred = policy.get("deferred", {})
    hot = set(policy.get("hot", []))
    out = []
    for n in names:
        key = aliases.get(n, n)
        if key in hot:
            continue  # already live, nothing to activate
        if key in deferred:
            mcp = deferred[key].get("mcp", key)
            out.append({"toolset": key, "mcp": mcp})
        else:
            out.append({"toolset": n, "mcp": None, "note": "unknown toolset; wire by hand"})
    # dedupe by toolset
    seen, uniq = set(), []
    for o in out:
        if o["toolset"] in seen:
            continue
        seen.add(o["toolset"]); uniq.append(o)
    return uniq

def main(argv):
    if not argv:
        print(__doc__); return 1
    cmd, rest = argv[0], argv[1:]
    policy = _load_policy()
    if cmd == "audit":
        print("HOT (always live):")
        for h in policy.get("hot", []): print(f"  {h}")
        print("DEFERRED (load on demand):")
        for k, v in (policy.get("deferred") or {}).items():
            print(f"  {k} -> mcp:{v.get('mcp')}  {v.get('description','')}")
        return 0
    if cmd == "resolve":
        print(json.dumps(resolve(rest, policy), indent=2)); return 0
    if cmd == "for-skill":
        if len(rest) != 2:
            sys.stderr.write("usage: for-skill <skills.index.json> <skill-name>\n"); return 2
        idx_path, name = rest
        manifest = json.load(open(idx_path))
        rec = next((r for r in manifest.get("kept", []) if r["name"] == name), None)
        if not rec:
            sys.stderr.write(f"skill not found in index: {name}\n"); return 3
        names = list(rec.get("tools", [])) + list(rec.get("requires_toolsets", []))
        print(json.dumps(resolve(names, policy), indent=2)); return 0
    sys.stderr.write(f"unknown command: {cmd}\n"); return 2

if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
