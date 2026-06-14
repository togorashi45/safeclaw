# knowledge/, the client's domain facts

This is the per-client customization surface. The agent reads these on demand (not all at once) when a task needs them, and the ingestion routines + brain build on top of them. Fill the templates per client during provisioning, save them on the box under a `knowledge/` directory the actor profile can read, and seed the key ones into gBrain so they are searchable.

## What goes here
- `client-profile.md`, who the client is, their business, their voice, what they want the agent to do and not do.
- `deal-criteria.md`, for real-estate clients: the buy box, thresholds, and disqualifiers the agent uses to score or filter.
- `key-people.md`, the client's team and contacts, so the agent routes and addresses correctly.
- Add domain files as needed (e.g. `pipeline-stages.md`, `service-area.md`).

## Rules
- Facts only. No secrets (those live in `client.env`).
- Keep each file short and skimmable. The agent reads the one that matches the task.
- Update when the client changes their business, not on every call.
- No dashes in prose (client-facing voice).
