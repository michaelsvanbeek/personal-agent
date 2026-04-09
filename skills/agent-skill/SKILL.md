---
name: agent-skill
description: >-
  Best practices for writing, organizing, and maintaining AI agent skills. Use
  when: creating a new skill, reviewing an existing skill for quality, deciding
  skill granularity and boundaries, writing skill descriptions for retrieval
  optimization, structuring skill content for agent consumption, auditing a
  skill library for gaps or overlap, or improving how skills are discovered
  and loaded by the IDE.
---

# Agent Skill Design

## When to Use

- Creating a new skill from scratch
- Reviewing or improving an existing skill
- Deciding whether to split or merge skills
- Writing descriptions that optimize for IDE retrieval
- Organizing a growing library of skills
- Auditing skills for quality, overlap, or gaps

---

## What Makes a Good Skill

A skill is a self-contained reference document that gives the AI agent domain
expertise it doesn't have out of the box. The best skills share these traits:

| Trait | Why it matters |
|-------|---------------|
| **Discoverable** | The IDE finds and loads it when relevant |
| **Prescriptive** | Tells the agent what to do, not just what exists |
| **Scoped** | Covers one coherent domain, not everything |
| **Concrete** | Includes examples, templates, and code samples |
| **Concise** | Fits within context window limits (200-400 lines ideal) |

---

## Anatomy of a SKILL.md

### YAML Frontmatter

```yaml
---
name: skill-name
description: >-
  One-sentence domain summary. Use when: trigger 1, trigger 2, trigger 3,
  trigger 4, or trigger 5.
---
```

**Rules:**
- `name` must match the directory name exactly
- `description` determines whether the skill is ever loaded — it is the most
  critical field
- Use the pattern: `<domain summary>. Use when: <comma-separated triggers>.`
- Include 3-7 specific triggers in the "Use when:" clause
- Triggers should be actions a user would ask an agent to perform

### Content Sections

A well-structured skill follows this pattern:

```markdown
# Skill Title

## When to Use

Bullet list expanding on the frontmatter triggers. Each bullet is a concrete
scenario where this skill applies.

## Core Sections (2-5 sections)

Domain knowledge organized by topic. Each section should be independently
useful — the agent may reference just one section during a conversation.

## Examples

Concrete code samples, templates, or patterns. Show the right way, and
optionally contrast with the wrong way.

## Anti-patterns (optional)

Common mistakes and why they're wrong. Helps the agent avoid generating
bad output.
```

---

## Writing Effective Descriptions

The description is the retrieval key. The IDE reads it to decide whether to
load the skill. If the description doesn't match the conversation, the skill
is invisible.

### Formula

```
<What this skill covers in one sentence>.
Use when: <action 1>, <action 2>, <action 3>, <action 4>, or <action 5>.
```

### Good descriptions

```yaml
description: >-
  REST API design conventions and contract standards. Use when: designing
  API endpoints, defining request/response schemas, implementing pagination,
  versioning APIs, adding rate limiting, or reviewing existing APIs for
  consistency.
```

```yaml
description: >-
  Git commit, branching, and documentation conventions. Use when: writing
  commit messages, creating branches, preparing pull requests, reviewing
  changelogs, or establishing git workflow standards.
```

### Bad descriptions

```yaml
# Too vague — matches everything, helps nothing
description: "Coding best practices."

# Missing triggers — IDE can't match to conversations
description: "Everything about databases."

# Too specific — only one narrow trigger
description: "How to write a PostgreSQL index."
```

### Trigger word strategy

Use verbs that match how users phrase requests to AI agents:

| Verb | Signal |
|------|--------|
| designing | Creating something new |
| implementing | Building a specific feature |
| reviewing / auditing | Checking existing work |
| debugging / fixing | Solving a problem |
| choosing / deciding | Making a technical decision |
| configuring / setting up | Initial setup or configuration |
| migrating | Moving from one approach to another |

---

## Granularity: Scoping Skills

### The domain test

A skill should cover one domain — a cohesive area of expertise that a person
could reasonably specialize in.

| Scope | Example | Verdict |
|-------|---------|---------|
| One tip | "Always use trailing commas" | Too narrow — this is a bullet point |
| One topic | "REST API design" | Right size |
| One discipline | "Backend engineering" | Too broad — split into API, database, auth, etc. |

### Splitting rules

Split a skill when:
- It exceeds 500 lines
- It covers topics that don't reference each other
- The description needs unrelated "Use when" triggers
- Different users would want different subsets of the content

### Merging rules

Merge skills when:
- They're under 50 lines each
- They share most of the same triggers
- One frequently references the other
- They cover the same domain from slightly different angles

### Overlap between skills

Some overlap is fine — "git-workflow" might mention commit messages and
"code-review" might reference commit conventions too. The rule: each skill
should be self-contained enough to be useful on its own, but reference other
skills for depth.

```markdown
For full commit message conventions, see the **git-workflow skill**.
```

---

## Content Principles

### Be prescriptive

Tell the agent what to do, not what exists:

```markdown
<!-- Prescriptive (good) -->
## Error Responses

Return errors as JSON with `error` and `message` fields:
{ "error": "not_found", "message": "User 123 does not exist" }

<!-- Descriptive (less useful) -->
## Error Responses

There are many ways to format error responses. Some APIs use
HTTP status codes, others use error objects...
```

### Include concrete examples

Every major section should have at least one example. The agent learns by
example more reliably than by abstract description.

```markdown
## Commit Messages

### Good

feat(auth): add refresh token rotation

### Bad

update auth stuff
```

### Use tables for structured knowledge

Tables are dense and scannable — ideal for agent context:

```markdown
| HTTP Method | Use for | Idempotent |
|-------------|---------|------------|
| GET | Read | Yes |
| POST | Create | No |
| PUT | Replace | Yes |
| PATCH | Partial update | No |
| DELETE | Remove | Yes |
```

### Keep it under 400 lines

Context windows are finite. Long skills crowd out other context the agent
needs (file contents, conversation history, other skills). If a skill exceeds
400 lines:

1. Cut encyclopedic background — the agent already knows general concepts
2. Consolidate repetitive examples
3. Split into two skills if the content is naturally separable

---

## Organizing a Skill Library

### Directory structure

```
skills/
├── api-design/SKILL.md
├── code-review/SKILL.md
├── database/SKILL.md
├── git-workflow/SKILL.md
├── testing/SKILL.md
└── ...
```

One directory per skill. The directory name matches the `name` field in
frontmatter. No nesting — all skills are top-level.

### Naming conventions

- Use `kebab-case`: `api-design`, not `apiDesign` or `API_Design`
- Use nouns or noun phrases: `git-workflow`, `error-handling`
- Be specific: `python-testing` over `testing` if you also have
  `javascript-testing`
- Avoid redundant prefixes: `database`, not `skill-database`

### Auditing for gaps

Periodically ask:

1. **What do I repeat in code reviews?** — That's a skill.
2. **What conventions does the agent get wrong?** — That's a skill.
3. **What decisions do I make the same way every time?** — That's a skill.
4. **What would a new team member need to learn?** — That's a skill.

### Auditing for quality

For each skill, check:

- [ ] Description has 3+ specific "Use when" triggers
- [ ] Content is prescriptive (actions, not descriptions)
- [ ] Has concrete examples with code blocks
- [ ] Under 500 lines
- [ ] No stale or outdated guidance
- [ ] References other skills where appropriate
- [ ] No personal data or internal URLs

---

## Testing a Skill

After creating or updating a skill:

1. **Run the installer**: `./install.sh`
2. **Open a fresh IDE chat**
3. **Ask a question that should trigger the skill**
4. **Verify the agent's response reflects the skill's guidance**

If the skill isn't loaded:
- Check the description — does it match the question you asked?
- Check the symlink exists in the IDE's skill directory
- Restart the IDE — some cache skill lists at startup
