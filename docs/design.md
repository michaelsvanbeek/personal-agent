# Design Guide

The architecture and philosophy behind personal-agent.

---

## Design Philosophy

### For everyone, not just developers

Personal Agent is a framework for anyone who works with an AI assistant — not
just software engineers. A manager preparing board decks, a researcher reviewing
literature, a marketing lead drafting campaigns, and a developer writing code
all benefit from the same pattern: teach the AI *your* conventions, connect it
to *your* systems, and let it carry that context across every conversation.

The framework is deliberately **unopinionated**. It provides the scaffolding —
skills, instructions, MCP servers — but makes no assumptions about what domain
you work in. You bring the content; the framework ensures it's organized,
versioned, and discoverable.

### Take it in any direction

This repository is a **starting point**. It ships with a handful of foundational
skills (how to write skills, how to evaluate integrations, git conventions, and
documentation standards). Everything else is up to you.

- A **project manager** might add skills for stakeholder communication, sprint
  planning, and risk tracking — and connect Jira, Confluence, and Slack MCPs.
- A **data analyst** might add skills for SQL style, chart readability, and
  statistical methods — and connect BigQuery and Tableau MCPs.
- A **writer** might add skills for tone guides, editorial workflows, and
  citation standards — and connect Google Docs and Grammarly MCPs.

There is no "right" configuration — only the one that matches your work.

### Community skills live elsewhere

This repo contains only the **framework and foundational skills**. Domain skills
contributed by the community belong in the
[personal-agent-skills](https://github.com/michaelsvanbeek/personal-agent-skills)
repository. This separation keeps the core framework lean and lets the skill
library grow independently.

---

## Context Management

AI assistants have a finite context window — every token of context consumed by
skills, instructions, and MCP tool schemas leaves less room for the actual
conversation, file contents, and reasoning.

### The cost of context

| What consumes context | When | Cost |
|-----------------------|------|------|
| Instructions | Every conversation | Always-on — highest cost-per-token |
| Skills (loaded) | When the IDE matches the topic | On-demand — moderate |
| MCP tool schemas | When servers are connected | Listed in every conversation |
| File contents | When the agent reads code | Scales with file size |
| Conversation history | As chat continues | Grows over time |

### Less is more

Adding every possible skill and MCP server is counterproductive:

1. **Retrieval noise** — when many skills have overlapping triggers, the IDE
   loads the wrong ones or loads too many, diluting relevant guidance.
2. **Schema bloat** — every connected MCP server advertises its tool schemas.
   Ten servers with 5 tools each means 50 tool descriptions competing for
   context space.
3. **Decision fatigue** — the agent performs worse when it has too many tools
   to choose from, just like a person with too many options.

### Right-size your setup

**Start minimal.** Install only the skills and MCP servers that directly support
your daily work. Add more only when you notice the agent repeatedly getting
something wrong (add a skill) or when you need live data from a system you
access frequently (add an MCP server).

**Audit periodically.** Remove skills you haven't triggered in months. Disconnect
MCP servers you rarely query. A lean context means better responses.

**Personalize for your role.** Not every skill in the community library is for
you. Browse the persona-organized catalog in
[personal-agent-skills](https://github.com/michaelsvanbeek/personal-agent-skills)
and pick only what's relevant. You can always add more later.

---

## Example Personas

These examples show how different roles might configure their personal agent.
They are illustrations, not prescriptions.

### Engineering Manager

**Goal:** Coordinate team work, review code, prepare reports.

| Type | Examples |
|------|---------|
| **Skills** | code-review, git-workflow, meeting-agendas, sprint-planning |
| **MCP Servers** | GitHub (PRs, issues), Slack (team channels), Google Calendar |
| **Instructions** | Conventional commits, PR review checklist |

**Typical prompts:**
- "Draft a team standup summary from today's Slack thread."
- "Review this PR for our naming and testing conventions."
- "Prepare a sprint retrospective agenda based on this sprint's issues."

### Marketing Manager

**Goal:** Write campaigns, analyze channel performance, coordinate with agencies.

| Type | Examples |
|------|---------|
| **Skills** | brand-voice, campaign-planning, content-calendar |
| **MCP Servers** | Google Drive (docs, sheets), Slack, Outlook (email) |
| **Instructions** | Brand tone guide, approval workflows |

**Typical prompts:**
- "Draft a product launch email in our brand voice."
- "Pull this quarter's campaign metrics from the Google Sheet and summarize."
- "Write a creative brief for the agency based on this Slack thread."

### Data Analyst

**Goal:** Query data, build dashboards, communicate findings.

| Type | Examples |
|------|---------|
| **Skills** | sql-style, chart-design, statistical-methods, data-storytelling |
| **MCP Servers** | BigQuery, Google Sheets, Slack |
| **Instructions** | SQL formatting rules, chart accessibility standards |

**Typical prompts:**
- "Write a query to find monthly active users by cohort."
- "Create a chart spec for this retention data — use our standard palette."
- "Summarize these query results for a non-technical stakeholder."

### Executive / Operations Lead

**Goal:** Prepare board materials, track OKRs, manage cross-functional projects.

| Type | Examples |
|------|---------|
| **Skills** | okr-tracking, board-reporting, executive-summaries |
| **MCP Servers** | Google Drive, Outlook, Notion, Slack |
| **Instructions** | Report formatting standards, data confidentiality rules |

**Typical prompts:**
- "Draft the Q2 board update from this Google Doc outline."
- "Pull action items from last week's leadership Slack channel."
- "Summarize this Notion project tracker into a one-page status report."

### Researcher

**Goal:** Review literature, organize references, draft papers.

| Type | Examples |
|------|---------|
| **Skills** | citation-standards, literature-review, academic-writing |
| **MCP Servers** | Filesystem (local papers), Zotero, Google Scholar |
| **Instructions** | Citation format (APA, Chicago), writing style guide |

**Typical prompts:**
- "Summarize the key findings from these five papers."
- "Draft an abstract for a paper on this topic."
- "Check this bibliography for formatting consistency."

---

## Core Idea

Your AI assistant is only as useful as the context it has. Out of the box, it
knows general information — but it doesn't know *your* conventions, your team's
patterns, or the systems you work with.

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
reviewed, versioned, and shared like any other asset. This prevents knowledge
drift and makes your conventions auditable.

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

### 7. Context budget is finite — less is more

Every skill, instruction, and MCP server consumes context window space. Adding
everything available is worse than adding nothing — it creates noise, confuses
retrieval, and overwhelms the agent with irrelevant tool options. Install only
what directly supports your daily work. See the [Context Management](context-management.md)
document for details.

### 8. Contribute skills to the community repo

This repository is the framework. New domain skills should be contributed to
[personal-agent-skills](https://github.com/michaelsvanbeek/personal-agent-skills),
where they can be tagged, cataloged by persona, and audited by the community.
Keep the core lean.

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

---

## Local Agents: Limitations and Opportunities

### What This Is (And Isn't)

Personal Agent runs **entirely on your machine** with local LLMs (Claude in VS Code, Cursor, or Claude Code). It is not:

- **Internet-scale retrieval** — Your skills are pre-loaded, not retrieved from a database
- **Team-scale orchestration** — This is a personal tool, not a shared service for 100+ people
- **Real-time collaboration** — You can't sync context with teammates live within the conversation
- **Production agent** — No observability, no audit logs, no error recovery mechanisms

What it *is*:

- **A prototype platform** for demonstrating how agents work with external context
- **A learning tool** to understand agent architecture, skills design, and tool integration
- **A personal productivity multiplier** that saves repeated typing and standardizes your work
- **A foundation** you can extend toward team or production use cases

### Limitations You'll Hit

#### 1. Static Context

Skills are baked into the IDE when you run `install.sh`. They don't update dynamically when you change them — you must:

1. Edit a skill
2. Save the file
3. Restart your IDE or chat session

**Workaround for teams**: Use the `personal-agent-skills` repo as a source, symlink it into `install.sh`, and redeploy regularly. See [Internal Org Skills Repositories](#internal-org-skills-repositories) below.

#### 2. No Observability

When the agent makes a mistake, you don't know why. There are no logs, no trace of what context was loaded, no audit of tool calls. Debugging is manual — read the conversation, re-examine the skill that was loaded, look at what the agent did.

**Workaround for teams**: Implement structured logging in your tools (MCPs and shell scripts) so you can see what actually happened.

#### 3. Context Window Pressure

Your context budget is fixed (~200K tokens for Claude). Every skill, every instruction, every tool schema crowds out your actual conversation. There's no smart ranking or retrieval — you either loaded the skill or you didn't.

**Workaround**: Be ruthless about what you install. Use the persona templates and only install what you actually use. Audit quarterly.

#### 4. No Real-Time Sync Across Machines

If you use multiple machines (laptop, desktop, server), each one runs `install.sh` independently. Changes to your skills don't automatically sync across machines — you must push to Git and pull on each machine.

**Workaround for teams**: Automate via CI/CD — on every push to `main`, deploy to all company machines via Ansible or similar.

#### 5. IDE-Specific Friction

Each IDE (VS Code, Cursor, Claude Code) has different paths, config formats, and capabilities. The installer tries to be idempotent, but gotchas exist (e.g., `.cursor/mcp.json` format differs from `.vscode/mcp.json`).

**Workaround**: Document IDE-specific quirks in [IDE Setup](ide-setup.md). Test on all three IDEs before releasing.

---

## Productionizing Personal Agent

If you want to move from a personal prototype toward a team or organization-scale agent, here's a high-level roadmap:

### Stage 1: Personal Prototype (Where You Are Now)

**Characteristics:**
- Single user
- Local LLM or API key on your machine
- Skills versioned in Git, deployed via `install.sh`
- No observability or audit logs

**Time to value:** Hours. Install, add a few skills, run `install.sh`.

**Scaling limit:** One person, one machine at a time.

### Stage 2: Team Assistant (Building Block: personal-agent-skills)

**Changes needed:**

1. **Centralized skill library** — Move all domain skills to a dedicated `personal-agent-skills`-like repo (or use ours). Organize by persona/tag. Implement pre-commit auditing (we've built this for you).

2. **Internal org skills repo** — Create a sister repo for org-specific skills (workflows, standards, internal tool integrations). See [Internal Org Skills Repositories](#internal-org-skills-repositories).

3. **Installation automation** — Instead of each person running `install.sh` manually, use CI/CD to push skill updates when they merge to `main`:
   ```bash
   # On every push to main: deploy skills to all team members' machines
   ./install.sh /path/to/personal-agent-skills
   ./install.sh /path/to/internal-org-skills
   ```

4. **Skill versioning** — Tag releases of skills (`v1.0`, `v1.1`, etc). Pin teams to specific versions.

5. **Shared MCP servers** — Some MCPs (GitHub, Slack, Postgres) become team infrastructure. Document setup in [MCP Servers](mcp-servers.md).

**Time to value:** Weeks. Set up repos, CI/CD, onboarding docs.

**Scaling limit:** ~50 people. Each person still runs locally; infrastructure is just skills + MCPs.

### Stage 3: Organizational Agent (Move to Cloud)

**Changes needed:**

1. **Centralized backend** — Instead of each person's local IDE, run a cloud-hosted agent service. Options:
   - LLM API endpoint (OpenAI, Anthropic, etc.)
   - Self-hosted LLM (LLaMA, Mistral) in Kubernetes
   - Custom wrapper around a large language model

2. **Context service** — Store skills, instructions, and MCP configs in a database. Implement:
   - Retrieval-augmented generation (RAG) instead of pre-loading all skills
   - User/role-based access (which skills can user X see?)
   - Versioning and rollout workflows

3. **Tool service** — Instead of shell scripts on each machine, run tools centrally:
   - HTTP service that wraps MCP tools
   - Proper authentication, rate limiting, audit logging
   - Fine-grained permissions (which tools can user X call?)

4. **Observability** — Essential at this scale:
   - Structured logging of all agent decisions
   - Distributed tracing (what skills were loaded, what tools were called)
   - Error tracking and alerting

5. **Multi-turn conversations** — Persist conversation state across sessions (this is new):
   - Message history in a database
   - User preferences and learned patterns
   - Context window optimization (cache, summarization)

**Time to value:** Months. Build the platform, migrate users, iterate.

**Scaling limit:** Organization-wide (1000s of users).

### Comparison

| Aspect | Stage 1 (Personal) | Stage 2 (Team) | Stage 3 (Org) |
|--------|---|---|---|
| **Users** | 1 | 5-50 | 50+ |
| **Deployment** | Manual (`install.sh`) | CI/CD + scripts | Cloud service |
| **Context** | Local, pre-loaded | Local, pre-loaded | Remote, RAG-retrieved |
| **Tools** | Shell scripts | Shared MCPs | Centralized HTTP service |
| **Observability** | Manual debugging | Structured logs | Full tracing + audit |
| **Cost** | Free (your machine) | Low (infrastructure) | Higher (servers + LLM API) |
| **Maintenance** | Low | Medium | High |

---

## Internal Org Skills Repositories

If you're building skills for your organization (not sharing publicly), create an internal `personal-agent-skills`-like repo:

```
my-org-agent-skills/
├── README.md                          ← installation and contribution guide
├── skills/
│   ├── internal-processes/
│   │   └── SKILL.md                   ← e.g., expense approval workflow
│   ├── company-standards/
│   │   └── SKILL.md                   ← e.g., code style rules, doc templates
│   └── tool-integrations/
│       └── SKILL.md                   ← e.g., how to use internal Jira setup
├── instructions/
│   └── internal-policies.instructions.md
├── docs/
│   ├── README.md
│   └── contributing.md
└── .hooks/
    └── audit-skills                   ← same pre-commit audit script
```

### Key Differences from Public Skills

1. **Organization-specific content is OK** — Internal skills *should* reference company tools, workflows, and standards.

2. **No persona filtering needed** — If it's your company, everyone in a role sees the same skills. You don't need the public library's persona tags.

3. **Stricter governance** — Audit internal skills for:
   - Compliance violations
   - Outdated information (skills referencing deprecated systems)
   - Security (no hardcoded credentials, API keys, database schemas)

4. **Integration with personal-agent-skills** — Layer them:
   ```bash
   sh ./install.sh                                    # Base framework
   sh ./install.sh /path/to/personal-agent-skills    # Public community skills
   sh ./install.sh /path/to/my-org-agent-skills      # Org-specific skills
   ```
   This lets your team use both public best practices and internal workflows.

### Install Script Modification

Update the base `install.sh` to accept an optional argument for an external skills repo:

```bash
#!/bin/bash
# install.sh [path-to-external-skills-repo]

EXTERNAL_SKILLS_REPO=${1:-}  # optional second arg

# Symlink base framework skills
# ...

# If external repo provided, symlink those too
if [[ -n "$EXTERNAL_SKILLS_REPO" ]]; then
  echo "Symlinking external skills from $EXTERNAL_SKILLS_REPO"
  for skill_dir in "$EXTERNAL_SKILLS_REPO"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    # ... symlink to IDE directories
  done
fi
```

Team members run:
```bash
./install.sh /path/to/my-org-agent-skills
```

This merges all skills into their IDE context.

For a symlink-first workflow that keeps external repos as source of truth, see
[Following External Skills Repositories](following-skills-repos.md).
