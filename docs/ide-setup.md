# IDE Setup

Per-IDE instructions for configuring skills, instructions, and MCP servers.

The `install.sh` script handles most of this automatically. This guide covers
what happens under the hood, manual configuration, and troubleshooting.

---

## VS Code with GitHub Copilot

### How It Works

| Construct | Location | Loaded by |
|-----------|----------|-----------|
| Skills | `~/.copilot/skills/*/SKILL.md` | Copilot Chat (auto-discovered) |
| Instructions | `~/Library/Application Support/Code/User/prompts/*.instructions.md` (macOS) | Copilot Chat (auto-applied per `applyTo` pattern) |
| MCP Servers | VS Code settings or `.vscode/mcp.json` | Copilot Chat |

### Skills Setup

The installer symlinks each `skills/<name>/` directory to `~/.copilot/skills/<name>/`.
Copilot discovers SKILL.md files automatically.

**Verify:** Open Copilot Chat and check the skills icon — your skills should
be listed.

### Instructions Setup

Instructions are `.instructions.md` files with YAML frontmatter specifying
which files they apply to:

```yaml
---
applyTo: "**"
---

# Always-On Rules

These rules apply to every conversation.
```

The `applyTo` field accepts glob patterns:

| Pattern | Applies to |
|---------|-----------|
| `**` | All files |
| `**/*.py` | Python files only |
| `**/*.{ts,tsx}` | TypeScript files only |
| `src/**` | Files under src/ |

The installer symlinks these to the VS Code prompts folder.

### MCP Server Setup

Add MCP servers to your VS Code settings or a `.vscode/mcp.json` file:

```json
{
  "mcp": {
    "servers": {
      "my-server": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
      }
    }
  }
}
```

---

## Cursor

### How It Works

| Construct | Location | Loaded by |
|-----------|----------|-----------|
| Skills | `~/.cursor/skills/*/SKILL.md` | Cursor (auto-discovered) |
| Instructions | `.cursor/rules/*.mdc` or project-level rules | Cursor rules system |
| MCP Servers | `.cursor/mcp.json` or Cursor settings | Cursor |

### Skills Setup

The installer symlinks skills to `~/.cursor/skills/`. Cursor discovers
SKILL.md files similarly to Copilot.

### Instructions Setup

Cursor uses its own rules format (`.mdc` files). You can either:

1. **Convert** your `.instructions.md` files to Cursor's format manually
2. **Reference** the skill files directly — Cursor reads SKILL.md from the
   skills directory

To add a project-level rule in Cursor:

```
.cursor/rules/
  git-commits.mdc
```

### MCP Server Setup

Create `.cursor/mcp.json` in your project or configure globally:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
    }
  }
}
```

---

## Claude Code

### How It Works

| Construct | Location | Loaded by |
|-----------|----------|-----------|
| Skills | `~/.claude/skills/*/SKILL.md` | Claude Code (auto-discovered) |
| Instructions | `~/.claude/CLAUDE.md` | Claude Code (loaded every session) |
| MCP Servers | `~/.claude/claude_desktop_config.json` | Claude Desktop / Code |

### Skills Setup

The installer symlinks skills to `~/.claude/skills/`.

### Instructions Setup

Claude Code reads `~/.claude/CLAUDE.md` at the start of every conversation.
The installer merges your instruction files into this file between marker
comments:

```markdown
<!-- personal-agent instructions start -->
(your instruction content here)
<!-- personal-agent instructions end -->
```

Any content outside these markers is preserved, so you can add personal notes
above or below the managed block.

### MCP Server Setup

Edit `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
    }
  }
}
```

---

## Troubleshooting

### Skills not showing up

1. **Check the symlink exists:**
   ```bash
   ls -la ~/.copilot/skills/    # or ~/.cursor/skills/, ~/.claude/skills/
   ```
2. **Verify the SKILL.md file is present** inside the skill directory.
3. **Restart the IDE** — some IDEs cache the skill list at startup.

### Instructions not applying

1. **Check the `applyTo` pattern** in the YAML frontmatter matches your files.
2. **For Claude Code**, verify the content appears in `~/.claude/CLAUDE.md`.
3. **Re-run the installer** — `./install.sh` is safe to run repeatedly.

### MCP servers not connecting

1. **Check the server command** — run it manually in a terminal to verify:
   ```bash
   npx -y @modelcontextprotocol/server-filesystem /tmp
   ```
2. **Check logs** — each IDE has its own MCP log location.
3. **Verify JSON syntax** — a misplaced comma will silently break the config.
