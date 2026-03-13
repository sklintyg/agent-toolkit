---
name: migrate
description: Start, continue, or finish a code migration — from Phase 1 planning through Phase 2 implementation to Phase 3 completion.
---

Invoke the Migrator agent to plan and execute a structured, incremental code migration.

**To start a new migration:**
Say: "Migrate [APP] from [SOURCE] to [TARGET]."

**To resume an in-progress migration:**
Say: "Continue the [APP] migration." The agent will read the progress document and pick up from the first incomplete increment.

**To update the guide mid-migration** (changed requirements, new findings):
Use the `migrate-update` skill instead.

---

The agent will follow: #file: ../agents/migrator.agent.md
