# CLAUDE.md

Guidance for Claude Code working in this repository.

## What this repo is

The **golden template** for RE Reset client agent boxes. The product is **Hermes + 2nd Brain**: standard, up-to-date Hermes (Nous Research) plus standard gBrain on local Postgres 16 + pgvector, with our layers on top:

- The client portal (cloned from `rereset-portal` at install)
- The PARA + OKF knowledge method (brain repo seeded from `orgo/knowledge/para-seed/`, rules in the SOUL template)
- Our cron routines (`orgo/routines/`), skill packs (`skills/`), and the agent SOUL (`orgo/SOUL.template.md`)

Nothing in the runtime is forked. All customization is config, skills, routines, and prompts.

## The canonical artifacts

- `orgo/install-box.sh` - THE installer. Idempotent, staged, non-Docker. Reads `/opt/install.env` on the box. Run everything: `sudo bash /opt/install-box.sh`, or selected stages: `... base brain_db`.
- `orgo/GOLDEN-TEMPLATE.md` - the build spec. Read it first.
- `orgo/SOUL.template.md` - the agent persona template, filled per client by `orgo/fill-soul.py` (off-box).
- `AGENTS.md` - the operating contract loaded by the agent on the box.

## Hard rules

- **Single default Hermes profile.** One gateway (`hermes-gateway` under supervisor), one config at `/root/.hermes/`. The two-agent actor/reader architecture is dead; do not reintroduce it.
- **No Docker, no PGlite.** The brain is supervised native Postgres + pgvector.
- **Never fork Hermes or gBrain.** Install stock, customize via config/skills/SOUL.
- **Secrets never in git.** Per-box secrets live in `/opt/install.env` and `/opt/brain/.env` on the box (chmod 600).
- **No em or en dashes in any client-facing prose**, including SOUL files (`fill-soul.py` hard-fails on them).

## Quality checks

`bash -n orgo/install-box.sh` for the installer; `python3 -m py_compile` for Python; keep every stage idempotent (safe to re-run on a live box).

## History note

This tree previously carried two retired generations (a Docker/VPS stack and a two-profile reader/actor trust split). Both were removed 2026-07-10 on the `v2-hermes-brain` branch. If a doc or script mentions reader/actor profiles or docker-compose, it is stale; the installer wins.
