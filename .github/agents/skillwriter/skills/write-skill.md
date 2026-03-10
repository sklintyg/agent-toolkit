---
description: Create a skill .md file for an existing agent.
input: Approved plan + the agent this skill belongs to
output: A complete skill.md file ready to be referenced via #file:
---

# Skill: Write a Skill File

## Structure

Every skill file follows this pattern (see `code-reviewer/skills/analyze-pr.md` as a reference):

```
---
description: [What this skill does in one line]
input: [What the caller provides]
output: [What this skill produces]
---

# Skill: [Name]

## Steps

1. [Concrete action]
2. [Concrete action — include sub-bullets only if a step has real variance]

## Output Format          ← include only if output format is specific

[show the exact structure, e.g. a markdown template]

## Notes                  ← include only if there are non-obvious constraints
- [Edge case or exclusion]
```

## Rules

- **Steps are imperative and concrete** — "Parse the diff" not "You should parse the diff".
- **One example beats three paragraphs** — if a concept is non-obvious, show 1 real case.
- **Output Format section is only needed** when the output must match an exact structure (e.g., a report, a JSON shape, a markdown template).
- **No motivation text** — skills are reference material, not essays. Skip "Why this matters."
- **Keep it under 60 lines** unless examples genuinely require more.

## Checklist

- [ ] frontmatter has description, input, and output
- [ ] steps are numbered and start with a verb
- [ ] any output format is shown as a literal template, not described in prose
- [ ] file is saved under `.github/agents/[agent-name]/skills/[skill-name].md`
- [ ] parent agent references this file with `#file:` 
