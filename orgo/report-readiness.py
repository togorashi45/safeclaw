#!/usr/bin/env python3
"""report-readiness.py: Stage 5 of the Conductor. Runs on the box.

Health-checks the box, seeds the principal's first-win task on the canonical
board, posts a Slack note to Jake, and pushes a portal tile. Called by the
install-box.sh `verify` stage and again when the onboarding readiness bar is met.

Env (set by the installer; any missing piece degrades to a warning, never a crash):
  CLIENT_SLUG                  the box principal slug (e.g. kim)
  GATEWAY_HEALTH_URL           default http://127.0.0.1:9000/health
  BRAIN_DB_URL                 postgres url for the vector check (or read /opt/brain/.env)
  TASKS_API_URL / TASKS_API_TOKEN   canonical board REST (preferred)
  TASKS_DATABASE_URL           direct Postgres fallback for seeding the task
  SLACK_WEBHOOK_URL            incoming webhook for the Jake note
  PORTAL_TELEMETRY_URL / PORTAL_TELEMETRY_TOKEN   portal tile ingest (Package F)
  FIRST_WIN                    text of the principal's first-win task (optional)

Usage: report-readiness.py [--first-win "..."] [--no-seed]
VERIFY on first live run: gateway health path, task board REST shape, portal ingest path.
"""
from __future__ import annotations
import argparse
import json
import os
import subprocess
import sys
import urllib.request

def _get(name, default=""):
    return os.environ.get(name, default)

def http_json(url, payload=None, headers=None, method=None, timeout=10):
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(url, data=data, method=method or ("POST" if data else "GET"))
    req.add_header("Content-Type", "application/json")
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        body = r.read().decode()
        return r.status, (json.loads(body) if body.strip().startswith(("{", "[")) else body)

def check_gateway():
    url = _get("GATEWAY_HEALTH_URL", "http://127.0.0.1:9000/health")
    try:
        status, _ = http_json(url, timeout=8)
        return ("gateway", status == 200, f"HTTP {status} {url}")
    except Exception as e:
        return ("gateway", False, f"{url}: {e}")

def check_postgres_vector():
    # Read the brain db url from env or /opt/brain/.env
    url = _get("BRAIN_DB_URL")
    if not url and os.path.exists("/opt/brain/.env"):
        for line in open("/opt/brain/.env"):
            if line.startswith("GBRAIN_DATABASE_URL="):
                url = line.split("=", 1)[1].strip()
    if not url:
        return ("postgres_vector", False, "no brain db url")
    try:
        out = subprocess.run(
            ["psql", url, "-tAc", "SELECT count(*) FROM pg_extension WHERE extname='vector';"],
            capture_output=True, text=True, timeout=10)
        ok = out.stdout.strip() == "1"
        return ("postgres_vector", ok, out.stdout.strip() or out.stderr.strip())
    except Exception as e:
        return ("postgres_vector", False, str(e))

def seed_first_task(first_win):
    if not first_win:
        return ("seed_task", True, "no first win provided, skipped")
    slug = _get("CLIENT_SLUG", "box")
    title = f"First win: {first_win}"
    api, token = _get("TASKS_API_URL"), _get("TASKS_API_TOKEN")
    if api:
        try:
            status, _ = http_json(
                api.rstrip("/") + "/tasks",
                payload={"title": title, "status": "This Week", "priority": "P1",
                         "owner": slug, "area": "Onboarding", "source": "conductor"},
                headers={"Authorization": f"Bearer {token}"} if token else {})
            return ("seed_task", status in (200, 201), f"REST HTTP {status}")
        except Exception as e:
            return ("seed_task", False, f"REST: {e}")
    dburl = _get("TASKS_DATABASE_URL")
    if dburl:
        try:
            out = subprocess.run(
                ["psql", dburl, "-tAc",
                 "INSERT INTO rereset_tasks (title,status,priority,owner,area,source) "
                 f"VALUES ('{title.replace(chr(39),chr(39)*2)}','This Week','P1','{slug}','Onboarding','conductor');"],
                capture_output=True, text=True, timeout=10)
            return ("seed_task", out.returncode == 0, out.stderr.strip() or "inserted")
        except Exception as e:
            return ("seed_task", False, f"PG: {e}")
    return ("seed_task", False, "no TASKS_API_URL or TASKS_DATABASE_URL")

def post_slack(lines):
    url = _get("SLACK_WEBHOOK_URL")
    if not url:
        return ("slack", False, "no SLACK_WEBHOOK_URL")
    try:
        status, _ = http_json(url, payload={"text": "\n".join(lines)})
        return ("slack", status == 200, f"HTTP {status}")
    except Exception as e:
        return ("slack", False, str(e))

def push_portal_tile(results):
    url = _get("PORTAL_TELEMETRY_URL")
    if not url:
        return ("portal_tile", False, "no PORTAL_TELEMETRY_URL (Package F not wired yet)")
    token = _get("PORTAL_TELEMETRY_TOKEN")
    try:
        status, _ = http_json(url, payload={"box": _get("CLIENT_SLUG", "box"),
                                            "checks": {k: ok for (k, ok, _m) in results}},
                              headers={"Authorization": f"Bearer {token}"} if token else {})
        return ("portal_tile", status in (200, 201), f"HTTP {status}")
    except Exception as e:
        return ("portal_tile", False, str(e))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--first-win", default=_get("FIRST_WIN"))
    ap.add_argument("--no-seed", action="store_true")
    args = ap.parse_args()

    checks = [check_gateway(), check_postgres_vector()]
    if not args.no_seed:
        checks.append(seed_first_task(args.first_win))

    slug = _get("CLIENT_SLUG", "box")
    lines = [f"*Readiness report: {slug}*"]
    for name, ok, msg in checks:
        lines.append(f"{'PASS' if ok else 'FAIL'} {name}: {msg}")
    checks.append(post_slack(lines))
    checks.append(push_portal_tile(checks))

    for name, ok, msg in checks:
        print(f"{'PASS' if ok else 'FAIL'} {name}: {msg}")
    core_ok = all(ok for (n, ok, _m) in checks if n in ("gateway", "postgres_vector"))
    return 0 if core_ok else 1

if __name__ == "__main__":
    sys.exit(main())
