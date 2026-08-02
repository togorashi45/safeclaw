#!/usr/bin/env python3
# Deterministic GHL -> gbrain collector. Pulls the ACTIVE working set (not the full
# contact list): open deals (deals/*), and digests (board/*): pipeline summary,
# unreplied conversations, upcoming appointments. Contact LOOKUP stays live via the
# GHL MCP. No frontmatter slug -> gbrain derives the slug from the file path.
import os, re, json, datetime, urllib.request, urllib.parse
from collections import defaultdict

BASE = "https://services.leadconnectorhq.com"
ROOT = "/opt/brain/repo/crm"
BOARD = ROOT + "/board"
ENV_CANDIDATES = ["/opt/ghl-mcp/.env", "/opt/safeclaw/client.env", "/root/.hermes/.env"]

def _read_envs():
    d = {}
    for path in ENV_CANDIDATES:
        if not os.path.exists(path):
            continue
        for line in open(path):
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            k = k.strip().upper()
            v = v.strip().strip('"').strip("'")
            if v and k not in d:
                d[k] = v
    return d

_ENV = _read_envs()
TOKEN = _ENV.get("GHL_API_KEY") or _ENV.get("GHL_PIT") or _ENV.get("GHL_TOKEN") or ""
LOC = _ENV.get("GHL_LOCATION_ID") or _ENV.get("GHL_LOCATION") or ""
if not TOKEN or not LOC:
    raise SystemExit("GHL token/location not found in any of: " + ", ".join(ENV_CANDIDATES))
HDRS = {"Authorization": "Bearer " + TOKEN, "Version": "2021-07-28", "Accept": "application/json",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
                      "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"}

def api(path):
    req = urllib.request.Request(BASE + path, headers=HDRS)
    try:
        with urllib.request.urlopen(req, timeout=25) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        print(f"  API {e.code} on {path.split('?')[0]}")
        raise

def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", (s or "untitled").lower()).strip("-")[:60]

def yq(s):
    """Emit a YAML double-quoted scalar.

    Deal names routinely contain a colon (via the "Deal: " prefix), a comma,
    an apostrophe or an em dash. An unquoted colon breaks the frontmatter
    mapping parse. Always emitting a fresh double-quoted scalar from the raw
    value is idempotent: the input never carries quotes of its own, and any
    that appear are escaped rather than re-wrapped.
    """
    s = "" if s is None else str(s)
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'

os.makedirs(ROOT + "/deals", exist_ok=True)
os.makedirs(BOARD, exist_ok=True)

pipes = api(f"/opportunities/pipelines?locationId={LOC}").get("pipelines", [])
pname, sname = {}, {}
for p in pipes:
    pname[p["id"]] = p.get("name", "")
    for st in p.get("stages", []):
        sname[st["id"]] = st.get("name", "")

opps, page = [], 1
while True:
    d = api(f"/opportunities/search?location_id={LOC}&status=open&limit=100&page={page}")
    batch = d.get("opportunities", [])
    opps += batch
    if len(batch) < 100 or page >= 20:
        break
    page += 1

today = datetime.date.today()
def days_since(iso):
    try:
        return (today - datetime.date.fromisoformat(str(iso)[:10])).days
    except Exception:
        return None

summary = defaultdict(lambda: defaultdict(lambda: [0, 0.0]))
for o in opps:
    pl = pname.get(o.get("pipelineId"), "Pipeline")
    stg = sname.get(o.get("pipelineStageId"), "Stage")
    val = o.get("monetaryValue") or 0
    summary[pl][stg][0] += 1
    summary[pl][stg][1] += val
    age = days_since(o.get("lastStageChangeAt") or o.get("updatedAt"))
    body = ["---", f"title: {yq('Deal: ' + str(o.get('name','') or ''))}", "source: ghl",
            f"pipeline: {yq(pl)}", f"stage: {yq(stg)}", "---", "",
            f"# {o.get('name','')}", "",
            f"- Pipeline: {pl}", f"- Stage: {stg}", f"- Value: ${val}",
            f"- Status: {o.get('status')}", f"- Source: {o.get('source','')}",
            f"- Days in stage: {age if age is not None else '?'}",
            f"- GHL opportunity id: {o.get('id')}"]
    open(f"{ROOT}/deals/{slug(o.get('name'))}.md", "w").write("\n".join(body))

ps = ["---", "title: CRM pipeline summary", "source: ghl", "---", "",
      f"# Pipeline summary ({today.isoformat()})", "", f"{len(opps)} open opportunities.", ""]
for pl in sorted(summary):
    tot = sum(v[0] for v in summary[pl].values())
    val = sum(v[1] for v in summary[pl].values())
    ps.append(f"## {pl}: {tot} open, ${int(val):,}")
    for stg in sorted(summary[pl], key=lambda s: -summary[pl][s][0]):
        c, v = summary[pl][stg]
        ps.append(f"- {stg}: {c}" + (f" (${int(v):,})" if v else ""))
    ps.append("")
open(f"{BOARD}/pipeline-summary.md", "w").write("\n".join(ps))

convos, page = [], 1
while True:
    d = api(f"/conversations/search?locationId={LOC}&limit=100&page={page}")
    batch = d.get("conversations", [])
    convos += batch
    if len(batch) < 100 or page >= 10:
        break
    page += 1
unreplied = [c for c in convos if c.get("lastMessageDirection") == "inbound" or (c.get("unreadCount") or 0) > 0]
unreplied.sort(key=lambda c: str(c.get("lastMessageDate", "")), reverse=True)
ur = ["---", "title: Unreplied conversations", "source: ghl", "---", "",
      f"# Unreplied conversations ({today.isoformat()})", "",
      f"{len(unreplied)} threads where the last message is inbound or unread.", ""]
for c in unreplied[:60]:
    who = c.get("contactName") or c.get("fullName") or c.get("id")
    msg = re.sub(r"\s+", " ", str(c.get("lastMessageBody", ""))).strip()[:160]
    ch = str(c.get("lastMessageType", "")).replace("TYPE_", "")
    ur.append(f"- **{who}** ({ch}, unread {c.get('unreadCount',0)}): {msg}")
open(f"{BOARD}/unreplied.md", "w").write("\n".join(ur))

appts = []
try:
    users = api(f"/users/?locationId={LOC}").get("users", [])
    uids = [u["id"] for u in users][:10]
    now = datetime.datetime.now(datetime.timezone.utc)
    start = now.strftime("%Y-%m-%dT00:00:00Z")
    end = (now + datetime.timedelta(days=21)).strftime("%Y-%m-%dT00:00:00Z")
    seen = set()
    for uid in uids:
        try:
            d = api(f"/calendars/events?locationId={LOC}&userId={uid}"
                    f"&startTime={urllib.parse.quote(start)}&endTime={urllib.parse.quote(end)}")
            for e in d.get("events", []):
                if e.get("id") in seen:
                    continue
                seen.add(e.get("id"))
                appts.append(e)
        except Exception:
            continue
except Exception as e:
    print("appointments fetch issue:", str(e)[:80])
appts.sort(key=lambda e: str(e.get("startTime", "")))
ap = ["---", "title: Upcoming appointments", "source: ghl", "---", "",
      f"# Upcoming appointments ({today.isoformat()})", "", f"{len(appts)} in the next 21 days.", ""]
for e in appts[:60]:
    t = str(e.get("startTime", ""))[:16].replace("T", " ")
    ap.append(f"- {t} - {e.get('title') or e.get('appointmentStatus','')} "
              f"({e.get('contactName') or e.get('contactId','')}) [{e.get('appointmentStatus','')}]")
open(f"{BOARD}/appointments.md", "w").write("\n".join(ap))

print(f"GHL COLLECT DONE: {len(opps)} deals, {len(summary)} pipelines, "
      f"{len(unreplied)} unreplied, {len(appts)} appts")
