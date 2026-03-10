---
name: migrate-update
description: Update the migration guide and progress document when issues, changed requirements, or new understanding arise during an in-progress migration.
agent: agent
tools:
  - search/codebase
---

# Update Migration

Follow the update skill to correct or extend the migration plan mid-migration.

## Instructions

Follow all steps in `#file:../agents/migrator/skills/update-migration.md`.

## When to use this prompt
- You hit an unexpected issue and the current guide approach won't work.
- Requirements changed or were clarified.
- You identified a better approach for an upcoming or completed increment.
- An `OBSERVE` item has been resolved and the guide needs to reflect the decision.

## Input

Focus area (what part of the migration needs updating):

Problem or concern:

Proposed solution (optional):

Current migration documents: `#codebase` `.github/migration/`