#!/usr/bin/env bash
# =============================================================================
# SafeClaw clean install template (hardened, non-Docker, supervised Postgres).
#
# This is the reconciled installer: it builds a VANILLA Orgo/Ubuntu box to a
# green SafeClaw agent box from scratch, every time, with no baked snapshot and
# no client secrets baked in (secrets are injected per box via install.env).
#
# It encodes the 2026-06 fleet hardening (Postgres + pgvector brain under
# supervisor, OpenRouter embeddings, one gateway on the single default profile)
# plus every documented install gotcha from the retired manual runbooks.
#
# RUN: push this file + a filled install.env to the box, then:
#        sudo bash /opt/install-box.sh            # full run
#        sudo bash /opt/install-box.sh base brain # selected stages
#        sudo bash /opt/install-box.sh verify     # doctor + live smoke only
# Idempotent: safe to re-run, AND a re-run converges (it upgrades; it does not
# skip because something already exists). Logs to /opt/install.log.
#
# STATUS: authored, NOT yet validated end to end on a live box (the base stage
# was validated on Kim's box 2026-06-14: apt needs --fix-missing + disabling the
# flaky sublime/chrome repos; node ships as v18 so we install 20). Verify the
# gbrain/hermes CLI flags marked VERIFY on the first real run.
# =============================================================================
set -uo pipefail

# Every stage records pass or fail here. The driver prints the tally at the end
# and exits nonzero if anything failed, so a half-failed re-run can no longer
# print a green done banner (audit finding 9).
STAGE_RESULTS=""
STAGE_FAILED=0   # count of failures, not a flag, so the driver can attribute them per stage
fail_stage() { echo "FAIL: $*"; STAGE_FAILED=$((STAGE_FAILED + 1)); return 1; }
LOG=/opt/install.log
exec > >(tee -a "$LOG") 2>&1
echo "================ install-box start $(date -u) ================"

ENV_FILE="${INSTALL_ENV:-/opt/install.env}"
[ -f "$ENV_FILE" ] && set -a && . "$ENV_FILE" && set +a || {
  echo "WARN: $ENV_FILE not found. Secrets/config must be in the environment."; }

# ---- required config (from install.env) ------------------------------------
: "${CLIENT_SLUG:?set CLIENT_SLUG (e.g. kim)}"
: "${SKILL_PROFILE:=team-member}"          # e.g. team-kim, base
: "${SAFECLAW_REF:=main}"                  # branch/tag of togorashi45/hermes-brain to install
: "${HERMES_MODEL:=glm-4.7}"
: "${HERMES_BASE_URL:=https://ollama.com/v1}"
# Secrets (leave blank to skip the dependent stage; the stage will warn):
: "${GITHUB_TOKEN:=}"                       # to clone the private safeclaw repo
: "${OPENROUTER_API_KEY:=}"                 # gbrain embeddings + dream
: "${OLLAMA_API_KEY:=}"                     # hermes model provider
: "${COMPOSIO_API_KEY:=}"                   # PROJECT key (preferred: minted off-box, injected here)
: "${COMPOSIO_ORG_API_KEY:=}"               # ORG key; ONLY for on-box fallback mint (prefer off-box)
: "${COMPOSIO_PROJECT:=${CLIENT_SLUG}}"     # per-box Composio project name (one project per box = isolation)
: "${WHATSAPP_ALLOWED_USERS:=}"            # set at onboarding (the principal's number)
: "${WHATSAPP_MODE:=bot}"                   # bot = dedicated box number the principal texts; self-chat = link their own
: "${AGENTMAIL_INBOX:=}"                     # this box's own email address (off-box minted)
: "${AGENTMAIL_API_KEY:=}"                   # INBOX-SCOPED key (never the org key); mint via orgo/agentmail-provision.sh
# Recurring routines (stage_cron). email-ingest + calendar-sync auto-enable when
# COMPOSIO_API_KEY is set; GHL sync is opt-in (clients on GoHighLevel only):
: "${ENABLE_GHL_SYNC:=}"                     # set to 1 to schedule the hourly GHL -> gbrain sync
# Portal (the per-box client portal, served natively against this box's Postgres):
: "${PORTAL_REF:=main}"  # branch/tag of togorashi45/rereset-portal to install
: "${PORTAL_SLUG:=${CLIENT_SLUG}}"          # the /c/<slug> + brief clientSlug (e.g. phil-gore)
: "${PORTAL_ALLOWLIST:=}"                    # the client's own login emails (comma-separated), gates /c
: "${PORTAL_DOMAIN:=portal-${PORTAL_SLUG}.rereset.ai}"  # public hostname (needs a Cloudflare CNAME to the tunnel)
: "${PORTAL_PORT:=3008}"
: "${AUTH_GOOGLE_ID:=}"                      # shared Google OAuth client id (NextAuth)
: "${AUTH_GOOGLE_SECRET:=}"                  # shared Google OAuth client secret
: "${PORTAL_INGEST_SECRET:=}"               # shared brief ingest secret; reused by the brief writer
# Portal ROLE: client (default) = single-tenant /c box; admin = the me.rereset.ai
# command center (keeps /me + /admin, sees ALL tenants). The admin variant is gated on
# this flag so a client box can never accidentally ship the admin surface.
: "${PORTAL_ROLE:=client}"                   # client | admin
: "${ADMIN_ALLOWLIST:=}"                      # admin role: comma-list of superadmin emails (e.g. jake@rspur.com)
: "${AUTH_SECRET:=}"                          # inject the SHARED secret to keep cross-subdomain SSO; blank = per-box generated
: "${AUTH_COOKIE_DOMAIN:=}"                   # set to .rereset.ai to share the session cookie across all *.rereset.ai portals
: "${GBRAIN_EMBED_MODEL:=openrouter:openai/text-embedding-3-small}"  # brain embed model; override per box (e.g. ollama:nomic-embed-text)
: "${GBRAIN_EMBED_DIMS:=1536}"               # MUST match the embed model; the schema bootstraps to this width
: "${GBRAIN_CHAT_MODEL:=openrouter:openai/gpt-5.2}"          # openai/gpt-5.2-mini does NOT exist; a typo fails at call time, not config time
: "${GBRAIN_RERANKER_MODEL:=openrouter:cohere/rerank-4-fast}" # the default zeroentropyai reranker needs a key we do not have
# gbrain source: OUR FORK, always latest, never hard pinned.
#
# The bug was never "unpinned". It was the wrong repo: the installer cloned
# upstream garrytan/gbrain, so boxes never carried the fixes our own fleet found
# and we shipped back into rspur-hq/gbrain. Latest from the fork wins, with a
# MINIMUM VERSION FLOOR that fails the install loudly when it is not met.
: "${GBRAIN_PKG:=github:rspur-hq/gbrain}"
# FLOOR JUSTIFICATION. Each of these is a fix this box's configuration depends
# on, so a build below the floor is broken in a way doctor will not tell you:
#   0.42.67.0  resolveModel() configFileValue slot. Below this, the hardcoded
#              anthropic tier default shadows our file-plane chat_model, and
#              dream/extract silently produce ZERO takes on an OpenRouter-only
#              brain. This is the failure the fleet shipped.
#   0.42.68.0  buildGatewayConfig() threads reranker_model through the seam. We
#              set reranker_model in the file plane, so below this our reranker
#              config is dead and every search runs unreranked.
#   0.42.69.0  email-headers conversation parser builtin. Our email sense writes
#              header-style pages; below this they never parse as conversations.
# We depend on all three, so the floor is the highest of them.
: "${GBRAIN_MIN_VERSION:=0.42.69.0}"
# Weekly maintenance window (canary Saturday, fleet Sunday). See
# orgo/routines/gbrain-weekly-maintenance.sh. Exactly one box in the fleet is
# the canary.
: "${MAINT_ROLE:=fleet}"                     # canary | fleet
: "${MAINT_GATE_URL:=}"                      # where a fleet box reads the canary verdict; unset = fleet never upgrades
: "${MAINT_GATE_PUBLISH_URL:=}"              # canary only: where to POST the verdict
: "${MAINT_GATE_PUBLISH_SECRET:=}"           # canary only: shared secret for the publish POST
: "${TS_AUTHKEY:=}"                           # Tailscale auth key; set to join the tailnet (off-box writers reach this box over it)
# Connect page (on-box Composio "connect your accounts" page, served by safeclaw-ui):
: "${CONNECT_PORT:=8899}"                    # loopback port for the connect Flask app
: "${CONNECT_DOMAIN:=safeclaw-${PORTAL_SLUG}.rereset.ai}"  # public hostname (needs a CF CNAME to the tunnel)
: "${CONNECT_SERVICES_JSON:=}"               # optional path to a filled composio-services.json (from orgo/composio-setup-authconfigs.sh)

REPO=/opt/safeclaw
PORTAL=/opt/rereset-portal
BRAIN=/opt/brain
PGV=16

# GBRAIN_HOME MOVES THE CONFIG PATH. With /opt/brain, gbrain reads
# /opt/brain/.gbrain/config.json, not /root/.gbrain/config.json. Every routine
# on the box already exports this; the installer never did, so `gbrain init`
# wrote its config to one home while every scheduled run read another. The
# file-plane settings (embed model, chat model, reranker, schema pack) were
# invisible to every cron. The same split sends audit JSONL to a directory
# doctor never looks at. Export it once, here, before any gbrain invocation.
export GBRAIN_HOME="$BRAIN"

gen() { openssl rand -hex "${1:-16}"; }
have() { command -v "$1" >/dev/null 2>&1; }
say() { echo; echo "---- $* ----"; }
# Version compare that understands 0.42.9 < 0.42.69. Never string compare.
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

# =============================================================================
stage_base() {
  say "STAGE base: system packages"
  export DEBIAN_FRONTEND=noninteractive
  # Swap: Orgo/VPS boxes ship with 0 swap, so a memory spike OOM-kills services. Add an
  # 8G swapfile once so the box survives bursts (critical for the admin box: brain + portal
  # + local embedder on 8G RAM). Idempotent.
  if [ "$(swapon --show --noheadings 2>/dev/null | wc -l)" -eq 0 ] && [ ! -f /swapfile ]; then
    ( fallocate -l 8G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=8192 2>/dev/null ) \
      && chmod 600 /swapfile && mkswap /swapfile >/dev/null 2>&1 && swapon /swapfile \
      && { grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >>/etc/fstab; } \
      && echo "swap: 8G swapfile active" || echo "VERIFY: swapfile setup"
  fi
  # Full PATH incl sbin: orgo's non-interactive shell drops /usr/sbin+/sbin, which
  # breaks dpkg (start-stop-daemon) and every downstream install (validated live 2026-06-16).
  export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.bun/bin
  echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.bun/bin' >/etc/profile.d/00-fullpath.sh
  grep -q 'usr/sbin' /root/.bashrc 2>/dev/null || echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.bun/bin' >>/root/.bashrc
  # Orgo boxes often boot days behind, so apt rejects repo metadata as "not valid yet".
  # Try NTP, and tell apt to ignore the date regardless (validated live 2026-06-16).
  timedatectl set-ntp true 2>/dev/null || true
  local APT="-o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false"
  # Flaky third-party repos on the stock Orgo image break apt update (learned live).
  for f in /etc/apt/sources.list.d/*sublime* /etc/apt/sources.list.d/*google-chrome*; do
    [ -e "$f" ] && mv "$f" "$f.disabled" 2>/dev/null || true
  done
  apt-get $APT update -y --fix-missing || true
  apt-get $APT install -y --fix-missing \
    git curl jq unzip xz-utils build-essential python3-pip openssl supervisor \
    "postgresql-${PGV}" "postgresql-${PGV}-pgvector" || true
  # xz fallback via direct .deb if the resolver balked on a broken libc6-dev state (learned live).
  if ! have xz; then ( cd /tmp && apt-get $APT download xz-utils 2>/dev/null && dpkg -i xz-utils*.deb 2>/dev/null ) || true; fi
  # bun (gbrain runs under bun; shebang is #!/usr/bin/env bun, symlink required).
  if ! have bun; then curl -fsSL https://bun.sh/install | bash; fi
  ln -sf /root/.bun/bin/bun /usr/local/bin/bun
  # Node 20 (stock image ships 18; setup-hermes.sh + dashboard build want 20). Prefer
  # .tar.xz, fall back to .tar.gz so a missing xz never blocks node (learned live).
  if [ "$(node -v 2>/dev/null | cut -c2-3)" != "20" ]; then
    if have xz; then curl -fsSL -o /tmp/node20.tar.xz https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.xz && tar -xJf /tmp/node20.tar.xz -C /opt
    else curl -fsSL -o /tmp/node20.tar.gz https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.gz && tar -xzf /tmp/node20.tar.gz -C /opt; fi
    ln -sf /opt/node-v20.18.1-linux-x64/bin/node /usr/local/bin/node
    ln -sf /opt/node-v20.18.1-linux-x64/bin/npm /usr/local/bin/npm
    ln -sf /opt/node-v20.18.1-linux-x64/bin/npx /usr/local/bin/npx
  fi
  # cloudflared (only needed if a web tunnel is wanted; harmless to have).
  have cloudflared || { curl -fsSL -o /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared; }
  # Tailscale: off-box writers reach this box's Postgres/brain over the tailnet (Orgo has no
  # public ports). Install always; only join when TS_AUTHKEY is set. Orgo is systemd-less, so
  # fall back to running tailscaled under supervisor.
  have tailscale || { curl -fsSL https://tailscale.com/install.sh | sh || echo "VERIFY: tailscale install"; }
  if [ -n "${TS_AUTHKEY}" ]; then
    if ! pgrep -x tailscaled >/dev/null 2>&1; then
      if ! { have systemctl && systemctl enable --now tailscaled 2>/dev/null; }; then
        mkdir -p /var/lib/tailscale /run/tailscale
        cat >/etc/supervisor/conf.d/tailscaled.conf <<EOF
[program:tailscaled]
command=$(command -v tailscaled) --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock
autostart=true
autorestart=true
stdout_logfile=/var/log/tailscaled.log
stderr_logfile=/var/log/tailscaled.log
EOF
        supervisorctl reread 2>/dev/null; supervisorctl update 2>/dev/null; sleep 2
      fi
    fi
    tailscale up --authkey "${TS_AUTHKEY}" --hostname "safeclaw-${CLIENT_SLUG}" --ssh 2>/dev/null \
      && echo "tailscale: joined as safeclaw-${CLIENT_SLUG} ($(tailscale ip -4 2>/dev/null | head -1))" \
      || echo "VERIFY: tailscale up (authkey valid + tailscaled running?)"
  fi
  echo "base versions:"; psql --version; bun --version; node -v; cloudflared --version | head -1
}

# =============================================================================
stage_harden_boot() {
  say "STAGE harden_boot: survive a reboot (pg socket dir, DNS, single supervisord)"
  # WHY: /run is a fresh tmpfs every boot, and the orgo base image launches
  # supervisord from BOTH /opt/init.sh and /opt/startup.sh. Left alone, the next
  # reboot gives a box (a) two supervisord daemons fighting over the conf.d
  # programs, (b) postgres FATAL because its socket dir /var/run/postgresql is
  # gone, and (c) no DNS because /etc/resolv.conf dangles into the wiped tmpfs.
  # All three bit the live fleet on 2026-06-19. This stage makes them permanent.
  install -d -o postgres -g postgres -m 2775 /var/run/postgresql 2>/dev/null || true
  python3 - <<'PY'
import os
def bak(p):
    if os.path.exists(p) and not os.path.exists(p+'.bak-harden'):
        open(p+'.bak-harden','w').write(open(p).read())
# Remove the duplicate supervisord launch from /opt/startup.sh (init.sh owns it).
p='/opt/startup.sh'
if os.path.exists(p):
    bak(p); s=open(p).read()
    ns=s.replace('supervisord -c /etc/supervisor/supervisord.conf &',
        ': # [harden] redundant supervisord launch removed; /opt/init.sh starts it once')
    if ns!=s: open(p,'w').write(ns); print('startup.sh: duplicate supervisord launch removed')
    else: print('startup.sh: clean')
# Patch /opt/init.sh: guard the launch, create pg socket dir + DNS at every boot.
p='/opt/init.sh'
if not os.path.exists(p):
    print('init.sh: not found (non-orgo base?) — skipping'); raise SystemExit
bak(p); s=open(p).read(); changed=False
old='if command -v supervisord >/dev/null 2>&1; then'
new='if command -v supervisord >/dev/null 2>&1 && ! pgrep -f "supervisord -c /etc/supervisor/supervisord.conf" >/dev/null 2>&1; then'
if old in s and '! pgrep -f "supervisord' not in s:
    s=s.replace(old,new,1); changed=True; print('init.sh: supervisord launch guarded')
marker=new if new in s else old
add=''
if 'var/run/postgresql' not in s:
    add+=('# [harden] /run is fresh tmpfs each boot; postgres needs its socket dir.\n'
          'install -d -o postgres -g postgres -m 2775 /var/run/postgresql 2>/dev/null\n\n')
if 'nameserver 172.16.0.1' not in s:
    add+=('# [harden] resolv.conf dangles into tmpfs with no systemd-resolved present.\n'
          'if [ ! -s /etc/resolv.conf ]; then\n'
          '  rm -f /etc/resolv.conf\n'
          '  printf "nameserver 172.16.0.1\\nnameserver 1.1.1.1\\noptions edns0\\n" > /etc/resolv.conf\n'
          'fi\n\n')
if 'api.telegram.org' not in s:
    # hermes telegram SEND path resolves api.telegram.org via glibc; some boxes
    # return AAAA/IPv6-first with dead IPv6 egress, which hangs outbound sendMessage
    # (long-poll RECEIVE still works via hermes own auto-discovered fallback IPs, so
    # the bot looks connected but never replies). Bit elise live 2026-06-19. Force
    # IPv4 for the send path: pin api.telegram.org + prefer IPv4 in gai.conf.
    add+=('# [harden] telegram send path: force IPv4 (box can resolve IPv6-first with dead v6).\n'
          'grep -q "api.telegram.org" /etc/hosts || echo "149.154.167.220 api.telegram.org" >> /etc/hosts\n'
          'grep -q "::ffff:0:0/96" /etc/gai.conf 2>/dev/null || echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf\n\n')
if add and marker in s:
    i=s.find(marker); s=s[:i]+add+s[i:]; changed=True; print('init.sh: pg-dir + DNS boot fixes added')
if changed: open(p,'w').write(s)
else: print('init.sh: already hardened')
PY
}

# =============================================================================
stage_brain_db() {
  say "STAGE brain_db: supervised Postgres + pgvector"
  mkdir -p "$BRAIN/repo"
  # Let supervisor own Postgres (not systemd) so it restarts cleanly with the box.
  systemctl disable --now postgresql 2>/dev/null || true
  pg_ctlcluster "$PGV" main start 2>/dev/null || true
  local PW; PW="$(gen 16)"
  # BYPASSRLS TRAP: SUPERUSER alone does NOT set rolbypassrls; gbrain v24 schema
  # halts ("column chunker_version does not exist") without it.
  sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='brain'" | grep -q 1 \
    || sudo -u postgres psql -c "CREATE ROLE brain LOGIN SUPERUSER BYPASSRLS PASSWORD '$PW';"
  sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='brain'" | grep -q 1 \
    || sudo -u postgres createdb -O brain brain
  sudo -u postgres psql -d brain -c "CREATE EXTENSION IF NOT EXISTS vector;"
  cat >/etc/supervisor/conf.d/postgres-brain.conf <<EOF
[program:postgres-brain]
command=/usr/lib/postgresql/${PGV}/bin/postgres -c config_file=/etc/postgresql/${PGV}/main/postgresql.conf
user=postgres
autostart=true
autorestart=true
stdout_logfile=/var/log/postgres-brain.log
stderr_logfile=/var/log/postgres-brain.err
EOF
  # /opt/brain/.env: brain config + secrets. Generated tokens persist a rebuild.
  if [ ! -f "$BRAIN/.env" ]; then
    cat >"$BRAIN/.env" <<EOF
GBRAIN_DATABASE_URL=postgresql://brain:${PW}@127.0.0.1:5432/brain
GBRAIN_ADMIN_BOOTSTRAP_TOKEN=$(gen 24)
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
EOF
    chmod 600 "$BRAIN/.env"
  fi
  ( cd "$BRAIN/repo" && git init -q 2>/dev/null; git config user.email brain@rereset.local; git config user.name brain )
  # Hand Postgres to supervisor: stop the manually-started cluster first, else both
  # bind :5432 and the supervised one backoff-loops (validated live 2026-06-16).
  pg_ctlcluster "$PGV" main stop 2>/dev/null || true
  supervisorctl reread; supervisorctl update
  supervisorctl restart postgres-brain 2>/dev/null || supervisorctl start postgres-brain 2>/dev/null || true
  # WRITE THE FILE-PLANE CONFIG NOW, before anything invokes gbrain.
  # Pitfall 10: if a DATABASE_URL is visible when the gbrain package postinstall
  # runs migrations, the schema bootstraps with gbrain's COMPILED defaults
  # (ZeroEntropy zembed-1 at 1280 dims). A config.json written afterwards at
  # 1536 dims then mismatches the vector column and EVERY write fails with
  # "expected 1280 dimensions, not 1536". stage_runtime installs gbrain, so the
  # config has to exist by the end of this stage, not in stage_brain_init.
  write_gbrain_config_json
}

# Write $GBRAIN_HOME/.gbrain/config.json. Merges, never clobbers: an existing
# database_url holds the real Postgres password and must never be regenerated.
# Idempotent, and the vendored product script merges over this same file later.
write_gbrain_config_json() {
  local dburl=""
  [ -f "$BRAIN/.env" ] && dburl="$(sed -n 's/^GBRAIN_DATABASE_URL=//p' "$BRAIN/.env" | head -1)"
  if [ -z "$dburl" ]; then
    echo "NOTE: no GBRAIN_DATABASE_URL in $BRAIN/.env yet; skipping config.json write"
    return 0
  fi
  mkdir -p "$GBRAIN_HOME/.gbrain"
  python3 - "$GBRAIN_HOME/.gbrain/config.json" "$dburl" "$GBRAIN_EMBED_MODEL" "$GBRAIN_EMBED_DIMS" \
           "$GBRAIN_CHAT_MODEL" "$GBRAIN_RERANKER_MODEL" <<'PY'
import json, sys
path, db_url, embed, dims, chat, reranker = sys.argv[1:7]
try:
    cfg = json.load(open(path))
except Exception:
    cfg = {}
cfg.update({
    "engine": "postgres",
    "database_url": db_url,
    "embedding_model": embed,
    "embedding_dimensions": int(dims),
    "chat_model": chat,
    "reranker_model": reranker,
})
cfg.setdefault("schema_pack", "gbrain-base-v2")
cfg.setdefault("mcp", {"publish_skills": True})
# Self-upgrade stays OFF on every box. The weekly maintenance window is the only
# path that changes a version, so a box can never move itself underneath us.
cfg.setdefault("self_upgrade", {})["mode"] = "off"
json.dump(cfg, open(path, "w"), indent=2)
print("wrote " + path + " (file plane, before the first gbrain invocation)")
PY
  chmod 600 "$GBRAIN_HOME/.gbrain/config.json" 2>/dev/null || true
}

# =============================================================================
stage_backup() {
  say "STAGE backup: daily brain pg_dump + configs, supervised (cron is absent here)"
  # The brain lives in Postgres, so a pg_dump is the backup that matters. cron is
  # absent on orgo boxes, so a tiny supervisord timer is the reboot-safe scheduler.
  mkdir -p /opt/backups /root/.hermes/scripts
  cat >/root/.hermes/scripts/daily-backup.sh <<'BK'
#!/usr/bin/env bash
# Daily backup: brain DATABASE (pg_dump) + brain files + hermes config. Keeps 7 days.
BACKUP_DIR=/opt/backups
DATE=$(date +%Y-%m-%d)
KEEP_DAYS=7
mkdir -p "$BACKUP_DIR"
if sudo -u postgres pg_dump -Fc brain > "$BACKUP_DIR/brain-db-$DATE.dump" 2>/var/log/brain-backup.err; then
  echo "pg_dump ok: $(du -h "$BACKUP_DIR/brain-db-$DATE.dump" | cut -f1)"
else
  echo "PG_DUMP FAILED"; rm -f "$BACKUP_DIR/brain-db-$DATE.dump"
fi
tar -czf "$BACKUP_DIR/brain-files-$DATE.tar.gz" -C /opt --exclude='brain/.gbrain*' --exclude='brain/*.pglite*' brain 2>/dev/null
tar -czf "$BACKUP_DIR/hermes-configs-$DATE.tar.gz" -C /root/.hermes config.yaml .env cron scripts SOUL.md 2>/dev/null
find "$BACKUP_DIR" -name 'brain-db-*.dump' -mtime +$KEEP_DAYS -delete
find "$BACKUP_DIR" -name '*.tar.gz' -mtime +$KEEP_DAYS -delete
BK
  chmod +x /root/.hermes/scripts/daily-backup.sh
  cat >/opt/brain-backup-loop.sh <<'LOOP'
#!/usr/bin/env bash
SCRIPT=/root/.hermes/scripts/daily-backup.sh
while true; do
  now=$(date +%s)
  target=$(date -d 'today 09:10' +%s 2>/dev/null || echo $((now+86400)))
  [ "$target" -le "$now" ] && target=$(date -d 'tomorrow 09:10' +%s 2>/dev/null || echo $((now+86400)))
  sleep $(( target - now ))
  bash "$SCRIPT" >> /var/log/brain-backup.log 2>&1
done
LOOP
  chmod +x /opt/brain-backup-loop.sh
  cat >/etc/supervisor/conf.d/brain-backup.conf <<'CONF'
[program:brain-backup]
command=/opt/brain-backup-loop.sh
autostart=true
autorestart=true
startsecs=5
stdout_logfile=/var/log/brain-backup.log
stderr_logfile=/var/log/brain-backup.log
CONF
  supervisorctl reread; supervisorctl update
  bash /root/.hermes/scripts/daily-backup.sh || true
  echo "backup: first dump written to /opt/backups; daily timer running under supervisor."
}

# =============================================================================
stage_composio_project() {
  say "STAGE composio_project: isolated Composio project + key for '$COMPOSIO_PROJECT'"
  mkdir -p "$BRAIN"
  # Idempotent: a project key already on this box wins; never re-mint over a live one.
  if [ -f "$BRAIN/.env" ] && grep -q '^COMPOSIO_API_KEY=' "$BRAIN/.env"; then
    echo "exists: COMPOSIO_API_KEY already in $BRAIN/.env; leaving as-is."; return 0
  fi
  # PREFERRED PATH: the project key was minted OFF-BOX (composio-mint-project.sh on
  # the provisioner) and injected via install.env. Just persist it; the org key
  # never came near this box.
  if [ -n "$COMPOSIO_API_KEY" ]; then
    { echo "COMPOSIO_API_KEY=$COMPOSIO_API_KEY"
      [ -n "${COMPOSIO_PROJECT_ID:-}" ] && echo "COMPOSIO_PROJECT_ID=$COMPOSIO_PROJECT_ID"
      echo "COMPOSIO_PROJECT_NAME=$COMPOSIO_PROJECT"; } >> "$BRAIN/.env"
    chmod 600 "$BRAIN/.env"
    echo "persisted pre-minted Composio project key to $BRAIN/.env (off-box mint, clean isolation)."
    return 0
  fi
  # FALLBACK PATH: only the org key is on the box. This works but puts a
  # high-privilege org key on a tenant box; mint, then SCRUB it immediately.
  if [ -n "$COMPOSIO_ORG_API_KEY" ]; then
    echo "WARN: minting on-box with the ORG key. Prefer off-box (composio-mint-project.sh). Scrubbing the org key from install.env after."
    local API="https://backend.composio.dev/api/v3.1/org/owner" pid key resp
    # config is REQUIRED on create; log_visibility_setting enum: show_all | dont_store_data.
    local CFG='{"is_2FA_enabled":false,"mask_secret_keys_in_connected_account":true,"log_visibility_setting":"show_all"}'
    pid=$(curl -s -H "x-org-api-key: $COMPOSIO_ORG_API_KEY" "$API/project/list" \
          | jq -r --arg n "$COMPOSIO_PROJECT" '(.data // [])[] | select(.name==$n) | .id' | head -1)
    if [ -n "$pid" ] && [ "$pid" != null ]; then
      echo "FAIL: Composio project '$COMPOSIO_PROJECT' already exists ($pid) but its key cannot be retrieved (shown only at creation; regeneration disabled for this org). Inject COMPOSIO_API_KEY directly, or delete the project and re-run."; return 1
    fi
    resp=$(curl -s -X POST -H "x-org-api-key: $COMPOSIO_ORG_API_KEY" -H "Content-Type: application/json" \
           -d "{\"name\":\"$COMPOSIO_PROJECT\",\"should_create_api_key\":true,\"config\":$CFG}" "$API/project/new")
    pid=$(echo "$resp" | jq -r '.id // .nano_id // empty')
    # api_key may be a bare string OR an object {key:...}.
    key=$(echo "$resp" | jq -r '(.api_key | if type=="object" then .key else . end) // empty')
    if [ -z "$key" ] || [ "$key" = null ]; then echo "FAIL: no Composio project key in response:"; echo "$resp" | jq -c '.error // .'; return 1; fi
    { echo "COMPOSIO_API_KEY=$key"; echo "COMPOSIO_PROJECT_ID=$pid"; echo "COMPOSIO_PROJECT_NAME=$COMPOSIO_PROJECT"; } >> "$BRAIN/.env"
    chmod 600 "$BRAIN/.env"
    export COMPOSIO_API_KEY="$key"
    # Scrub the org key so it does not persist on the tenant box.
    [ -f "$ENV_FILE" ] && sed -i.bak -E '/^COMPOSIO_ORG_API_KEY=/d' "$ENV_FILE" && rm -f "$ENV_FILE.bak" && unset COMPOSIO_ORG_API_KEY
    echo "minted '$COMPOSIO_PROJECT' ($pid) on-box; project key stored, org key scrubbed from $ENV_FILE."
    return 0
  fi
  echo "SKIP: no COMPOSIO_API_KEY (off-box mint) and no COMPOSIO_ORG_API_KEY (on-box mint). Composio senses will be unwired."
}

# =============================================================================
stage_repo() {
  say "STAGE repo: clone safeclaw -> $REPO ($SAFECLAW_REF)"
  if [ -z "$GITHUB_TOKEN" ]; then echo "SKIP: no GITHUB_TOKEN (private repo). Provide it or push the repo manually."; return 0; fi
  if [ ! -d "$REPO/.git" ]; then
    git clone -b "$SAFECLAW_REF" "https://x-access-token:${GITHUB_TOKEN}@github.com/togorashi45/hermes-brain.git" "$REPO"
  else
    # Existing clone (e.g. a legacy-generation box): force it to the requested ref.
    # A prior generation can leave a dirty worktree (validated live 2026-07-10 on the
    # Atomic Stays rebuild: modified docker/ files aborted the checkout), and the
    # remote may be tokenless. Set the tokened remote, then checkout -f + hard reset
    # so the update path is as deterministic as a fresh clone.
    (
      cd "$REPO" || exit 1
      git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/togorashi45/hermes-brain.git"
      git fetch origin "$SAFECLAW_REF" -q || exit 1
      git checkout -f "$SAFECLAW_REF" -q 2>/dev/null \
        || git checkout -fb "$SAFECLAW_REF" FETCH_HEAD -q || exit 1
      git reset --hard "origin/$SAFECLAW_REF" -q 2>/dev/null || git reset --hard FETCH_HEAD -q
    ) || echo "VERIFY: stage_repo update path (fetch/checkout/reset of $SAFECLAW_REF)"
  fi
  pip3 install --break-system-packages flask pyyaml requests croniter
}

# =============================================================================
stage_runtime() {
  say "STAGE runtime: gbrain + hermes"
  [ -d "$REPO" ] || { echo "SKIP: repo not present (run stage_repo)"; return 0; }
  # Full PATH incl sbin: the orgo non-interactive shell drops /usr/sbin+/sbin, which
  # breaks dpkg (start-stop-daemon) and downstream installs (validated live 2026-06-16).
  export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.bun/bin
  # bun is gbrain's runtime. gbrain's shebang is #!/usr/bin/env bun, so bun MUST be
  # globally symlinked or every non-interactive gbrain spawn dies (issue 21).
  have bun || { curl -fsSL https://bun.sh/install | bash; }
  [ -x /root/.bun/bin/bun ] && ln -sf /root/.bun/bin/bun /usr/local/bin/bun
  # gbrain: LATEST from OUR FORK, every run. Not install-if-missing (a re-run
  # then never upgrades and drift only accumulates), and not a hard pin (we want
  # the latest fixes, and most of the recent ones came out of our own fleet).
  #
  # The actual gbrain plane is provisioned by the vendored product script in
  # stage_brain_init, which does the install in the correct order (config.json
  # BEFORE the first invocation against a fresh DB). Here we only make sure a
  # usable gbrain binary and the global symlink exist for the stages in between,
  # and we enforce the floor.
  install_gbrain() {
    # bun's global resolver reports a bogus DependencyLoop when the same package
    # name is already installed from a different source (upstream vs fork).
    # Remove the old global first.
    bun remove -g gbrain >/dev/null 2>&1 || true
    bun install -g "$GBRAIN_PKG" || echo "NOTE: bun install -g $GBRAIN_PKG returned nonzero"
    # bun blocks postinstall hooks by default; the postinstall runs migrations.
    bun pm -g trust gbrain >/dev/null 2>&1 || true
  }
  install_gbrain
  # Global symlink OUTSIDE any conditional: a legacy box can already have gbrain
  # on /root/.bun/bin, and non-login shells (supervisor, cron) still could not
  # find it (validated live 2026-07-10 on the Atomic Stays rebuild).
  ln -sf "$(command -v gbrain 2>/dev/null || echo /root/.bun/bin/gbrain)" /usr/local/bin/gbrain 2>/dev/null || true
  # THE FLOOR. Below it the box is broken in ways doctor reports as healthy, so
  # this fails the install rather than continuing. Retired legacy path: the old
  # /opt/gbrain-src clone of upstream garrytan/gbrain is no longer used.
  GBRAIN_VER="$(gbrain --version 2>/dev/null | awk '{print $NF}')"
  if [ -z "$GBRAIN_VER" ]; then
    fail_stage "gbrain is not on PATH after install from $GBRAIN_PKG"; return 1
  fi
  if ! version_ge "$GBRAIN_VER" "$GBRAIN_MIN_VERSION"; then
    echo "FAIL: gbrain $GBRAIN_VER is below the required floor $GBRAIN_MIN_VERSION."
    echo "      Below the floor, dream/extract silently produce zero takes on this box."
    echo "      Fix the fork ($GBRAIN_PKG), do not lower the floor."
    fail_stage "gbrain version floor"; return 1
  fi
  echo "gbrain $GBRAIN_VER from $GBRAIN_PKG (floor $GBRAIN_MIN_VERSION, ok)"
  # hermes: setup-hermes.sh lives at scripts/ (NOT orgo/setup/). Run BARE so a pipe
  # cannot mask its exit code (issue 4).
  if ! have hermes; then
    bash "$REPO/scripts/setup-hermes.sh" || echo "VERIFY: setup-hermes.sh exit + symlink"
  else
    # A re-run UPGRADES. Legacy boxes arrive with an old hermes already on PATH,
    # and install-if-missing left them thousands of commits behind (validated
    # live 2026-07-14 fleet migration: 0.16 boxes kept 0.16, gateway then FATAL
    # on the 0.18 config). Version changes are otherwise only made in the weekly
    # maintenance window.
    hermes update || echo "NOTE: hermes update returned nonzero (keeping the installed build)"
  fi
  have hermes || fail_stage "hermes not on PATH after setup"
  # The 0.18 whatsapp adapter resolves its bridge from the hermes-agent venv's
  # site-packages/scripts, which the package does not ship; and the adapter
  # imports aiohttp, also absent from the uv venv (both validated live 2026-07-14).
  SP=/root/.local/share/uv/tools/hermes-agent/lib/python3.11/site-packages
  if [ -d "$SP" ]; then
    [ -e "$SP/scripts" ] || ln -sfn /opt/hermes/scripts "$SP/scripts"
    /root/.local/bin/uv pip install --python /root/.local/share/uv/tools/hermes-agent/bin/python aiohttp >/dev/null 2>&1 \
      || echo "VERIFY: aiohttp install into the hermes-agent venv"
  fi
  echo "runtime: $(which gbrain hermes bun 2>/dev/null) hermes=$(hermes --version 2>/dev/null | head -1)"
}

# =============================================================================
stage_brain_init() {
  say "STAGE brain_init: gbrain on Postgres + embeddings"
  [ -z "$OPENROUTER_API_KEY" ] && { echo "SKIP: OPENROUTER_API_KEY needed for embeddings"; return 0; }
  set -a; . "$BRAIN/.env"; set +a
  # Legacy gbrain config poisons init: a pre-v2 /root/.gbrain/config.json (pglite
  # generation) carries its old embedding_dimensions into the new Postgres schema,
  # so the vector column comes out the wrong width (768 vs 1536, validated live
  # 2026-07-10 on the Atomic Stays rebuild). Move it aside so init starts clean.
  if [ -f /root/.gbrain/config.json ] && grep -q '"engine": *"pglite"' /root/.gbrain/config.json; then
    mv /root/.gbrain "/root/.gbrain.pre-v2.$(date +%s)"
    echo "legacy pglite gbrain config moved aside (fresh init)"
  fi
  # Config.json is already on disk from stage_brain_db (pitfall 10 ordering).
  # Re-run the writer anyway: this stage can be invoked on its own, and the
  # merge is cheap and idempotent.
  write_gbrain_config_json
  # Embedding model MUST be named at init so the vector column is the right width.
  # (Flag validated live 2026-07-10: gbrain 0.42 accepts --url and --embedding-model.)
  gbrain init --url "$GBRAIN_DATABASE_URL" --embedding-model "$GBRAIN_EMBED_MODEL" \
    || echo "NOTE: gbrain init returned nonzero (already initialized is normal on a re-run)"

  # THE PRODUCT'S OWN RECIPE. orgo/gbrain-recipe/vm-hermes-setup.sh is a verbatim
  # copy of scripts/vm-hermes-setup.sh from rspur-hq/gbrain: file-plane config,
  # fork install, the DB-plane model mirror, MCP registration, doctor. Vendored
  # so provisioning never depends on network state at install time. Provenance
  # and the refresh path are in orgo/gbrain-recipe/VENDOR.md. Do not hand edit
  # it; our overrides run after it.
  local VM="$REPO/orgo/gbrain-recipe/vm-hermes-setup.sh"
  if [ -f "$VM" ]; then
    GBRAIN_HOME="$GBRAIN_HOME" \
    DATABASE_URL="$GBRAIN_DATABASE_URL" \
    GBRAIN_PKG="$GBRAIN_PKG" \
    CHAT_MODEL="$GBRAIN_CHAT_MODEL" \
    EMBED_MODEL="$GBRAIN_EMBED_MODEL" \
    EMBED_DIMS="$GBRAIN_EMBED_DIMS" \
    RERANKER_MODEL="$GBRAIN_RERANKER_MODEL" \
    HERMES_CONFIG=/root/.hermes/config.yaml \
      bash "$VM" || fail_stage "vendored vm-hermes-setup.sh"
    # The vendored script registers gbrain as a STDIO MCP server. Our boxes run
    # the native HTTP endpoint instead (proven on the live fleet), so
    # stage_hermes_config replaces that entry. Both cannot coexist under one key
    # and the HTTP one wins.
  else
    fail_stage "vendored vm-hermes-setup.sh missing at $VM (run stage_repo first)"
  fi

  # Re-assert the floor AFTER the vendored install, which is the step that
  # actually moves the version.
  local V; V="$(gbrain --version 2>/dev/null | awk '{print $NF}')"
  if [ -z "$V" ] || ! version_ge "$V" "$GBRAIN_MIN_VERSION"; then
    echo "FAIL: gbrain ${V:-missing} is below the floor $GBRAIN_MIN_VERSION after the vendored install."
    fail_stage "gbrain version floor after vm-hermes-setup"
  else
    echo "gbrain $V clears the floor $GBRAIN_MIN_VERSION"
  fi

  # SPEND GATES. gbrain ships these and we had every one of them unset when the
  # OpenRouter balance hit zero on 2026-08-01. Setting them explicitly is worth
  # more than the numbers: a stated posture is auditable and does not move when
  # a product default changes.
  #   spend.posture=gated                   gates enforce. Never tokenmax on a client box.
  #   sync.cost_gate_min_usd=0.50           product default. Above it a non-TTY sync
  #                                         defers embeds to capped backfill jobs
  #                                         instead of wedging the cron.
  #   embed.backfill_max_usd=5              per job. Our corpora are small; a job
  #                                         that wants more than $5 is a bug, not a big brain.
  #   embed.backfill_max_usd_per_source_24h=10   a runaway loop stops at $10 a day
  #                                         per source, not the $25 default.
  gbrain config set spend.posture gated                          2>/dev/null || echo "NOTE: spend.posture set failed"
  gbrain config set sync.cost_gate_min_usd 0.50                  2>/dev/null || echo "NOTE: sync.cost_gate_min_usd set failed"
  gbrain config set embed.backfill_max_usd 5                     2>/dev/null || echo "NOTE: embed.backfill_max_usd set failed"
  gbrain config set embed.backfill_max_usd_per_source_24h 10     2>/dev/null || echo "NOTE: embed.backfill_max_usd_per_source_24h set failed"

  gbrain config set sync.repo_path "$BRAIN/repo" 2>/dev/null || true
  # gbrain >=0.42 resolves the sync path from the DB-backed sources table, and a
  # re-init against a recreated DB leaves the default source with a NULL
  # local_path ("Source \"default\" has no local_path", validated live 2026-07-10).
  # 'sources add default' refuses (already registered), so set it directly.
  sudo -u postgres psql -d brain -c \
    "UPDATE sources SET local_path='$BRAIN/repo' WHERE id='default' AND local_path IS NULL;" 2>/dev/null || true
  # PARA + OKF skeleton: the brain repo is organized from day one (inbox /
  # projects / areas / resources / archive, each with an OKF index page). The
  # agent's filing rules live in SOUL.md; these pages are the structure they
  # point at. Never overwrite an existing page (idempotent re-run).
  if [ -d "$REPO/orgo/knowledge/para-seed" ]; then
    ( cd "$REPO/orgo/knowledge/para-seed" && find . -name '*.md' -print0 ) | \
    while IFS= read -r -d '' f; do
      dst="$BRAIN/repo/${f#./}"
      [ -f "$dst" ] || install -D -m 644 "$REPO/orgo/knowledge/para-seed/${f#./}" "$dst"
    done
    echo "brain repo seeded with the PARA skeleton (inbox/projects/areas/resources/archive)."
  fi
  ( cd "$BRAIN/repo" && git add -A && git commit -q -m "initial seed" 2>/dev/null || true )
  # --full: the incremental bookmark can believe it is caught up after a re-init
  # (checkpoint survives a DB recreate), silently skipping the seed pages
  # (validated live 2026-07-10). A full sync of the tiny seed set is cheap.
  gbrain sync --full 2>&1 | tail -3 || true
  gbrain extract --stale 2>/dev/null || true   # link/timeline extraction for the seed pages
}

# =============================================================================
stage_hermes_config() {
  say "STAGE hermes_config: model + gbrain MCP + token economy"
  [ -z "$OLLAMA_API_KEY" ] && echo "WARN: OLLAMA_API_KEY missing; gateway will demand a model key"
  hermes config set model.base_url "$HERMES_BASE_URL" 2>/dev/null || true   # installer ships openrouter base by default (issue 20)
  hermes config set model.name "$HERMES_MODEL" 2>/dev/null || true
  hermes config set agent.max_turns 25 2>/dev/null || true
  hermes config set agent.auxiliary.compression.enabled true 2>/dev/null || true
  # Cron --no-agent scripts (email-ingest etc.) are killed at 120s by default; a run
  # that actually ingests takes minutes. Raise the cron script timeout to 1800s on
  # the default profile so real ingest runs are not killed (learned live on the fleet).
  hermes config set cron.script_timeout_seconds 1800 2>/dev/null || true
  [ -n "$OLLAMA_API_KEY" ] && hermes auth add ollama-cloud --type api-key --key "$OLLAMA_API_KEY" 2>/dev/null || true

  # ---- gbrain MCP: the native HTTP endpoint --------------------------------
  # This used to be a comment and nothing else, which is why every box that
  # worked was hand wired. config/toolset-policy.yaml lists `brain` as an
  # always-on hot toolset and email-ingest.sh hard errors without a put_page
  # tool, so on a strictly per-script fresh install the flagship email sense
  # could not store anything.
  #
  # HTTP, not stdio. gbrain serves a native MCP endpoint at /mcp with bearer
  # auth. That is what runs on the live fleet, so that is what we provision.
  # The vendored product script registers the stdio variant by default; the
  # block below overwrites it.
  set -a; [ -f "$BRAIN/.env" ] && . "$BRAIN/.env"; set +a
  export GBRAIN_HOME="$BRAIN"
  local GB_PORT="${GBRAIN_HTTP_PORT:-3131}"
  if [ -z "${GBRAIN_DATABASE_URL:-}" ]; then
    echo "SKIP: no GBRAIN_DATABASE_URL in $BRAIN/.env; cannot wire the gbrain MCP (run stage_brain_db)"
  else
    # Supervised serve process. GBRAIN_ADMIN_BOOTSTRAP_TOKEN is generated once in
    # stage_brain_db and persists in $BRAIN/.env, so the token survives a restart
    # and never has to be scraped out of a log. --suppress-bootstrap-token keeps
    # it out of the supervisor log entirely.
    cat >/etc/supervisor/conf.d/gbrain-http.conf <<EOF
[program:gbrain-http]
command=/bin/bash -lc 'set -a; . ${BRAIN}/.env; set +a; export GBRAIN_HOME=${BRAIN}; exec /usr/local/bin/gbrain serve --http --port ${GB_PORT} --bind 127.0.0.1 --suppress-bootstrap-token'
autostart=true
autorestart=true
startsecs=8
stdout_logfile=/var/log/gbrain-http.log
stderr_logfile=/var/log/gbrain-http.err
EOF
    supervisorctl reread; supervisorctl update
    supervisorctl restart gbrain-http 2>/dev/null || supervisorctl start gbrain-http 2>/dev/null || true

    # A dedicated MCP token, not the admin bootstrap token. `gbrain auth create`
    # is idempotent by name only in the sense that it mints a new one each time,
    # so persist the first one in $BRAIN/.env and reuse it on every re-run.
    if ! grep -q '^GBRAIN_MCP_TOKEN=' "$BRAIN/.env" 2>/dev/null; then
      local TOK
      # A token by this name can exist from a previous generation with its value
      # lost (create prints it once). Revoke, then mint, so the box always holds
      # a token it actually knows.
      gbrain auth revoke "hermes-${CLIENT_SLUG}" >/dev/null 2>&1 || true
      TOK="$(gbrain auth create "hermes-${CLIENT_SLUG}" 2>/dev/null | grep -oE 'gbrain_[a-f0-9]{64}' | head -1)"
      if [ -n "$TOK" ]; then
        echo "GBRAIN_MCP_TOKEN=$TOK" >> "$BRAIN/.env"
        chmod 600 "$BRAIN/.env"
        echo "minted a gbrain MCP token for hermes-${CLIENT_SLUG} (stored in $BRAIN/.env)"
      else
        echo "NOTE: could not mint a gbrain MCP token; falling back to the admin bootstrap token"
      fi
      set -a; . "$BRAIN/.env"; set +a
    fi
    local MCP_TOKEN="${GBRAIN_MCP_TOKEN:-${GBRAIN_ADMIN_BOOTSTRAP_TOKEN:-}}"
    if [ -z "$MCP_TOKEN" ]; then
      fail_stage "no gbrain MCP token available; Hermes would get zero brain tools"
    else
      GBRAIN_MCP_URL="http://127.0.0.1:${GB_PORT}/mcp" GBRAIN_MCP_TOKEN="$MCP_TOKEN" python3 - <<'PY'
import os, yaml
cfg_path = "/root/.hermes/config.yaml"
cfg = {}
if os.path.exists(cfg_path):
    cfg = yaml.safe_load(open(cfg_path)) or {}
mcp = cfg.setdefault("mcp_servers", {})
# Timeouts are deliberate. A cold brain answers the first tools/list slowly and
# the default is short enough to look like "0 tools".
mcp["gbrain"] = {
    "url": os.environ["GBRAIN_MCP_URL"],
    "headers": {"Authorization": "Bearer " + os.environ["GBRAIN_MCP_TOKEN"]},
    "timeout": 120,
    "connect_timeout": 30,
    "enabled": True,
}
yaml.safe_dump(cfg, open(cfg_path, "w"), default_flow_style=False, sort_keys=False)
print("hermes config: mcp_servers.gbrain wired to " + os.environ["GBRAIN_MCP_URL"] + " (http + bearer)")
PY
      chmod 600 /root/.hermes/config.yaml 2>/dev/null || true
    fi
  fi
}

# =============================================================================
stage_composio_mcp() {
  # Ported from Sten (Vasanth19/sten @ 3f2f3f5, live-proven 2026-07-02): one MCP
  # server per box bound to the box's toolkits, agent connects to a per-box url.
  # Replaces the manual Console /api/gmail/wire step. Idempotent; re-run after
  # adding a toolkit or reconnecting an account (this IS the reconcile path).
  say "STAGE composio_mcp: per-box Composio MCP server + Hermes wiring"
  [ -d "$REPO" ] || { echo "SKIP: repo not present (run stage_repo)"; return 0; }
  export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.bun/bin
  have node || { echo "SKIP: node not installed (stage_base installs node 20)"; return 0; }
  # Key comes from $BRAIN/.env (persisted by stage_composio_project); never from install.env here.
  set -a; [ -f "$BRAIN/.env" ] && . "$BRAIN/.env"; set +a
  [ -n "${COMPOSIO_API_KEY:-}" ] || { echo "SKIP: no COMPOSIO_API_KEY in $BRAIN/.env (run stage_composio_project)"; return 0; }
  # Provisioner runs from its own dir so ESM resolves @composio/core locally.
  local PDIR=/opt/composio-provision
  mkdir -p "$PDIR"
  cp "$REPO/orgo/composio-provision-mcp.mjs" "$PDIR/"
  [ -f "$PDIR/package.json" ] || echo '{"name":"composio-provision","private":true,"type":"module","dependencies":{"@composio/core":"^0.13.1"}}' > "$PDIR/package.json"
  ( cd "$PDIR" && npm install --no-fund --no-audit --loglevel=error ) || { echo "FAIL: npm install @composio/core"; return 1; }
  mkdir -p /opt/safeclaw
  local OUT
  if ! OUT=$(cd "$PDIR" && \
      COMPOSIO_API_KEY="$COMPOSIO_API_KEY" \
      CLIENT_SLUG="$CLIENT_SLUG" \
      COMPOSIO_USER_ID="${COMPOSIO_USER_ID:-client:$CLIENT_SLUG}" \
      COMPOSIO_TOOLKITS="${COMPOSIO_TOOLKITS:-gmail,googlecalendar,googledrive,slack}" \
      COMPOSIO_ENV_FILES="$BRAIN/.env,/root/.hermes/.env" \
      COMPOSIO_SERVICES_JSON=/opt/safeclaw/composio-services.json \
      node composio-provision-mcp.mjs); then
    echo "FAIL: composio-provision-mcp.mjs (see stderr above)"; return 1
  fi
  echo "provisioned: $OUT"
  # Wire mcp_servers.composio into the default profile config. Strip-when-absent:
  # a bare/empty url in the config breaks Hermes boot (empty-scheme MCP url), so
  # the entry only exists when a real https url does.
  set -a; . "$BRAIN/.env"; set +a
  python3 - <<'PY'
import os, yaml
cfg_path = "/root/.hermes/config.yaml"
cfg = {}
if os.path.exists(cfg_path):
    cfg = yaml.safe_load(open(cfg_path)) or {}
mcp = cfg.setdefault("mcp_servers", {})
url = os.environ.get("COMPOSIO_MCP_URL", "")
if url.startswith("https://"):
    mcp["composio"] = {
        "url": url,
        "headers": {
            "x-api-key": os.environ.get("COMPOSIO_API_KEY", ""),
            "x-composio-user-id": os.environ.get("COMPOSIO_USER_ID", ""),
        },
    }
else:
    mcp.pop("composio", None)  # never leave a bare url behind
yaml.safe_dump(cfg, open(cfg_path, "w"), default_flow_style=False, sort_keys=False)
print("hermes config: mcp_servers.composio " + ("wired" if url.startswith("https://") else "stripped (no url)"))
PY
  # Hermes binds MCP tools at boot; if the gateway is already up, restart it so
  # the new server binds. Cold-start note: Composio MCP tools are absent ~50% of
  # cold spawns; the first turn may need a retry (Sten pitfall 9).
  if supervisorctl status hermes-gateway 2>/dev/null | grep -q RUNNING; then
    supervisorctl restart hermes-gateway || true
    echo "gateway restarted to bind the Composio MCP."
  fi
}

# =============================================================================
stage_identity() {
  say "STAGE identity: SOUL.md"
  mkdir -p /root/.hermes
  if [ -f /opt/SOUL.md ]; then
    cp /opt/SOUL.md /root/.hermes/SOUL.md   # pre-filled per person (e.g. Kim's), pushed alongside install.env
  elif [ -f "$REPO/orgo/SOUL.template.md" ]; then
    echo "NOTE: deploy a filled SOUL.md to /root/.hermes/SOUL.md (template at $REPO/orgo/SOUL.template.md)."
  fi
  # Guard: never ship a SOUL with em/en dashes (instant AI tell).
  if [ -f /root/.hermes/SOUL.md ] && grep -qP "[\x{2013}\x{2014}]" /root/.hermes/SOUL.md; then
    echo "FAIL: SOUL.md contains em/en dashes. Fix before going live."
  fi
}

# =============================================================================
stage_skills() {
  say "STAGE skills: apply profile $SKILL_PROFILE + skill-router"
  [ -d "$REPO" ] || { echo "SKIP: repo not present"; return 0; }
  # apply_skill_profile.sh is the canonical entrypoint: it runs skills_manifest.py
  # itself with the required --skills-dir/--out args, prunes, and writes
  # SKILL_INDEX.md. (The old direct skills_manifest.py call here was malformed:
  # --skills-dir and --out are required. Validated live 2026-07-10.)
  bash "$REPO/tools/apply_skill_profile.sh" "$SKILL_PROFILE" \
    || echo "VERIFY: apply_skill_profile.sh $SKILL_PROFILE (profile in config/skill-profiles.yaml?)"
}

# =============================================================================
stage_channels() {
  say "STAGE channels: WhatsApp bridge"
  # The bridge ships with Hermes. Kim gives his number + scans the QR at onboarding.
  local BR=/opt/hermes/scripts/whatsapp-bridge/bridge.js
  if [ -f "$BR" ]; then
    # The bridge imports @whiskeysockets/baileys; its node_modules must be
    # installed or it crash-loops with ERR_MODULE_NOT_FOUND (validated live 2026-06-16).
    if [ ! -d /opt/hermes/scripts/whatsapp-bridge/node_modules ]; then
      ( cd /opt/hermes/scripts/whatsapp-bridge && npm install --no-audit --no-fund 2>&1 | tail -3 ) \
        || echo "VERIFY: whatsapp-bridge npm install"
    fi
    cat >/etc/supervisor/conf.d/whatsapp-bridge.conf <<EOF
[program:whatsapp-bridge]
command=/usr/local/bin/node $BR
environment=WHATSAPP_ALLOWED_USERS="${WHATSAPP_ALLOWED_USERS:-*}",WHATSAPP_MODE="${WHATSAPP_MODE:-bot}"
autostart=true
autorestart=true
stdout_logfile=/var/log/whatsapp-bridge.log
stderr_logfile=/var/log/whatsapp-bridge.err
EOF
    supervisorctl reread; supervisorctl update
    echo "WhatsApp bridge configured. Scan the QR in /var/log/whatsapp-bridge.log to pair."
  else
    echo "NOTE: bridge not present until Hermes is installed (stage_runtime)."
  fi
  [ -n "$COMPOSIO_API_KEY" ] && echo "Composio key present; wire gmail/calendar into the DEFAULT profile config (mcp_servers.gmail_<slug>) via Console /api/gmail/wire after gateway is up. email-ingest reads the gmail MCP from the default config." || true

  # Telegram: seed the bot token + numeric allowlist so the gateway actually enables
  # the platform. Without a token in the loaded env the gateway boots "No messaging
  # platforms enabled" and silently ignores every message (bit the fleet 2026-06-19).
  # The gateway runs on the single default profile, so the token lives in the
  # default .env only.
  if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
    env=/root/.hermes/.env
    mkdir -p "$(dirname "$env")"; touch "$env"
    grep -q '^TELEGRAM_BOT_TOKEN=' "$env" || echo "TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN" >> "$env"
    if [ -n "${TELEGRAM_ALLOWED_USERS:-}" ]; then
      grep -q '^TELEGRAM_ALLOWED_USERS=' "$env" || echo "TELEGRAM_ALLOWED_USERS=$TELEGRAM_ALLOWED_USERS" >> "$env"
    fi
    chmod 600 "$env" 2>/dev/null || true
    echo "Telegram token seeded into the default profile .env (allowlist: ${TELEGRAM_ALLOWED_USERS:-<UNSET - bot will deny everyone!>})."
  else
    echo "NOTE: TELEGRAM_BOT_TOKEN not set; skipping Telegram seed (fill it in install.env)."
  fi
}

# =============================================================================
stage_email() {
  say "STAGE email: wire agentmail MCP (the agent's own email identity)"
  if [ -z "${AGENTMAIL_API_KEY:-}" ] || [ -z "${AGENTMAIL_INBOX:-}" ]; then
    echo "SKIP: AGENTMAIL_API_KEY (inbox-scoped) + AGENTMAIL_INBOX needed; mint off-box via orgo/agentmail-provision.sh"; return 0
  fi
  local SRV="$REPO/orgo/onboarding/agentmail-mcp/server.py"
  [ -f "$SRV" ] || { echo "SKIP: agentmail MCP not in repo"; return 0; }
  # Run the MCP under the hermes venv python: system pip cannot install 'mcp'
  # (debian typing_extensions conflict), but the venv already has it (validated live).
  printf 'y\n' | hermes mcp add agentmail \
    --env AGENTMAIL_API_KEY="$AGENTMAIL_API_KEY" AGENTMAIL_INBOX="$AGENTMAIL_INBOX" \
    --command /opt/hermes/venv/bin/python3 --args "$SRV" 2>&1 | tail -3 \
    || echo "VERIFY: hermes mcp add agentmail"
}

# =============================================================================
stage_cron() {
  say "STAGE cron: deploy recurring routines + register them on the DEFAULT profile"
  # Single-profile architecture: scripts live in /root/.hermes/scripts and the jobs
  # are registered in the DEFAULT cron store (the default gateway is the only one
  # running, so it is the only scheduler that ticks). Deterministic collectors that
  # call gbrain/Composio directly live in /opt/brain/scripts.
  [ -d "$REPO/orgo/routines" ] || { echo "SKIP: orgo/routines not in repo"; return 0; }
  have hermes || { echo "SKIP: hermes not installed (run stage_runtime)"; return 0; }
  local R="$REPO/orgo/routines" SD=/root/.hermes/scripts BS=/opt/brain/scripts
  mkdir -p "$SD" "$BS"

  # 1. shell routines -> default scripts dir (cron resolves --script relative to $HERMES_HOME/scripts)
  for s in email-ingest.sh email-ingest-cron.sh ingest-retry.sh calendar-sync.sh ghl-sync.sh \
           gbrain-dream.sh gbrain-hygiene.sh gbrain-smoke.sh gbrain-weekly-maintenance.sh; do
    [ -f "$R/$s" ] && install -m 755 "$R/$s" "$SD/$s"
  done
  # 1b. shared helpers the routines source (heartbeat append to the integrations plane)
  [ -f "$R/lib/heartbeat.sh" ] && install -D -m 644 "$R/lib/heartbeat.sh" "$SD/lib/heartbeat.sh"
  # 2. deterministic python collectors -> /opt/brain/scripts (what calendar-sync/ghl-sync call)
  for p in calendar-collect.py ghl-collect.py; do
    [ -f "$R/$p" ] && install -m 755 "$R/$p" "$BS/$p"
  done

  # 3. register jobs on the default profile (idempotent: hermes cron create upserts by name).
  #    email-ingest runs via the cron WRAPPER (cold-start pre-check + retries) because the
  #    default profile loads the box's full MCP set and gmail can lose the registration race.
  if [ -n "${COMPOSIO_API_KEY:-}" ]; then
    hermes cron create "15 * * * *" --name email-ingest --script email-ingest-cron.sh --no-agent --deliver local 2>&1 | tail -1 \
      || echo "VERIFY: hermes cron create email-ingest (flags per hermes version)"
    hermes cron create "30 5 * * *" --name calendar-sync --script calendar-sync.sh --no-agent --deliver local 2>&1 | tail -1 \
      || echo "VERIFY: hermes cron create calendar-sync"
  else
    echo "NOTE: COMPOSIO_API_KEY unset; skipping email-ingest + calendar-sync (no Gmail/Calendar source)."
  fi
  if [ -n "${ENABLE_GHL_SYNC:-}" ]; then
    hermes cron create "0 * * * *" --name ghl-sync --script ghl-sync.sh --no-agent --deliver local 2>&1 | tail -1 \
      || echo "VERIFY: hermes cron create ghl-sync"
  fi
  # gbrain-dream: brain compaction EVERY 6 HOURS, not daily. cycle_freshness
  # warns past 6h and fails at 24h, so a daily dream leaves the brain fresh only
  # 6h out of 24 and doctor decays 100 to 95 every evening. Fix the cadence, not
  # the threshold: the check is honest and staleness compounds. Dream phases are
  # incremental, so steady-state cost is small.
  if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    hermes cron create "5 */6 * * *" --name gbrain-dream --script gbrain-dream.sh --no-agent --deliver local 2>&1 | tail -1 \
      || echo "VERIFY: hermes cron create gbrain-dream"
  else
    echo "NOTE: OPENROUTER_API_KEY unset; skipping gbrain-dream (dream needs it)."
  fi
  # gbrain-hygiene: weekly rule-based brain checks (doctor, orphans,
  # contradictions), zero LLM cost; writes areas/brain-hygiene/latest.md.
  hermes cron create "0 13 * * 1" --name gbrain-hygiene --script gbrain-hygiene.sh --no-agent --deliver local 2>&1 | tail -1 \
    || echo "VERIFY: hermes cron create gbrain-hygiene"

  # WEEKLY MAINTENANCE WINDOW: canary Saturday, fleet Sunday.
  # The canary upgrades first and soaks about 24h. The Sunday fleet run is gated
  # on the canary's doctor score not regressing. Sunday-night-only was rejected:
  # a bad upgrade would land with no buffer before Monday. This window is the
  # ONLY path that changes a gbrain or Hermes version on any box; self-upgrade
  # stays off everywhere (see write_gbrain_config_json).
  #
  # hermes cron create, never a hand-edited crontab. Hermes owns the box crontab.
  #
  # Fork sync note: "latest from our fork" goes stale unless rspur-hq/gbrain is
  # merged from upstream garrytan/gbrain on a recurring basis. That merge is a
  # repo job, not a box job, and nothing here does it for us.
  {
    echo "MAINT_ROLE=${MAINT_ROLE}"
    [ -n "${MAINT_GATE_URL}" ]            && echo "MAINT_GATE_URL=${MAINT_GATE_URL}"
    [ -n "${MAINT_GATE_PUBLISH_URL}" ]    && echo "MAINT_GATE_PUBLISH_URL=${MAINT_GATE_PUBLISH_URL}"
    [ -n "${MAINT_GATE_PUBLISH_SECRET}" ] && echo "MAINT_GATE_PUBLISH_SECRET=${MAINT_GATE_PUBLISH_SECRET}"
    echo "GBRAIN_MIN_VERSION=${GBRAIN_MIN_VERSION}"
    echo "GBRAIN_PKG=${GBRAIN_PKG}"
  } > "$BRAIN/.maintenance.env"
  chmod 600 "$BRAIN/.maintenance.env"
  # The routine reads /opt/brain/.env, so append the maintenance settings there
  # too (idempotent: replace the block rather than stacking duplicates).
  sed -i '/^MAINT_ROLE=/d;/^MAINT_GATE_URL=/d;/^MAINT_GATE_PUBLISH_URL=/d;/^MAINT_GATE_PUBLISH_SECRET=/d;/^GBRAIN_MIN_VERSION=/d;/^GBRAIN_PKG=/d' "$BRAIN/.env" 2>/dev/null || true
  cat "$BRAIN/.maintenance.env" >> "$BRAIN/.env"
  chmod 600 "$BRAIN/.env"
  if [ "${MAINT_ROLE}" = "canary" ]; then
    hermes cron create "0 8 * * 6" --name gbrain-maintenance --script gbrain-weekly-maintenance.sh --no-agent --deliver local 2>&1 | tail -1 \
      || echo "VERIFY: hermes cron create gbrain-maintenance (canary, Saturday)"
    echo "maintenance: CANARY, Saturday 08:00 UTC. It publishes the gate the fleet reads."
  else
    hermes cron create "0 8 * * 0" --name gbrain-maintenance --script gbrain-weekly-maintenance.sh --no-agent --deliver local 2>&1 | tail -1 \
      || echo "VERIFY: hermes cron create gbrain-maintenance (fleet, Sunday)"
    if [ -z "${MAINT_GATE_URL}" ]; then
      echo "maintenance: FLEET, Sunday 08:00 UTC. MAINT_GATE_URL is unset, so this box runs checks only and never upgrades (fail closed)."
    else
      echo "maintenance: FLEET, Sunday 08:00 UTC, gated on the canary verdict at ${MAINT_GATE_URL}."
    fi
  fi
  echo "cron jobs registered (default profile):"; hermes cron list 2>/dev/null | grep -E "Name:|Next run:" || true
}

# =============================================================================
stage_gateway() {
  say "STAGE gateway: hermes-gateway (single default profile)"
  # HERMES_ALLOW_ROOT_GATEWAY=1: orgo boxes run as root; without it the gateway
  # refuses to start ("Refusing to run as root", validated live 2026-06-16).
  # A prior-generation box may carry hermes-gateway-actor; retire it so only one
  # gateway polls the channels.
  rm -f /etc/supervisor/conf.d/hermes-gateway-actor.conf
  cat >/etc/supervisor/conf.d/hermes-gateway.conf <<'EOF'
[program:hermes-gateway]
command=/bin/bash -lc 'cd /root/.hermes && HERMES_ALLOW_ROOT_GATEWAY=1 hermes gateway run'
autostart=true
autorestart=true
stdout_logfile=/var/log/hermes-gateway.log
stderr_logfile=/var/log/hermes-gateway.err
EOF
  supervisorctl reread; supervisorctl update; supervisorctl start hermes-gateway 2>/dev/null || true
}

# =============================================================================
stage_verify() {
  say "STAGE verify: doctor score + live smoke, gated"
  # The old verify ran `gbrain query | head -3` with `|| echo not ready`. An exit
  # code is not proof and a returned count is not data. It passed every day the
  # fleet was producing zero takes. This one gates the install.
  echo "supervisor:"; supervisorctl status 2>/dev/null || true
  echo "postgres:"; sudo -u postgres psql -d brain -tAc "SELECT count(*) FROM pg_extension WHERE extname='vector';" 2>/dev/null

  export GBRAIN_HOME="$BRAIN"
  set -a; [ -f "$BRAIN/.env" ] && . "$BRAIN/.env"; set +a
  export GBRAIN_HOME="$BRAIN"

  if ! have gbrain; then fail_stage "gbrain not installed"; return 1; fi

  # 1. version floor
  local V; V="$(gbrain --version 2>/dev/null | awk '{print $NF}')"
  if [ -z "$V" ] || ! version_ge "$V" "$GBRAIN_MIN_VERSION"; then
    fail_stage "gbrain ${V:-missing} below floor $GBRAIN_MIN_VERSION"
  else
    echo "verify: gbrain $V (floor $GBRAIN_MIN_VERSION, ok)"
  fi

  # 2. doctor, with the SCORE captured. Threshold is a warn, not a pass: doctor
  #    can be green while a model id is subtly wrong, which is why step 4 exists.
  local SCORE
  SCORE="$(gbrain doctor 2>&1 | tee /tmp/doctor-verify.log | sed -n 's/^Overall health score: \([0-9][0-9]*\)\/100.*/\1/p' | tail -1)"
  tail -25 /tmp/doctor-verify.log
  local MIN_SCORE="${GBRAIN_MIN_DOCTOR_SCORE:-80}"
  if [ -z "$SCORE" ]; then
    fail_stage "gbrain doctor produced no score (it did not run)"
  elif [ "$SCORE" -lt "$MIN_SCORE" ]; then
    fail_stage "gbrain doctor $SCORE/100 is below the $MIN_SCORE gate"
  else
    echo "verify: doctor $SCORE/100"
  fi

  # 3. the model keys that decide whether extraction runs at all
  for k in models.chat models.tier.reasoning models.dream.extract_atoms; do
    local kv; kv="$(gbrain config get "$k" 2>/dev/null | tail -1)"
    case "$kv" in
      *openrouter:*) echo "verify: $k = $kv" ;;
      *) fail_stage "$k is '${kv:-unset}', expected an openrouter model" ;;
    esac
  done

  # 4. LIVE SMOKE: page in, extraction, takes count GREW. This is the only check
  #    that would have caught the zero-takes failure.
  if [ -x /root/.hermes/scripts/gbrain-smoke.sh ]; then
    bash /root/.hermes/scripts/gbrain-smoke.sh || fail_stage "live smoke test (page -> extract -> takes did not grow)"
  else
    fail_stage "gbrain-smoke.sh not deployed (run stage_cron)"
  fi

  # 5. the brain MCP actually answers on the wired url
  local GB_PORT="${GBRAIN_HTTP_PORT:-3131}"
  if curl -fsS --max-time 15 -o /dev/null \
       -H "Authorization: Bearer ${GBRAIN_MCP_TOKEN:-${GBRAIN_ADMIN_BOOTSTRAP_TOKEN:-}}" \
       "http://127.0.0.1:${GB_PORT}/mcp" 2>/dev/null; then
    echo "verify: gbrain MCP endpoint answering on :${GB_PORT}"
  else
    # A bare GET on /mcp is not a full handshake, so a non-2xx here is only a
    # signal. What matters is that the port is listening and the process is up.
    supervisorctl status gbrain-http 2>/dev/null | grep -q RUNNING \
      && echo "verify: gbrain-http RUNNING (endpoint did not answer a bare GET, which is expected for MCP)" \
      || fail_stage "gbrain-http is not running; Hermes will bind zero brain tools"
  fi

  # 6. integrations plane: our routines now write heartbeats, so this should show
  #    real state instead of AVAILABLE across the board.
  gbrain integrations doctor 2>&1 | tail -20 || echo "NOTE: gbrain integrations doctor unavailable on this build"

  # Stage 5 report: health checks + seed first task + Slack note + portal tile.
  if [ -f "$REPO/orgo/report-readiness.py" ]; then
    CLIENT_SLUG="$CLIENT_SLUG" python3 "$REPO/orgo/report-readiness.py" --no-seed || echo "NOTE: report-readiness (seed/slack/portal env on first run)"
  fi
  echo "READINESS: brain extension present, supervisor programs up, SOUL deployed, skills profile applied."
}

# =============================================================================
stage_onboard() {
  say "STAGE onboard: wire connect MCP + start agent-driven onboarding"
  [ -d "$REPO/orgo/onboarding/composio-connect-mcp" ] || { echo "SKIP: onboarding kit not in repo"; return 0; }
  # Install the connect MCP deps into the HERMES venv (where the MCP runs), not
  # system pip: debian's typing_extensions blocks 'mcp' system-wide, and the venv
  # is uv-managed with no pip module (both validated live 2026-07-10). uv lives
  # at /root/.local/bin after setup-hermes.sh.
  if PATH=/root/.local/bin:$PATH command -v uv >/dev/null 2>&1 && [ -x /opt/hermes/venv/bin/python3 ]; then
    PATH=/root/.local/bin:$PATH uv pip install --python /opt/hermes/venv/bin/python3 -q \
      -r "$REPO/orgo/onboarding/composio-connect-mcp/requirements.txt" \
      || echo "VERIFY: composio-connect-mcp deps into the hermes venv (uv)"
  else
    pip3 install --break-system-packages -r "$REPO/orgo/onboarding/composio-connect-mcp/requirements.txt" 2>/dev/null \
      || echo "VERIFY: composio-connect-mcp deps (mcp, composio)"
  fi
  echo "NOTE: wire the composio-connect MCP into the default profile per $REPO/orgo/onboarding/composio-connect-mcp/README.md (mcp_servers: composio-connect)."
  # Kickoff is fired by the orchestrator (Package A) once the box is confirmed green,
  # so it does not run as part of a bare install. Run manually with:
  echo "NOTE: start onboarding with: bash $REPO/orgo/onboarding/onboarding-kickoff.sh"
}

# =============================================================================
stage_portal() {
  say "STAGE portal: native per-box client portal (Next.js + this box's Postgres)"
  if [ -z "${GITHUB_TOKEN:-}" ]; then echo "SKIP: GITHUB_TOKEN needed to clone the portal repo"; return 0; fi
  export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.bun/bin
  have node || { echo "SKIP: node not installed (stage_base installs node 20)"; return 0; }

  # 1. source. Clone or fast-forward the requested branch. Token stays in the remote
  #    (this box's own deploy token) so fleet-updater can pull later.
  if [ -d "$PORTAL/.git" ]; then
    ( cd "$PORTAL" && git fetch --depth 1 origin "$PORTAL_REF" && git reset --hard FETCH_HEAD )
  else
    git clone --depth 1 -b "$PORTAL_REF" \
      "https://x-access-token:${GITHUB_TOKEN}@github.com/togorashi45/rereset-portal.git" "$PORTAL"
  fi
  [ -f "$PORTAL/package.json" ] || { echo "SKIP: portal clone failed"; return 0; }

  # 2. Postgres: a non-superuser portal role + its own DB on the supervised cluster
  #    (separate from the brain DB). pg_hba already allows 127.0.0.1 scram.
  local PPW; PPW="$(gen 16)"
  sudo -u postgres psql -c "ALTER ROLE portal LOGIN PASSWORD '$PPW'" 2>/dev/null \
    || sudo -u postgres psql -c "CREATE ROLE portal LOGIN PASSWORD '$PPW'"
  sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='rereset_portal'" | grep -q 1 \
    || sudo -u postgres psql -c "CREATE DATABASE rereset_portal OWNER portal"
  sudo -u postgres psql -d rereset_portal -f "$PORTAL/db/portal-schema.sql" >/dev/null 2>&1 || echo "VERIFY: portal schema apply"
  # Numbered migrations: the portal has no auto-runner, and every box cutover on
  # 2026-07-14 needed 008/009/010 applied by hand. Track applied files in a
  # ledger table so re-runs are cheap and ordered.
  sudo -u postgres psql -d rereset_portal -c \
    "CREATE TABLE IF NOT EXISTS _migrations (filename text PRIMARY KEY, applied_at timestamptz DEFAULT now())" >/dev/null 2>&1
  for MIG in "$PORTAL"/db/migrations/*.sql; do
    [ -e "$MIG" ] || continue
    MB=$(basename "$MIG")
    if ! sudo -u postgres psql -d rereset_portal -tAc "SELECT 1 FROM _migrations WHERE filename='$MB'" | grep -q 1; then
      if sudo -u postgres psql -d rereset_portal -v ON_ERROR_STOP=1 -f "$MIG" >/dev/null 2>&1; then
        sudo -u postgres psql -d rereset_portal -c "INSERT INTO _migrations (filename) VALUES ('$MB') ON CONFLICT DO NOTHING" >/dev/null 2>&1
        echo "migration applied: $MB"
      else
        echo "VERIFY: migration $MB failed (may predate the ledger; inspect + insert into _migrations manually if already applied)"
      fi
    fi
  done
  sudo -u postgres psql -d rereset_portal -c \
    "GRANT ALL ON SCHEMA public TO portal; GRANT ALL ON ALL TABLES IN SCHEMA public TO portal; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO portal;" >/dev/null 2>&1
  # Future migrations run as postgres; without default privileges every new
  # table is invisible to the portal role (fleet-wide "permission denied for
  # table integration_connections", 2026-07-15).
  sudo -u postgres psql -d rereset_portal -c \
    "ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO portal; ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO portal;" >/dev/null 2>&1

  # 3. env. AUTH_SECRET persists a rebuild; secrets stay on the box, chmod 600.
  #    Inject AUTH_SECRET (+ AUTH_COOKIE_DOMAIN=.rereset.ai) to SHARE cross-subdomain SSO across
  #    the fleet; leave AUTH_SECRET blank to generate a per-box secret. Role decides the tenant
  #    scope: client = NEXT_PUBLIC_PORTAL_SLUG (one tenant); admin = unset (sees all) + ADMIN_ALLOWLIST.
  local SEC="${PORTAL_INGEST_SECRET:-$(gen 24)}"
  if [ ! -f "$PORTAL/.env.local" ] || ! grep -q '^AUTH_SECRET=' "$PORTAL/.env.local"; then
    cat >"$PORTAL/.env.local" <<EOF
DATABASE_URL=postgresql://portal:${PPW}@127.0.0.1:5432/rereset_portal
INGEST_SECRET=${SEC}
AUTH_SECRET=${AUTH_SECRET:-$(gen 32)}
AUTH_GOOGLE_ID=${AUTH_GOOGLE_ID}
AUTH_GOOGLE_SECRET=${AUTH_GOOGLE_SECRET}
AUTH_URL=https://${PORTAL_DOMAIN}
NEXTAUTH_URL=https://${PORTAL_DOMAIN}
AUTH_TRUST_HOST=true
PORTAL_ALLOWLIST=${PORTAL_ALLOWLIST}
PORT=${PORTAL_PORT}
NODE_ENV=production
EOF
    [ -n "${AUTH_COOKIE_DOMAIN}" ] && echo "AUTH_COOKIE_DOMAIN=${AUTH_COOKIE_DOMAIN}" >> "$PORTAL/.env.local"
    if [ "${PORTAL_ROLE}" = "admin" ]; then
      echo "ADMIN_ALLOWLIST=${ADMIN_ALLOWLIST}" >> "$PORTAL/.env.local"
    else
      echo "NEXT_PUBLIC_PORTAL_SLUG=${PORTAL_SLUG}" >> "$PORTAL/.env.local"
    fi
    chmod 600 "$PORTAL/.env.local"
  else
    # keep the generated db password in sync with the role we just (re)set
    sed -i "s#^DATABASE_URL=.*#DATABASE_URL=postgresql://portal:${PPW}@127.0.0.1:5432/rereset_portal#" "$PORTAL/.env.local"
    if [ "${PORTAL_ROLE}" = "admin" ]; then
      grep -q '^ADMIN_ALLOWLIST=' "$PORTAL/.env.local" || echo "ADMIN_ALLOWLIST=${ADMIN_ALLOWLIST}" >> "$PORTAL/.env.local"
      sed -i '/^NEXT_PUBLIC_PORTAL_SLUG=/d' "$PORTAL/.env.local"   # admin sees all tenants: never scope-filter
    else
      grep -q '^NEXT_PUBLIC_PORTAL_SLUG=' "$PORTAL/.env.local" \
        || echo "NEXT_PUBLIC_PORTAL_SLUG=${PORTAL_SLUG}" >> "$PORTAL/.env.local"
    fi
  fi

  # 3b. HARDENING (client boxes only): never ship the /me + /admin command center onto a
  # client's box (security audit 2026-06-24, finding T-2). The admin instance
  # (PORTAL_ROLE=admin, me.rereset.ai) KEEPS them. clients.ts is runtime-scoped to
  # NEXT_PUBLIC_PORTAL_SLUG, so dropping these trees removes the admin surface at rest.
  if [ "${PORTAL_ROLE}" != "admin" ] && [ -n "${PORTAL_SLUG}" ]; then
    rm -rf "$PORTAL/src/app/me" "$PORTAL/src/app/admin"
  fi

  # 4. build
  ( cd "$PORTAL" && npm ci && npm run build ) || { echo "VERIFY: portal build failed"; return 0; }

  # 5. service. Run the next binary DIRECTLY (not via npm) with kill/stopasgroup, else
  #    npm fails to forward SIGTERM and the old server orphans the port on restart.
  cat >/etc/supervisor/conf.d/portal-app.conf <<EOF
[program:portal-app]
command=$(command -v node) ${PORTAL}/node_modules/next/dist/bin/next start -p ${PORTAL_PORT} -H 127.0.0.1
directory=${PORTAL}
autostart=true
autorestart=true
startsecs=8
stopwaitsecs=20
stopasgroup=true
killasgroup=true
stdout_logfile=/var/log/portal-app.log
stderr_logfile=/var/log/portal-app.log
environment=PATH="$(dirname "$(command -v node)"):/usr/bin:/bin",NODE_ENV="production"
EOF

  # 6. hourly Zoom -> brain ingestion (no-ops until the client connects Zoom).
  cat >/etc/supervisor/conf.d/portal-zoom-ingest.conf <<EOF
[program:portal-zoom-ingest]
command=/bin/bash -lc 'cd ${PORTAL}; set -a; . ${PORTAL}/.env.local; set +a; while true; do $(command -v node) ${PORTAL}/scripts/box-zoom/zoom-ingest.mjs; sleep 3600; done'
autostart=true
autorestart=true
stdout_logfile=/var/log/portal-zoom-ingest.log
stderr_logfile=/var/log/portal-zoom-ingest.log
EOF

  # 7. brief writer. The canonical portal_brief.py (native ingest + rich emails/
  #    events + the Composio 413 metadata-only fix) ships in the portal repo. Deploy
  #    it and supervise it pointed at THIS box's portal, so a fresh box gets a brief.
  install -D -m 644 "$PORTAL/scripts/box-brief/portal_brief.py" /root/.hermes/scripts/portal_brief.py
  if [ -f /etc/supervisor/conf.d/portal-brief.conf ]; then
    # an existing writer (older Convex-era box): just retarget it at the local portal
    grep -q PORTAL_NATIVE_URL /etc/supervisor/conf.d/portal-brief.conf \
      || sed -i "/^environment=/ s#\$#,PORTAL_NATIVE_URL=\"http://127.0.0.1:${PORTAL_PORT}\"#" /etc/supervisor/conf.d/portal-brief.conf
  else
    cat >/etc/supervisor/conf.d/portal-brief.conf <<EOF
[program:portal-brief]
command=/usr/bin/python3 /root/.hermes/scripts/portal_brief.py
autostart=true
autorestart=true
stdout_logfile=/var/log/portal-brief.log
stderr_logfile=/var/log/portal-brief.log
environment=PORTAL_SECRET="${SEC}",CLIENT_SLUG="${PORTAL_SLUG}",PORTAL_NATIVE_URL="http://127.0.0.1:${PORTAL_PORT}"
EOF
  fi

  # 7b. task board: mirror the client's SafeClaw board (tasks.db) -> this box's
  #     Postgres tasks (what /api/c/tasks reads). Canonical script ships in the
  #     portal repo; supervise it as portal-tasks-sync.
  if [ -f "$PORTAL/scripts/box-tasks-sync/portal_tasks_sync.py" ]; then
    install -D -m 755 "$PORTAL/scripts/box-tasks-sync/portal_tasks_sync.py" /root/.hermes/scripts/portal_tasks_sync.py
    cat >/etc/supervisor/conf.d/portal-tasks-sync.conf <<EOF
[program:portal-tasks-sync]
command=/usr/bin/python3 /root/.hermes/scripts/portal_tasks_sync.py
autostart=true
autorestart=true
stdout_logfile=/var/log/portal-tasks-sync.log
stderr_logfile=/var/log/portal-tasks-sync.log
environment=PORTAL_ENV="${PORTAL}/.env.local",TASKS_DB="/opt/safeclaw/data/tasks.db"
EOF
  fi

  # 8. edge: add the portal hostname to the cloudflared tunnel (before the 404 catch).
  #    The DNS CNAME (PORTAL_DOMAIN -> <tunnel>.cfargotunnel.com) is created off-box.
  local CFG=/root/.cloudflared/config.yml
  if [ -f "$CFG" ] && ! grep -q "$PORTAL_DOMAIN" "$CFG"; then
    python3 - "$CFG" "$PORTAL_DOMAIN" "$PORTAL_PORT" <<'PY'
import sys
cfg, host, port = sys.argv[1], sys.argv[2], sys.argv[3]
lines = open(cfg).read().splitlines(); out = []
for l in lines:
    if l.strip() == "- service: http_status:404":
        out += [f"  - hostname: {host}", f"    service: http://localhost:{port}"]
    out.append(l)
open(cfg, "w").write("\n".join(out) + "\n")
PY
    pkill -f "cloudflared tunnel" 2>/dev/null || true   # autorestarts with the new ingress
  fi

  supervisorctl reread; supervisorctl update
  supervisorctl restart portal-app portal-zoom-ingest 2>/dev/null || true
  supervisorctl restart portal-brief 2>/dev/null || true
  supervisorctl restart portal-tasks-sync 2>/dev/null || true
  echo "portal: built + supervised on :${PORTAL_PORT}; public at https://${PORTAL_DOMAIN} (needs the CF CNAME + Google redirect URI /api/auth/callback/google)."
}

stage_connect() {
  # LEGACY OPT-IN: superseded by the portal's Connections tab (Sten Composio
  # wrapper lifted into rereset-portal). Not in the default ALL run; invoke
  # explicitly (`install-box.sh connect`) only if a box needs the standalone
  # page while the portal tab is being validated.
  say "STAGE connect: on-box Composio connect page (safeclaw-ui, legacy opt-in)"
  [ -d "$REPO/safeclaw-ui" ] || { echo "SKIP: safeclaw-ui not in repo"; return 0; }
  pip3 install --break-system-packages -q flask requests pyyaml 2>/dev/null \
    || echo "VERIFY: pip flask/requests/pyyaml for safeclaw-ui"
  # Per-client service map (auth_config_id / user_id / alias). Built off-box by
  # orgo/composio-setup-authconfigs.sh; injected via CONNECT_SERVICES_JSON. Otherwise
  # seed from the example with the slug filled (auth_config_id left to fill).
  local SVC=/opt/safeclaw/composio-services.json
  mkdir -p /opt/safeclaw
  if [ ! -f "$SVC" ]; then
    if [ -n "${CONNECT_SERVICES_JSON:-}" ] && [ -f "${CONNECT_SERVICES_JSON}" ]; then
      install -m 644 "$CONNECT_SERVICES_JSON" "$SVC"
    else
      sed "s/<slug>/${PORTAL_SLUG}/g" "$REPO/safeclaw-ui/composio-services.example.json" > "$SVC"
      echo "VERIFY: $SVC has ac_REPLACE placeholders - run orgo/composio-setup-authconfigs.sh for ${PORTAL_SLUG} and fill auth_config_id per service (or set CONNECT_SERVICES_JSON)."
    fi
  fi
  # Supervised connect service (loopback). COMPOSIO_API_KEY is sourced from
  # /opt/brain/.env (persisted by stage_composio_project).
  cat >/etc/supervisor/conf.d/safeclaw-connect.conf <<EOF
[program:safeclaw-connect]
command=/bin/bash -lc 'set -a; [ -f ${BRAIN}/.env ] && . ${BRAIN}/.env; [ -f /root/.hermes/.env ] && . /root/.hermes/.env; set +a; HERMES_HOME=/root/.hermes COMPOSIO_SERVICES_FILE=${SVC} HOST=127.0.0.1 PORT=${CONNECT_PORT} /usr/bin/python3 ${REPO}/safeclaw-ui/app.py'
autostart=true
autorestart=true
startsecs=5
stdout_logfile=/var/log/safeclaw-connect.log
stderr_logfile=/var/log/safeclaw-connect.log
EOF
  # Edge: route the connect hostname through the cloudflared tunnel (before 404).
  local CFG=/root/.cloudflared/config.yml
  if [ -f "$CFG" ] && ! grep -q "$CONNECT_DOMAIN" "$CFG"; then
    python3 - "$CFG" "$CONNECT_DOMAIN" "$CONNECT_PORT" <<'PY'
import sys
cfg, host, port = sys.argv[1], sys.argv[2], sys.argv[3]
lines = open(cfg).read().splitlines(); out = []
for l in lines:
    if l.strip() == "- service: http_status:404":
        out += [f"  - hostname: {host}", f"    service: http://localhost:{port}"]
    out.append(l)
open(cfg, "w").write("\n".join(out) + "\n")
PY
    pkill -f "cloudflared tunnel" 2>/dev/null || true   # autorestarts with the new ingress
  fi
  supervisorctl reread; supervisorctl update
  supervisorctl restart safeclaw-connect 2>/dev/null || supervisorctl start safeclaw-connect 2>/dev/null || true
  echo "connect: safeclaw-ui supervised on :${CONNECT_PORT}; public at https://${CONNECT_DOMAIN}/connect-accounts (needs the CF CNAME + a filled composio-services.json)."
}

stage_health() {
  say "STAGE health: box-health writer for the portal BrainStatus badge"
  [ -f "$REPO/scripts/box/write_brain_health.py" ] || { echo "SKIP: write_brain_health.py not in repo"; return 0; }
  install -D -m 755 "$REPO/scripts/box/write_brain_health.py" /root/.hermes/scripts/write_brain_health.py
  # Supervised loop (these boxes run supervisor, not cron). Fails open in the
  # portal, so a hiccup never shows a healthy box as offline.
  cat >/etc/supervisor/conf.d/brain-health.conf <<'EOF'
[program:brain-health]
command=/bin/bash -c 'while true; do /usr/bin/python3 /root/.hermes/scripts/write_brain_health.py >/dev/null 2>&1; sleep 120; done'
autostart=true
autorestart=true
startsecs=3
stdout_logfile=/root/.hermes/logs/brain-health.log
stderr_logfile=/root/.hermes/logs/brain-health.log
EOF
  supervisorctl reread; supervisorctl update
  supervisorctl restart brain-health 2>/dev/null || supervisorctl start brain-health 2>/dev/null || true
  echo "health: brain-health supervised (writes /opt/rereset-portal/.brain-health.json every 120s)."
}

# ---- driver ----------------------------------------------------------------
# `connect` (standalone safeclaw-ui page) is deliberately NOT in ALL: the portal's
# Connections tab is the client-facing connect surface now. Run it explicitly if needed.
ALL=(base harden_boot brain_db backup composio_project repo runtime brain_init hermes_config composio_mcp identity skills channels email cron onboard gateway portal health verify)
TARGETS=("$@"); [ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")

# --verify / verify: doctor plus the live smoke, nothing else. Mirrors the
# product's `vm-hermes-setup.sh --verify`. Use it to check a box without
# reprovisioning it.
if [ "${TARGETS[0]}" = "--verify" ]; then TARGETS=(verify); fi

for t in "${TARGETS[@]}"; do
  if ! declare -F "stage_${t}" >/dev/null; then
    echo "FAIL: no such stage: $t"; STAGE_FAILED=$((STAGE_FAILED + 1))
    STAGE_RESULTS="${STAGE_RESULTS}\n  UNKNOWN  ${t}"
    continue
  fi
  BEFORE_FAILED=$STAGE_FAILED
  "stage_${t}"
  if [ "$STAGE_FAILED" -gt "$BEFORE_FAILED" ]; then
    STAGE_RESULTS="${STAGE_RESULTS}\n  FAIL     ${t}  ($((STAGE_FAILED - BEFORE_FAILED)) failure(s))"
  else
    STAGE_RESULTS="${STAGE_RESULTS}\n  ok       ${t}"
  fi
done

echo
echo "---- stage tally ----"
printf '%b\n' "$STAGE_RESULTS"
if [ "$STAGE_FAILED" -ne 0 ]; then
  echo "================ install-box FAILED $(date -u) ================"
  echo "One or more stages failed. This box is NOT ready. See the FAIL lines above."
  exit 1
fi
echo "================ install-box done $(date -u) ================"
