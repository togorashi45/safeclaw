# composio-connect MCP

A stdio MCP the box's Hermes actor uses during onboarding to send OAuth connect
links and confirm connections, using the per-box Composio PROJECT key. The org
key never touches the box.

## Wire into the actor profile
Add to the actor Hermes config (`config/actor-hermes.yaml` / on-box
`/root/.hermes/profiles/actor/config.yaml`) alongside gbrain:

```yaml
mcp_servers:
  composio-connect:
    command: /usr/bin/python3
    args: ["/opt/safeclaw/orgo/onboarding/composio-connect-mcp/server.py"]
    env:
      COMPOSIO_API_KEY: "${COMPOSIO_API_KEY}"
      COMPOSIO_USER_ID: "${COMPOSIO_USER_ID}"
      COMPOSIO_AUTHCFG_GMAIL: "${COMPOSIO_AUTHCFG_GMAIL}"
      COMPOSIO_AUTHCFG_GOOGLECALENDAR: "${COMPOSIO_AUTHCFG_GOOGLECALENDAR}"
      COMPOSIO_AUTHCFG_GOOGLEDRIVE: "${COMPOSIO_AUTHCFG_GOOGLEDRIVE}"
      COMPOSIO_AUTHCFG_SLACK: "${COMPOSIO_AUTHCFG_SLACK}"
```

## Env (set by the installer / composio-setup-authconfigs.sh)
- `COMPOSIO_API_KEY`   per-box project key (x-api-key)
- `COMPOSIO_USER_ID`   the principal's user id in this project (e.g. `kim`)
- `COMPOSIO_AUTHCFG_<TOOLKIT>`   auth_config_id per toolkit

## Tools
- `connect_link(toolkit)` returns a hosted OAuth URL to send.
- `connection_status(toolkit)` returns ACTIVE | pending | none.

## Install deps
`pip3 install --break-system-packages -r requirements.txt`

VERIFY on first live run: confirm the installed `composio` SDK exposes
`connected_accounts.link(user_id, auth_config_id)` and `.list(user_ids=[...])`,
and the redirect-url attribute name. The server falls back to a clear tool error
rather than guessing.
