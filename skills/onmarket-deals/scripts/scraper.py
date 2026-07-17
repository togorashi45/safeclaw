#!/usr/bin/env python3
"""On-market deals scraper (free sources, Redfin unofficial API).

Three feeds per run:
  fresh - listings new to market (low DOM or first time seen)
  stale - long days-on-market listings (motivated seller candidates)
  fixer - listing-remarks keyword matches, plus a low price-per-sqft screen

Data comes from Redfin's gis JSON endpoint, which includes remarks, DOM,
$/sqft, and listing agent name inline. Agent PHONE numbers require a
listing-page fetch, done only for flagged deals up to a cap.

Usage:
  python3 scraper.py --config config/travis-denver.json
  python3 scraper.py --config config/travis-denver.json --no-phones

Output: out/<client>/<YYYY-MM-DD>/{fresh,stale,fixer}.csv + report.md
State:  state/<client>-seen.json (MLS numbers seen before, for fresh-diff)

Stdlib only. No API keys. Redfin blocks default UAs; we send browser headers.
It also soft-blocks bursts (empty 200s) - keep sleeps in place.
"""

import argparse
import csv
import html as html_mod
import json
import os
import random
import re
import sys
import time
import ssl
import urllib.request
from datetime import date

try:
    import certifi
    SSL_CTX = ssl.create_default_context(cafile=certifi.where())
except ImportError:
    try:
        ssl.create_default_context().load_default_certs()
        SSL_CTX = ssl.create_default_context()
    except Exception:
        SSL_CTX = ssl._create_unverified_context()

UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36")

GIS = ("https://www.redfin.com/stingray/api/gis?al=1&market={market}"
       "&num_homes={num_homes}&page_number=1&region_id={region_id}"
       "&region_type={region_type}&sf=1,2,3,5,6,7&status=9&uipt={uipt}&v=8")

DEFAULT_FIXER_KEYWORDS = [
    "fixer", "fix up", "tlc", "handyman", "as-is", "as is", "sold as-is",
    "investor special", "investor", "cash only", "cash offers", "needs work",
    "needs updating", "needs repair", "needs some", "bring your vision",
    "sweat equity", "estate sale", "probate", "gut", "rehab", "flip",
    "contractor special", "diamond in the rough", "not fha", "no fha",
    "won't qualify", "sold in its present condition", "structural",
    "foundation issue", "roof needs", "original condition", "outdated",
]


def fetch(url, referer="https://www.redfin.com/", timeout=30):
    req = urllib.request.Request(url, headers={
        "User-Agent": UA,
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
        "Referer": referer,
        "Accept-Encoding": "identity",
    })
    with urllib.request.urlopen(req, timeout=timeout, context=SSL_CTX) as resp:
        return resp.read().decode("utf-8", errors="replace")


def val(field):
    """Redfin wraps scalars as {'value': x, 'level': n}."""
    if isinstance(field, dict):
        return field.get("value")
    return field


def fetch_region(region, num_homes, uipt):
    url = GIS.format(market=region["market"], num_homes=num_homes,
                     region_id=region["region_id"],
                     region_type=region["region_type"], uipt=uipt)
    raw = fetch(url)
    data = json.loads(raw.split("&&", 1)[1])
    if data.get("resultCode") != 0:
        raise RuntimeError(f"{region['name']}: {data.get('errorMessage')}")
    homes = data.get("payload", {}).get("homes", [])
    rows = []
    for h in homes:
        rows.append({
            "address": val(h.get("streetLine")) or "",
            "city": h.get("city", ""),
            "state": h.get("state", ""),
            "zip": h.get("zip", ""),
            "price": val(h.get("price")),
            "beds": h.get("beds", ""),
            "baths": h.get("baths", ""),
            "sqft": val(h.get("sqFt")),
            "lot_sqft": val(h.get("lotSize")),
            "year_built": val(h.get("yearBuilt")),
            "dom": val(h.get("dom")),
            "ppsf": val(h.get("pricePerSqFt")),
            "hoa": val(h.get("hoa")),
            "status": h.get("mlsStatus", ""),
            "property_type": h.get("uiPropertyType", ""),
            "mls": val(h.get("mlsId")) or "",
            "url": "https://www.redfin.com" + h.get("url", ""),
            "region": region["name"],
            "remarks": h.get("listingRemarks", "") or "",
            "remarks_hit": "",
            "listing_agent": (h.get("listingAgent") or {}).get("name", ""),
            "agent_phone": "",
            "brokerage": (h.get("listingBroker") or {}).get("name", ""),
            "is_new_construction": h.get("isNewConstruction", False),
        })
    return rows


def area_median_ppsf(rows):
    """Median $/sqft per zip (fallback: whole pull)."""
    by_zip = {}
    for r in rows:
        if r["ppsf"]:
            by_zip.setdefault(r["zip"], []).append(r["ppsf"])
    medians = {z: sorted(v)[len(v) // 2] for z, v in by_zip.items()}
    allv = sorted(x for v in by_zip.values() for x in v)
    overall = allv[len(allv) // 2] if allv else None
    return medians, overall


def fetch_phone(listing, sleep_range):
    """Listing pages embed listingAgentNumber; the gis feed does not."""
    try:
        page = fetch(listing["url"])
    except Exception:
        return
    m = re.search(r'listingAgentNumber\\?":\\?"(.*?)\\?"[,}]', page)
    if m:
        listing["agent_phone"] = html_mod.unescape(m.group(1)).replace("\\", "")
    time.sleep(random.uniform(*sleep_range))


FIELDNAMES = ["address", "city", "state", "zip", "price", "beds", "baths",
              "sqft", "lot_sqft", "year_built", "dom", "ppsf", "hoa", "status",
              "property_type", "mls", "url", "region", "remarks_hit",
              "listing_agent", "agent_phone", "brokerage", "remarks"]


def write_csv(path, rows):
    with open(path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=FIELDNAMES, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--no-phones", action="store_true",
                    help="skip listing-page fetches for agent phone numbers")
    args = ap.parse_args()

    with open(args.config) as f:
        cfg = json.load(f)

    base = os.environ.get("ONMARKET_DATA_DIR") or os.path.dirname(os.path.abspath(__file__))
    client = cfg["client"]
    today = date.today().isoformat()
    outdir = os.path.join(base, "out", client, today)
    os.makedirs(outdir, exist_ok=True)
    statedir = os.path.join(base, "state")
    os.makedirs(statedir, exist_ok=True)
    state_path = os.path.join(statedir, f"{client}-seen.json")
    seen = set()
    first_run = not os.path.exists(state_path)
    if not first_run:
        with open(state_path) as f:
            seen = set(json.load(f))

    stale_min = cfg.get("stale_min_dom", 60)
    fresh_max = cfg.get("fresh_max_dom", 1)
    max_price = cfg.get("max_price")
    keywords = [k.lower() for k in cfg.get("fixer_keywords", DEFAULT_FIXER_KEYWORDS)]
    uipt = cfg.get("uipt", "1,2,3,4")
    num_homes = cfg.get("num_homes_per_region", 500)
    phone_cap = cfg.get("max_phone_fetches", 60)
    sleep_range = tuple(cfg.get("detail_sleep_seconds", [1.0, 2.5]))

    all_rows, errors = [], []
    for region in cfg["regions"]:
        try:
            rows = fetch_region(region, num_homes, uipt)
            all_rows.extend(rows)
            print(f"[{region['name']}] {len(rows)} listings")
        except Exception as e:
            errors.append(f"{region['name']}: {e}")
            print(f"[{region['name']}] ERROR: {e}", file=sys.stderr)
        time.sleep(random.uniform(1.5, 3.0))

    if not all_rows:
        print("No listings pulled - likely soft-blocked. Back off and retry.",
              file=sys.stderr)
        sys.exit(1)

    # Dedup across regions on MLS# (fallback: address+zip)
    dedup = {}
    for r in all_rows:
        key = r["mls"] or (r["address"] + r["zip"])
        dedup.setdefault(key, r)
    listings = list(dedup.values())
    if max_price:
        listings = [r for r in listings if r["price"] and r["price"] <= max_price]

    zip_med, overall_med = area_median_ppsf(listings)

    fresh, stale, fixer = [], [], []
    for r in listings:
        key = r["mls"] or (r["address"] + r["zip"])
        is_new = key not in seen
        if r["dom"] is not None and r["dom"] >= stale_min:
            stale.append(r)
        # First run: seen-state is empty, so only DOM qualifies as fresh.
        if (r["dom"] is not None and r["dom"] <= fresh_max) or (is_new and not first_run):
            if not r["is_new_construction"]:
                fresh.append(r)

        low = r["remarks"].lower()
        hits = [k for k in keywords
                if re.search(r"\b" + re.escape(k) + r"\b", low)]
        med = zip_med.get(r["zip"]) or overall_med
        ratio = (r["ppsf"] / med) if (r["ppsf"] and med) else None
        cheap = ratio is not None and ratio <= cfg.get("fixer_ppsf_ratio", 0.75)
        if hits or (cheap and (r["year_built"] or 9999) <= cfg.get("fixer_max_year_built", 1985)):
            r["remarks_hit"] = "; ".join(hits) if hits else f"ppsf {int(ratio*100)}% of zip median"
            fixer.append(r)

    stale.sort(key=lambda r: -(r["dom"] or 0))
    fresh.sort(key=lambda r: r["dom"] or 0)
    fixer.sort(key=lambda r: -len(r["remarks_hit"]))

    if not args.no_phones:
        targets = [r for r in fixer + stale if not r["agent_phone"]][:phone_cap]
        print(f"Fetching agent phones for {len(targets)} flagged listings...")
        for r in targets:
            fetch_phone(r, sleep_range)

    write_csv(os.path.join(outdir, "fresh.csv"), fresh)
    write_csv(os.path.join(outdir, "stale.csv"), stale)
    write_csv(os.path.join(outdir, "fixer.csv"), fixer)

    for r in listings:
        seen.add(r["mls"] or (r["address"] + r["zip"]))
    with open(state_path, "w") as f:
        json.dump(sorted(seen), f)

    def fmt(r):
        price = f"${r['price']:,}" if r["price"] else "?"
        return (f"- {r['address']}, {r['city']} {price} DOM {r['dom']} "
                f"| {r['listing_agent']} {r['agent_phone']} | {r['url']}")

    report = [
        f"# On-market deals - {client} - {today}",
        "",
        f"Active listings pulled: {len(listings)} across {len(cfg['regions'])} regions",
        f"- Fresh (DOM <= {fresh_max}{'' if first_run else ' or new since last run'}): {len(fresh)}",
        f"- Stale (DOM >= {stale_min}): {len(stale)}",
        f"- Fixer flags: {len(fixer)}",
        "",
    ]
    if first_run:
        report.append("_First run: seeded seen-state; fresh feed diffs start tomorrow._\n")
    if fixer:
        report.append("## Top fixer flags")
        for r in fixer[:15]:
            report.append(fmt(r) + f"  [{r['remarks_hit']}]")
        report.append("")
    if stale:
        report.append("## Longest on market")
        report.extend(fmt(r) for r in stale[:15])
        report.append("")
    if fresh:
        report.append("## Freshest")
        report.extend(fmt(r) for r in fresh[:15])
        report.append("")
    if errors:
        report.append("## Errors")
        report.extend(f"- {e}" for e in errors)
    with open(os.path.join(outdir, "report.md"), "w") as f:
        f.write("\n".join(report) + "\n")

    print(f"Done. fresh={len(fresh)} stale={len(stale)} fixer={len(fixer)} -> {outdir}")


if __name__ == "__main__":
    main()
