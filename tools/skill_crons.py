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
Usage: skill_crons.py --skills-dir /opt/safeclaw/skills --installed installed.json [--dry-run]
"""
import argparse, json, re, subprocess, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from skills_manifest import scan_skills, read_frontmatter  # noqa: E402

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--skills-dir", required=True)
    ap.add_argument("--installed", required=True, help="JSON array of installed slugs")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    installed = set(json.load(open(a.installed)))

    wanted = []  # (slug, name, schedule, command)
    for rec in scan_skills(a.skills_dir):
        fm = read_frontmatter(os.path.join(a.skills_dir, rec["path"]))
        for c in ((fm.get("metadata") or {}).get("hermes") or {}).get("crons") or []:
            if rec["name"] in installed and c.get("schedule") and c.get("command"):
                wanted.append((rec["name"], c.get("name", "job"), c["schedule"], c["command"]))

    cur = subprocess.run(["crontab", "-l"], capture_output=True, text=True).stdout.splitlines()
    keep = [l for l in cur if not re.search(r"# skill:\S+$", l)]
    new = keep + [f"{sch} {cmd} # skill:{slug}" for slug, _n, sch, cmd in wanted]
    text = "\n".join(new).strip() + "\n"
    if a.dry_run:
        print(text); return 0
    subprocess.run(["crontab", "-"], input=text, text=True, check=True)
    print(f"skill_crons: {len(wanted)} managed cron(s) for {len(installed)} installed pack(s)")
    return 0

if __name__ == "__main__":
    sys.exit(main())
