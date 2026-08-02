---
type: reference
description: What is vendored from the gbrain product into this repo, which version it came from, and how to refresh it.
---

# Vendored gbrain provisioning script

Directory note: this lives at `orgo/gbrain-recipe/`, not `orgo/vendor/`, because
`.gitignore` ignores `vendor/` (build-time third-party clones). The whole point
of this copy is that it IS committed.

`vm-hermes-setup.sh` is a **verbatim copy** of `scripts/vm-hermes-setup.sh` from
our gbrain fork. It is the product's own known-good recipe for the gbrain plane:
file-plane config written before the first install, the DB-plane model mirror,
Hermes MCP registration with the real database_url, and a doctor pass.

We vendor it so provisioning does not depend on network state at install time.
A box being built must not fail because GitHub is slow or the fork moved.

## Provenance

| Field | Value |
|---|---|
| Source repo | `rspur-hq/gbrain` |
| Source path | `scripts/vm-hermes-setup.sh` |
| Vendored commit | `0ac1898f363ee9a96cf1eb517d66022dda88bb81` |
| Vendored gbrain version | `0.42.70.0` |
| SHA256 of the vendored file | `93d34b44daab0b6c9e9bb4f8137aa8eedf6448db0141c6b26de43cff5b093a17` |
| Vendored on | 2026-08-02 |

## Rule: never hand edit this file

Local edits get silently reverted on the next refresh. Everything we need on top
of the product recipe lives in `orgo/install-box.sh` and runs **after** the
vendored script:

- the minimum version floor check (`stage_runtime`)
- the HTTP gbrain MCP wiring, which replaces the product's stdio registration
  (`stage_hermes_config`), because the native HTTP endpoint on `127.0.0.1:3131`
  is what is proven on our live boxes
- the spend gates (`stage_brain_init`)
- `self_upgrade.mode=off` (`stage_brain_init`)

## Refreshing

Run the refresh script from this repo root. It pulls the current fork copy,
diffs it, and updates the provenance table above:

```bash
bash orgo/gbrain-recipe/refresh-vendor.sh            # show the diff, change nothing
bash orgo/gbrain-recipe/refresh-vendor.sh --apply    # take the new copy
```

Read the diff before applying. If the product changes the recipe in a way that
conflicts with one of our overrides above, fix the override, do not fork the
vendored file.

## Cadence

Refresh on the weekly maintenance window (see
`orgo/routines/gbrain-weekly-maintenance.sh`). Our fork also needs a recurring
sync from upstream `garrytan/gbrain`, or "latest from our fork" quietly becomes
"latest from whenever we last merged".
