#!/usr/bin/env python3
"""skill_crons.py - reconcile crontab entries owned by skill packs.

Packs declare crons in SKILL.md frontmatter:
  metadata:
    hermes:
      crons:
        - name: tc-ghl-sync
          schedule: "*/30 * * * *"
          command: /opt/rereset-tools/tc-ghl-sync/run.sh
Each managed line is tagged `# skill:<slug>` in root's crontab. Reconcile:
crons for INSTALLED packs present, crons for uninstalled packs removed.

Crons are also source-gated: a pack that declares required sources in
`metadata.hermes.sources` (optional: false) only gets its crons when the
box's live probe (agent-sources) reports every required source present.
Missing required source means the pack's crons are skipped and any
previously installed ones are removed. Optional sources never block.
Usage: skill_crons.py --skills-dir /opt/safeclaw/skills --installed installed.json
       [--dry-run] [--sources probe.json]
"""
import argparse, json, re, subprocess, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from skills_manifest import scan_skills, read_frontmatter  # noqa: E402

PROBE_PATHS = ("/usr/local/bin/agent-sources",
               os.path.join(os.path.dirname(os.path.abspath(__file__)), "agent-sources"))


def load_probe(path: str | None) -> dict | None:
    """Return the box source probe as a dict, or None when no probe is available."""
    if path:
        return json.load(open(path))
    for cand in PROBE_PATHS:
        if os.path.exists(cand):
            try:
                r = subprocess.run([sys.executable, cand], capture_output=True,
                                   text=True, timeout=60)
                if r.returncode == 0 and r.stdout.strip():
                    return json.loads(r.stdout)
            except (OSError, ValueError, subprocess.TimeoutExpired):
                pass
    return None


def source_present(kind: str, probe: dict) -> bool:
    """Check one declared source kind against the probe. Unknown kinds pass:
    the probe cannot verify them, so they never block."""
    if kind == "brain":
        return bool(probe.get("brain"))
    if kind.startswith("cli:"):
        name = kind[4:]
        clis = probe.get("clis") or {}
        return name in clis or f"{name}-cli" in clis
    if kind.startswith("portal:"):
        return kind.split(":", 1)[1] in (probe.get("portal_collections") or [])
    if kind in (probe.get("connections") or []):
        return True
    # Composio toolkit slug not connected; only block kinds the probe covers.
    known = {"gmail", "googlecalendar", "googledrive", "googlesheets", "slack", "gohighlevel"}
    return kind not in known


def missing_required(hermes: dict, probe: dict | None) -> list[str]:
    """Required (optional: false) sources the probe says this box lacks."""
    if probe is None:
        return []
    out = []
    for s in hermes.get("sources") or []:
        if isinstance(s, dict) and not s.get("optional", False):
            kind = s.get("kind")
            if kind and not source_present(kind, probe):
                out.append(kind)
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--skills-dir", required=True)
    ap.add_argument("--installed", required=True, help="JSON array of installed slugs")
    ap.add_argument("--sources", default=None,
                    help="path to an agent-sources JSON dump; default runs the probe")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    installed = set(json.load(open(a.installed)))

    probe = load_probe(a.sources)
    if probe is None:
        print("skill_crons: no source probe available; installing crons ungated")

    wanted = []  # (slug, name, schedule, command)
    skipped = 0
    for rec in scan_skills(a.skills_dir):
        if rec["name"] not in installed:
            continue
        fm = read_frontmatter(os.path.join(a.skills_dir, rec["path"]))
        hermes = (fm.get("metadata") or {}).get("hermes") or {}
        crons = [c for c in hermes.get("crons") or []
                 if c.get("schedule") and c.get("command")]
        if not crons:
            continue
        missing = missing_required(hermes, probe)
        if missing:
            print(f"skip crons for {rec['name']}: missing required source "
                  + ", ".join(missing))
            skipped += len(crons)
            continue
        for c in crons:
            wanted.append((rec["name"], c.get("name", "job"), c["schedule"], c["command"]))

    cur = subprocess.run(["crontab", "-l"], capture_output=True, text=True).stdout.splitlines()
    keep = [l for l in cur if not re.search(r"# skill:\S+$", l)]
    new = keep + [f"{sch} {cmd} # skill:{slug}" for slug, _n, sch, cmd in wanted]
    text = "\n".join(new).strip() + "\n"
    if a.dry_run:
        print(text); return 0
    subprocess.run(["crontab", "-"], input=text, text=True, check=True)
    print(f"skill_crons: {len(wanted)} managed cron(s) for {len(installed)} installed pack(s)"
          + (f", {skipped} skipped on missing sources" if skipped else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
