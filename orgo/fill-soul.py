#!/usr/bin/env python3
"""fill-soul.py: render a personalized SOUL.md from the template + a profile.

Package A (runs on the provisioner, off-box). Fills the {{PLACEHOLDER}} fields in
orgo/SOUL.template.md from a JSON profile and writes /opt/SOUL.md (or --out),
ready for the install-box.sh `identity` stage to deploy to /root/.hermes/SOUL.md.

Hard guard: a SOUL with an em or en dash is an instant AI tell. This refuses to
write one (exit 2) so a bad SOUL never reaches a box.

Usage:
  fill-soul.py --template orgo/SOUL.template.md --profile kim.json --out /opt/SOUL.md
  fill-soul.py --profile kim.json            # template + out default as above
  echo '{...}' | fill-soul.py --profile -    # profile from stdin

Profile JSON keys map to placeholders (any not provided are flagged):
  agent_name, agent_email, principal_name, principal_email, company,
  company_one_liner, allowlist, mission, priority_1, priority_2, priority_3
"""
from __future__ import annotations
import argparse
import json
import os
import re
import sys

KEY_TO_PLACEHOLDER = {
    "agent_name": "AGENT_NAME",
    "agent_email": "AGENT_EMAIL",
    "principal_name": "PRINCIPAL_NAME",
    "principal_email": "PRINCIPAL_EMAIL",
    "company": "COMPANY",
    "company_one_liner": "COMPANY_ONE_LINER",
    "allowlist": "ALLOWLIST",
    "mission": "MISSION",
    "priority_1": "PRIORITY_1",
    "priority_2": "PRIORITY_2",
    "priority_3": "PRIORITY_3",
}

DASH_RE = re.compile("[–—]")  # en dash, em dash


def load_profile(path: str) -> dict:
    raw = sys.stdin.read() if path == "-" else open(path, encoding="utf-8").read()
    return json.loads(raw)


def main() -> int:
    ap = argparse.ArgumentParser()
    here = os.path.dirname(os.path.abspath(__file__))
    ap.add_argument("--template", default=os.path.join(here, "SOUL.template.md"))
    ap.add_argument("--profile", required=True, help="JSON file path, or - for stdin")
    ap.add_argument("--out", default="/opt/SOUL.md")
    ap.add_argument("--print", action="store_true", help="write to stdout instead of --out")
    args = ap.parse_args()

    template = open(args.template, encoding="utf-8").read()
    profile = load_profile(args.profile)

    # Strip the leading instructional HTML comment block (the template says to
    # delete it before deploying; it also documents the placeholders, which we
    # must not treat as real fields).
    template = re.sub(r"^\s*<!--.*?-->\s*", "", template, count=1, flags=re.DOTALL)

    out = template
    missing_values = []
    for key, ph in KEY_TO_PLACEHOLDER.items():
        token = "{{" + ph + "}}"
        if key in profile and profile[key] not in (None, ""):
            out = out.replace(token, str(profile[key]))
        elif token in template:
            missing_values.append(ph)

    # Any leftover {{...}} placeholders are unfilled and must be caught.
    leftovers = sorted(set(re.findall(r"\{\{[A-Z_0-9]+\}\}", out)))
    if leftovers:
        sys.stderr.write("FAIL: unfilled placeholders remain: " + ", ".join(leftovers) + "\n")
        sys.stderr.write("Provide them in the profile JSON keys: "
                         + ", ".join(k for k, v in KEY_TO_PLACEHOLDER.items() if v in
                                     [l.strip("{}") for l in leftovers]) + "\n")
        return 2

    # Dash guard.
    if DASH_RE.search(out):
        lines = [str(i + 1) for i, ln in enumerate(out.splitlines()) if DASH_RE.search(ln)]
        sys.stderr.write("FAIL: em/en dash in rendered SOUL (lines " + ", ".join(lines)
                         + "). Fix the profile text. No dashes in prose.\n")
        return 2

    if args.print:
        sys.stdout.write(out)
    else:
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(out)
        sys.stderr.write(f"wrote {args.out} ({len(out)} bytes), dash-clean, no placeholders left\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
