---
name: real-estate-playbooks
description: "Real estate investor playbook library: deal analysis (ARV, comps, cap rate, MAO), creative finance (subject-to, seller finance, capital stack, Dodd-Frank), dispositions, lead generation, property management, transactions (LOI, assignment, double close), reporting, and marketing. Reference this for ANY real estate investing, wholesaling, or acquisition task. Triggers on: ARV, comps, MAO, wholesale, subject to, seller finance, assignment, disposition, cold call, lease, eviction, cap rate, LOI, double close, creative finance, deal analysis."
license: MIT
metadata:
  hermes:
    tags: [real-estate, investing, wholesaling, acquisitions, creative-finance]
    category: real-estate
---

# Real Estate Investor Playbooks

A library of 127 playbooks for real estate investing and wholesaling. Each playbook is a reference file under `references/<category>/<slug>.md`. Do not load them all. When a task matches one of the plays below, read ONLY that file with your file-reading tool, then follow it. Pick the closest match by the description; if several apply, read them in order.

## Integration with SafeClaw

For **SafeClaw deployments** (Hermes + gBrain + GHL + Kanban), use the lead intake workflow first:

1. **New lead arrives** → Create Kanban task in `acquisitions` board
2. **Kanban worker** → Creates GHL contact, tags, logs details
3. **Analysis phase** → Then use playbooks below for deal evaluation

See `safeclaw-deployment/references/real-estate-lead-intake-kanban-ghl.md` for the complete lead-to-pipeline workflow.

## How to use

1. Find the play whose description matches the user's request.
2. Read `references/<category>/<slug>.md` (one file).
3. Follow that playbook. Pull live data from the connected GHL CRM, Gmail, Calendar, and the brain as the play directs.

## Playbook index

### Deal Analysis

- **ARV Calculator** — Calculate After Repair Value using comparable sales with adjustment methodology, confidence scoring, and MAO calculation. → `references/deal-analysis/arv-calculator.md`
- **Cap Rate Comparison** — Compare cap rates across properties or submarkets for rental and commercial investment analysis. → `references/deal-analysis/cap-rate-comp.md`
- **Cap Rate Tracker** — Track cap rate trends over time for target markets. Identify cap rate compression or expansion as investment timing signals. → `references/deal-analysis/cap-rate-tracker.md`
- **Cash Flow Projector** — Project monthly and annual cash flow for rental properties including vacancy, management, maintenance, taxes, insurance, and debt service. → `references/deal-analysis/cash-flow-projector.md`
- **Commercial Acquisition Analyzer** — Analyze commercial property acquisitions — retail, office, industrial, mixed-use. Cap rate, NOI, lease analysis, and tenant evaluation. → `references/deal-analysis/commercial-acquisition.md`
- **Comp Pull Bot** — Pull and analyze comparable sales for any property. Builds a structured comp grid with adjustments, ARV range, and confidence score. → `references/deal-analysis/comp-pull.md`
- **Competitor Flip Tracker** — Track competitor flip activity — who is buying, where, at what price, rehab scope, and resale performance. Know your competition. → `references/deal-analysis/competitor-flip-tracker.md`
- **Deal P&L Calculator** — Calculate complete profit and loss for any real estate deal — wholesale, flip, or rental. Includes all costs, fees, holding costs, and net profit. → `references/deal-analysis/deal-pnl.md`
- **Deal Predictor** — Score deal probability of closing based on seller motivation, pricing, timeline, financing, and comparable deal outcomes. → `references/deal-analysis/deal-predictor.md`
- **Days on Market Tracker** — Track average days on market for target areas to identify market speed changes. → `references/deal-analysis/dom-tracker.md`
- **Market Snapshot** — Generate a comprehensive market overview for any zip code or city — median prices, DOM, inventory, price trends, rent ratios, and investment signals. → `references/deal-analysis/market-snapshot.md`
- **Market Velocity Report** — Track market speed — absorption rate, DOM trends, inventory changes, and price velocity. Identifies heating or cooling markets. → `references/deal-analysis/market-velocity.md`
- **Multifamily Underwriter** — Underwrite multifamily apartment deals — NOI, cap rate, DSCR, cash-on-cash, price per unit, expense ratios, and value-add projections. → `references/deal-analysis/mf-underwriter.md`
- **Neighborhood Scoring** — Score neighborhoods on investability — school ratings, crime, employment, rent growth, population trends, and investor activity. → `references/deal-analysis/neighborhood-scoring.md`
- **NOI Analyzer** — Calculate and analyze Net Operating Income for rental and commercial properties. Break down income vs expenses and identify optimization opportunities. → `references/deal-analysis/noi-analyzer.md`
- **Value-Add Opportunity Finder** — Identify forced appreciation opportunities — rent bumps, expense reduction, unit additions, conversions, and repositioning strategies. → `references/deal-analysis/value-add-opportunity.md`

### Creative Finance

- **Balloon Payment Calendar** — Track balloon payment dates across portfolio — alert thresholds, refinance planning, extension negotiation, and payoff calculations. → `references/creative-finance/balloon-payment-calendar.md`
- **Borrower Workout Outreach** — Outreach templates for non-performing note borrowers — initial contact, modification offers, forbearance, and cash-for-keys. → `references/creative-finance/borrower-workout-outreach.md`
- **Capital Stack Builder** — Structure the capital stack for deals — debt/equity mix, senior/mezzanine tranches, cost of capital, OPM structuring, and investor terms. → `references/creative-finance/capital-stack.md`
- **Creative Deal Structurer** — Compare creative finance strategies side-by-side — sub-to vs seller finance vs wrap vs lease-option for any given deal. → `references/creative-finance/creative-deal-structurer.md`
- **Dodd-Frank DTI Compliance** — Dodd-Frank compliance for seller financing — DTI calculation, ability-to-repay verification, exemption analysis, and safe harbor provisions. → `references/creative-finance/dodd-frank-dti.md`
- **JV Split Tracker** — Track JV/partnership profit splits — equity contributions, preferred returns, waterfall structures, promote calculations, and distributions. → `references/creative-finance/jv-split-tracker.md`
- **Lease Option Structurer** — Structure lease-option/rent-to-own deals — option fee, rent credit, purchase price, lease terms, and tenant-buyer qualification. → `references/creative-finance/lease-option.md`
- **Lender Package Builder** — Prepare lender/bank presentation packages — executive summary, property details, pro forma, borrower resume, and deal analysis. → `references/creative-finance/lender-package.md`
- **Note Due Diligence Coordinator** — Due diligence checklist for note purchases — 5-category DD across legal, collateral, borrower, payment history, and title. 15+ tracked items. → `references/creative-finance/note-due-diligence.md`
- **Note Investing Analyzer** — Analyze notes for purchase — yield calculation, ITV, collateral assessment, borrower analysis, and risk grading. → `references/creative-finance/note-investing-analyzer.md`
- **Note Portfolio Tracker** — Track portfolio of owned notes — payment log, UPB tracking, yield calculation, performance dashboard, event timeline, and watch list. → `references/creative-finance/note-portfolio-tracker.md`
- **Note Sale Readiness** — Prepare notes for sale — loan file assembly, pricing at target yields, marketing package creation, and buyer channel identification. → `references/creative-finance/note-sale-readiness.md`
- **Note Servicer Comparison** — Compare note servicing companies — fee structures, capabilities, reporting quality, compliance, borrower portal, and payment processing. → `references/creative-finance/note-servicer-comparison.md`
- **Note Tape Screener** — Screen and filter note tapes for acquisition targets — filter by UPB, ITV, state, performance status, interest rate, and remaining term. Score notes and flag red flags. → `references/creative-finance/note-tape-screener.md`
- **Note Tape Sourcing** — Source note tapes for acquisition — 10-channel source map, outreach templates, relationship building, and 90-day pipeline plan. → `references/creative-finance/note-tape-sourcing.md`
- **Note Workout Strategy Modeler** — Decision framework for non-performing notes — reinstatement, modification, forbearance, deed-in-lieu, cash-for-keys, foreclosure with side-by-side NPV comparison. → `references/creative-finance/note-workout-strategy.md`
- **Note Yield Calculator** — Calculate note yields — IRR, yield-to-maturity, cash-on-cash, and total ROI including purchase discount and servicing costs. → `references/creative-finance/note-yield-calculator.md`
- **Seller Finance Clauses** — Generate special clauses for seller finance contracts — due-on-sale, insurance requirements, tax escrow, property maintenance, and subordination. → `references/creative-finance/seller-finance-clauses.md`
- **Seller Finance Note Creator** — Draft promissory notes for seller-financed deals — terms, rate, payments, maturity, late fees, default provisions, acceleration, and prepayment. → `references/creative-finance/seller-finance-note-creator.md`
- **Seller Finance Tape Aggregator** — Aggregate seller finance notes into a standardized tape format for portfolio review or sale preparation. → `references/creative-finance/seller-finance-tape.md`
- **Seller Finance Term Calculator** — Structure seller finance offers — calculate payments at various rates/terms, balloon scenarios, amortization schedules, and compare to traditional financing. → `references/creative-finance/seller-finance-terms.md`
- **Subject-To Analyzer** — Analyze subject-to deals — existing mortgage terms, equity capture, cash flow, DSCR, and due-on-sale risk assessment. → `references/creative-finance/sub-to-analyzer.md`
- **Wrap Mortgage Calculator** — Calculate wrap/AITD mortgage terms — underlying P&I, wrap rate, wrap payment, spread calculation, and monthly profit. → `references/creative-finance/wrap-mortgage-calculator.md`
- **Wrap Note Default Workflow** — Default workflow for wrap mortgages — notice requirements, cure periods, underlying mortgage protection, and remedies. → `references/creative-finance/wrap-note-default.md`
- **Wrap Payment Manager** — Manage wrap mortgage payment flows — incoming wrap payment, outgoing underlying payment, spread capture, and escrow. → `references/creative-finance/wrap-payment-manager.md`

### Dispositions

- **Dispo Bot — Buyer Matcher** — Match wholesale deals to buyers based on buy-box criteria. Auto-segment buyer list, rank matches by fit, and prioritize outreach. → `references/dispositions/dispo-bot.md`
- **Disposition CRM Updater** — Log deal activity, track buyer pipeline stages, and generate follow-up cadences for wholesale dispositions. → `references/dispositions/dispo-crm-updater.md`
- **Offer Blast Email Generator** — Write compelling wholesale deal blast emails that get buyers to respond fast. Subject lines, email body, follow-up bump, and SMS version. → `references/dispositions/offer-blast-email.md`
- **Offer Letter Drip** — Generate and manage offer letter sequences to sellers with increasing urgency and adjusted terms over multiple touches. → `references/dispositions/offer-letter-drip.md`
- **Seller Objection Handler** — Handle common seller objections with proven scripts and strategies. Price too low, not ready, using an agent, and more. → `references/dispositions/seller-objection-handler.md`
- **Seller Portal Generator** — Generate seller-facing status pages showing deal progress, next steps, timeline, and contact info. Builds trust and reduces seller anxiety. → `references/dispositions/seller-portal.md`
- **Weekly Pipeline Report** — Generate weekly pipeline report — active deals by stage, stalled deals, deals needing action, projected closings, and revenue forecast. → `references/dispositions/weekly-pipeline.md`

### Lead Generation

- **Adaptive Follow-Up** — Dynamic follow-up sequences that adjust based on lead behavior — opened, replied, went silent, said not now. Multi-channel cadence optimization. → `references/lead-generation/adaptive-follow-up.md`
- **Agent Outreach** — Build relationships with real estate agents for off-market and pocket listing deal flow. Outreach templates, follow-up cadence, and relationship CRM tracking. → `references/lead-generation/agent-outreach.md`
- **Appointment Setter** — Book appointments with qualified sellers. Includes confirmation sequences, reminder flows, no-show recovery scripts, and scheduling logistics. → `references/lead-generation/appointment-setter.md`
- **Cold Call Script Generator** — Generate cold call scripts for motivated sellers. Includes opener, qualification questions, objection handlers, and appointment-setting flows. → `references/lead-generation/cold-caller.md`
- **Daily MLS Feed** — Pull and filter daily new MLS listings matching investor buy criteria — price, area, condition, deal type. Surfaces deals before competition. → `references/lead-generation/daily-mls-feed.md`
- **Expired Listings Hunter** — Find expired and withdrawn MLS listings as motivated seller leads. Filter by equity, days on market, price drops, and area. → `references/lead-generation/expired-listings-hunter.md`
- **Follow-Up Sequence Manager** — Manage multi-channel follow-up cadences across SMS, email, voicemail, and direct mail with timing rules and escalation logic. → `references/lead-generation/follow-up-sequence.md`
- **Lead Auto-Qualifier** — Score and qualify inbound leads based on motivation, timeline, equity, property condition, and situation. Outputs a 1-10 score with recommended action. → `references/lead-generation/lead-auto-qualifier.md`
- **Lead Orchestrator** — Route leads through pipeline stages, assign actions, and manage lead workflow from new lead to appointment to offer. → `references/lead-generation/lead-orchestrator.md`
- **Lead Source ROI Calculator** — Calculate ROI per lead source — direct mail, PPC, cold calling, SEO, referrals. Compare cost per lead, cost per deal, and conversion rates to optimize marketing spend. → `references/lead-generation/lead-source-roi.md`
- **Marketplace Monitor** — Monitor Facebook Marketplace, Craigslist, and FSBO sites for motivated seller listings. Score and alert on matches. → `references/lead-generation/marketplace-monitor.md`
- **SMS Responder** — Generate auto-response templates for inbound seller SMS. Match intent, qualify leads via text, and route to appropriate follow-up. → `references/lead-generation/sms-responder.md`
- **Voice to Deal** — Transcribe call recordings or voicemails, extract deal details, and create structured lead records from voice notes. → `references/lead-generation/voice-to-deal.md`
- **Voicemail Drop Script Generator** — Generate ringless voicemail scripts for motivated seller outreach. Different scripts for cold outreach, warm follow-up, and re-engagement. → `references/lead-generation/voicemail-drop.md`

### Property Management

- **Eviction Process Guide** — Guide the eviction process — state-specific timelines, notice requirements, court filing steps, documentation checklist, and cost estimation. → `references/property-management/eviction-process.md`
- **Insurance Gap Detector** — Identify insurance coverage gaps — policy review, replacement cost analysis, liability adequacy, flood/wind requirements, and umbrella policy needs. → `references/property-management/insurance-gap-detector.md`
- **Lead Paint Certification** — Lead paint disclosure and certification tracking — pre-1978 property requirements, EPA RRP rule compliance, disclosure forms, and contractor certification. → `references/property-management/lead-paint-cert.md`
- **Lease Generator** — Generate residential lease agreements with state-aware clauses, pet addenda, late fee structures, security deposit terms, and maintenance responsibilities. → `references/property-management/lease-generator.md`
- **Lease Renewal Manager** — Manage lease renewals — market rent comparison, rent increase calculation, renewal letter generation, and counter-offer handling. → `references/property-management/lease-renewal.md`
- **Market Rent Analyzer** — Determine market rent using comparable rental analysis — nearby rental comps, amenity adjustments, seasonal factors, and rent positioning strategy. → `references/property-management/market-rent.md`
- **Materials List Generator** — Generate materials and supplies lists for rehabs — bill of materials by room, quantity calculator, budget tracking, and vendor recommendations. → `references/property-management/materials-list.md`
- **Move-In/Out Inspection** — Generate property condition inspection reports — room-by-room checklist, condition ratings, damage assessment, and deposit deduction calculations. → `references/property-management/move-in-out-inspection.md`
- **Permit Tracker** — Track building permits — application status, inspection scheduling, required permits by project type, deadline tracking, and compliance. → `references/property-management/permit-tracker.md`
- **POA Expiration Tracker** — Track Power of Attorney documents — expiration dates, renewal process, scope verification, and state-specific requirements. → `references/property-management/poa-expiration.md`
- **Portfolio Dashboard** — Generate portfolio overview — all properties, occupancy rates, rent roll, maintenance status, lease expirations, cash flow summary, and equity position. → `references/property-management/portfolio-dashboard.md`
- **Punch List Generator** — Generate renovation/turnover punch lists — room-by-room items, contractor assignment, cost estimates, completion tracking, and quality verification. → `references/property-management/punch-list.md`
- **Tenant Communication Drafter** — Draft professional, legally compliant tenant communications — late rent notices, lease violations, maintenance updates, rent increases, and general announcements. → `references/property-management/tenant-communication.md`
- **Tenant Onboarding Package** — Generate new tenant move-in packages — welcome letter, move-in checklist, utility transfer guide, emergency contacts, house rules, and maintenance request process. → `references/property-management/tenant-onboarding.md`
- **Tenant Screener** — Screen tenant applications using credit, income, rental history, and background criteria. Outputs approve/conditional/deny with scoring matrix. → `references/property-management/tenant-screener.md`
- **Work Order Manager** — Create and manage maintenance work orders — priority levels, contractor assignment, cost tracking, tenant communication, and completion verification. → `references/property-management/work-order.md`

### Transactions

- **Addendum Builder** — Create contract addenda and amendments to modify existing purchase agreements — price changes, deadline extensions, repair credits, and special terms. → `references/transactions/addendum-builder.md`
- **Assignment Agreement Generator** — Generate wholesale assignment of contract agreements with all required clauses, fee structure, and buyer/seller details. → `references/transactions/assignment-agreement.md`
- **Double Close Compliance** — Structure and manage double (simultaneous) closings with compliance checklists, transactional funding requirements, and A-B / B-C coordination. → `references/transactions/double-close-compliance.md`
- **Escrow Change Alert** — Monitor and manage escrow changes, EMD tracking, title commitment review, and wire fraud prevention for active deals. → `references/transactions/escrow-change-alert.md`
- **Fair Housing Compliance** — Review communications, listings, and tenant interactions for Fair Housing Act compliance — protected classes, advertising guidelines, and documentation. → `references/transactions/fair-housing.md`
- **LOI Generator** — Generate Letters of Intent for real estate acquisitions — commercial, multifamily, and large residential deals. → `references/transactions/loi-generator.md`
- **Purchase Agreement Generator** — Generate real estate purchase agreements with investor-friendly terms, contingencies, and closing provisions. → `references/transactions/purchase-agreement.md`
- **Seller Disclosure Review** — Systematically review seller property disclosures for red flags, hidden costs, and negotiation leverage points. → `references/transactions/seller-disclosure-review.md`
- **TCPA Compliance** — Telephone Consumer Protection Act compliance for cold calling, texting, and ringless voicemail campaigns — consent requirements, DNC management, and penalty awareness. → `references/transactions/tcpa-compliance.md`
- **TREC Contract Guide** — Texas-specific TREC 1-4 Family Residential Contract guidance — section-by-section walkthrough with investor-friendly modifications. → `references/transactions/trec-contract.md`
- **Wholesale Transaction Coordinator** — Step-by-step closing checklist for wholesale deals from contract to close — document tracking, deadline management, and coordination. → `references/transactions/wholesale-tc.md`

### Reporting

- **Cash Flow Forecaster** — Forward-looking cash flow forecast — project income and expenses 3-12 months forward including known closings, rental income, and seasonal adjustments. → `references/reporting/cash-flow-forecaster.md`
- **Exit Timing Advisor** — Analyze hold vs sell timing — market conditions, equity position, cash flow trajectory, tax implications, and opportunity cost. → `references/reporting/exit-timing-advisor.md`
- **Financial Q&A** — Answer accounting and financial questions in RE investor context — depreciation, 1031 exchanges, cost segregation, self-directed IRA, and capital gains strategies. → `references/reporting/financial-qa.md`
- **Goal Tracker** — Track business goals vs actuals — revenue targets, deal counts, marketing spend, and portfolio growth with progress tracking. → `references/reporting/goal-tracker.md`
- **Investor Report Generator** — Generate LP/investor update reports — capital deployed, returns, deal pipeline, distributions, and portfolio performance. → `references/reporting/investor-report.md`
- **KPI Benchmark** — Compare your KPIs against industry benchmarks for wholesaling, flipping, rentals, and note investing. → `references/reporting/kpi-benchmark.md`
- **KPI Tracker** — Track key business KPIs — leads, cost per lead, appointments, offers, contracts, deals closed, assignment fees, and marketing ROI. → `references/reporting/kpi-tracker.md`
- **Monthly P&L Statement** — Generate monthly profit and loss statements — revenue from all sources vs expenses, with month-over-month comparison. → `references/reporting/monthly-pnl.md`
- **Multi-Entity Tax Prep** — Multi-entity tax preparation — entity structure review, inter-entity transactions, consolidated reporting, and entity-specific deductions. → `references/reporting/tax-prep-multi-entity.md`
- **Tax Prep Assistant** — Tax preparation helper — categorize expenses, identify deductions, flag audit triggers, and generate CPA-ready summaries. → `references/reporting/tax-prep.md`

### Marketing

- **RE Ad Copy Writer** — Write Facebook, Google, and direct response ad copy for motivated seller lead generation and buyer acquisition campaigns. → `references/marketing/ad-copy.md`
- **Brand Voice Guide** — Define and maintain brand voice for RE investor marketing — tone, vocabulary, messaging principles, and do/don't rules. → `references/marketing/brand-voice.md`
- **Content Atomizer** — Break one piece of long-form content into platform-native posts for Instagram, Facebook, LinkedIn, TikTok, email, and Twitter. → `references/marketing/content-atomizer.md`
- **Content Calendar Generator** — Generate a 30-day content calendar with theme weeks, platform distribution, batch workflow, and daily posting plan for RE investors. → `references/marketing/content-calendar.md`
- **Content Ideation Engine** — Generate content ideas for RE investors — deal breakdowns, education, behind-the-scenes, engagement posts, and authority-building content. → `references/marketing/content-ideation.md`
- **Creative Strategist** — Develop marketing campaign strategies — messaging angles, audience targeting, channel mix, and creative direction for RE investor marketing. → `references/marketing/creative-strategist.md`
- **Deal Case Study Creator** — Turn closed deals into marketing case studies with before/after, full numbers breakdown, timeline, and lessons learned. → `references/marketing/deal-case-study.md`
- **Direct Response Copywriter** — Write high-converting landing pages, sales pages, and squeeze pages for motivated sellers, cash buyers, and investor leads. → `references/marketing/direct-response-copy.md`
- **Email Sequence Builder** — Build email nurture sequences — welcome series, seller follow-up, buyer engagement, re-engagement campaigns for RE investors. → `references/marketing/email-sequences.md`
- **AI Image Generator** — Generate AI images for real estate marketing — property mockups, social graphics, thumbnails, and branded visuals. → `references/marketing/image-gen.md`
- **Keyword Research Tool** — SEO keyword research for RE investor content — find search terms, analyze competition, and prioritize content opportunities. → `references/marketing/keyword-research.md`
- **Newsletter Creator** — Create weekly or monthly newsletters for RE investors — market updates, deal spotlights, educational content, and calls to action. → `references/marketing/newsletter.md`
- **Direct Mail Campaign Designer** — Design direct mail campaigns — postcard copy, yellow letters, professional letters, print vendor recommendations, and multi-touch sequences. → `references/marketing/postcard-mailer.md`
- **Product Photo Creator** — Create property photo mockups — virtual staging, before/after renders, listing photo enhancement, and marketing visuals. → `references/marketing/product-photo.md`
- **Product Video Creator** — Create property video scripts and outlines — walkthrough scripts, promo videos, social clips, and listing videos. → `references/marketing/product-video.md`
- **SEO Content Writer** — Write SEO-optimized blog posts and long-form content for RE investor websites to attract organic traffic from motivated sellers and buyers. → `references/marketing/seo-content.md`
- **Social Graphics Designer** — Design social media graphics — carousels, quote cards, deal highlight graphics, and branded templates for RE investors. → `references/marketing/social-graphics.md`
- **AI Talking Head Video** — Create AI talking head videos with scripts, avatar selection, and formatting for social media and marketing. → `references/marketing/talking-head.md`
- **YouTube SEO Optimizer** — Optimize YouTube videos for RE investor content — titles, descriptions, tags, chapters, and thumbnail concepts for maximum discoverability. → `references/marketing/youtube-seo.md`

### Operations

- **Calendar Optimizer** — Optimize daily and weekly calendar — time-block lead gen, acquisition calls, deal analysis, admin, and property visits. → `references/operations/calendar-optimizer.md`
- **CRM Sync** — CRM cleanup and sync — identify duplicates, stale leads, missing follow-ups, incomplete records, and pipeline issues. GHL is source of truth. → `references/operations/crm-sync.md`
- **Daily Briefing** — Morning briefing — deals needing action, follow-ups due, appointments, closings this week, and urgent items from all sources. → `references/operations/daily-briefing.md`
- **Daily Planner** — Plan the day using Eisenhower matrix — prioritize by urgency and importance, block time for deep work and calls. → `references/operations/daily-planner.md`
- **Email Triage** — Triage inbox — categorize emails by deals, leads, tenants, marketing, and financial. Flag urgent items and draft routine responses. → `references/operations/email-triage.md`
- **Meeting Notes** — Process meeting notes and transcripts — extract action items, decisions, follow-ups, key numbers, and next meeting date. → `references/operations/meeting-notes.md`
- **Meeting Prep** — Prepare for meetings — pull context on who you are meeting, deal history, property details, talking points, and documents needed. → `references/operations/meeting-prep.md`
- **Task Prioritizer** — Stack rank tasks by ROI and urgency — score by revenue impact, time sensitivity, and effort. Output prioritized task list. → `references/operations/task-prioritizer.md`
- **Weekly Review** — End of week retrospective — deals progressed, deals stalled, KPIs, marketing results, money in and out, wins, and lessons. → `references/operations/weekly-review.md`
