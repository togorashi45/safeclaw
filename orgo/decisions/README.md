# Box decisions log (ADR)

Why this box is configured the way it is. Stops the next person (or the next session) from re-litigating settled calls or "fixing" something that is intentional. One entry per decision, newest at top.

**Format:** Decision, Date, Status, Why, Implication.

---

## Baseline decisions (inherited from the fleet, true on every box)

### Brain runs on local Postgres, never a shared DB
**active.** gBrain on local Postgres + pgvector, self-contained. **Why:** the client must be able to leave with their own data, and PGlite corrupted under concurrent writers. **Implication:** no commingled Supabase brain.

### One gateway: actor only
**active.** Exactly one supervised `hermes-gateway-actor`. **Why:** the reader/trifecta split was overhead without real isolation. **Implication:** the reader profile is dormant; keep it lean (Gmail + gbrain) for ingest routines.

### Brain is supervised; the watchdog never touches it
**active.** `safeclaw-brain` runs under supervisord. The tmux watchdog keeps only the console, tunnel, and dashboard alive. **Why:** dual managers on the brain caused the PGlite corruption. **Implication:** never add a brain block back to the watchdog.

### Skills load on demand through the skill-router
**active.** The metaskill routes to the one skill a task needs. **Why:** preloading hundreds of skills blows the context budget (~250k). **Implication:** add skills to the manifest, do not preload them.

### Outbound is draft-first
**active.** The agent drafts messages to the client's contacts; auto-send is off until the client opts in. **Why:** safety and trust. **Implication:** the autonomy ceiling lives in SOUL.md.

---

## Per-box decisions (fill during provisioning)
Add anything specific to THIS client here (channel choice, which OAuth scopes, custom autonomy ceiling, skill profile).
