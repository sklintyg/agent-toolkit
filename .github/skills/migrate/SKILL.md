---
name: migrate
description: Start, continue, or finish a code migration — from Phase 1 planning through Phase 2 implementation to Phase 3 completion.
agent: agent
tools:
  - search/codebase
  - execute/getTerminalOutput
  - execute/runInTerminal
  - read/terminalLastCommand
  - read/terminalSelection
---

# Code Migration

Follow the steps in the migrator agent to perform a structured, incremental code migration.

## Instructions

1. **Determine state** — check whether `.github/migration/` already contains documents for this app.
   - **No documents** → this is a new migration. Begin with Phase 1.
   - **Guide + progress exist** → this is a resumption. Read the progress document and continue from the first incomplete increment.

2. **Follow the appropriate skill:**

   | Phase | Skill |
   |-------|-------|
   | Phase 1 — Build foundation documents | `#file:../agents/migrator/skills/plan-migration.md` |
   | Phase 2 — Execute incremental migration | `#file:../agents/migrator/skills/execute-migration.md` |
   | Mid-migration correction | `#file:../agents/migrator/skills/update-migration.md` |

3. **Key rules:**
   - The requirements document is the highest-priority reference.
   - Every increment must leave the application in a buildable, functional state.
   - Mark all uncertainties and design decisions with `OBSERVE` in the progress document.
   - Never proceed to the next phase without developer approval.
   - Update the progress document after **every** quality-checked increment.

4. **Example templates** are in `.github/agents/migrator/templates/` — reference them for migration-type-specific scaffolds
   (requirements, analysis instructions) but do not modify them during the migration.

## Input

Repository to migrate: `#codebase`

Migration type (if known): [e.g., React 16 → React 18 / WildFly → Spring Boot]
App name (if known): [used to name all documents]
