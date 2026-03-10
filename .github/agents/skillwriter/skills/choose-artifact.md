---
description: Determine the right artifact type before building anything.
input: A description of what the developer wants to automate or improve.
output: A recommended artifact type with a brief rationale and proposed file structure.
---

# Skill: Choose Artifact Type

## Step 1 — Ask these questions (all at once, not one by one)

> 1. What problem does this solve, and who uses it?
> 2. Will this be used repeatedly, or is it a one-off?
> 3. Does it need to create/edit files, run searches, or just give advice?
> 4. Is it specific to a language, framework, or project?
> 5. Does it need branching logic or orchestrate multiple steps?

## Step 2 — Apply the decision matrix

| Criteria | → Artifact |
|---|---|
| Repeated task + orchestrates files + branching logic | **AGENT** (+ skills) |
| Repeated task, single clear step | **SKILL** (add to existing agent if possible) |
| Language/framework coding rules | **INSTRUCTION** (`applyTo` glob) |
| One-off, contextual, no file edits needed | **PROMPT** |

## Step 3 — Propose a plan

State clearly:
- Recommended artifact type and why
- Files to create and their paths
- Any existing agent/skill it should extend instead of duplicating

Wait for developer approval before proceeding.

## Example

**Developer says:** "I want help writing Playwright tests following our patterns."

**Analysis:**
- Repeated task ✓, edits test files ✓, needs to reference patterns ✓
- Similar agents exist: `tdd.agent.md`, `test-generator.agent.md` — check if a skill can be added there instead

**Proposal:**
> This looks like a skill for the existing `test-generator` agent rather than a new agent.
> I'd create `.github/agents/test-generator/skills/write-playwright-test.md`.
> Shall I proceed?
