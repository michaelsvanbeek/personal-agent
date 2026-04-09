# Building Tools

How to add CLI tools and automation scripts to your personal agent.

---

## What is a Tool?

Tools are executable scripts in the `tools/` directory. The installer symlinks
them to `~/.local/bin/`, making them available on your PATH.

Tools automate repetitive tasks: scaffolding projects, running audit checks,
generating release notes, or anything else you do often enough to script.

---

## Creating a Tool

### 1. Write the script

Create a file in `tools/` (no file extension):

```bash
#!/usr/bin/env bash
set -euo pipefail

# my-tool — one-line description of what this does

usage() {
    echo "Usage: my-tool <arg>"
    echo ""
    echo "What this tool does and why."
    exit 1
}

[[ $# -lt 1 ]] && usage

# Your logic here
echo "Running with: $1"
```

### 2. Make it executable

```bash
chmod +x tools/my-tool
```

### 3. Install it

```bash
./install.sh
```

The tool is now available as `my-tool` in your terminal.

---

## Tool Conventions

### Naming

- `kebab-case`, no file extension: `scaffold-project`, `lint-all`, `check-deps`
- Name should describe the action: verb-noun format

### Structure

- Start with `#!/usr/bin/env bash` (or `#!/usr/bin/env python3`)
- Set `set -euo pipefail` for bash scripts
- Include a `usage()` function that prints help
- Accept `--help` or `-h` flags
- Use positional arguments for required inputs
- Exit with non-zero codes on failure

### Output

- Keep output concise — tools should be scriptable
- Use color sparingly (only for interactive use)
- Write errors to stderr: `echo "Error: ..." >&2`
- Support piping: don't add decorative output if stdout might be piped

---

## Tool Ideas

| Tool | What it does |
|------|-------------|
| `scaffold-project` | Initialize a new project with boilerplate |
| `lint-all` | Run all linters for the current project type |
| `check-deps` | Audit dependencies for vulnerabilities |
| `release-notes` | Generate changelog from git history |
| `audit-project` | Check a project against your conventions |

---

## Tools vs MCP Servers

Tools and MCP servers both extend what your agent can do, but they serve
different purposes:

| | Tools | MCP Servers |
|-|-------|-------------|
| **Runs when** | You invoke it manually or agent calls it | Agent calls it during conversation |
| **Access to** | Local filesystem, CLI commands | External APIs, databases, services |
| **Stateful** | No (runs and exits) | Can maintain connections |
| **Best for** | Automation scripts, project scaffolding | Live data, external system queries |

See the [agent-integrator](../skills/agent-integrator/SKILL.md) skill for
deeper guidance on when to build custom tools vs use MCP servers.
