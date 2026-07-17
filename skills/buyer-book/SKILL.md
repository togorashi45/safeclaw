---
name: buyer-book
description: "The client's living buyer database: ingest buyer lists (spreadsheets, CRM pipelines), keep a buy-box record per buyer in the brain, and update it from actual reply/close behavior. Backs dispo matching and cold outreach with real data. Triggers on: buyer list, buy box, who buys, add buyer, buyer book, dispo list."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: [buyers, dispo, buy-box, brain]
    category: real-estate
    sources:
      - {kind: brain, optional: false}
      - {kind: ghl-pipelines, optional: true}
      - {kind: googlesheets, optional: true}
---

# Buyer Book

One brain page per buyer (`buyers/<slug>`): name, contacts, buy-box (markets/
zips, property types, price band, rehab tolerance, close speed, proof of
funds), provenance, and a rolling activity log (deals sent, replies, offers,
closes). The book is the single source dispo and cold-outreach read.

## Source discovery (run `agent-sources` first)
- CRM pipelines that hold buyers (e.g. Travis: "Cash Buyer Lead Pipeline",
  "Retail Buyer Pipeline" with Travis/Sam lanes) -> sync stage + replies.
- Google Sheets buyer lists (e.g. Sam's spreadsheet) -> one-time ingest with
  activity levels preserved; keep the sheet as source-of-origin note.
- Email/SMS threads in the brain -> harvest buyer signals (what they bid on,
  what they passed on, why).

## Behaviors
1. **Ingest**: given a sheet/CSV/pipeline, create or update buyer pages.
   Never drop existing activity history on re-ingest; merge.
2. **Learn**: when a buyer replies to a blast, bids, or closes, append to
   their page and adjust the buy-box (e.g. "passed twice on heavy rehab ->
   rehab tolerance: light").
3. **Answer**: "who buys 2bd fixers in 80207 under 450?" -> ranked list from
   the book with one-line whys and freshness (last activity date).
4. **Feed dispo**: the re-dispositions matcher and cold-outreach target
   scoring read these pages; keep them structured (frontmatter fields).
Buyer contact info is client data: stays in the brain, never leaves the box.
