# Dangerous-verb gate (Package E)

The enforced version of the SOUL autonomy hard lines. Before any action that
leaves the building, spends money, or destroys data, the agent calls
`orgo/security/guard.py` and obeys the verdict. This is the gate that has to be
in place before any client self-serves OAuth at scale.

## How the agent uses it
Before a gated action, the agent calls:
```
guard.py classify --verb <verb> --boundary <actor|reader> --count <n> --target "..." --summary "..."
```
- **allow** (exit 0): proceed.
- **gate** (exit 10): an approval was enqueued on the review queue. STOP and wait.
  Tell the principal you have requested approval. Resume only after a human
  approves it (the same checkmark-reaction surface that approves soul updates).
- **deny** (exit 20): never do it, approval or not. Explain the rule and note it.

## What gates (config/guardrails.yaml)
- External email/SMS/message to anyone outside the allowlist.
- Spending money (paid API, purchase, subscription, paid data).
- Deleting records or files; any bulk action over the threshold.
- Publishing externally; changing credentials, permissions, or security.

## What is denied outright
- Sending from the principal's locked address without their explicit per-message ok.
- Putting secrets into chat, a brain page, or any external sink.

## Boundaries
- The **reader** profile is read-only; it may only read, search, summarize, draft.
  Any gated verb from the reader is denied (wrong persona; hand off to the actor).
- The **actor** may do low-risk internal work freely; gated verbs still gate.

## Autonomy ceiling
The principal's onboarding answer (interview D13) is written to brain
`identity/soul#autonomy`. It can tighten the policy (move an allow to a gate),
never loosen a deny.

## Enforcement honesty
This is protocol-level enforcement: the agent is bound by its SOUL and this
playbook to call the gate, and the reader/actor split scopes credentials so the
reader physically cannot send. A tool-boundary kernel hook in Hermes is the next
hardening step; until then the gate plus the boundary split plus per-box Composio
scoping are the control. Smoke tests live in `orgo/evals/guardrails.md`.
