#!/usr/bin/env python3
"""Box-health writer for the per-box client portal BrainStatus badge.

Reads supervisorctl status and writes a small JSON the portal reads at
/api/brain-status. Only GENUINE failures (FATAL/BACKOFF) count as down; RUNNING
counts as up; transitional/intentional states (STARTING/STOPPED/EXITED) are not
flagged so a restart never cries wolf. Ignores itself + known-cosmetic programs.
The portal fails open (missing/stale file -> "Live"), so this never paints a
healthy box offline. Run as a supervised loop (program:brain-health)."""
import json, os, subprocess, tempfile, time
OUT = os.environ.get("BRAIN_HEALTH_FILE", "/opt/rereset-portal/.brain-health.json")
IGNORE = {"safeclaw-console", "websockify", "brain-health"}
DOWN_STATES = {"FATAL", "BACKOFF"}
def main():
    try:
        res = subprocess.run(["supervisorctl", "status"], capture_output=True, text=True, timeout=20)
        lines = [l for l in res.stdout.splitlines() if l.strip()]
    except Exception:
        lines = []
    up = total = 0; down = []
    for l in lines:
        parts = l.split()
        if len(parts) < 2: continue
        name, state = parts[0], parts[1]
        if name in IGNORE: continue
        if state == "RUNNING":
            up += 1; total += 1
        elif state in DOWN_STATES:
            down.append(name); total += 1
    if down and up == 0: health = "down"
    elif down: health = "degraded"
    else: health = "healthy"
    payload = {"health": health, "servicesUp": up, "servicesTotal": total, "down": down, "ts": int(time.time()*1000)}
    d = os.path.dirname(OUT); fd, tmp = tempfile.mkstemp(dir=d, prefix=".bh-")
    with os.fdopen(fd, "w") as f: json.dump(payload, f)
    os.replace(tmp, OUT); print(json.dumps(payload))
if __name__ == "__main__": main()
