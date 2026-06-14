---
name: skill-router
description: The skill directory. Consult this first for ANY task to find the right capability. It points to every skill on this box without loading them. Triggers on the start of any task where you are unsure which skill, playbook, or tool applies.
version: 1.0.0
author: SafeClaw
license: MIT
platforms: [linux, macos]
auto_load: true
metadata:
  hermes:
    tags: [router, meta, skills, directory, orchestration]
    category: meta
---

# Skill router

This is the metaskill. It is always loaded. Its only job is to send you to the
right skill without every skill sitting in your context.

## How to use

1. Read `SKILL_INDEX.md` (generated next to this file, or at the manifest path
   the box was built with). It is the directory of every skill on this box: one
   line each, with a description and a path.
2. Match the user's request to the single closest skill by its description.
3. Read that skill's `SKILL.md` (its `path`), then follow it. Read a skill's
   referenced files only when its body points to them.
4. If two skills could match, read both, then pick the more specific one.
5. If nothing matches, say so and ask. Do not invent a capability.

## Why it works this way

Loading every skill body would cost hundreds of thousands of tokens. Instead the
directory keeps only a short name and description per skill in context. The full
instructions, reference files, and tools load only at the moment a skill is
chosen. This is progressive disclosure: dozens of skills cost less context than
a single activated one.

## Trust boundaries

Skills are tagged `[reader]` or `[actor]` in the directory.

- The **Reader** is read-only intake. It may run only `[reader]` skills.
- The **Actor** makes decisions, sends, and writes. It runs `[actor]` skills.

Never run a skill across its boundary. If a request needs the other persona,
hand it off, do not load the wrong skill.

## Tools

When a chosen skill declares the tools it needs, load only those. Keep the
heavy toolsets (the GHL servers, the full Composio set) deferred until a skill
actually calls for them. A few high-frequency tools stay live; the rest load on
demand. See docs/SKILL-LOADING.md.
