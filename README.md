# Personal Agent

A framework for building your own AI coding assistant — a collection of skills,
tools, and MCP server connections that follow you across IDEs.

Clone this repo, add your own domain expertise, and run the installer to symlink
everything into VS Code (Copilot), Cursor, or Claude Code.

## Why

AI coding assistants are powerful out of the box, but they don't know *your*
conventions. Every team has patterns, preferences, and hard-won lessons that get
repeated in code reviews and Slack threads but never make it into the assistant's
context.

Personal Agent fixes this. You encode your knowledge as **skills** (markdown
files the agent loads on demand), wire up **MCP servers** for live data, and add
**tools** for automation. The install script symlinks everything into the right
IDE paths so every conversation starts with your context already loaded.

## What's Inside

| Construct | Purpose | Location |
|-----------|---------|----------|
| **Skills** | Domain knowledge the agent loads when relevant | `skills/*/SKILL.md` |
| **Instructions** | Always-on rules applied to every conversation | `instructions/*.instructions.md` |
| **MCP Servers** | Live connections to external systems | `mcp/` |
| **Tools** | Shell scripts and utilities on your PATH | `tools/` |
| **Configs** | IDE settings and extension recommendations | `configs/` |

### Starter Skills

| Skill | Description |
|-------|-------------|
| [agent-skill](skills/agent-skill/SKILL.md) | Best practices for writing and organizing skills |
| [agent-integrator](skills/agent-integrator/SKILL.md) | When to use MCP servers vs custom tools |
| [git-workflow](skills/git-workflow/SKILL.md) | Conventional commits, branching, and PR standards |
| [markdown-docs](skills/markdown-docs/SKILL.md) | Documentation structure, linking, and formatting |

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/personal-agent.git
cd personal-agent
chmod +x install.sh
./install.sh
```

The installer will:

1. Symlink all skills into your IDE's skill directories
2. Symlink instructions into VS Code's prompt folder and Claude's config
3. Report what was added, skipped, or errored with color-coded output

Run `./install.sh` again any time you add or change skills — it's idempotent.

## Adding Your Own Skills

Create a new directory under `skills/` with a `SKILL.md` file:

```
skills/
  my-new-skill/
    SKILL.md
```

Then run `./install.sh` to distribute it. See the
[Building Skills](docs/building-skills.md) guide and the
[agent-skill](skills/agent-skill/SKILL.md) skill for best practices.

## Adding MCP Servers

MCP (Model Context Protocol) connects your agent to live data sources — calendars,
databases, APIs, and more. See [MCP Servers](docs/mcp-servers.md) for a directory
of available servers and setup instructions.

## Documentation

- [Getting Started](docs/getting-started.md) — first-time setup walkthrough
- [IDE Setup](docs/ide-setup.md) — per-IDE configuration instructions
- [Design Guide](docs/design.md) — architecture and philosophy
- [Building Skills](docs/building-skills.md) — how to write effective skills
- [Building Tools](docs/building-tools.md) — adding CLI tools and scripts
- [MCP Servers](docs/mcp-servers.md) — connecting to external services

## Supported IDEs

| IDE | Skills | Instructions | MCP |
|-----|--------|-------------|-----|
| VS Code (Copilot) | ✓ | ✓ | Via extension settings |
| Cursor | ✓ | Via rules | Via settings |
| Claude Code | ✓ | ✓ (CLAUDE.md) | Via config file |

## Project Structure

```
personal-agent/
├── README.md                  ← you are here
├── LICENSE
├── install.sh                 ← idempotent installer
├── skills/                    ← domain knowledge (SKILL.md files)
│   ├── agent-skill/
│   ├── agent-integrator/
│   ├── git-workflow/
│   └── markdown-docs/
├── instructions/              ← always-on rules
│   └── git-commits.instructions.md
├── tools/                     ← CLI scripts (symlinked to ~/.local/bin)
├── mcp/                       ← MCP server configs and docs
├── docs/                      ← guides and references
└── configs/                   ← IDE settings templates
    └── vscode/
```

## Contributing

Contributions are welcome. Please open an issue or pull request.

When contributing skills, follow the conventions in the
[agent-skill](skills/agent-skill/SKILL.md) skill and ensure your SKILL.md passes
the quality checklist in [Building Skills](docs/building-skills.md).

## License

[MIT](LICENSE)
