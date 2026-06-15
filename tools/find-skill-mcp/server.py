#!/usr/bin/env python3
"""find-skill: a stdio MCP that retrieves the closest skills for a query.

Part B of the lean loader. The skill-router calls find_skill(query) instead of
reading the whole SKILL_INDEX.md once a box carries hundreds of skills. Backed by
the pgvector skill_index table built by tools/skill_index_embed.py.

Env (read from /opt/brain/.env if unset):
  GBRAIN_DATABASE_URL, OPENROUTER_API_KEY, EMBED_MODEL (default text-embedding-3-small)

VERIFY on first live run: EMBED_MODEL must match the table's vector width.
"""
from __future__ import annotations
import json
import os
import subprocess
import sys
import urllib.request

try:
    from mcp.server.fastmcp import FastMCP
except Exception as e:  # pragma: no cover
    sys.stderr.write(f"find-skill: missing 'mcp' package: {e}\n")
    raise

def _env_from_brain():
    p = "/opt/brain/.env"
    if os.path.exists(p):
        for line in open(p):
            if "=" in line and not line.strip().startswith("#"):
                k, v = line.strip().split("=", 1)
                os.environ.setdefault(k, v)

_env_from_brain()
mcp = FastMCP("find-skill")

def _embed(text):
    key = os.environ["OPENROUTER_API_KEY"]
    model = os.environ.get("EMBED_MODEL", "openai/text-embedding-3-small")
    req = urllib.request.Request(
        "https://openrouter.ai/api/v1/embeddings",
        data=json.dumps({"model": model, "input": text}).encode(),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)["data"][0]["embedding"]

@mcp.tool()
def find_skill(query: str, k: int = 5, boundary: str = "") -> str:
    """Return the k closest skills to `query` (name, path, boundary, description).

    boundary: optional 'reader' or 'actor' filter. The router reads the returned
    path's SKILL.md to actually run the skill. Use this instead of scanning the
    full directory when many skills are installed.
    """
    dburl = os.environ.get("GBRAIN_DATABASE_URL")
    if not dburl:
        return "ERROR: GBRAIN_DATABASE_URL not set"
    try:
        vec = "[" + ",".join(f"{x:.6f}" for x in _embed(query)) + "]"
    except Exception as e:
        return f"ERROR embedding query: {e}"
    where = f"WHERE boundary = '{boundary.replace(chr(39),'')}'" if boundary in ("reader", "actor") else ""
    sql = (f"SELECT name, path, boundary, left(description,160) "
           f"FROM skill_index {where} ORDER BY embedding <=> '{vec}' LIMIT {int(k)};")
    out = subprocess.run(["psql", dburl, "-tA", "-F", "\t", "-c", sql],
                         capture_output=True, text=True)
    if out.returncode != 0:
        return f"ERROR querying skill_index: {out.stderr.strip()}"
    rows = [ln for ln in out.stdout.splitlines() if ln.strip()]
    if not rows:
        return "no matches (is skill_index built? run tools/skill_index_embed.py)"
    lines = []
    for ln in rows:
        parts = ln.split("\t")
        name = parts[0] if len(parts) > 0 else "?"
        path = parts[1] if len(parts) > 1 else "?"
        bnd = parts[2] if len(parts) > 2 else ""
        desc = parts[3] if len(parts) > 3 else ""
        tag = f" [{bnd}]" if bnd else ""
        lines.append(f"{name}{tag}  ({path})  {desc}")
    return "\n".join(lines)

if __name__ == "__main__":
    mcp.run()
