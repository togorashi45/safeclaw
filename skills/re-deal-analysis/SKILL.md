---
name: re-deal-analysis
description: "Deal Analysis Playbooks: ARV, comps, MAO, cap rate, rehab estimating, and offer math for evaluating any residential deal. Installable category pack split from the real-estate playbook library so a box only carries what the client uses."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: ['deal-analysis', 'arv', 'comps', 'mao']
    category: real-estate
    sources:
      - {kind: brain, optional: false}
      - {kind: gohighlevel, optional: true}
      - {kind: gmail, optional: true}
      - {kind: googlecalendar, optional: true}
---

# Deal Analysis Playbooks

ARV, comps, MAO, cap rate, rehab estimating, and offer math for evaluating any residential deal.

16 playbooks. Do not load them all. Pick the closest play by its
description, read ONLY that file, then follow it. Pull live data from the
connected CRM, email, calendar, and the brain as the play directs.

## Plays

- `references/arv-calculator.md` - Calculate After Repair Value using comparable sales with adjustment methodology, confidence scoring, and MAO calculation
- `references/cap-rate-comp.md` - Compare cap rates across properties or submarkets for rental and commercial investment analysis
- `references/cap-rate-tracker.md` - Track cap rate trends over time for target markets. Identify cap rate compression or expansion as investment timing signals
- `references/cash-flow-projector.md` - Project monthly and annual cash flow for rental properties including vacancy, management, maintenance, taxes, insurance, and debt service
- `references/commercial-acquisition.md` - Analyze commercial property acquisitions — retail, office, industrial, mixed-use. Cap rate, NOI, lease analysis, and tenant evaluation
- `references/comp-pull.md` - Pull and analyze comparable sales for any property. Builds a structured comp grid with adjustments, ARV range, and confidence score
- `references/competitor-flip-tracker.md` - Track competitor flip activity — who is buying, where, at what price, rehab scope, and resale performance. Know your competition
- `references/deal-pnl.md` - Calculate complete profit and loss for any real estate deal — wholesale, flip, or rental. Includes all costs, fees, holding costs, and net profit
- `references/deal-predictor.md` - Score deal probability of closing based on seller motivation, pricing, timeline, financing, and comparable deal outcomes
- `references/dom-tracker.md` - Track average days on market for target areas to identify market speed changes
- `references/market-snapshot.md` - Generate a comprehensive market overview for any zip code or city — median prices, DOM, inventory, price trends, rent ratios, and investment signals
- `references/market-velocity.md` - Track market speed — absorption rate, DOM trends, inventory changes, and price velocity. Identifies heating or cooling markets
- `references/mf-underwriter.md` - Underwrite multifamily apartment deals — NOI, cap rate, DSCR, cash-on-cash, price per unit, expense ratios, and value-add projections
- `references/neighborhood-scoring.md` - Score neighborhoods on investability — school ratings, crime, employment, rent growth, population trends, and investor activity
- `references/noi-analyzer.md` - Calculate and analyze Net Operating Income for rental and commercial properties. Break down income vs expenses and identify optimization opportunities
- `references/value-add-opportunity.md` - Identify forced appreciation opportunities — rent bumps, expense reduction, unit additions, conversions, and repositioning strategies
