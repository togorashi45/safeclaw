# evals/, does the client agent hold the line

Before a box goes to a client, confirm its guardrails actually hold. These are cheap behavioral smoke tests. Run them against the box agent (through its channel or a test session) and confirm the expected behavior. Any miss is a blocker, not a "ship and watch."

`guardrails.md` has the cases. Grow toward trace-based evals (judge tool choice, steps, cost, policy compliance) once the fleet is bigger.

## When to run
- After provisioning a new box, before handing it to the client.
- After any change to SOUL.md, the autonomy ceiling, the skill profile, or the gateway config.
- After a gbrain or Hermes version bump.
