---
description: Capture a visual and behavioural baseline of the running application before any migration code changes are made. Produces timestamped screenshots, console error logs, and network call records that become the truth anchor for all post-increment comparisons.
input: Running application URL and top-level routes/flows
output: .github/migration/screenshots/baseline/ directory and the initial [APP]-exploratory-report.md
---

# Skill: Capture Exploratory Baseline

## Purpose
Establish what the application looks like and how it behaves *before a single line is changed*.
This is purely informational — no comparison, no gates. The output is the anchor that
`verify-increment.md` will diff against after every significant increment.

Run once: at the end of Phase 1, after the progress document is created and before Phase 2 begins.

---

## Step 0 — Confirm Prerequisites

```
🌐 Baseline Capture — Prerequisites

Base URL:       [ask developer if not already known]
Auth required:  [yes / no]
Output:         .github/migration/screenshots/baseline/

Is the application running and accessible at that URL?
```

Wait for developer confirmation. If the app is not running, record "Baseline not captured — app unavailable" in the progress document and stop.

---

## Step 1 — Confirm Exploratory Scope

The areas to capture were determined and approved by the developer in `plan-migration.md` Step 10.
Do not re-derive the full app structure here — use the agreed scope list from the progress document's **Build / Test Status** section.

If no scope list was recorded (e.g. baseline is being captured independently), derive it now using this filter:

| Include | Exclude |
|---------|---------|
| Pages/routes whose files appear in any increment's scope | Static informational pages with no logic being migrated |
| Flows backed by services, components, or configs being migrated | Admin/internal tooling untouched by migration |
| Areas flagged 🔴 or 🟡 in the risk register | Entire app sections with zero migration surface |
| Shared UI (navigation, layout, auth) | Rarely-used flows in increments rated 🟢 Low risk |

Present the list and wait for confirmation before opening the browser:

```
🗺️ Baseline Exploration Plan — [APP]

Areas to capture ([N] total):
1. [Area name] → [route or URL path]
2. [Area name] → [route or URL path]
...

Excluded: [list with reasons, or "None — all areas are in scope"]

Auth flow: [required / not required]
Estimated screenshots: ~[N]

Proceed?
```

Wait for developer confirmation.

---

## Step 2 — Handle Authentication (if required)

If auth is needed and no saved state exists, open the app and log in manually:

```bash
playwright-cli -s=migration-baseline open [BASE_URL]
```

Navigate to the login page, authenticate, then save state for reuse:

```bash
playwright-cli -s=migration-baseline state-save .github/migration/screenshots/auth.json
```

> **Security:** Never hard-code credentials. Ask the developer to type them in the terminal or load them from a `.env` file. Do not write credentials to any project file.

For all future sessions in this migration, load state with:

```bash
playwright-cli -s=[session] open [BASE_URL]
playwright-cli -s=[session] state-load .github/migration/screenshots/auth.json
```

---

## Step 3 — Capture Each Area

For each area in the plan:

### 3a. Navigate and screenshot

```bash
playwright-cli -s=migration-baseline goto [FULL_URL]
playwright-cli -s=migration-baseline screenshot --filename=.github/migration/screenshots/baseline/[area-name]-initial.png
playwright-cli -s=migration-baseline snapshot --filename=.github/migration/screenshots/baseline/[area-name]-snapshot.yaml
```

### 3b. Record console state

```bash
playwright-cli -s=migration-baseline console
```

Record all `error` and `warning` entries. These are the **pre-migration baseline** — they are not problems to fix, just the starting state.

### 3c. Record network state

```bash
playwright-cli -s=migration-baseline network
```

Record any failed requests (4xx/5xx). Pre-existing failures are noted but not actioned — they matter only if they *appear* after an increment.

### 3d. Interact with primary elements

For each area, interact with the main elements (forms, buttons, navigation, data tables):

```bash
playwright-cli -s=migration-baseline snapshot          # read refs
playwright-cli -s=migration-baseline click [ref]
playwright-cli -s=migration-baseline screenshot --filename=.github/migration/screenshots/baseline/[area-name]-after-[action].png
playwright-cli -s=migration-baseline console           # record any new errors post-interaction
```

### 3e. Scroll to reveal lazy-loaded content

```bash
playwright-cli -s=migration-baseline mousewheel 0 500
playwright-cli -s=migration-baseline screenshot --filename=.github/migration/screenshots/baseline/[area-name]-scrolled.png
```

---

## Step 4 — Close Session

```bash
playwright-cli -s=migration-baseline close
```

---

## Step 5 — Create Exploratory Report

Create **`.github/migration/[APP]-exploratory-report.md`**:

````markdown
# Exploratory Test Report — [APP]

> This report is updated after each high-risk increment and at Phase 3 completion.
> Compare any POST-INCREMENT or FINAL run against the BASELINE section below.

---

## BASELINE
**Date:** YYYY-MM-DD
**URL:** [BASE_URL]
**State:** Before any migration changes

### Areas Captured

| Area | Route | Console Errors | Network Failures | Screenshots |
|------|-------|---------------|-----------------|-------------|
| [Area name] | /route | None | None | [initial](screenshots/baseline/[area]-initial.png) |
| [Area name] | /route | 2 warnings (pre-existing) | None | [initial](screenshots/baseline/[area]-initial.png) · [scrolled](screenshots/baseline/[area]-scrolled.png) |

### Pre-existing Issues (present before migration — not regression targets)
- [Area]: [console error or network failure] — pre-existing, do not count as regression

### Summary
- **Areas captured:** N
- **Pre-existing console errors:** N
- **Pre-existing network failures:** N
````

---

## Step 6 — Present to Developer

```
📸 Baseline Captured — [APP]

Areas captured: N
Screenshots:    .github/migration/screenshots/baseline/
Report:         .github/migration/[APP]-exploratory-report.md

Pre-existing issues noted (will not be counted as regressions):
- [list any pre-existing errors/failures, or "None"]

Phase 2 can now begin. After each 🔴/🟡 risk increment, run verify-increment
to compare the new state against this baseline.
```

Add a "Baseline captured ✅" entry to the **Build / Test Status** section of `[APP]-migration-progress.md`.

---

## Notes
- Capture everything — not just in-scope migration areas. Regressions can appear in untouched areas due to shared state, CSS, or config changes.
- Pre-existing errors are recorded but not flagged as problems. They become the baseline truth, not issues to fix.
- If the application requires complex auth (SSO, MFA), raise an OBSERVE and ask the developer to provide a pre-authenticated `auth.json` state file before proceeding.
