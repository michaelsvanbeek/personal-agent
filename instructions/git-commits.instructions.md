---
applyTo: "**"
---

# Git Commit Discipline

After completing each logical unit of work, commit the changes before moving to
the next task.

## Commit Message Format

Follow Conventional Commits:

```
<type>(<scope>): <subject>
```

- **Subject**: Imperative mood, lowercase, no trailing period, max 72 characters.
- **Scope**: Optional but encouraged — the file, module, or feature area changed.
- **Body**: Add below a blank line if the change needs context; explain *what*
  and *why*, not *how*.

### Types

| Type | When |
|------|------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code restructuring with no behavior change |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `build` | Build config, dependencies |
| `ci` | CI pipeline changes |
| `chore` | Maintenance, tooling, config |

## Commit Rules

- Each commit represents **one logical change** — reviewable on its own.
- Tests must pass on every commit.
- Linting and type checking must pass on every commit.
- Never commit broken or half-finished code.
- Never commit secrets, credentials, or environment files.
- Do not include unrelated cleanup in a feature commit.
