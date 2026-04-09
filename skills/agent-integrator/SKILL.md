---
name: agent-integrator
description: >-
  Integration strategy for AI agent capabilities — when to use off-the-shelf MCP
  servers vs custom tools vs custom MCP servers. Use when: deciding how to connect
  an external system, evaluating MCP servers for quality, choosing between building
  a custom tool or using an existing integration, designing a custom MCP server,
  auditing existing integrations for reliability, or planning the agent's
  integration architecture.
---

# Agent Integration Strategy

## When to Use

- Deciding how to connect the agent to a new external system
- Evaluating whether an existing MCP server meets your needs
- Choosing between a custom tool, a custom MCP server, or an off-the-shelf server
- Designing a custom MCP server
- Auditing existing integrations for quality and security
- Planning which integrations to add to your agent

---

## The Integration Decision Framework

When you need the agent to interact with an external system, you have three
options. Choose the simplest one that meets your requirements:

```
Does an MCP server already exist?
  ├─ Yes → Does it meet your quality bar? (see evaluation checklist)
  │    ├─ Yes → Use the off-the-shelf MCP server
  │    └─ No  → Can you fork and fix it?
  │         ├─ Yes → Fork, fix, contribute back
  │         └─ No  → Build custom (tool or MCP server)
  └─ No  → Is this a simple, one-direction integration?
       ├─ Yes → Build a custom tool (shell script or CLI)
       └─ No  → Build a custom MCP server
```

### Decision matrix

| Criteria | Off-the-shelf MCP | Custom tool | Custom MCP server |
|----------|-------------------|-------------|-------------------|
| **Time to set up** | Minutes | Hours | Days |
| **Maintenance burden** | Low (community) | Medium (you) | High (you) |
| **Customization** | Limited | Full | Full |
| **Best for** | Standard integrations | Simple automation | Complex or novel systems |
| **Risk** | Dependency on maintainer | Script rot | Over-engineering |

---

## When to Use Off-the-Shelf MCP Servers

**Default choice.** Start here unless you have a strong reason not to.

### Advantages

- Immediate capability — minutes from decision to working integration
- Community maintenance — bugs fixed and features added by others
- Battle-tested — used by other developers, edge cases discovered
- Standard protocol compliance — works across IDEs without modification

### When off-the-shelf works well

- Standard SaaS integrations (GitHub, Slack, Google Workspace)
- Common developer tools (databases, file systems, search)
- Well-documented APIs with established MCP servers
- Read-heavy use cases (querying, searching, fetching)

### MCP Server Evaluation Checklist

Before adopting an MCP server, evaluate it:

| Check | What to look for |
|-------|-----------------|
| **Active maintenance** | Commits in the last 3 months, responsive issues |
| **Documentation** | Clear README with setup instructions and tool descriptions |
| **Tool schemas** | Well-typed parameters with meaningful descriptions |
| **Error handling** | Returns structured errors, doesn't crash silently |
| **Security** | Handles credentials via env vars, no hardcoded secrets |
| **Scope** | Focused tools, not a kitchen-sink server |
| **License** | Compatible with your use (MIT, Apache 2.0 preferred) |
| **Dependencies** | Reasonable dependency tree, no known vulnerabilities |

### Red flags

- No commits in 6+ months with open issues
- Requires broad permissions beyond minimum needed
- No tests or CI pipeline
- Monolithic server with 50+ tools (retrieval becomes unreliable)
- Hardcoded config or credentials in source

---

## When to Build a Custom Tool

Build a custom tool (shell script or CLI) when:

- **One-direction**: You need to *do something*, not have a conversation about
  it (e.g., scaffolding a project, running a lint check)
- **Simple**: The integration is a thin wrapper around an API call or CLI command
- **Local**: It operates on the local filesystem or development environment
- **Manual trigger**: You invoke it explicitly, not the agent during conversation

### Custom tool examples

| Tool | What it does | Why not MCP? |
|------|-------------|-------------|
| `scaffold-project` | Create project boilerplate | One-shot, local, no conversation needed |
| `lint-all` | Run all linters for current project | Local automation, manual trigger |
| `deploy` | Push to staging | Destructive action, explicit invocation |
| `rotate-keys` | Refresh API credentials | Security-sensitive, manual approval |

### Tool design guidelines

- **Make it idempotent** where possible — safe to run twice
- **Fail fast** — validate inputs before doing work
- **Exit codes** — 0 for success, non-zero for failure
- **Stdout for data, stderr for logs** — keep output scriptable
- **Include --help** — self-documenting usage

---

## When to Build a Custom MCP Server

Build a custom MCP server when:

- **No server exists** for the system you need to integrate
- **Existing servers are inadequate** — wrong abstraction, poor quality, abandoned
- **Custom business logic** — you need domain-specific tool behavior, not raw API
  pass-through
- **Bidirectional** — the agent needs to both query and act on the system
- **Multi-tool** — you need several related tools that share auth and state

### Custom MCP server examples

| Server | Why custom? |
|--------|------------|
| Internal ticketing system | No public MCP server exists |
| Custom analytics API | Needs domain-specific query builder |
| Proprietary data warehouse | Company-specific schema and auth |
| Multi-step workflow engine | Complex state across tool calls |

### Architecture guidelines

1. **One server per system** — don't build a mega-server for all integrations
2. **Minimal tools** — 3-7 tools per server; more hurts agent retrieval accuracy
3. **Typed schemas** — every parameter and return value has a Pydantic/Zod schema
4. **Structured responses** — return JSON, not prose. Let the agent format for
   the user.
5. **Error as data** — return `{"error": "message"}`, don't crash

### Building with the MCP SDK

The official SDKs support multiple languages:

| Language | Package | Install |
|----------|---------|---------|
| TypeScript | `@modelcontextprotocol/sdk` | `npm install @modelcontextprotocol/sdk` |
| Python | `mcp` | `pip install mcp` |

Basic server structure (Python):

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-server")

@mcp.tool()
def search_items(query: str, limit: int = 10) -> str:
    """Search for items matching the query.
    Use when the user asks to find or look up items."""
    results = do_search(query, limit)
    return json.dumps(results)

if __name__ == "__main__":
    mcp.run()
```

Basic server structure (TypeScript):

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "my-server", version: "1.0.0" });

server.tool(
  "search_items",
  "Search for items matching the query",
  { query: z.string(), limit: z.number().default(10) },
  async ({ query, limit }) => {
    const results = await doSearch(query, limit);
    return { content: [{ type: "text", text: JSON.stringify(results) }] };
  },
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

---

## Integration Architecture

### Start small, expand deliberately

```
Week 1:  Add 1-2 off-the-shelf MCP servers (e.g., GitHub, filesystem)
Week 2:  Build 1 custom tool for your most repeated task
Week 4:  Evaluate what's missing — add more MCP servers as needed
Month 2: Build a custom MCP server only if a real gap exists
```

### Track your integrations

Maintain a table in `mcp/README.md`:

```markdown
| Integration | Type | Status | Notes |
|-------------|------|--------|-------|
| GitHub | Off-the-shelf MCP | Active | @modelcontextprotocol/server-github |
| Filesystem | Off-the-shelf MCP | Active | @modelcontextprotocol/server-filesystem |
| scaffold-project | Custom tool | Active | tools/scaffold-project |
| Internal API | Custom MCP server | Planned | Needs auth integration |
```

### Security principles

- **Least privilege** — create tokens scoped to exactly what the integration needs
- **Env var credentials** — never hardcode secrets in config files
- **Review before trust** — read the source of MCP servers before connecting them
  to sensitive systems
- **Audit periodically** — check what tools the agent is calling and whether the
  access is still needed
- **Separate dev from prod** — never point MCP servers at production databases or
  APIs during development
