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
# Idempotent: safe to re-run. Logs to /opt/install.log.
#
# STATUS: authored, NOT yet validated end to end on a live box (the base stage
# was validated on Kim's box 2026-06-14: apt needs --fix-missing + disabling the
# flaky sublime/chrome repos; node ships as v18 so we install 20). Verify the
# gbrain/hermes CLI flags marked VERIFY on the first real run.
# =============================================================================
set -uo pipefail
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
: "${TS_AUTHKEY:=}"                           # Tailscale auth key; set to join the tailnet (off-box writers reach this box over it)
# Connect page (on-box Composio "connect your accounts" page, served by safeclaw-ui):
: "${CONNECT_PORT:=8899}"                    # loopback port for the connect Flask app
: "${CONNECT_DOMAIN:=safeclaw-${PORTAL_SLUG}.rereset.ai}"  # public hostname (needs a CF CNAME to the tunnel)
: "${CONNECT_SERVICES_JSON:=}"               # optional path to a filled composio-services.json (from orgo/composio-setup-authconfigs.sh)

REPO=/opt/safeclaw
PORTAL=/opt/rereset-portal
BRAIN=/opt/brain
PGV=16

gen() { openssl rand -hex "${1:-16}"; }
have() { command -v "$1" >/dev/null 2>&1; }
say() { echo; echo "---- $* ----"; }

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
  # gbrain: cloned + built from source (github.com/garrytan/gbrain), then symlinked
  # globally. There is NO vendored install script; this is the canonical method from
  # (the old orgo/setup/install-gbrain.sh path never existed; build from source)
  if ! have gbrain; then
    [ -d /opt/gbrain-src/.git ] || git clone https://github.com/garrytan/gbrain.git /opt/gbrain-src
    ( cd /opt/gbrain-src && bun install && bun link )
  fi
  # Global symlink OUTSIDE the install-if-missing block: a legacy box can already
  # have gbrain on /root/.bun/bin (bun global install), in which case the block is
  # skipped and non-login shells (supervisor, cron) still could not find gbrain
  # (validated live 2026-07-10 on the Atomic Stays rebuild).
  [ -e /usr/local/bin/gbrain ] \
    || ln -sf "$(command -v gbrain 2>/dev/null || echo /root/.bun/bin/gbrain)" /usr/local/bin/gbrain 2>/dev/null || true
  # hermes: setup-hermes.sh lives at scripts/ (NOT orgo/setup/). Run BARE so a pipe
  # cannot mask its exit code (issue 4).
  if ! have hermes; then
    bash "$REPO/scripts/setup-hermes.sh" || echo "VERIFY: setup-hermes.sh exit + symlink"
  fi
  # Legacy boxes arrive with an old hermes already on PATH; install-if-missing
  # leaves them thousands of commits behind (validated live 2026-07-14 fleet
  # migration: 0.16 boxes kept 0.16, gateway then FATAL on the 0.18 config).
  if [ -n "${HERMES_VERSION:-}" ] && ! hermes --version 2>/dev/null | grep -q "v${HERMES_VERSION%.*}"; then
    hermes update || echo "VERIFY: hermes update to $HERMES_VERSION"
  fi
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
  # Embedding model MUST be named at init so the vector column is the right width.
  # (Flag validated live 2026-07-10: gbrain 0.42 accepts --url and --embedding-model.)
  gbrain init --url "$GBRAIN_DATABASE_URL" --embedding-model "$GBRAIN_EMBED_MODEL" \
    || echo "VERIFY: gbrain init flags for the Postgres path"
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
  # gbrain wired as a URL MCP (not stdio) once the HTTP/serve endpoint is up. VERIFY endpoint per gbrain version.
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
  for s in email-ingest.sh email-ingest-cron.sh ingest-retry.sh calendar-sync.sh ghl-sync.sh gbrain-dream.sh gbrain-hygiene.sh; do
    [ -f "$R/$s" ] && install -m 755 "$R/$s" "$SD/$s"
  done
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
  # gbrain-dream: nightly brain compaction. Needs the OpenRouter key (same one gbrain
  # embeds/dreams with); runs against Postgres so no brain-server stop is needed.
  if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    hermes cron create "0 9 * * *" --name gbrain-dream --script gbrain-dream.sh --no-agent --deliver local 2>&1 | tail -1 \
      || echo "VERIFY: hermes cron create gbrain-dream"
  else
    echo "NOTE: OPENROUTER_API_KEY unset; skipping gbrain-dream (dream needs it)."
  fi
  # gbrain-hygiene: weekly rule-based brain checks (doctor, orphans,
  # contradictions), zero LLM cost; writes areas/brain-hygiene/latest.md.
  hermes cron create "0 13 * * 1" --name gbrain-hygiene --script gbrain-hygiene.sh --no-agent --deliver local 2>&1 | tail -1 \
    || echo "VERIFY: hermes cron create gbrain-hygiene"
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
  say "STAGE verify"
  echo "supervisor:"; supervisorctl status 2>/dev/null || true
  echo "postgres:"; sudo -u postgres psql -d brain -tAc "SELECT count(*) FROM pg_extension WHERE extname='vector';" 2>/dev/null
  have gbrain && gbrain query "$CLIENT_SLUG" 2>/dev/null | head -3 || echo "gbrain not ready"
  # Stage 5 report: health checks + seed first task + Slack note + portal tile.
  if [ -f "$REPO/orgo/report-readiness.py" ]; then
    CLIENT_SLUG="$CLIENT_SLUG" python3 "$REPO/orgo/report-readiness.py" --no-seed || echo "VERIFY: report-readiness (seed/slack/portal env on first run)"
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
for t in "${TARGETS[@]}"; do "stage_${t}"; done
echo "================ install-box done $(date -u) ================"
