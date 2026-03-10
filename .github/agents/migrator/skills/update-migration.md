---
description: Update the migration guide and progress document when issues, changed requirements, or new understanding arise during any phase of the migration.
input: Focus area, description of the problem or concern, and optional proposed solution
output: Updated migration guide and progress document, with optional re-execution of the affected increment
---

# Skill: Update Migration (Mid-Migration Corrections)

## When to Use
- An unexpected issue is encountered during Phase 2 implementation.
- Requirements change or are clarified mid-migration.
- A new or better approach is identified for an already-planned increment.
- An `OBSERVE` item is resolved and the guide needs updating.
- The developer wants to change the approach for an upcoming increment.

---

## Step 1 — Gather Context

Ask the developer:

```
🤖 To update the migration documents, I need:

Focus Area: [What part of the migration needs updating?]
  Examples: "state management", "REST controllers", "logging configuration", "component routing"

Problem / Concern: [What issue was encountered or what needs to change?]

Proposed Solution (optional): [Your preferred approach, if you have one]
```

Wait for developer response before proceeding.

---

## Step 2 — Read Current State

Read the following documents to understand the current situation:

1. **Migration guide**: `.github/migration/[APP]-migration-guide.md`
2. **Progress document**: `.github/migration/[APP]-migration-progress.md`
3. **Requirements**: `.github/migration/instructions/[APP]-requirements.md`
4. **Test coverage** (if exists): `.github/migration/[APP]-test-coverage-analysis.md`

Locate the sections relevant to the focus area. Note:
- Current planned approach for that area.
- Which increments have already been completed.
- Any related `OBSERVE` items.

---

## Step 3 — Analyse and Propose Updates

Based on the focus area and problem:

1. Identify all affected sections in the migration guide.
2. Compare the current approach to what is needed.
3. Draft specific, minimal changes.
4. Identify any knock-on effects (dependent increments, already-completed work that may need revisiting).

**Present to developer:**
```
🤖 Analysis

Current Approach:
[Summarise the current approach in the affected section]

Proposed Updates:
1. [Specific change to guide section / increment X]
2. [Specific change to guide section / increment Y]
3. [Progress document update — status changes, new OBSERVE items]

Knock-on Effects:
- [Any completed increments that may need re-visiting]
- [Any upcoming increments affected]

Rationale:
[Why these changes address the problem]

Do you approve these updates?
```

Wait for developer confirmation before making any changes.

---

## Step 4 — Update Documents

After approval:

### Migration Guide (`[APP]-migration-guide.md`)
- Update the affected increment(s) with the new approach.
- Add clarifying steps or examples where needed.
- Ensure the change is consistent with the requirements document — requirements always win.
- Add a note with the change date on significantly modified sections (e.g., `<!-- Updated: YYYY-MM-DD — reason -->`).
- **If this issue stems from a gap in the original analysis or requirements template** — a step that was missing, a pattern that wasn't covered, an assumption that turned out wrong — add a `[TEMPLATE]` tagged note to the progress document's Improvement Feedback section so it is picked up automatically at Phase 3 completion:
  ```
  - [TEMPLATE] Analysis template missing guidance on [X] — add to agents/migrator/templates/[source]-analysis-template.md
  - [TEMPLATE] Requirements template should include [Y] section — add to agents/migrator/templates/[type]-requirements-template.md
  ```

### Progress Document (`[APP]-migration-progress.md`)
- Update the status of affected increments (e.g., re-open a completed increment if it must be revisited).
- Add an `OBSERVE` note if developer review is still needed.
- Add a note explaining why the change was made, for context in future iterations.

### Consistency Check
- Guide and progress document are aligned.
- Updated sections do not conflict with requirements.
- Related increments (earlier or later) are still consistent with the change.

---

## Step 5 — Summarise and Optionally Re-execute

**Present:**
```
✅ Updates Complete

Migration Guide Changes:
- [What was changed and where]

Progress Document Changes:
- [Status updates, new OBSERVE items]

Consistency: [Confirmed / Issues found]
```

**Ask developer:**
```
Would you like me to:
A) Continue migration from where we left off (next incomplete increment)
B) Re-execute the affected increment with the updated approach
C) Review the updated guide section before proceeding
```

Wait for developer response.

---

## Notes
- Keep changes **minimal and targeted** — only update what is needed to address the specific concern.
- If the change affects an already-completed increment, add an `OBSERVE` flag and ask the developer whether to re-do that increment.
- Always document *why* a change was made in the progress document — future iterations depend on this context.
- If the change reveals a broader design problem, flag it as a separate `OBSERVE` rather than trying to fix everything at once.
