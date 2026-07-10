#!/usr/bin/env python3
"""skills_manifest.py - build a lean, profile-driven skill directory for Hermes.

This is the metaskill loader: a config-driven system so each box (base profile
or a specific team member) ships ONLY the skills it needs, and so the agent gets
one always-loaded directory of those skills instead of every SKILL.md body.

It does three things:

  1. SCAN   every SKILL.md under a skills tree and read its frontmatter
            (name, description, category, tags, trust boundary, auto_load).
  2. APPLY  a named profile from config/skill-profiles.yaml (keep/drop rules
            + which skills pin into the always-loaded index).
  3. EMIT   three artifacts:
              - SKILL_INDEX.md   the always-loaded metaskill directory (one
                                 line per kept skill, grouped by category). This
                                 is what sits in context. Bodies stay on disk and
                                 load only when the agent reads the matched skill.
              - skills.index.json a machine-readable manifest (for a future
                                 pgvector / find_skill retrieval layer).
              - keeplist.txt     newline list of kept skill paths, for the image
                                 build to prune everything else.

Why this matters: Hermes loads the name+description of EVERY discovered skill
into the prompt at session start. Trim the set per profile and the idle context
drops with it. Progressive disclosure does the rest: only the matched skill body
ever enters context. See docs/SKILL-LOADING.md.

Usage:
  # Demo against the repo's custom skills:
  python3 tools/skills_manifest.py --profile base --skills-dir skills --out build/skills

  # At image-build time, point it at the full bundled tree:
  python3 tools/skills_manifest.py --profile team-member --skills-dir /opt/hermes/skills --out /opt/hermes/.skill-manifest

Exit codes: 0 ok, 2 bad profile, 3 no skills found.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys

try:
    import yaml
except ImportError:  # pragma: no cover - image always has python3-yaml
    sys.stderr.write("skills_manifest: PyYAML required (apt install python3-yaml)\n")
    sys.exit(1)

FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)


def estimate_tokens(text: str) -> int:
    """Rough token estimate (~4 chars/token). Good enough for budgeting."""
    return (len(text) + 3) // 4


def read_frontmatter(skill_md_path: str) -> dict:
    """Return the YAML frontmatter of a SKILL.md as a dict (empty if none)."""
    try:
        with open(skill_md_path, "r", encoding="utf-8") as fh:
            head = fh.read(8192)  # frontmatter is always at the top
    except OSError:
        return {}
    match = FRONTMATTER_RE.match(head)
    if not match:
        return {}
    try:
        data = yaml.safe_load(match.group(1))
    except yaml.YAMLError:
        return {}
    return data if isinstance(data, dict) else {}


def skill_record(skill_md_path: str, skills_root: str) -> dict | None:
    """Build one skill record from a SKILL.md. None if it has no usable name."""
    fm = read_frontmatter(skill_md_path)
    hermes = (fm.get("metadata") or {}).get("hermes") or {}

    name = fm.get("name")
    rel_dir = os.path.relpath(os.path.dirname(skill_md_path), skills_root)
    if not name:
        # Fall back to the directory name so untagged bundled skills still index.
        name = rel_dir.split(os.sep)[-1]
    if not name:
        return None

    # Category: explicit frontmatter wins, else the top-level tree folder.
    category = hermes.get("category") or fm.get("category")
    if not category:
        parts = rel_dir.split(os.sep)
        category = parts[0] if parts and parts[0] != "." else "uncategorized"

    description = (fm.get("description") or "").strip()
    requires = hermes.get("requires_toolsets") or fm.get("requires_toolsets") or []
    # Legacy trust-boundary metadata; carried through for skill authors that
    # declare it, but no longer enforced (single default profile).
    boundary = (hermes.get("boundary") or fm.get("boundary") or "").lower() or None

    return {
        "name": name,
        "category": category,
        "description": description,
        "tags": hermes.get("tags") or fm.get("tags") or [],
        "requires_toolsets": requires,
        "boundary": boundary,
        # New SafeClaw frontmatter conventions (optional). auto_load pins the
        # skill into the always-loaded index even if a profile would lazy it;
        # tools declares which toolsets the body needs so they can load lazily.
        "auto_load": bool(fm.get("auto_load", False)),
        "tools": fm.get("tools") or [],
        "path": os.path.relpath(skill_md_path, skills_root),
    }


def scan_skills(skills_root: str) -> list[dict]:
    records = []
    for dirpath, _dirs, files in os.walk(skills_root):
        if "/.git/" in dirpath or dirpath.endswith("/.git"):
            continue
        if "SKILL.md" in files:
            rec = skill_record(os.path.join(dirpath, "SKILL.md"), skills_root)
            if rec:
                records.append(rec)
    records.sort(key=lambda r: (r["category"], r["name"]))
    return records


def load_profiles(config_path: str) -> dict:
    with open(config_path, "r", encoding="utf-8") as fh:
        cfg = yaml.safe_load(fh) or {}
    return cfg.get("profiles") or {}


def resolve_profile(profiles: dict, name: str, _seen: set | None = None) -> dict:
    """Flatten a profile, following `inherits` chains. Later (child) keys win,
    list keys ending in `_add` extend the inherited list."""
    _seen = _seen or set()
    if name not in profiles:
        raise KeyError(name)
    if name in _seen:
        raise ValueError(f"circular inherits at {name}")
    _seen.add(name)

    raw = profiles[name] or {}
    parent_name = raw.get("inherits")
    base = resolve_profile(profiles, parent_name, _seen) if parent_name else {}

    merged = dict(base)
    for key, val in raw.items():
        if key == "inherits":
            continue
        if key.endswith("_add"):
            target = key[:-4]
            merged[target] = list(dict.fromkeys((merged.get(target) or []) + list(val)))
        else:
            merged[key] = val
    return merged


def apply_profile(records: list[dict], profile: dict) -> list[dict]:
    """Mark each record kept/dropped and auto_load per the profile rules."""
    keep_categories = set(profile.get("keep_categories") or [])
    drop_categories = set(profile.get("drop_categories") or [])
    keep_skills = set(profile.get("keep_skills") or [])
    drop_skills = set(profile.get("drop_skills") or [])
    auto_load = set(profile.get("auto_load") or [])
    # If keep_categories is empty, default to keep-all-except-drop.
    keep_all = not keep_categories

    out = []
    for rec in records:
        name, cat = rec["name"], rec["category"]
        if name in drop_skills:
            kept = False
        elif name in keep_skills:
            kept = True
        elif cat in drop_categories:
            kept = False
        elif keep_all or cat in keep_categories:
            kept = True
        else:
            kept = False
        rec = dict(rec)
        rec["kept"] = kept
        rec["auto_load"] = rec["auto_load"] or (name in auto_load)
        out.append(rec)
    return out


def render_index(kept: list[dict], profile_name: str) -> str:
    """The always-loaded metaskill directory. Grouped by category. One line each."""
    by_cat: dict[str, list[dict]] = {}
    for rec in kept:
        by_cat.setdefault(rec["category"], []).append(rec)

    lines = [
        "# Skill directory",
        "",
        f"> Generated by tools/skills_manifest.py for profile `{profile_name}`. ",
        "> Do not edit by hand. This is the always-loaded index. To USE a skill, ",
        "> read its `path` (the SKILL.md) and follow it. Do not load skill bodies ",
        "> until one matches. Pick the closest match by description; if two could ",
        "> match, read both, then choose.",
        "",
    ]
    total_auto = [r for r in kept if r["auto_load"]]
    if total_auto:
        lines.append("## Always on (auto-loaded)")
        lines.append("")
        for rec in sorted(total_auto, key=lambda r: r["name"]):
            lines.append(f"- **{rec['name']}** - {rec['description']} (`{rec['path']}`)")
        lines.append("")

    for cat in sorted(by_cat):
        lines.append(f"## {cat}")
        lines.append("")
        for rec in by_cat[cat]:
            boundary = f" [{rec['boundary']}]" if rec.get("boundary") else ""
            desc = rec["description"] or "(no description)"
            lines.append(f"- **{rec['name']}**{boundary} - {desc} → `{rec['path']}`")
        lines.append("")

    lines += [
        "## Disambiguation",
        "",
        "1. Match the user's intent to the single closest skill by its description.",
        "2. Read that skill's SKILL.md, then follow it. Read its referenced files ",
        "   only when the body points to them.",
        "3. If two skills could match, read both and pick the more specific one.",
        "4. If nothing matches, say so and ask, do not guess.",
        "",
    ]
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description="Build a lean profile-driven skill directory.")
    ap.add_argument("--skills-dir", required=True, help="root of the skills tree to scan")
    ap.add_argument("--profile", default="base", help="profile name from the config")
    ap.add_argument("--config", default=None, help="path to skill-profiles.yaml")
    ap.add_argument("--out", required=True, help="output directory for the artifacts")
    args = ap.parse_args(argv)

    config_path = args.config or os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "config",
        "skill-profiles.yaml",
    )
    if not os.path.isdir(args.skills_dir):
        sys.stderr.write(f"skills_manifest: skills dir not found: {args.skills_dir}\n")
        return 3

    profiles = load_profiles(config_path)
    try:
        profile = resolve_profile(profiles, args.profile)
    except (KeyError, ValueError) as exc:
        sys.stderr.write(f"skills_manifest: bad profile '{args.profile}': {exc}\n")
        return 2

    records = scan_skills(args.skills_dir)
    if not records:
        sys.stderr.write(f"skills_manifest: no SKILL.md found under {args.skills_dir}\n")
        return 3

    marked = apply_profile(records, profile)
    kept = [r for r in marked if r["kept"]]
    dropped = [r for r in marked if not r["kept"]]

    os.makedirs(args.out, exist_ok=True)
    index_md = render_index(kept, args.profile)
    index_path = os.path.join(args.out, "SKILL_INDEX.md")
    with open(index_path, "w", encoding="utf-8") as fh:
        fh.write(index_md)

    manifest = {
        "profile": args.profile,
        "skills_dir": os.path.abspath(args.skills_dir),
        "kept": [
            {k: r[k] for k in ("name", "category", "description", "tags",
                               "requires_toolsets", "boundary", "auto_load",
                               "tools", "path")}
            for r in kept
        ],
        "dropped": [{"name": r["name"], "category": r["category"]} for r in dropped],
        "index_token_estimate": estimate_tokens(index_md),
    }
    with open(os.path.join(args.out, "skills.index.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=2)

    with open(os.path.join(args.out, "keeplist.txt"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(r["path"] for r in kept) + "\n")

    print(f"skills_manifest: profile={args.profile}")
    print(f"  scanned : {len(records)} skills")
    print(f"  kept    : {len(kept)}")
    print(f"  dropped : {len(dropped)}")
    print(f"  index   : {index_path} (~{manifest['index_token_estimate']} tokens always loaded)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
