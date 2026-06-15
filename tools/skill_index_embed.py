#!/usr/bin/env python3
"""skill_index_embed.py: Part B of the lean loader (pgvector skill retrieval).

Past a few hundred skills the always-loaded directory stops being cheap. This
embeds each kept skill's "name: description" into a pgvector table in the box
brain so the agent can `find_skill(query)` instead of reading the whole index.
Input is skills.index.json (emitted by skills_manifest.py).

Usage:
  skill_index_embed.py --index build/skills/skills.index.json
Env:
  GBRAIN_DATABASE_URL   brain postgres (or read /opt/brain/.env)
  OPENROUTER_API_KEY    embeddings (read /opt/brain/.env if unset)
  EMBED_MODEL           default openai/text-embedding-3-small (1536 dims)

VERIFY on first live run: that EMBED_MODEL matches what the brain was init'd with
(vector width must match). Uses psql so no extra python db driver is needed.
"""
from __future__ import annotations
import argparse
import json
import os
import subprocess
import sys
import urllib.request

DIM = 1536  # openai/text-embedding-3-small

def _env_from_brain():
    p = "/opt/brain/.env"
    if os.path.exists(p):
        for line in open(p):
            if "=" in line and not line.strip().startswith("#"):
                k, v = line.strip().split("=", 1)
                os.environ.setdefault(k, v)

def embed(text, model, key):
    req = urllib.request.Request(
        "https://openrouter.ai/api/v1/embeddings",
        data=json.dumps({"model": model, "input": text}).encode(),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)["data"][0]["embedding"]

def psql(dburl, sql, args=None):
    cmd = ["psql", dburl, "-v", "ON_ERROR_STOP=1", "-c", sql]
    out = subprocess.run(cmd, capture_output=True, text=True)
    if out.returncode != 0:
        raise RuntimeError(out.stderr.strip())
    return out.stdout

def vec_literal(v):
    return "[" + ",".join(f"{x:.6f}" for x in v) + "]"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--index", required=True)
    args = ap.parse_args()
    _env_from_brain()
    dburl = os.environ.get("GBRAIN_DATABASE_URL")
    key = os.environ.get("OPENROUTER_API_KEY")
    model = os.environ.get("EMBED_MODEL", "openai/text-embedding-3-small")
    if not dburl: sys.exit("GBRAIN_DATABASE_URL not set")
    if not key: sys.exit("OPENROUTER_API_KEY not set")

    manifest = json.load(open(args.index))
    kept = manifest.get("kept", [])

    psql(dburl, f"""CREATE TABLE IF NOT EXISTS skill_index (
        name text PRIMARY KEY, category text, boundary text, path text,
        description text, tools jsonb, embedding vector({DIM}));""")

    n = 0
    for rec in kept:
        text = f"{rec['name']}: {rec.get('description','')}"
        try:
            v = embed(text, model, key)
        except Exception as e:
            sys.stderr.write(f"embed failed for {rec['name']}: {e}\n"); continue
        if len(v) != DIM:
            sys.stderr.write(f"WARN: {rec['name']} embedding dim {len(v)} != {DIM} (model mismatch?)\n")
        name = rec["name"].replace("'", "''")
        desc = (rec.get("description") or "").replace("'", "''")
        cat = (rec.get("category") or "").replace("'", "''")
        bnd = (rec.get("boundary") or "").replace("'", "''")
        path = (rec.get("path") or "").replace("'", "''")
        tools = json.dumps(rec.get("tools") or []).replace("'", "''")
        psql(dburl, f"""INSERT INTO skill_index (name,category,boundary,path,description,tools,embedding)
            VALUES ('{name}','{cat}','{bnd}','{path}','{desc}','{tools}'::jsonb,'{vec_literal(v)}')
            ON CONFLICT (name) DO UPDATE SET category=EXCLUDED.category, boundary=EXCLUDED.boundary,
            path=EXCLUDED.path, description=EXCLUDED.description, tools=EXCLUDED.tools, embedding=EXCLUDED.embedding;""")
        n += 1
    print(f"skill_index_embed: embedded {n}/{len(kept)} skills into skill_index (dim {DIM}, model {model})")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
