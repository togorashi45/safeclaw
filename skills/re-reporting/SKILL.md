---
name: re-reporting
description: "Reporting & Finance Playbooks: P&L, KPI tracking, cash-flow forecasting, investor reports, and tax prep for the investing entity. Installable category pack split from the real-estate playbook library so a box only carries what the client uses."
version: 1.0.0
author: RE Reset
license: MIT
metadata:
  hermes:
    tags: ['reporting', 'kpi', 'pnl']
    category: real-estate
    sources:
      - {kind: brain, optional: false}
      - {kind: gohighlevel, optional: true}
      - {kind: gmail, optional: true}
      - {kind: googlecalendar, optional: true}
---

# Reporting & Finance Playbooks

P&L, KPI tracking, cash-flow forecasting, investor reports, and tax prep for the investing entity.

10 playbooks. Do not load them all. Pick the closest play by its
description, read ONLY that file, then follow it. Pull live data from the
connected CRM, email, calendar, and the brain as the play directs.

## Plays

- `references/cash-flow-forecaster.md` - Forward-looking cash flow forecast — project income and expenses 3-12 months forward including known closings, rental income, and seasonal adjustments
- `references/exit-timing-advisor.md` - Analyze hold vs sell timing — market conditions, equity position, cash flow trajectory, tax implications, and opportunity cost
- `references/financial-qa.md` - Answer accounting and financial questions in RE investor context — depreciation, 1031 exchanges, cost segregation, self-directed IRA, and capital gains strategi
- `references/goal-tracker.md` - Track business goals vs actuals — revenue targets, deal counts, marketing spend, and portfolio growth with progress tracking
- `references/investor-report.md` - Generate LP/investor update reports — capital deployed, returns, deal pipeline, distributions, and portfolio performance
- `references/kpi-benchmark.md` - Compare your KPIs against industry benchmarks for wholesaling, flipping, rentals, and note investing
- `references/kpi-tracker.md` - Track key business KPIs — leads, cost per lead, appointments, offers, contracts, deals closed, assignment fees, and marketing ROI
- `references/monthly-pnl.md` - Generate monthly profit and loss statements — revenue from all sources vs expenses, with month-over-month comparison
- `references/tax-prep-multi-entity.md` - Multi-entity tax preparation — entity structure review, inter-entity transactions, consolidated reporting, and entity-specific deductions
- `references/tax-prep.md` - Tax preparation helper — categorize expenses, identify deductions, flag audit triggers, and generate CPA-ready summaries
