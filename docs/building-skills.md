# Building Skills

How to write effective skills that your AI agent can discover and use.

---

## What is a Skill?

A skill is a `SKILL.md` file inside a named directory under `skills/`. It
contains domain knowledge the agent loads on demand when the conversation topic
matches.

```
skills/
  api-design/
    SKILL.md       ← the skill content
  testing/
    SKILL.md
```

The agent's IDE reads the YAML frontmatter to decide when to load the skill.
When loaded, the full markdown content becomes part of the conversation context.

---

## SKILL.md Format

Every skill file has two parts: YAML frontmatter and markdown content.

### Frontmatter

```yaml
---
name: api-design
description: >-
  REST API design conventions and contract standards. Use when: designing API
  endpoints, defining request/response schemas, implementing pagination,
  versioning APIs, or reviewing existing APIs for consistency.
---
```

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | Identifier matching the directory name |
| `description` | Yes | How the IDE decides whether to load this skill |

**The description is the most important field.** It determines whether the skill
is ever loaded. Write it as:

1. A one-sentence summary of the domain
2. Followed by "Use when:" with specific trigger scenarios

### Content Structure

```markdown
# Skill Title

## When to Use

Bullet list of concrete scenarios that trigger this skill.

## Core content sections

Domain-specific knowledge organized by topic.

## Examples

Concrete code samples, templates, or patterns.

## Anti-patterns

What to avoid and why.
```

---

## Writing Good Descriptions

The description field is what the IDE uses to match conversations to skills.
A vague description means the skill will rarely (or never) be loaded.

### Good descriptions

```yaml
# Specific triggers, concrete scenarios
description: >-
  REST API design conventions. Use when: designing endpoints, defining schemas,
  implementing pagination, versioning APIs, adding rate limiting, or reviewing
  existing APIs for consistency.
```

```yaml
# Clear domain, actionable triggers
description: >-
  Database migration patterns for zero-downtime deployments. Use when: writing
  SQL migrations, planning breaking schema changes, designing rollback
  strategies, or running data backfills.
```

### Bad descriptions

```yaml
# Too vague — when would the IDE load this?
description: "General coding best practices."

# Too narrow — misses many valid triggers
description: "How to write a REST endpoint."

# No triggers — the IDE can't match this to conversations
description: "Things I've learned about APIs."
```

---

## Granularity: How Big Should a Skill Be?

### One skill per domain

A skill should cover one coherent domain — not one tip, and not an entire
engineering handbook.

| Too narrow | Right size | Too broad |
|-----------|-----------|----------|
| "How to name a REST endpoint" | "REST API design conventions" | "Everything about backend development" |
| "pytest fixture syntax" | "Testing strategy and patterns" | "All Python knowledge" |
| "git commit format" | "Git workflow: commits, branches, PRs" | "Software engineering processes" |

### Signs a skill is too big

- It's over 500 lines — the agent's context window has limits
- It covers unrelated topics — "API design AND database schema AND deployment"
- The description needs multiple "Use when" categories with no overlap

### Signs a skill is too small

- It could be a bullet point in a larger skill
- It's under 30 lines — probably not worth the retrieval overhead
- The description is almost identical to another skill's description

---

## Content Best Practices

### Be prescriptive, not descriptive

Skills should tell the agent what to *do*, not explain concepts in the abstract.

```markdown
<!-- Good: actionable -->
## Endpoint Naming

- Use plural nouns: `/users`, not `/user`
- Use kebab-case: `/user-profiles`, not `/userProfiles`
- Nest for relationships: `/users/{id}/orders`

<!-- Bad: encyclopedic -->
## About REST

REST stands for Representational State Transfer. It was introduced by
Roy Fielding in his doctoral dissertation in 2000...
```

### Include examples

Concrete examples are the most effective way to convey patterns. Show the right
way, and optionally contrast with the wrong way:

```markdown
## Commit Messages

### Good

```
feat(auth): add refresh token rotation

Tokens now rotate on each refresh, reducing the window for token theft.
Refresh tokens expire after 7 days of inactivity.
```

### Bad

```
update auth stuff
```
```

### Use tables for structured comparisons

```markdown
| Pattern | When to use | Example |
|---------|-------------|---------|
| Factory function | Complex object with many fields | `create_user(overrides)` |
| Fixture | Shared test setup | `@pytest.fixture` |
| Builder | Step-by-step construction | `UserBuilder().with_name("Jo").build()` |
```

### Reference other skills

If a topic is covered in depth by another skill, reference it:

```markdown
For full testing patterns, see the **testing skill**.
For commit message conventions, see the **git-workflow skill**.
```

---

## Quality Checklist

Before committing a new skill, verify:

- [ ] **name** field matches the directory name
- [ ] **description** includes "Use when:" with 3+ specific triggers
- [ ] Content is prescriptive (tells the agent what to do)
- [ ] Includes concrete examples with code blocks
- [ ] Under 500 lines (ideally 200-400)
- [ ] No personal data, credentials, or internal URLs
- [ ] Organized with clear headings (`##` sections)
- [ ] Anti-patterns section included where relevant

---

## Example Prompts for Skill Development

When building new skills, try these prompts to test whether the agent loads
and applies them correctly:

```
I'm designing a new REST API for user management. Help me define the
endpoints and response schemas.
```

```
Review this commit history and suggest improvements based on our git
workflow standards.
```

```
I need to write documentation for this module. What should the README
and docs/ structure look like?
```

```
Should I build a custom tool for this, or is there an MCP server I
can use instead?
```
