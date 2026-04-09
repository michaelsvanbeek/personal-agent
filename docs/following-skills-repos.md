# Following External Skills Repositories

Use this workflow to follow community, organization, and personal skill repositories through your local `personal-agent` checkout.

## Goal

Keep your skills sourced from external repositories while still using `personal-agent` as your central runtime.

This gives you:
- One install flow (`./install.sh`) for all skills
- Automatic updates when external repos change
- Clean git status in `personal-agent` (linked skills are ignored)

## Strategy

1. External repositories stay as the source of truth:
- `personal-agent-skills` for public, broadly accepted skills
- Your org-private skills repo for company-specific practices
- Your personal skills repo for private experiments

2. `personal-agent` tracks links in `skills/linked/`.

3. `skills/linked/` is ignored by git (except placeholders), so local links do not pollute commits.

4. `install.sh` discovers both:
- direct skills in `skills/*`
- linked skills in `skills/linked/*`

## One-Time Setup

1. Clone your repositories:

```bash
cd ~/code
git clone https://github.com/michaelsvanbeek/personal-agent.git
git clone https://github.com/michaelsvanbeek/personal-agent-skills.git
git clone git@github.com:<your-org>/<your-org-agent-skills>.git
```

2. Install base framework:

```bash
cd ~/code/personal-agent
./install.sh
```

3. Link external repositories:

```bash
link-skills-repo add ~/code/personal-agent-skills community
link-skills-repo add ~/code/<your-org-agent-skills> org
link-skills-repo add ~/code/<your-personal-skills> personal
```

4. Re-run installer:

```bash
./install.sh
```

## Daily Workflow

1. Pull updates in external repos:

```bash
cd ~/code/personal-agent-skills && git pull
cd ~/code/<your-org-agent-skills> && git pull
```

2. Re-link (safe to re-run):

```bash
cd ~/code/personal-agent
link-skills-repo add ~/code/personal-agent-skills community
link-skills-repo add ~/code/<your-org-agent-skills> org
```

3. Sync to IDEs:

```bash
./install.sh
```

## Tool Reference

### Add a repository

```bash
link-skills-repo add <repo-path> [alias]
```

- `repo-path` must contain `skills/*/SKILL.md`
- `alias` defaults to the directory name
- links are created as `<alias>--<skill-name>` under `skills/linked/`

### List links

```bash
link-skills-repo list
```

### Remove a repository's links

```bash
link-skills-repo remove <alias>
```

## Conflict Rules

If two repos contain the same skill name:
- links are still unique because names are namespaced by alias
- your IDE sees each linked skill as a separate skill
- to avoid retrieval overlap, keep only one active version of a concept

## Git Behavior

`skills/linked/` is intentionally ignored:
- local symlink changes are not committed by default
- each developer can link different repos without creating git churn
- if you want team-wide linked repos, document the setup steps rather than committing links

## Related Docs

- [Context Management](context-management.md)
- [Design Guide](design.md)
- [Building Skills](building-skills.md)
- [Internal Org Skills Repositories](https://github.com/michaelsvanbeek/personal-agent-skills/blob/main/docs/internal-org-skills.md)
