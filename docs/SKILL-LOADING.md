# Lean skill loading (the metaskill)

How SafeClaw holds hundreds of skills while loading almost no extra context, and
how an operator controls what each box ships.

## The problem

Hermes reads the name and description of every discovered skill into the prompt
at session start, and the heavy MCP toolsets (the GHL servers alone are ~500
tools) pile on top. A stock box pays for all of it whether or not it uses any.
The old fix was `docker/prune-skills.sh`, a hardcoded list of folders to delete.
It worked but it was one fixed set for every box and it said nothing about which
skills stay "always on".

## The approach: progressive disclosure

Keep a tiny directory of skills resident, load a skill's body only when it is
chosen, and defer the heavy tools until a skill calls for them. This is the same
pattern Anthropic ships for Agent Skills and the Tool Search tool. Dozens of
skills cost less context than a single activated one.

Three layers:

1. **Directory (always loaded).** `SKILL_INDEX.md`, one line per skill: name,
   when-to-use description, path, trust boundary. Generated, never hand-edited.
2. **Body (loaded on match).** The agent reads the one `SKILL.md` it picked, then
   that skill's reference files only if the body points to them.
3. **Tools (loaded on demand).** Heavy toolsets stay deferred; a few hot tools
   stay live; a chosen skill's declared tools load when it runs.

The `skill-router` skill (`skills/skill-router/SKILL.md`) is the metaskill. It is
always on and its whole job is to send the agent to the right skill via the
directory.

## The pieces

| File | Role |
|------|------|
| `config/skill-profiles.yaml` | Single source of truth: which skills ship and which are pinned, per profile (base, reader, actor, per team member). |
| `tools/skills_manifest.py` | Scans a skills tree, applies a profile, emits `SKILL_INDEX.md`, `skills.index.json`, `keeplist.txt`. |
| `tools/apply_skill_profile.sh` | Runs the generator, prunes the tree to the keeplist, installs the directory. The config-driven replacement for `prune-skills.sh`. |
| `skills/skill-router/SKILL.md` | The always-on metaskill that consults the directory. |

## Frontmatter conventions

Standard Hermes frontmatter, plus two optional SafeClaw fields:

```yaml
---
name: email-to-brain
description: Ingest important Gmail into the brain as deduplicated summary pages.
auto_load: false          # true pins this skill into the always-loaded directory
tools: [gmail-read, brain] # toolsets the body needs, for lazy tool loading
metadata:
  hermes:
    category: integrations
    boundary: reader        # reader | actor (trust boundary)
    requires_toolsets: [native-mcp]
---
```

- `category` drives grouping and the keep/drop rules. If absent, the top folder
  of the skill path is used.
- `boundary` marks a skill reader-only or actor-only. The directory shows it and
  the router enforces it.
- `auto_load: true` pins a skill on regardless of profile (use sparingly).
- `tools` lists the toolsets the skill needs so they can load lazily instead of
  sitting in context.

## Profiles

A profile in `config/skill-profiles.yaml`:

```yaml
profiles:
  reader:
    inherits: base
    keep_skills: [email-to-brain, calendar-to-brain]
    drop_skills: [ghl-to-brain]
```

Keys: `keep_categories`, `drop_categories`, `keep_skills`, `drop_skills`,
`auto_load`, `inherits`. A `<list>_add:` key extends an inherited list. Empty
`keep_categories` means keep everything except `drop_categories`.

The shipped profiles: `base` (lean default), `reader` (read-only intake),
`actor` (full permission), `team-member` (template), and `team-<name>` per
person. Narrow a person's profile as their role firms up so their box ships only
what they use.

## Running it

Demo against the repo's own skills:

```bash
python3 tools/skills_manifest.py --profile base --skills-dir skills --out build/skills-base
cat build/skills-base/SKILL_INDEX.md
```

On a box or in the image, prune to a profile and install the directory:

```bash
tools/apply_skill_profile.sh reader /opt/hermes/skills
```

## Wiring into the image (next step, needs an image build to verify)

In `docker/Dockerfile.safeclaw-hermes`, the current static prune is:

```dockerfile
COPY --chmod=0755 docker/prune-skills.sh /usr/local/bin/prune-skills.sh
RUN /usr/local/bin/prune-skills.sh /opt/hermes/skills
```

Replace it with the profile-driven prune (the profile comes from a build arg so
reader and actor images differ):

```dockerfile
ARG SKILL_PROFILE=actor
COPY tools/skills_manifest.py tools/apply_skill_profile.sh /opt/hermes/tools/
COPY config/skill-profiles.yaml /opt/hermes/config/skill-profiles.yaml
RUN /opt/hermes/tools/apply_skill_profile.sh "${SKILL_PROFILE}" /opt/hermes/skills \
      /opt/hermes/config/skill-profiles.yaml
```

Build reader and actor variants by passing `--build-arg SKILL_PROFILE=reader`
vs `actor`. Verify the image starts and `SKILL_INDEX.md` lands in the skills
volume before shipping to a box.

## Part B (built): pgvector skill retrieval

The directory stays cheap into the low hundreds of skills (~80 tokens each). Past
that, the router stops reading the whole index and calls `find_skill(query)`.

- `tools/skill_index_embed.py` reads `skills.index.json`, embeds each kept skill's
  "name: description" with the brain's embedding model, and upserts into a
  `skill_index` pgvector table in the box brain.
- `tools/find-skill-mcp/server.py` is a stdio MCP exposing `find_skill(query, k,
  boundary)`. It embeds the query and returns the top matches (name, path,
  boundary, description). The router reads the returned path's SKILL.md to run it.

Build it after pruning a profile:
```bash
python3 tools/skills_manifest.py --profile actor --skills-dir /opt/hermes/skills --out /opt/hermes/.skill-manifest
python3 tools/skill_index_embed.py --index /opt/hermes/.skill-manifest/skills.index.json
```
Wire `find-skill` into the actor profile like any stdio MCP. Pin the few
highest-frequency skills (`auto_load: true`) so common paths skip the search hop.

## Part C (built): lazy tool-schema defer

Heavy MCP toolsets (the GHL servers are ~500-600 tools) never sit in the idle
prompt. `config/toolset-policy.yaml` declares `hot` toolsets (always live, small)
and `deferred` ones (loaded on demand). `tools/toolset_loader.py` resolves a
chosen skill's frontmatter `tools:` to the deferred toolsets to activate:
```bash
tools/toolset_loader.py audit                 # what is hot vs deferred
tools/toolset_loader.py for-skill skills.index.json ghl-to-brain   # what that skill needs
```
The router activates a toolset only when a chosen skill declares it. VERIFY on a
box: the hot-load of a deferred MCP server into the running gateway (reload vs
restart).
