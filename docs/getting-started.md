# Getting Started

A step-by-step guide to setting up your personal agent from scratch.

## Prerequisites

- **Git** — to clone and version-control your agent
- **A supported IDE** — VS Code with GitHub Copilot, Cursor, or Claude Code
- **A terminal** — bash or zsh on macOS/Linux (WSL on Windows)

## Step 1: Clone the Repo

```bash
git clone https://github.com/YOUR_USERNAME/personal-agent.git
cd personal-agent
```

> Replace `YOUR_USERNAME` with your GitHub handle after forking.

## Step 2: Run the Installer

```bash
chmod +x install.sh
./install.sh
```

The installer symlinks your skills and instructions into each IDE's expected
directories. You'll see color-coded output:

- `✓` — newly linked
- `~` — already linked (no change)
- `→` — informational (e.g., no tools found yet)
- `✗` — error

## Step 3: Verify in Your IDE

Open your IDE and start a new AI chat. Ask:

```
What skills do you have available?
```

The agent should list the starter skills (agent-skill, agent-integrator,
git-workflow, markdown-docs). If it doesn't, check the
[IDE Setup](ide-setup.md) guide for your specific editor.

## Step 4: Write Your First Skill

Create a skill for something you repeat often. Good first skills:

| Idea | What it captures |
|------|-----------------|
| **Code review checklist** | Your team's review standards |
| **API conventions** | Endpoint naming, error formats, pagination |
| **Testing patterns** | How you structure tests, what to mock |
| **Project scaffolding** | Boilerplate for new modules or services |

### Create the skill

```bash
mkdir -p skills/code-review
```

Create `skills/code-review/SKILL.md`:

```markdown
---
name: code-review
description: >-
  Code review standards and checklist. Use when: reviewing a pull request,
  preparing code for review, or establishing review guidelines.
---

# Code Review Standards

## When to Use

- Reviewing a pull request
- Preparing code for review
- Writing review comments

## Checklist

- [ ] Linter passes with no warnings
- [ ] Tests cover the changed behavior
- [ ] No hardcoded secrets or credentials
- [ ] Error handling covers failure cases
- [ ] Documentation updated if behavior changed
```

### Install it

```bash
./install.sh
```

### Test it

Open a chat and ask:

```
Review this code for issues — use the code-review skill.
```

## Step 5: Connect an MCP Server (Optional)

MCP servers give your agent live access to external systems. See the
[MCP Servers](mcp-servers.md) guide for setup instructions and a directory of
available servers.

## Next Steps

- Read the [Design Guide](design.md) to understand the architecture
- Read [Building Skills](building-skills.md) for skill writing best practices
- Browse the [MCP Servers](mcp-servers.md) directory for useful connections
- Read [Building Tools](building-tools.md) to add CLI automation

## Example Prompts to Try

Once installed, try these prompts to see your agent in action:

```
Help me write a commit message for the changes I just made.
```

```
I'm starting a new Python project. What should the README include?
```

```
I need to decide between building a custom tool or using an existing
MCP server for accessing my calendar. Help me evaluate the options.
```

```
Review this function and suggest improvements based on our code
review standards.
```
