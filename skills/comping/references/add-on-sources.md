# Comping add-on sources (per-client setup steps)

RentCast is the base on every box. These add-ons are wired per client during
setup; when present they OUTRANK RentCast for their data type. Detect before
use; never assume.

## MLS bridge (licensed comps - best sale comps where licensed)
- Detect: `/opt/recolorado-cli` (or another `/opt/*-cli` MLS tool) + its
  supervisor programs (e.g. recolorado-bridge, recolorado-browser).
- Setup: client supplies MLS login; deploy the bridge + persistent browser;
  keep session alive via supervisor. Example live install: Travis
  (REcolorado, Denver metro).
- Use for: sold comps, active/DOM data, listing history.

## GHL (client's own CRM - deal context, not comps)
- Detect: ghl-mcp supervisor program or GHL MCP block in hermes config.
- Setup: Private Integration token for the client's location, scoped to
  contacts/opportunities.
- Use for: the deal's own record (contract price, seller, stage) to anchor
  the comp request; never as a valuation source.

## LeadForge (our prospecting stack - parcel + owner + value data)
- Detect: box has lf access (Matt/madison only today per standing rule) or
  the brain carries lf parcel pages.
- Setup: admin-side; LeadForge data reaches client boxes only through
  approved pushes. Use its assessed values/parcel data as a sanity check on
  ARV, labeled as assessment data, not market comps.

## Reonomy (CRE - admin/M1 only)
- Detect: not on client boxes. CRE comp requests route to Jake's side.

## Fleet matrix (as of 2026-07-17; verify on box before relying)
| Box | MLS | GHL | LeadForge | Notes |
|---|---|---|---|---|
| travis-wilcox | REcolorado LIVE | yes | no | best-equipped comping box |
| matt-hoover | no | yes (WeBuy731) | yes (Madison pushes) | |
| jake | no | agency | admin | Reonomy via M1 |
| elise / jeremiah / phil / atomic | no | varies | no | RentCast-only today |
