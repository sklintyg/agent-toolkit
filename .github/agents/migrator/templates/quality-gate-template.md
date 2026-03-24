---
description: Configurable quality gate for a migration project. Copy to `.github/migration/[app]-quality-gate.md` and fill in the commands before Phase 2 begins. The Migrator agent reads this file before every VALIDATE step and runs exactly the commands listed here.
---

# Quality Gate — [APP]

> **How this file works**
>
> The Migrator agent reads this file before every VALIDATE step in Phase 2.
> It runs the commands you define in the sections below and treats any failure as a
> build failure — the increment cannot be marked done until all configured checks pass.
>
> Leave a section **blank** or mark it `skip` to disable that check for this project.
> Add extra rows to any table for project-specific checks.

---

## Build

Command the agent must run to build the application after every increment.

| # | Command | Working directory | Must pass? |
|---|---------|------------------|------------|
| 1 | `npm run build` | `apps/[app]/` | ✅ Yes |
| *(add / edit)* | | | |

---

## Type Check

Static type checking to run after every increment (in addition to IDE problems).

| # | Command | Working directory | Must pass? |
|---|---------|------------------|------------|
| 1 | `npx tsc --noEmit` | `apps/[app]/` | ✅ Yes |
| *(add / edit)* | | | |

---

## Lint

Linting to run after every increment.

| # | Command | Working directory | Must pass? |
|---|---------|------------------|------------|
| 1 | `npx eslint src --max-warnings 0` | `apps/[app]/` | ✅ Yes |
| *(add / edit)* | | | |

---

## Tests

Test suites to run after every increment. The agent always runs the **full** suite (not just tests related to the current increment) to catch cumulative regressions.

| # | Command | Working directory | Scope | Must pass? |
|---|---------|------------------|-------|------------|
| 1 | `npx vitest run` | `apps/[app]/` | All unit + integration tests | ✅ Yes |
| *(add / edit)* | | | | |

> **Note:** Add additional rows for e2e test suites, coverage thresholds, or workspace-level test commands.

---

## Application Start

Verify the application starts successfully after every increment (or only for specific increment types — configure below).

| Setting | Value |
|---------|-------|
| Run start check? | `yes` / `no` / `high-risk increments only` |
| Start command | `npm run dev` |
| Working directory | `apps/[app]/` |
| Health-check URL | `http://localhost:5173` |
| Expected status | `200` |
| Startup timeout | `30s` |

---

## Custom Checks

Any additional project-specific checks to run after every increment (e.g. bundle size limits, custom scripts, security scanners).

| # | Description | Command | Working directory | Must pass? |
|---|-------------|---------|------------------|------------|
| *(add rows as needed)* | | | | |

---

## Increment-Specific Overrides

If certain increments require a different check configuration (e.g. tests are expected to fail mid-refactor before a later increment restores them), document the override here. The agent will apply the override **only** for the named increment.

| Increment name | Section overridden | Override value | Reason |
|----------------|-------------------|----------------|--------|
| *(add rows as needed)* | | | |

---

## Notes

- The agent will report each check in the VALIDATE block using the label from the **Description** column (or the command if no description is given).
- Commands are run exactly as written — include all flags.
- If a command is missing a working directory it defaults to the repository root.
