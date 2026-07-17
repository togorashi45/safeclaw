# RentCast budget + caps

## Why
RentCast bills per API call over the plan allowance. An uncapped agent that
accepts "comp this list" can burn a month's budget in minutes. The cap is
enforced in CODE by the wrapper, not by trust in the model.

## The wrapper contract (`rentcast-comp`, ships with this pack)
- Env: RENTCAST_API_KEY (per box, in /opt/install.env or hermes .env),
  RENTCAST_DAILY_CAP (default 25), RENTCAST_MONTHLY_CAP (default 400).
- Counters: /var/lib/rentcast/usage.json (day + month tallies, resets on
  rollover). Every call increments BEFORE the request.
- One address per invocation. No list/batch flags exist on purpose.
- Over cap -> exits nonzero printing CAP_EXCEEDED with reset time. The agent
  must relay that, not retry.
- Every response is also written to the brain (comp cache) so repeat asks
  are free.

## Plan sizing (fill when the account is set up)
- RentCast plan: ___ (calls/month included)
- Monthly cap should be <= plan allowance minus a safety margin.
- Daily cap ~= monthly / 20 working days, rounded down.

## Add-ons
MLS bridges and Reonomy are per-client custom work with their own auth and
their own limits; they do not consume RentCast budget. Prefer them when
installed.
