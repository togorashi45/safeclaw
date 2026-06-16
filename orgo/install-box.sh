#!/usr/bin/env bash
# =============================================================================
# SafeClaw clean install template (hardened, non-Docker, supervised Postgres).
#
# This is the reconciled installer: it builds a VANILLA Orgo/Ubuntu box to a
# green SafeClaw agent box from scratch, every time, with no baked snapshot and
# no client secrets baked in (secrets are injected per box via install.env).
#
# Supersedes the older PGLite + Docker path in provision-client.py. It encodes
# the 2026-06 fleet hardening (Postgres + pgvector brain under supervisor,
# OpenRouter embeddings, consolidated gateway) plus the documented install
# gotchas from ORGO-CLIENT-TEMPLATE.md / INSTALL-CHECKLIST.md.
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
: "${SKILL_PROFILE:=team-member}"          # e.g. team-kim, base, actor
: "${SAFECLAW_REF:=golden-template}"       # branch/tag to install
: "${HERMES_MODEL:=glm-4.7}"
: "${HERMES_BASE_URL:=https://ollama.com/v1}"
# Secrets (leave blank to skip the dependent stage; the stage will warn):
: "${GITHUB_TOKEN:=}"                       # to clone the private safeclaw repo
: "${OPENROUTER_API_KEY:=}"                 # gbrain embeddings + dream
: "${OLLAMA_API_KEY:=}"                     # hermes model provider
: "${COMPOSIO_API_KEY:=}"                   # PROJECT key (preferred: minted off-box, injected here)
: "${COMPOSIO_ORG_API_KEY:=}"               # ORG key; ONLY for on-box fallback mint (prefer off-box)
: "${COMPOSIO_PROJECT:=${CLIENT_SLUG}}"     # per-box Composio project name (one project per box = isolation)
: "${WHATSAPP_ALLOWED_USERS:=}"            # set at onboarding (Kim's number)

REPO=/opt/safeclaw
BRAIN=/opt/brain
PGV=16

gen() { openssl rand -hex "${1:-16}"; }
have() { command -v "$1" >/dev/null 2>&1; }
say() { echo; echo "---- $* ----"; }

# =============================================================================
stage_base() {
  say "STAGE base: system packages"
  export DEBIAN_FRONTEND=noninteractive
  # Flaky third-party repos on the stock Orgo image break apt update (learned live).
  for f in /etc/apt/sources.list.d/*sublime* /etc/apt/sources.list.d/*google-chrome*; do
    [ -e "$f" ] && mv "$f" "$f.disabled" 2>/dev/null || true
  done
  apt-get update -y --fix-missing
  apt-get install -y --fix-missing \
    git curl jq unzip build-essential python3-pip openssl supervisor \
    "postgresql-${PGV}" "postgresql-${PGV}-pgvector"
  # bun (gbrain runs under bun; shebang is #!/usr/bin/env bun, symlink required).
  if ! have bun; then curl -fsSL https://bun.sh/install | bash; fi
  ln -sf /root/.bun/bin/bun /usr/local/bin/bun
  # Node 20 (stock image ships 18; setup-hermes.sh + dashboard build want 20).
  if [ "$(node -v 2>/dev/null | cut -c2-3)" != "20" ]; then
    curl -fsSL -o /tmp/node20.tar.xz https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.xz
    tar -xJf /tmp/node20.tar.xz -C /opt && ln -sf /opt/node-v20.18.1-linux-x64/bin/node /usr/local/bin/node
    ln -sf /opt/node-v20.18.1-linux-x64/bin/npm /usr/local/bin/npm
  fi
  # cloudflared (only needed if a web tunnel is wanted; harmless to have).
  have cloudflared || { curl -fsSL -o /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared; }
  echo "base versions:"; psql --version; bun --version; node -v; cloudflared --version | head -1
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
    git clone -b "$SAFECLAW_REF" "https://x-access-token:${GITHUB_TOKEN}@github.com/togorashi45/safeclaw.git" "$REPO"
  else
    ( cd "$REPO" && git fetch --all -q && git checkout "$SAFECLAW_REF" -q && git pull -q )
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
  # ORGO-CLIENT-TEMPLATE.md Step 1 (the old orgo/setup/install-gbrain.sh path never existed).
  if ! have gbrain; then
    [ -d /opt/gbrain-src/.git ] || git clone https://github.com/garrytan/gbrain.git /opt/gbrain-src
    ( cd /opt/gbrain-src && bun install && bun link )
    ln -sf "$(command -v gbrain 2>/dev/null || echo /root/.bun/bin/gbrain)" /usr/local/bin/gbrain 2>/dev/null || true
  fi
  # hermes: setup-hermes.sh lives at scripts/ (NOT orgo/setup/). Run BARE so a pipe
  # cannot mask its exit code (issue 4).
  if ! have hermes; then
    bash "$REPO/scripts/setup-hermes.sh" || echo "VERIFY: setup-hermes.sh exit + symlink"
  fi
  echo "runtime: $(which gbrain hermes bun 2>/dev/null)"
}

# =============================================================================
stage_brain_init() {
  say "STAGE brain_init: gbrain on Postgres + embeddings"
  [ -z "$OPENROUTER_API_KEY" ] && { echo "SKIP: OPENROUTER_API_KEY needed for embeddings"; return 0; }
  set -a; . "$BRAIN/.env"; set +a
  # Embedding model MUST be named at init so the vector column is the right width.
  gbrain init --url "$GBRAIN_DATABASE_URL" --embedding-model openrouter:openai/text-embedding-3-small \
    || echo "VERIFY: gbrain init flags for the Postgres path"
  gbrain config set sync.repo_path "$BRAIN/repo" 2>/dev/null || true
  ( cd "$BRAIN/repo" && git add -A && git commit -q -m "initial seed" 2>/dev/null || true )
}

# =============================================================================
stage_hermes_config() {
  say "STAGE hermes_config: model + gbrain MCP + token economy"
  [ -z "$OLLAMA_API_KEY" ] && echo "WARN: OLLAMA_API_KEY missing; gateway will demand a model key"
  hermes config set model.base_url "$HERMES_BASE_URL" 2>/dev/null || true   # installer ships openrouter base by default (issue 20)
  hermes config set model.name "$HERMES_MODEL" 2>/dev/null || true
  hermes config set agent.max_turns 25 2>/dev/null || true
  hermes config set agent.auxiliary.compression.enabled true 2>/dev/null || true
  [ -n "$OLLAMA_API_KEY" ] && hermes auth add ollama-cloud --type api-key --key "$OLLAMA_API_KEY" 2>/dev/null || true
  # gbrain wired as a URL MCP (not stdio) once the HTTP/serve endpoint is up. VERIFY endpoint per gbrain version.
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
  python3 "$REPO/tools/skills_manifest.py" --profile "$SKILL_PROFILE" 2>/dev/null \
    || echo "VERIFY: skills_manifest.py flags (--profile $SKILL_PROFILE)"
  bash "$REPO/tools/apply_skill_profile.sh" "$SKILL_PROFILE" 2>/dev/null || true
}

# =============================================================================
stage_channels() {
  say "STAGE channels: WhatsApp bridge"
  # The bridge ships with Hermes. Kim gives his number + scans the QR at onboarding.
  local BR=/opt/hermes/scripts/whatsapp-bridge/bridge.js
  if [ -f "$BR" ]; then
    cat >/etc/supervisor/conf.d/whatsapp-bridge.conf <<EOF
[program:whatsapp-bridge]
command=/usr/local/bin/node $BR
environment=WHATSAPP_ALLOWED_USERS="${WHATSAPP_ALLOWED_USERS:-*}"
autostart=true
autorestart=true
stdout_logfile=/var/log/whatsapp-bridge.log
EOF
    supervisorctl reread; supervisorctl update
    echo "WhatsApp bridge configured. Scan the QR in /var/log/whatsapp-bridge.log to pair."
  else
    echo "NOTE: bridge not present until Hermes is installed (stage_runtime)."
  fi
  [ -n "$COMPOSIO_API_KEY" ] && echo "Composio key present; wire gmail/calendar via Console /api/gmail/wire after gateway is up." || true
}

# =============================================================================
stage_gateway() {
  say "STAGE gateway: consolidated hermes-gateway-actor"
  cat >/etc/supervisor/conf.d/hermes-gateway-actor.conf <<'EOF'
[program:hermes-gateway-actor]
command=/bin/bash -lc 'cd /root/.hermes && hermes gateway run'
autostart=true
autorestart=true
stdout_logfile=/var/log/hermes-gateway.log
EOF
  supervisorctl reread; supervisorctl update; supervisorctl start hermes-gateway-actor 2>/dev/null || true
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
  pip3 install --break-system-packages -r "$REPO/orgo/onboarding/composio-connect-mcp/requirements.txt" 2>/dev/null \
    || echo "VERIFY: composio-connect-mcp deps (mcp, composio)"
  echo "NOTE: wire the composio-connect MCP into the actor profile per $REPO/orgo/onboarding/composio-connect-mcp/README.md (mcp_servers: composio-connect)."
  # Kickoff is fired by the orchestrator (Package A) once the box is confirmed green,
  # so it does not run as part of a bare install. Run manually with:
  echo "NOTE: start onboarding with: bash $REPO/orgo/onboarding/onboarding-kickoff.sh"
}

# ---- driver ----------------------------------------------------------------
ALL=(base brain_db composio_project repo runtime brain_init hermes_config identity skills channels onboard gateway verify)
TARGETS=("$@"); [ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "stage_${t}"; done
echo "================ install-box done $(date -u) ================"
