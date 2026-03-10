---
description: Create a new .agent.md file following the established patterns in this library.
input: Approved plan from choose-artifact.md
output: A complete agent.md file + scaffolded skills folder
---

# Skill: Write an Agent

## Structure

Every agent file follows this exact pattern (see `code-reviewer.agent.md` as a reference):

```
---
description: '[One sentence: what it does + when to use it]'
tools: ['only', 'the', 'tools', 'it', 'actually', 'needs']
---
You are the [Name] agent. [One sentence: role and value.]

Follow the skills defined in this workspace:
- [Task label]: Follow #file: ./[agent-name]/skills/[skill].md
- [Task label]: Follow #file: ./[agent-name]/skills/[skill].md

Also apply:
- #file: ../instructions/[relevant].instructions.md  (only if applicable)

Key rules:
- [Actionable rule — no "consider" or "try"]
- [Actionable rule with example if helpful]

Output contract:
| Task | Primary Output |
|---|---|
| [Task A] | [Output A] |
```

## Rules

- **description** must state both what it does AND when to use it — this is how Copilot selects the agent.
- **tools**: only include what the agent actually calls. Valid tools: `search/codebase`, `edit/editFiles`, `search/usages`, `search/changes`, `read/problems`, `execute/runInTerminal`, `execute/getTerminalOutput`, `read/terminalLastCommand`.
- **Skills go in files** — never write step-by-step instructions inline in the agent. Put them in `./[agent-name]/skills/`.
- **Key rules** should be ≤8 items, each starting with a verb.
- **Output contract** is optional but recommended for agents with multiple modes.

## Checklist

- [ ] description is one sentence covering purpose + trigger condition
- [ ] tools list has no unnecessary entries
- [ ] all `#file:` paths point to files that exist (or will be created now)
- [ ] key rules are actionable (no "consider", "try", "maybe")
- [ ] a `skills/` folder exists alongside the agent file
