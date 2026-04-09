# Context Management

Personal Agent is designed around the principle that **context budget is finite**. This document explains what gets loaded into your agent's context, when, and how to decide what content should live in each construct (skills, instructions, tools, MCP servers).

## What Gets Loaded and When

### Quick Reference Table

| Content Type | Where | When Loaded | Dynamic? | Limit | Purpose |
|---|---|---|---|---|---|
| **Instructions** | `.instructions.md` files | Always, on startup | Fixed per file | ~1-3 per repo | Always-on constraints and conventions |
| **Skills** | `skills/*/SKILL.md` files | On-demand, if description matches conversation context | Fixed per skill | ~50-100 searchable | Domain knowledge + when-to-use triggers |
| **Tools** | `~/.local/bin/` executables | On-demand, if user or agent invokes by name | Dynamic per tool | Unlimited | Executable scripts that modify/query systems |
| **MCP Servers** | IDE config (`mcp.json`, `claude_desktop_config.json`) | On connection, persistent per IDE session | Dynamic per server | 5-15 active | Live API connections (GitHub, Slack, Figma, etc) |

---

## Fixed vs Dynamic Content

### Fixed Content (Never Changes During a Conversation)

**Instructions** (`instructions/*.instructions.md`)
- Loaded once at startup and remain active for the entire conversation
- Should contain universal constraints, code style rules, and workflow conventions
- Examples: "Always follow Conventional Commits", "Run tests before committing", "Use type hints"
- **Rule of thumb**: If it applies to 95% of conversations, it's an instruction

**Skills** (`skills/*/SKILL.md`)
- Loaded on-demand once you describe a task matching the skill's "Use when:" triggers
- Once loaded, the skill stays in context for the conversation (it's not reloaded per message)
- Contains detailed domain knowledge, checklists, templates, examples
- **Rule of thumb**: If it's rarely needed but contains 500 lines of details when needed, it's a skill

### Dynamic Content (Changes Across Connections)

**MCP Servers** (in IDE config)
- Established at the start of an IDE session
- Persist for the lifetime of the IDE process
- Provide live, real-time access to external APIs
- Can be enabled/disabled by restarting the IDE
- Examples: GitHub API, Slack, Google Drive, Jira, Figma
- **Rule of thumb**: If you need live data or the ability to modify external systems, use an MCP

**Tools** (`tools/*.sh` scripts)
- Executable scripts in `~/.local/bin/`
- Invoked on-demand by the user or agent
- Can be more complex than MCP commands, with local filesystem access
- Updated independently from agent context
- Examples: git post-commit hooks, data processing scripts, CI helpers
- **Rule of thumb**: If it's a shell script that needs Unix pipes and file I/O, it's a tool

---

## Routing: Which Construct For What?

### Decision Matrix

**Is this a code style rule, convention, or always-on constraint?**
- → **Instruction** (e.g., "Always run `ruff format` before committing")

**Is this domain knowledge that gets loaded on-demand when someone asks about a topic?**
- → **Skill** (e.g., "testing strategy", "caching patterns", "API design")

**Do you need to query or modify an external system (GitHub, Slack, Figma, etc) in real-time?**
- → **MCP Server** (e.g., GitHub, Slack, Google Docs, Jira)

**Is this a CLI command or script that runs locally on the developer's machine?**
- → **Tool** (e.g., `pre-commit-hook`, `format-code`, `sync-data`)

### Real-World Examples

#### "How to write good commit messages"
- **Instruction** (`git-commits.instructions.md`): "Follow Conventional Commits format. Type, scope, subject"
- **Skill** (`skills/git-workflow/SKILL.md`): Full style guide with templates, examples, anti-patterns, real commit history

*Decision*: Both. Instruction is quick reference (1-2 sentences). Skill is detailed knowledge loaded on-demand.

#### "How to run tests before pushing"
- **Tool** (`tools/pre-commit-hook`): Shell script that runs `pytest` locally
- **Instruction** (`testing.instructions.md`): "Never push without running tests locally"

*Decision*: Both. Instruction sets the rule. Tool automates enforcement.

#### "How to format Python code"
- **Instruction** (`python.instructions.md`): "Run `ruff format .` before committing"
- **MCP***: Not needed (formatting is local)
- **Skill**: Could contain detailed ruff config options, but unnecessary if the instruction is clear

*Decision*: Instruction only. No skill needed unless the user commonly asks for deep ruff customization.

#### "How to open a pull request"
- **MCP Server**: GitHub MCP (query repos, create PRs, comment on issues)
- **Skill** (`skills/git-workflow/SKILL.md`): "Best practices for PR descriptions, review process, merge strategies"

*Decision*: Both. MCP handles the mechanics. Skill handles the best practices.

#### "Personal marketing strategy for my startup"
- **Skill** (`skills/marketing-strategy/SKILL.md`): "Market sizing, go-to-market channels, positioning"
- **Tool**: Not applicable
- **MCP**: Not needed (marketing is planning, not system queries)
- **Instruction**: Only if there's a company-wide marketing policy

*Decision*: Skill only. High-value domain knowledge, loaded on-demand when user asks for marketing help.

---

## Instruction vs Skill: The Complete Guide

### Instruction is Better When

- **It's a rule, not a reference.**  
  Example: "Always run linters before committing" (instruction) vs "How to configure ESLint" (skill)

- **It applies to nearly all work in the project.**  
  Example: "Use type hints in Python" vs "Deep dive on Python's typing module" (skill)

- **You want to constrain behavior universally.**  
  Example: "Use double quotes for strings" vs "String quoting conventions and trade-offs" (skill)

- **Breaking the rule would be surprising.**  
  Example: "Never commit console.log" vs "Debugging strategies and best practices" (skill)

- **It's concise: <100 lines total.**  
  Example: Code style rules vs comprehensive design philosophy

### Skill is Better When

- **It's knowledge the user asks about explicitly or a specific task triggers.**  
  Example: User asks "how do I design an API?" → load `api-design` skill

- **It contains detailed guidance: checklists, templates, examples, anti-patterns.**  
  Example: "Testing strategy" skill with 300+ lines of guidance on test boundaries, mocking, coverage

- **It's specialized knowledge for a specific domain/role.**  
  Example: `meeting-agendas` skill for managers, `code-review` skill for developers

- **It applies to <80% of work or is niche.**  
  Example: "Advanced caching strategies" vs "Never cache without thinking" (instruction)

- **It would clutter instructions if included inline.**  
  If merging a skill into an instruction would exceed 150 lines, keep it as a skill.

### Example Boundary

**"How to write tests"**

| Aspect | Instruction or Skill? | Example |
|---|---|---|
| "Always write tests for new code" | Instruction | In `testing.instructions.md` |
| "80-90% coverage target, branch coverage, test boundaries (unit/integration/e2e)" | Skill | In `skills/testing/SKILL.md` |
| "How to run the test suite" | Either (if simple, instruction; if complex, skill) | Instruction if `npm test` works; skill if it requires setup |
| "How to mock external APIs in tests" | Skill | In `skills/testing/SKILL.md` with examples |

---

## Installation Flow: Loading Content Into Your IDE

### 1. Install Scripts Symlink Content

```bash
./install.sh
```

This runs once after cloning the repo and sets up:

- **Skills**: Symlinks all `skills/*/SKILL.md` → IDE skills directories  
  (How IDE finds skills for on-demand loading)
- **Instructions**: Symlinks `instructions/*.instructions.md` → IDE config  
  (How IDE loads always-on rules)
- **Tools**: Symlinks `tools/*.sh` → `~/.local/bin/`  
  (How you run tools from terminal)

### 2. IDE-Specific Config for MCP Servers

MCP servers are configured in IDE-specific files (not symlinked):

- **VS Code**: `.vscode/mcp.json` (symlinked from repo)
- **Cursor**: `.cursor/mcp.json` (symlink, similar structure)
- **Claude Code**: `~/.claude/claude_desktop_config.json` (manual setup)

To add an MCP:
1. Edit the corresponding `mcp.json` file in `configs/vscode/` or `configs/cursor/`
2. Run `./install.sh` again to symlink the updated config
3. Restart the IDE to activate the MCP

### 3. On Demand: Skills Are Loaded Dynamically

When you describe a task, the IDE searches your skills' "Use when:" descriptions:

- "Design a REST API" → loads `api-design` skill
- "Write tests for this module" → loads `testing` skill
- "Plan a marketing launch" → loads `marketing-strategy` skill

The skill stays loaded for the conversation. You don't reload it per message.

---

## Context Budget: How Much is Too Much?

Personal Agent is designed for a developer/manager working **locally on their machine**. The agent has:

- **~200K tokens** budget per conversation
- **~1-2MB** of skill knowledge available
- **~10-15 MCP servers** reasonably connected
- **No internet-scale retrieval** (all context is preloaded)

### Budget Rules of Thumb

| Content | Limit | Reason |
|---|---|---|
| Total skills in repo | 50-100 | Easier to search, faster IDE indexing |
| Active instructions | 3-5 | More instructions = more constraints to track |
| Active MCP servers | 10-15 | Each MCP consumes setup complexity |
| Skill file size | <500 lines | Keeps skills digestible, focused |
| Instructions per file | <150 lines | Easier to parse and apply |

**If you exceed these limits**, your context will fill rapidly, and the agent will struggle to focus on the task at hand.

---

## Example: Adding Support for a New Tool

You want to add support for handling complex Git workflows. Where does content go?

1. **Instruction** (`instructions/git-commits.instructions.md`):  
   "Always follow Conventional Commits. Type, scope, subject."  
   (1-2 lines: universal rule)

2. **Skill** (`skills/git-workflow/SKILL.md`):  
   "Detailed guide to commits, branching, PR descriptions, merge strategies"  
   (300 lines: detailed domain knowledge, examples, templates)

3. **Tool** (`tools/conventional-commit.sh`):  
   Bash script to auto-generate commit message based on branch name + changes  
   (Interactive shell script: local automation)

4. **MCP Server** (if needed):  
   GitHub MCP to query open PRs, create PRs, comment on issues  
   (Live API integration: only if you need real-time GitHub access)

This layering ensures:
- The rule is always enforced (instruction)
- Detailed guidance is available when needed (skill)
- Common workflows are automated (tool)
- External systems can be queried live (MCP)

---

## Linking & Discovery

All content should be discoverable through links:

- **README.md links to docs/** — Start here
- **docs/README.md links to all guides** — Navigation hub
- **docs/design.md links to docs/context-management.md** — Design rationale
- **docs/context-management.md (this file) links back to skills/** — Bidirectional
- **Each skill links to relevant instructions and tools** — Cross-references

When adding new content:
1. Update the docs index (`docs/README.md`)
2. Add reciprocal links in related documents
3. Link from the top-level README if it's a significant addition

---

## Next Steps

- **To understand the design philosophy**: Read [Design Philosophy](design.md)
- **To see example personas and what they need**: Read [Design Philosophy - Example Personas](design.md#example-personas)
- **To add a new skill**: See [Building Skills](building-skills.md) and [agent-skill SKILL.md](../skills/agent-skill/SKILL.md)
- **To add a new instruction**: See [Building Instructions](building-tools.md#instructions)
- **To create an org-specific skills repository**: See [personal-agent-skills: Internal Skills Repositories](https://github.com/michaelsvanbeek/personal-agent-skills/blob/main/docs/internal-org-skills.md)
