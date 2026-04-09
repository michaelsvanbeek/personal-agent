# MCP Servers

How to connect your AI agent to external systems using the Model Context Protocol.

---

## What is MCP?

The [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) is an open
standard for connecting AI assistants to external data sources and tools. An MCP
server exposes capabilities (tools, resources, prompts) that the AI agent can
call during a conversation.

Think of it as giving your agent hands: instead of just knowing things (skills),
it can *do* things — query a database, check a calendar, file an issue.

---

## Finding MCP Servers

The ecosystem is growing quickly. These directories list available servers:

| Directory | Description |
|-----------|-------------|
| [MCP Server Registry](https://github.com/modelcontextprotocol/servers) | Official Anthropic registry of reference and community servers |
| [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers) | Community-curated list of MCP servers |
| [mcp.so](https://mcp.so/) | Searchable directory of MCP servers |
| [Glama MCP Directory](https://glama.ai/mcp/servers) | Categorized MCP server directory |
| [Smithery](https://smithery.ai/) | MCP server marketplace and registry |

### Popular Categories

| Category | Examples |
|----------|---------|
| **Developer tools** | GitHub, GitLab, Linear, Jira |
| **Communication** | Slack, Discord, Email |
| **Productivity** | Google Workspace, Notion, Obsidian |
| **Data** | PostgreSQL, SQLite, BigQuery |
| **File systems** | Local filesystem, S3, Google Drive |
| **Monitoring** | Sentry, Datadog, PagerDuty |
| **Search** | Brave Search, Exa, Tavily |

---

## Setting Up an MCP Server

### General pattern

1. **Find the server** in one of the directories above
2. **Install it** (usually via npm or pip)
3. **Configure it** in your IDE's MCP settings
4. **Test it** by asking the agent to use the server's tools

### Configuration by IDE

#### VS Code (Copilot)

Add to `.vscode/mcp.json` or VS Code settings:

```json
{
  "mcp": {
    "servers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
        }
      }
    }
  }
}
```

#### Cursor

Add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
      }
    }
  }
}
```

#### Claude Code

Add to `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
      }
    }
  }
}
```

---

## Evaluating MCP Servers

Before adding a server, evaluate it:

### Quality signals

- **Maintained** — recent commits, responsive to issues
- **Documented** — clear README with setup instructions
- **Typed** — tool schemas have good descriptions and typed parameters
- **Scoped** — does one thing well rather than everything poorly
- **Secure** — handles credentials properly, no hardcoded secrets

### Red flags

- No updates in 6+ months
- No documentation or examples
- Requires broad permissions beyond what's needed
- No error handling — crashes silently or returns opaque errors
- Bundles unrelated tools (kitchen-sink servers)

---

## Build vs Buy Decision

Sometimes you need a capability that no existing MCP server provides, or the
existing options don't meet your quality bar. See the
[agent-integrator](../skills/agent-integrator/SKILL.md) skill for a framework
to decide between:

- Using an existing MCP server
- Wrapping an API with a lightweight custom tool
- Building a full custom MCP server

---

## Security Best Practices

- **Never hardcode credentials** in MCP config files. Use environment variable
  references (`${env:MY_TOKEN}`) or a secrets manager.
- **Use least-privilege tokens** — create a token scoped to only what the MCP
  server needs.
- **Review server source code** before granting access to sensitive systems.
- **Audit tool calls** — periodically review what tools the agent is calling
  and what data it's accessing.
- **Isolate sensitive servers** — don't expose production databases through MCP
  during development.

---

## Documenting Your MCP Connections

As you add MCP servers, document them in `mcp/README.md`:

```markdown
# MCP Servers

| Server | Purpose | Auth | Status |
|--------|---------|------|--------|
| GitHub | Issues, PRs, code search | Personal access token | Active |
| Filesystem | Local project access | None (local) | Active |
| PostgreSQL | Query dev database | Connection string | Active |
```

This helps you track what's connected and makes it easy to set up on a new
machine.
