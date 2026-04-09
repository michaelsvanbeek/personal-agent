# Design Guide

The architecture and philosophy behind personal-agent.

---

## Core Idea

Your AI coding assistant is only as useful as the context it has. Out of the
box, it knows general programming — but it doesn't know *your* conventions,
your team's patterns, or the systems you work with.

Personal Agent bridges this gap with three constructs:

| Construct | When it's loaded | What it does |
|-----------|-----------------|--------------|
| **Skills** | On demand, when relevant | Injects domain knowledge into the conversation |
| **Instructions** | Every conversation, automatically | Enforces always-on rules and conventions |
| **MCP Servers** | When the agent calls a tool | Connects to live external data and systems |

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                   Your IDE                   │
│  ┌────────────┐  ┌──────────┐  ┌─────────┐ │
│  │   Skills    │  │  Instrs  │  │   MCP   │ │
│  │  (on-demand │  │ (always  │  │ (live   │ │
│  │   context)  │  │  loaded) │  │  data)  │ │
│  └──────┬─────┘  └────┬─────┘  └────┬────┘ │
│         │              │              │      │
│         └──────────────┼──────────────┘      │
│                        │                     │
│                   AI Agent                   │
└─────────────────────────────────────────────┘
         ▲                        ▲
         │                        │
    ┌────┴────┐            ┌──────┴──────┐
    │ skills/ │            │    mcp/     │
    │ instrs/ │            │  (configs)  │
    │ tools/  │            └─────────────┘
    └─────────┘
    personal-agent repo
```

### Skills

Skills are markdown files (`SKILL.md`) that contain domain knowledge. The IDE
loads them into the agent's context when the conversation topic matches.

**Key properties:**
- Loaded on demand, not always — keeps context windows lean
- Self-contained — each skill is a complete reference for its domain
- Retrievable by description — the IDE matches the skill description against
  the conversation

**Examples:** API design conventions, testing strategies, deployment procedures,
code review checklists, database patterns.

### Instructions

Instructions are always-on rules that apply to every conversation (or to
conversations involving specific file types). They enforce conventions you never
want the agent to forget.

**Key properties:**
- Always loaded — the agent sees these in every conversation
- File-scoped — use `applyTo` patterns to target specific file types
- Lightweight — keep instructions short because they consume context in every
  conversation

**Examples:** "Use conventional commits", "Format Python with Ruff", "Never use
`any` type in TypeScript".

### MCP Servers

MCP (Model Context Protocol) servers give the agent live access to external
systems. Unlike skills (which are static knowledge), MCP servers return real-time
data.

**Key properties:**
- Live data — the agent can query databases, APIs, calendars, etc.
- Tool-based — each MCP server exposes tools the agent can call
- Composable — connect multiple servers for a rich set of capabilities

**Examples:** GitHub (issues, PRs), Google Calendar, Slack, databases, file
systems.

---

## Design Principles

### 1. Knowledge lives in version control

Skills, instructions, and configs are plain files in a Git repo. They are
reviewed, versioned, and shared like code. This prevents knowledge drift and
makes your conventions auditable.

### 2. Separate static knowledge from live connections

Skills = what the agent knows (static, versioned).
MCP Servers = what the agent can access (live, external).

Don't put API endpoints or database schemas in skills — connect an MCP server
instead. Skills should contain patterns and conventions, not volatile data.

### 3. Right-size each construct

| Need | Use |
|------|-----|
| Convention the agent should always follow | Instruction |
| Deep reference loaded when relevant | Skill |
| Live data or external actions | MCP Server |
| Automation script for your workflow | Tool |

### 4. Optimize for retrieval

Skills are only useful if the IDE can find them. Write clear, specific
descriptions in YAML frontmatter. The description is what the IDE matches
against — vague descriptions mean the skill is never loaded.

### 5. Keep instructions minimal

Instructions are loaded into *every* conversation. A 2000-word instruction file
eats into the context window of every chat, even ones where it's irrelevant.
Move deep references to skills; keep instructions to essential rules.

### 6. Prefer off-the-shelf MCP servers

Before building a custom tool, check if an MCP server already exists. The
ecosystem is growing fast. See the [agent-integrator](../skills/agent-integrator/SKILL.md)
skill for decision criteria.

---

## How the Installer Works

The `install.sh` script creates symlinks from your repo into each IDE's expected
directories:

```
skills/git-workflow/  →  ~/.copilot/skills/git-workflow/
                     →  ~/.claude/skills/git-workflow/
                     →  ~/.cursor/skills/git-workflow/
```

Symlinks mean:
- **One source of truth** — edit in the repo, all IDEs see the change instantly
- **Version controlled** — `git diff` shows what changed in your agent config
- **Idempotent** — run the installer as many times as you want

The installer also merges instruction content into `~/.claude/CLAUDE.md` between
HTML comment markers, preserving any manual content in that file.

---

## Directory Conventions

```
personal-agent/
├── skills/              ← one directory per skill, each with SKILL.md
├── instructions/        ← *.instructions.md files with applyTo frontmatter
├── tools/               ← executable scripts (symlinked to ~/.local/bin)
├── mcp/                 ← MCP server documentation and configs
├── docs/                ← this documentation
└── configs/             ← IDE settings templates
```

### Naming rules

- **Skill directories**: `kebab-case` — `api-design`, `git-workflow`
- **Instruction files**: `<topic>.instructions.md` — `git-commits.instructions.md`
- **Tool scripts**: `kebab-case`, no extension — `scaffold-project`, `lint-all`
