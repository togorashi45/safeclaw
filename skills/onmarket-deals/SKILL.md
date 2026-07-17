---
name: onmarket-deals
description: "On-Market Deal Feeds: pull fresh daily listings, stale/long-DOM listings, and fixer-upper flags for the client's market from the free Redfin source. Outputs three CSVs + a report, optionally posts the top opportunities to Slack. Triggers on: on-market deals, stale listings, fixer uppers, what hit the market today, daily listings run, hot on market."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [listings, mls, acquisitions, deal-flow, fixer, dom]
    category: real-estate
    sources:
      - {kind: slack, optional: true}
      - {kind: gohighlevel, optional: true}
---

# On-Market Deal Feeds

Free-source on-market scraper. One run pulls every active listing in the
client's configured regions from Redfin's unofficial gis JSON API (no key,
no cost) and splits them into three feeds:

- **fresh.csv** - just hit the market (DOM <= threshold, or newly seen vs
  the state file; day-over-day diff starts on the second run)
- **stale.csv** - long days-on-market, sorted longest first (motivated
  seller / targeted outreach list)
- **fixer.csv** - fixer-upper flags from word-boundary keyword matches on
  listing remarks ("investor special", "as-is", "structural", ...) plus a
  price-per-sqft screen vs the zip median

Every row carries the listing agent NAME; agent PHONE numbers come from a
capped listing-page fetch for flagged deals (`max_phone_fetches`).

## Run

```bash
cd scripts/
python3 scraper.py --config <client-config>.json
python3 post_slack.py --config <client-config>.json --channel <CHANNEL_ID> --top 10
```

- Set `ONMARKET_DATA_DIR` to keep out/ and state/ outside the repo tree
  (e.g. `/opt/brain/onmarket`), otherwise they land next to the scripts.
- `post_slack.py` needs `SLACK_BOT_TOKEN` in the env. Skip it if the box
  has no Slack; the CSVs and `report.md` are the deliverable either way.
- Intended cadence: ONE run per day (cron). Redfin soft-blocks bursts
  (empty 200/202 responses); if regions come back empty, back off minutes.

## New market setup

Copy `scripts/config.example.json` (Denver metro). Per region you need
`region_id` + `region_type` (5 = county, 6 = city) - both visible in
Redfin URLs (`redfin.com/county/377/CO/Denver-County` -> id 377 type 5) -
and the `market` slug (metro name). County IDs run alphabetically by state
nationally. Verify each region with a small probe run and confirm sample
cities before trusting output. Tune the buy box: `max_price`,
`stale_min_dom` (60), `fresh_max_dom` (1), `fixer_ppsf_ratio` (0.75),
`fixer_keywords`.

## Rules

- Free tier only; never add paid data sources without Jake's approval.
- Do NOT switch to Redfin's gis-csv endpoint: MLS download rules silently
  drop entire counties from CSV export. The JSON endpoint is complete.
- Feeds may be pushed into the client's GHL as outreach lists only when
  that client's GHL push is approved.
- The client's licensed MLS access, when it exists, beats this feed - use
  it and keep this as the fallback.
