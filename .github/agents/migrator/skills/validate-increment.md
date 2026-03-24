---
description: Run the configured quality gate checks (build, type check, lint, tests, app start, custom, quality hooks) for a completed increment. Reads commands from [APP]-quality-gate.md. Produces a VALIDATION report and blocks progress on any failure.
input: Completed increment name, [APP]-quality-gate.md, running environment
output: VALIDATION report block — PASS or FAIL per check — appended to the increment entry in [APP]-migration-progress.md
---

# Skill: Validate Increment

## Purpose
After IMPLEMENT, verify the application still compiles, passes all configured quality checks, and runs correctly. Every check is driven by **`.github/migration/[APP]-quality-gate.md`** — that file is the source of truth for what "passing" means on this project.

**Does not assess code quality.** That is the job of the QUALITY CHECK step that follows. This skill only verifies that the code builds and tests pass.

---

## Step 0 — Load Quality Gate Config

Read **`.github/migration/[APP]-quality-gate.md`**.

- **File exists** → proceed with its configured commands.
- **File missing** → stop and raise OBSERVE:
  ```
  OBSERVE — Quality Gate Config Missing

  .github/migration/[APP]-quality-gate.md was not found.
  This file should have been created in Phase 1 (Step 2.7).
  Please create it from agents/migrator/templates/quality-gate-template.md
  and confirm when ready.
  ```
  Wait for developer to confirm the file exists before continuing.

Also check for **increment-specific overrides** in `## Increment-Specific Overrides` — apply any row matching the current increment name before running checks.

---

## Step 1 — Check IDE Problems

Use the `read/problems` tool.

- Any **errors** (not warnings) must be resolved before running any other check.
- If errors are found, stop and report them. Do not proceed until the error count is zero.

---

## Step 2 — Run Configured Checks

For each section in `[APP]-quality-gate.md`, run the configured command(s) in the order listed below. Apply increment-specific overrides (Step 0) before running.

### Command error handling

If a command **cannot be run** — command not found, wrong working directory, missing script, environment not configured — stop immediately and present:

```
⚠️ VALIDATE — Command Error

Check:    [Build / Type Check / Lint / Tests / Application Start / Custom]
Command:  [exact command that failed]
Error:    [the error output]

This looks like a configuration issue, not a code problem. Please update
.github/migration/[APP]-quality-gate.md with the correct command for this
environment, then confirm so I can re-run this check.
```

Do **not** mark this as a code failure. Do **not** try to fix the code. Wait for the developer to update the quality gate file and confirm before re-running.

---

### 2a — Build

Run command(s) from `## Build`. Must pass — a failing build blocks all subsequent checks.

---

### 2b — Type Check

Run command(s) from `## Type Check`. Skip if section is empty or set to `skip`.

---

### 2c — Lint

Run command(s) from `## Lint`. Skip if section is empty or set to `skip`.

---

### 2d — Tests

Run command(s) from `## Tests`.

> **Always run the full suite** — not just tests related to the current increment.
> A passing increment that breaks a previous one is still a failure.

Skip if section is empty or set to `skip` (not recommended).

---

### 2e — Application Start

Follow the `## Application Start` setting:

| Setting value | Run start check? |
|--------------|-----------------|
| `yes` | Always |
| `high-risk increments only` | Only if this increment is tagged 🔴 Critical or 🟡 High in the risk register |
| `no` | Never |

Navigate to the configured health-check URL and verify the expected status within the configured timeout.

---

### 2f — Custom Checks

Run each row in `## Custom Checks` in order. Skip if the section is empty.

---

### 2g — Quality Hooks

If `.github/copilot/pre-push` exists: confirm the hook will run on push.
If it can be run locally, run it now and include the result.
Hook failure is treated the same as a build failure — fix before proceeding.

**What the hook enforces:**

| Stack | Checks |
|-------|--------|
| Java | Compile → Checkstyle → SpotBugs (if configured) → SonarLint BLOCKER/CRITICAL (if installed) → full test suite |
| TypeScript | `tsc --noEmit` → ESLint `--max-warnings 0` → full Vitest/Jest suite |

---

## Step 3 — Report

Present the full VALIDATION report:

```
✅ VALIDATION — [Increment Name]

IDE Problems (read/problems): [PASS / FAIL] [error count if any]
Build:                        [PASS / FAIL] [command] [details]
Type Check:                   [PASS / FAIL / SKIP] [command] [details]
Lint:                         [PASS / FAIL / SKIP] [command] [details]
Full Test Suite:              [PASS / FAIL] [command] [X/Y passing]
Application Start:            [PASS / FAIL / SKIPPED] [details]
[Custom check name]:          [PASS / FAIL / SKIP] [details]
Quality Hook:                 [PASS / FAIL / NOT RUN] [details]

Issues found:
- [list any problems — or "None"]
```

---

## Step 4 — Gate Decision

| Outcome | Action |
|---------|--------|
| All checks PASS | Return ✅ PASS to the caller (`execute-migration.md`). Proceed to QUALITY CHECK. |
| Any check FAIL (code problem) | Return ❌ FAIL. Caller returns to IMPLEMENT with the specific failures listed. Repeat VALIDATE after fixes. |
| Any check errors (config problem) | Blocked — wait for developer to fix quality gate config (Step 2 command error handling). Do not mark as code failure. |
