---
name: agent-integrator
description: >-
  Integration strategy for AI agent capabilities — covering MCP server discovery, selection,
  configuration, secrets management, and multi-IDE installation. Use when: installing an MCP server,
  deciding how to connect an external system, evaluating MCP server candidates, choosing between
  off-the-shelf and custom MCP servers, managing secrets for MCP configurations, configuring MCP
  for VS Code Copilot, Claude Desktop, or Cursor, troubleshooting MCP connectivity issues,
  auditing installed MCP servers, or summarizing the current integration state.
argument-hint: Describe the system to integrate (e.g. "Google Drive", "Obsidian", "Jira") and the target IDE(s). Include any constraints on auth method, data sensitivity, or package preference.
---

# Agent Integrator

## When to Use

- Installing a new MCP server into Claude Desktop, VS Code Copilot, or Cursor
- Researching which MCP server to use for a given integration (e.g. Google Calendar, Slack, Notion)
- Evaluating multiple MCP candidates and selecting the best fit
- Managing secrets (API keys, OAuth tokens) for MCP server configurations
- Troubleshooting MCP connection failures, tool not appearing, or auth errors
- Auditing the current state of all configured MCP servers
- Deciding between an off-the-shelf MCP and building a custom one

---

## MCP Server Discovery Framework

When the user asks to "install X MCP" or "connect X to an agent", follow this decision order:

```
1. Does an official/first-party MCP exist for X?
   ├── Yes (Anthropic, vendor-published, or modelcontextprotocol monorepo) → prefer it
   └── No → continue

2. Does a well-maintained community MCP exist?
   ├── Search: npm search <service> mcp --json
   ├── Search: GitHub search: "<service> mcp server"
   ├── Evaluate quality (see §Candidate Evaluation below)
   └── If 2+ stars criteria met → use community; else → build custom

3. Build a custom MCP server
   └── When: high frequency use, sensitive data, auth reuse needed, complex response shaping
   └── See: agent-integrations skill for build guidance
```

### Candidate Evaluation Scorecard

Score each candidate MCP server on these criteria before selecting:

| Criterion | Points | What to Check |
|-----------|--------|--------------|
| **Official / vendor-published** | +3 | npm org matches vendor or `@modelcontextprotocol/` |
| **Active maintenance** | +2 | Last publish < 6 months ago; GitHub commits recent |
| **High adoption** | +2 | npm weekly downloads > 500 OR GitHub stars > 100 |
| **Typed responses** | +1 | TypeScript or Pydantic models, not raw dicts |
| **Minimal scopes** | +1 | Requests only required auth scopes |
| **Good documentation** | +1 | README covers auth setup, tool list, and examples |
| **MIT/Apache license** | +1 | Open source with permissive license |
| **No secrets in tool params** | +1 | Secrets come from env vars, not tool arguments |

**Decision threshold**:
- **8–11 pts** → use this server with confidence
- **5–7 pts** → use for prototyping; monitor; plan to build custom if usage grows
- **< 5 pts** → build custom or keep searching

### Useful Discovery Commands

```bash
# npm package search
npm search <service> mcp --json | python3 -c "
import json,sys
for p in json.load(sys.stdin)[:10]:
    print(f'{p[\"name\"]} | {p.get(\"description\",\"\")[:80]}')
"

# Verify a package exists and get metadata
npm view <package-name> version description repository keywords

# Check download stats
npm view <package-name> --json | python3 -c "import json,sys; p=json.load(sys.stdin); print(p.get('dist-tags'), p.get('repository'))"
```

---

## Secrets Management for MCP Servers

### Rule: Secrets go in `env`, not `args`

Claude Desktop and Cursor resolve `${ENV_VAR}` interpolation in the `env` block.
Never pass secrets as command-line arguments — they appear in process lists and logs.

```jsonc
// ✅ Correct — secrets in env block with variable interpolation
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"],
      "env": {
        "API_KEY": "${MY_SERVICE_API_KEY}"
      }
    }
  }
}

// ❌ Wrong — secrets in args, visible in process list
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server", "--api-key", "sk-abc123"]
    }
  }
}
```

---

### How macOS GUI Apps Get Environment Variables

This is the source of most MCP secrets confusion. There are **two separate environment chains on macOS**:

```
Terminal session (interactive shell):
  Login → /etc/zshenv → ~/.zshenv → /etc/zshrc → ~/.zshrc → your prompt
  Any program you run from the terminal inherits these exports.

GUI app session (Dock / Launchpad / Spotlight):
  Boot → launchd → WindowServer → GUI apps
  ~/.zshrc is NEVER read. Apps get only the launchd environment.
```

**Consequence**: If you `export API_KEY=...` in `~/.zshrc`, Claude Desktop launched from the Dock **cannot see it** unless you also set it in launchd. This is why MCP servers silently fail when configuration looks correct.

---

### Secrets Delivery Options (macOS)

Choose based on your security posture and convenience requirements:

#### Option 1: macOS Keychain (most secure, recommended for sensitive tokens)

Secrets stored encrypted in Keychain. Never live on disk in plaintext.

```bash
# Store a secret (one time)
security add-generic-password -s "mcp-google" -a "client_secret" -w "your-secret-here"

# Retrieve it (in a wrapper script or shell profile)
export GOOGLE_CLIENT_SECRET=$(security find-generic-password -s "mcp-google" -a "client_secret" -w)
```

Use a LaunchAgent (see below) to inject Keychain-sourced values into the launchd environment at login. This gives you Keychain security without re-exporting secrets interactively each session.

**Caveat**: The value is still in memory as an env var once injected — but it never touches disk, and you control exactly which process receives it.

---

#### Option 2: LaunchAgent plist (persistent across reboots, scoped to GUI apps)

A `~/.config/launchd/mcp-env.plist` LaunchAgent that runs at login and injects env vars into launchd. These become visible to all GUI apps (including Claude, VS Code, Cursor) but **not** to shells spawned from external processes.

```xml
<!-- ~/.config/launchd/com.mvb.mcp-env.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mvb.mcp-env</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <!-- Reads from Keychain and sets launchd env vars -->
        <string>
            launchctl setenv GOOGLE_CLIENT_ID "$(security find-generic-password -s mcp-google -a client_id -w)"
            launchctl setenv GOOGLE_CLIENT_SECRET "$(security find-generic-password -s mcp-google -a client_secret -w)"
            launchctl setenv GITHUB_PERSONAL_ACCESS_TOKEN "$(security find-generic-password -s mcp-github -a token -w)"
        </string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

```bash
# Install the LaunchAgent
ln -sf ~/.config/launchd/com.mvb.mcp-env.plist ~/Library/LaunchAgents/com.mvb.mcp-env.plist
launchctl load ~/Library/LaunchAgents/com.mvb.mcp-env.plist

# Test immediately (or log out/in for it to run automatically)
launchctl start com.mvb.mcp-env
```

This is the **recommended pattern** for personal machines: secrets in Keychain, injected into launchd at login, available to all IDEs without polluting every terminal session.

---

#### Option 3: `~/.zshenv` (simple, process-broad)

`~/.zshenv` is loaded for **every zsh invocation** — interactive, non-interactive, and scripts — unlike `~/.zshrc` (interactive only). It's also inherited by GUI apps that launch a login shell to resolve PATH.

```bash
# ~/.zshenv — loaded for all zsh instances
export GOOGLE_CLIENT_ID="..."
export GOOGLE_CLIENT_SECRET="..."
```

**Problem**: Every process on your machine (scripts, background tools, random npm packages) can read these vars. If a supply-chain attack runs in your npm install scripts, it can exfiltrate them via `process.env`.

**Use when**: Non-sensitive configuration (e.g., `AWS_REGION`, `LOG_LEVEL`). Not for API keys or OAuth secrets.

---

#### Option 4: `~/.config/mcp/.env` sourced at IDE launch (acceptable, scoped file)

Keep secrets in a single file with tight file permissions. Source it once at IDE launch via a wrapper script, rather than exporting it permanently.

```bash
# ~/.config/mcp/.env (chmod 600 — readable by owner only)
GOOGLE_CLIENT_ID=your_id
GOOGLE_CLIENT_SECRET=your_secret
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
```

```bash
chmod 600 ~/.config/mcp/.env

# Source it for the current shell only (no permanent export)
set -a; source ~/.config/mcp/.env; set +a
```

To make this available to GUI apps without polluting the shell, use a LaunchAgent that sources this file and calls `launchctl setenv` for each var.

**Use when**: Multiple secrets that would be tedious to store individually in Keychain. Always pair with a LaunchAgent (not `~/.zshrc`) if IDEs need the vars.

---

#### Option 5: Inline in IDE config (never for real secrets)

Some IDEs allow literal values directly in config. Only acceptable for non-secret config (paths, feature flags).

```jsonc
// ❌ Never do this for actual secrets
{ "env": { "API_KEY": "sk-live-abc123" } }

// ✅ Fine for non-sensitive values
{ "env": { "VAULT_PATH": "/Users/you/vault", "LOG_LEVEL": "info" } }
```

---

### Comparison Table

| Method | Exposure | Survives reboot | GUI apps see it | Terminal sees it | Effort |
|--------|----------|----------------|-----------------|-----------------|--------|
| **Keychain + LaunchAgent** | Keychain encrypted | ✅ Yes | ✅ Yes | ❌ No | Medium |
| **LaunchAgent (plaintext plist)** | plist file on disk | ✅ Yes | ✅ Yes | ❌ No | Medium |
| **`~/.zshenv` export** | All zsh child processes | ✅ Yes | ⚠️ Often no | ✅ Yes | Low |
| **`~/.zshrc` export** | Interactive shells only | ✅ Yes | ❌ No | ✅ Yes | Low |
| **`~/.config/mcp/.env` + LaunchAgent** | File (chmod 600) | ✅ Yes | ✅ Yes | ❌ No | Low-Med |
| **Inline in config** | Config file on disk | ✅ Yes | ✅ Yes | ✅ Yes | None |

**Bottom line for macOS MCP secrets**:
- `~/.zshrc` is the most common advice but is wrong for two reasons: GUI apps can't see it, and it exposes secrets to all child shells.
- The **practical default** is: store in Keychain, inject via LaunchAgent, available to all IDEs without terminal pollution.
- The **quick pragmatic option** (if security risk is tolerable): `~/.zshenv` with a chmod-protected file, accepting broad exposure in exchange for simplicity.

---

### OAuth Token Storage

For OAuth 2.0 MCP servers (Google, Microsoft 365):

- The MCP server typically handles the OAuth dance on first run
- Tokens are stored locally in a path set by the server (often `~/.config/<server-name>/tokens.json` or `~/.<server-name>/credentials.json`)
- Never commit this token file to git — add to `.gitignore`
- Access tokens expire; the server must implement refresh token rotation automatically

---

## IDE-Specific Installation

### Claude Desktop

**Config file**: `~/.claude/claude_desktop_config.json`

```jsonc
{
  "mcpServers": {
    "<server-name>": {
      "command": "npx",        // or "uvx" for Python servers
      "args": ["-y", "<npm-package>"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

**Reload**: Quit and reopen Claude Desktop. There is no hot-reload.

**Python (uv) server**:
```jsonc
{
  "mcpServers": {
    "my-python-server": {
      "command": "uvx",
      "args": ["<package-name>"]
    }
  }
}
```

**Local development server**:
```jsonc
{
  "mcpServers": {
    "my-local-server": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"]
    }
  }
}
```

---

### VS Code Copilot

**Config file options** (in order of precedence):
1. Workspace: `.vscode/mcp.json` — scoped to a project
2. User: VS Code `settings.json` → `"mcp"` key — applies to all workspaces

**Settings.json format**:
```jsonc
{
  "mcp": {
    "servers": {
      "<server-name>": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "<npm-package>"],
        "env": {
          "API_KEY": "${env:API_KEY}"  // VS Code uses ${env:VAR_NAME} syntax
        }
      }
    }
  }
}
```

**Note**: VS Code uses `${env:VAR_NAME}` syntax (not `${VAR_NAME}`) for environment variable interpolation.

**.vscode/mcp.json format** (workspace-scoped):
```jsonc
{
  "servers": {
    "<server-name>": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "<npm-package>"],
      "env": {
        "API_KEY": "${env:API_KEY}"
      }
    }
  }
}
```

**Reload**: Use the VS Code Command Palette → "MCP: List Servers" to trigger refresh. Or restart VS Code.

---

### Cursor

**Config file**: `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (workspace)

```jsonc
{
  "mcpServers": {
    "<server-name>": {
      "command": "npx",
      "args": ["-y", "<npm-package>"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

Cursor uses the same `${VAR_NAME}` interpolation syntax as Claude Desktop.

**Reload**: Cursor picks up changes on restart, or use Cursor Settings → MCP → toggle the server off/on.

---

### Windsurf

**Config file**: `~/.codeium/windsurf/mcp_config.json`

```jsonc
{
  "mcpServers": {
    "<server-name>": {
      "command": "npx",
      "args": ["-y", "<npm-package>"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

**Reload**: Windsurf requires full restart to pick up MCP config changes.

---

## Troubleshooting Guide

### Diagnosis Flow

When an MCP server is not working, follow this sequence:

```
1. Is the server appearing in the IDE's tool list at all?
   ├── No → "Server not loading" (see §Server Not Loading)
   └── Yes → Is the tool call failing?
              ├── Auth error → see §Authentication Failures
              ├── Not found error → see §Package Not Found
              └── Wrong output / timeout → see §Runtime Failures
```

---

### Server Not Loading

**Symptoms**: Tools from the server don't appear; server shows error in IDE MCP settings.

**Checklist**:
1. **Config file syntax** — validate JSON with `python3 -m json.tool ~/.claude/claude_desktop_config.json`
2. **Package exists** — `npm view <package-name> version`
3. **node/npm available** — `which node && node --version` (must be accessible in the IDE's PATH)
4. **Environment variables set** — set vars, then **restart the IDE** (not just the terminal)
5. **Port conflict** (HTTP-mode servers) — check if port is in use with `lsof -i :<port>`

**IDE-specific**:
- **Claude Desktop**: Check `~/Library/Logs/Claude/` for `mcp-server-*.log` files
- **VS Code**: Open Output panel → select "MCP" from the dropdown
- **Cursor**: Check Cursor Settings → MCP → click the server name for error details

---

### Authentication Failures

**Symptoms**: Server loads but returns auth errors; tools fail with 401/403.

**OAuth 2.0 (Google, M365)**:
1. Verify `CLIENT_ID` and `CLIENT_SECRET` are correct and exported in shell
2. Delete the existing token file (usually `~/.config/<server>/tokens.json`) and re-authorize
3. Check OAuth consent screen — your email must be listed as a test user if app is in "Testing" mode
4. Verify required APIs are enabled in the cloud console (e.g., Drive API, Calendar API)
5. Check scopes: the token was created with certain scopes; if server requests new scopes, re-authorize

**API Key**:
1. Verify the env var is exported: `echo $API_KEY` (must return the key)
2. Verify the IDE was restarted **after** the env var was set
3. Check the key hasn't been revoked in the provider's dashboard

**Token file location troubleshooting** (for OAuth servers):
```bash
# Common token file locations
ls ~/.config/                     # many servers use this
ls ~/.gdrive/                     # @modelcontextprotocol/server-gdrive
ls ~/.<server-name>/              # varies by server
```

---

### Package Not Found

**Symptoms**: `Can't resolve module`, `package not found`, `ENOENT` errors.

1. Verify the exact package name: `npm view <exact-package-name> version`
2. Check the package is published and not deprecated: `npm view <package-name> --json | grep deprecated`
3. For scoped packages, ensure the `@scope/` prefix is included in args
4. Try pre-installing: `npm install -g <package-name>` then use `<package-binary>` as command instead of `npx`

---

### Runtime Failures

**Symptoms**: Tools appear but fail when called; timeouts or unexpected errors.

1. **Enable debug logging** — Many MCP servers support `DEBUG=true` or `LOG_LEVEL=debug` env vars
2. **Check tool arguments** — Ensure the agent is passing the right types (string vs number, etc.)
3. **Test the underlying API directly** — If Google Drive fails, test with `curl` using the same credentials
4. **Rate limits** — Check for 429 responses; add delays or reduce call frequency
5. **Version mismatch** — `npx -y` uses the latest cached version. Clear cache: `npx --yes --ignore-existing <package>`

---

### Platform-Specific Issues

#### macOS
- **Keychain auth prompts**: If a server requests keychain access repeatedly, allow it permanently in System Settings → Privacy
- **PATH issues**: IDE apps launched from Dock may not inherit your shell PATH. Add to `~/.zshenv` (not just `~/.zshrc`): `export PATH="/opt/homebrew/bin:$PATH"`
- **SIP restrictions**: Some file paths may be blocked. Run the server directly in terminal to confirm access.

#### Windows
- **Command**: Use `cmd` as command and `/c npx <package>` as args, or ensure Node.js is on `%PATH%`
- **Path separators**: Use forward slashes `/` or escaped backslashes `\\\\` in config JSON

#### Linux
- **Node.js PATH**: Ensure `node` and `npx` are accessible from `/usr/local/bin` or add to PATH in `/etc/environment`
- **File permissions**: MCP servers accessing local files need read/write permissions

---

## Audit: Current MCP State

When asked to summarize installed MCP servers, retrieve the config and report:

```bash
# Claude Desktop
cat ~/.claude/claude_desktop_config.json

# VS Code
cat ~/.config/Code/User/settings.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d.get('mcp',{}), indent=2))"

# Cursor  
cat ~/.cursor/mcp.json 2>/dev/null || cat ~/.cursor/config/mcp.json 2>/dev/null
```

For each server, report:
1. **Name** — the key in mcpServers
2. **Package / command** — what is being run
3. **Auth state** — which env vars are set vs missing (check with `echo $VAR_NAME`)
4. **Tools available** — list from documentation or by calling the server
5. **Config issues** — any env vars that aren't set, packages that don't exist, etc.

---

## Quick-Reference: Common MCP Servers

| Service | Best Package | Auth Method | Notes |
|---------|-------------|-------------|-------|
| **Google Drive** | `@modelcontextprotocol/server-gdrive` | OAuth 2.0 | Official Anthropic server |
| **Google Calendar** | `@takumi0706/google-calendar-mcp` | OAuth 2.0 | Best community option; enhanced security |
| **Gmail** | `@gongrzhe/gmail-mcp-server` | OAuth 2.0 | Community; check freshness before use |
| **GitHub** | `@modelcontextprotocol/server-github` | PAT token | Official Anthropic server |
| **Obsidian** | `obsidian-mcp` | File path | Direct file I/O; no Obsidian plugin needed |
| **Postgres** | `@modelcontextprotocol/server-postgres` | Connection string | Official Anthropic server |
| **Slack** | `@modelcontextprotocol/server-slack` | Bot token | Official Anthropic server |
| **Jira** | `@modelcontextprotocol/server-atlassian` | API key | Official Anthropic server |
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | Path allow-list | Official; expose specific directories |
| **Playwright** | `@playwright/mcp` | None | Browser automation |
| **Sequential thinking** | `@modelcontextprotocol/server-sequential-thinking` | None | Reasoning enhancement |

---

## Integration Checklist

Before marking an MCP integration as complete:

- [ ] Package exists and is published: `npm view <package> version`
- [ ] Config JSON is valid: `python3 -m json.tool <config-file>`
- [ ] Secrets stored in env vars, not hardcoded in args
- [ ] Env vars set in shell init file (`~/.zshrc` or `~/.zshenv`)
- [ ] IDE restarted after setting env vars
- [ ] Server appears in IDE tool list without error
- [ ] At least one tool call tested successfully
- [ ] For OAuth servers: token file created and stored securely
- [ ] Token file added to `.gitignore` if in a repo directory
- [ ] Setup steps documented in project README
