#!/usr/bin/env python3
"""Post the day's best on-market opportunities to Slack.

Ranks the fixer feed (keyword-flagged deals score highest, boosted by DOM
and by how deep the price sits under the zip median), takes the top N, and
posts one message to the given channel.

Usage:
  python3 post_slack.py --config config/travis-denver.json \
      --channel C0BHZN0950A [--top 10] [--date YYYY-MM-DD]

Token: SLACK_BOT_TOKEN env var, or read from marcus-agent/.env two levels up.
"""

import argparse
import csv
import json
import os
import ssl
import sys
import urllib.request
from datetime import date

try:
    import certifi
    SSL_CTX = ssl.create_default_context(cafile=certifi.where())
except ImportError:
    SSL_CTX = ssl.create_default_context()


def load_token(base):
    tok = os.environ.get("SLACK_BOT_TOKEN")
    if tok:
        return tok
    envfile = os.path.join(base, "..", "..", "marcus-agent", ".env")
    if os.path.exists(envfile):
        for line in open(envfile):
            if "SLACK" in line.upper() and "TOKEN" in line.upper() and "=" in line:
                return line.split("=", 1)[1].strip()
    sys.exit("No Slack token found (SLACK_BOT_TOKEN or marcus-agent/.env)")


def score(r):
    hits = [h for h in r["remarks_hit"].split("; ") if h and not h.startswith("ppsf ")]
    ppsf_bonus = 0.0
    for part in r["remarks_hit"].split("; "):
        if part.startswith("ppsf ") and "%" in part:
            try:
                pct = int(part.split()[1].rstrip("%"))
                ppsf_bonus = (100 - pct) / 10.0
            except ValueError:
                pass
    dom = int(r["dom"]) if r["dom"] else 0
    phone_bonus = 1.5 if r.get("agent_phone") else 0.0
    return len(hits) * 3.0 + ppsf_bonus + min(dom, 365) / 45.0 + phone_bonus


def fmt_deal(i, r):
    price = f"${int(r['price']):,}" if r["price"] else "?"
    flags = r["remarks_hit"]
    agent = r["listing_agent"] or "agent n/a"
    phone = f" {r['agent_phone']}" if r.get("agent_phone") else ""
    return (f"*{i}. <{r['url']}|{r['address']}, {r['city']}>* - {price} - "
            f"{r['dom']} DOM\n   _{flags}_ | {agent}{phone}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--channel", required=True)
    ap.add_argument("--top", type=int, default=10)
    ap.add_argument("--date", default=date.today().isoformat())
    args = ap.parse_args()

    base = os.environ.get("ONMARKET_DATA_DIR") or os.path.dirname(os.path.abspath(__file__))
    with open(args.config) as f:
        cfg = json.load(f)
    outdir = os.path.join(base, "out", cfg["client"], args.date)
    fixer_path = os.path.join(outdir, "fixer.csv")
    if not os.path.exists(fixer_path):
        sys.exit(f"No output for {args.date} - run scraper.py first ({fixer_path})")

    rows = list(csv.DictReader(open(fixer_path)))
    rows.sort(key=score, reverse=True)
    top = rows[:args.top]

    fresh_n = stale_n = 0
    for name in ("fresh", "stale"):
        p = os.path.join(outdir, f"{name}.csv")
        if os.path.exists(p):
            n = sum(1 for _ in open(p)) - 1
            if name == "fresh":
                fresh_n = n
            else:
                stale_n = n

    lines = [f":fire: *Hot on-market - {args.date}*",
             f"_{fresh_n} fresh today, {stale_n} stale (60+ DOM), "
             f"{len(rows)} fixer flags. Top {len(top)}:_", ""]
    lines += [fmt_deal(i + 1, r) for i, r in enumerate(top)]
    text = "\n".join(lines)

    token = load_token(base)
    req = urllib.request.Request(
        "https://slack.com/api/chat.postMessage",
        data=json.dumps({"channel": args.channel, "text": text,
                         "unfurl_links": False}).encode(),
        headers={"Authorization": f"Bearer {token}",
                 "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30, context=SSL_CTX) as resp:
        result = json.loads(resp.read())
    if not result.get("ok"):
        sys.exit(f"Slack post failed: {result.get('error')}")
    print(f"Posted top {len(top)} to {args.channel}")


if __name__ == "__main__":
    main()
