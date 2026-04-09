# Personal Agent

A framework for building your own AI assistant — a collection of skills,
tools, and MCP server connections that follow you across IDEs.

This works for any role: software engineers, managers, analysts, writers,
researchers, marketers — anyone who uses an AI assistant and wants it to know
their conventions and connect to their systems.

Clone this repo, add your own domain expertise, and run the installer to symlink
everything into VS Code (Copilot), Cursor, or Claude Code.

## Why

AI assistants are powerful out of the box, but they don't know *your*
conventions. Every team has patterns, preferences, and hard-won lessons that get
repeated in meetings, documents, and reviews but never make it into the
assistant's context.

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
git clone https://github.com/michaelsvanbeek/personal-agent.git
cd personal-agent
chmod +x install.sh
./install.sh
```

The installer will:

1. Symlink all skills into your IDE's skill directories
2. Symlink instructions into VS Code's prompt folder and Claude's config
3. Report what was added, skipped, or errored with color-coded output

Run `./install.sh` again any time you add or change skills — it's idempotent.

## Follow External Skill Repositories

Use `personal-agent` as your runtime, and follow external skill repos via symlinks.
This keeps your skills auto-updated from source repos while preserving a clean local setup.

```bash
# Link community skills
link-skills-repo add ~/code/personal-agent-skills community

# Link organization-specific skills
link-skills-repo add ~/code/my-org-agent-skills org

# Link personal/private skills
link-skills-repo add ~/code/my-personal-skills personal

# Sync all linked skills into your IDE directories
./install.sh
```

See [Following External Skills Repositories](docs/following-skills-repos.md) for the full workflow.

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

## Community Skills

Looking for more skills? The
[personal-agent-skills](https://github.com/michaelsvanbeek/personal-agent-skills)
repository is a community-maintained catalog of skills organized by persona. Browse
skills tagged for your role — developer, manager, analyst, writer, and more — and
install only what's relevant to your work.

Want to share a skill you've built? Contribute it to the community repo. All
contributed skills are audited for quality and duplication via pre-commit hooks.

Building skills for your organization? See [Internal Org Skills Repositories](docs/design.md#internal-org-skills-repositories) for how to create a private, org-specific skills repo.

## Context Management

Your AI assistant has a finite context window. Every skill, instruction, and MCP
server you add consumes space that could be used for the actual conversation.

**Start small.** Install only what you need today. Add more when you notice the
agent getting something wrong (add a skill) or when you need live data from a
system you access often (add an MCP server).

See the [Design Guide](docs/design.md) for the full context management philosophy.

## Adding MCP Servers

MCP (Model Context Protocol) connects your agent to live data sources — calendars,
databases, APIs, and more. See [MCP Servers](docs/mcp-servers.md) for a directory
of available servers and setup instructions.

## Documentation

- [Getting Started](docs/getting-started.md) — first-time setup walkthrough
- [IDE Setup](docs/ide-setup.md) — per-IDE configuration instructions
- [Design Guide](docs/design.md) — architecture, philosophy, and productionization roadmap
- [Context Management](docs/context-management.md) — what gets loaded, when, and how to route content
- [Following External Skills Repositories](docs/following-skills-repos.md) — symlink strategy for community, org, and personal skill repos
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

Contributions to the **framework** (installer, documentation, foundational skills)
are welcome here. Please open an issue or pull request.

**Domain skills** (specific to a role, technology, or workflow) should be
contributed to
[personal-agent-skills](https://github.com/michaelsvanbeek/personal-agent-skills)
instead. This keeps the core framework lean and the skill catalog discoverable.

When contributing skills to either repo, follow the conventions in the
[agent-skill](skills/agent-skill/SKILL.md) skill and ensure your SKILL.md passes
the quality checklist in [Building Skills](docs/building-skills.md).

**Building for your organization?** Create an internal skills repo following the same
pattern. See [Internal Org Skills Repositories](docs/design.md#internal-org-skills-repositories).

## License

[MIT](LICENSE)
