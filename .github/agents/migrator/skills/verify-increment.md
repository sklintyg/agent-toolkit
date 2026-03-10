---
description: After a migration increment (or at Phase 3 completion), explore the affected areas of the running application with playwright-cli, compare against the captured baseline, and report regressions — blocking progress on broken areas and asking the developer to confirm intentional changes.
input: Completed increment's PLAN output (affected areas), baseline screenshots from capture-baseline.md, running application URL
output: New section appended to [APP]-exploratory-report.md with screenshot pairs, console diff, network diff, and ✅/⚠️/❌ status per area
---

# Skill: Verify Increment (Exploratory)

## Purpose
After VALIDATE and QUALITY CHECK pass, confirm the running application still behaves correctly
in all areas touched by this increment — and in previously-migrated areas that could have been
affected cumulatively. Compare every signal against the baseline captured in `capture-baseline.md`.

**Does not replace automated tests.** Catches what tests miss: layout shifts, broken navigation,
silent JS errors, failed API calls, missing content, and interaction regressions.

## When to Run
| Trigger | Who calls this |
|---------|---------------|
| After VALIDATE + QUALITY CHECK pass on any 🔴 or 🟡 risk increment | `execute-migration.md` Step 4.5 |
| After Phase 3 final verification passes (full re-run of baseline areas) | `execute-migration.md` Phase 3 |
| On developer request for any other increment | Developer |

**Prerequisite:** `capture-baseline.md` must have run and `.github/migration/screenshots/baseline/` must exist. If no baseline is available, raise OBSERVE and ask the developer whether to capture one now before continuing.

---

## Step 0 — Confirm Prerequisites

```
🔍 Increment Verification — Prerequisites

Increment:    [N — Increment Name]
Phase:        [POST-INCREMENT / FINAL]
Base URL:     [from progress document or ask developer]
Baseline:     .github/migration/screenshots/baseline/ [exists ✅ / missing ⚠️]
Auth state:   .github/migration/screenshots/auth.json [exists ✅ / not needed / missing — will re-auth]
Output:       .github/migration/screenshots/[inc-N / final]/

Is the application running at [BASE_URL]?
```

Wait for developer confirmation.

---

## Step 1 — Derive Scope from Progress Document

Read **`[APP]-migration-progress.md`** — specifically the completed increment's PLAN output:
- "Files to modify" → map to pages/routes these files affect.
- "Potential risks" → any areas flagged as risky during planning.
- All increments marked ✅ Done before this one → include their areas to catch cumulative regressions.

For **FINAL** runs: use the full area list from the BASELINE section of `[APP]-exploratory-report.md`.

**Produce a scoped exploration plan before opening the browser:**

```
🗺️ Verification Plan — Increment [N]: [Name]

Areas from this increment:
1. [Area name] → [route] — reason: files changed: [list]
2. [Area name] → [route] — reason: potential risk flagged in plan

Previously-migrated areas (cumulative regression check):
3. [Area name] → [route] — reason: changed in increment [M]

Total areas: N
Auth required: [yes / no]

Proceed?
```

Wait for developer confirmation.

---

## Step 2 — Handle Authentication (if required)

If `auth.json` was saved during `capture-baseline.md`, load it:

```bash
playwright-cli -s=migration-inc-[N] open [BASE_URL]
playwright-cli -s=migration-inc-[N] state-load .github/migration/screenshots/auth.json
```

If not available, re-authenticate and save (see `capture-baseline.md` Step 2 for the auth pattern).

> **Security:** Never hard-code credentials. Do not write credentials to any file.

---

## Step 3 — Capture Each Area

For each area in the plan, follow the same sequence as the baseline capture:

### 3a. Navigate and screenshot

```bash
playwright-cli -s=migration-inc-[N] goto [FULL_URL]
playwright-cli -s=migration-inc-[N] screenshot --filename=.github/migration/screenshots/inc-[N]/[area-name]-initial.png
playwright-cli -s=migration-inc-[N] snapshot --filename=.github/migration/screenshots/inc-[N]/[area-name]-snapshot.yaml
```

### 3b. Check console

```bash
playwright-cli -s=migration-inc-[N] console
```

Compare against the baseline console record for this area. Any `error` entry **not present in baseline** = regression signal.

### 3c. Check network

```bash
playwright-cli -s=migration-inc-[N] network
```

Compare against baseline. Any failed request (4xx/5xx) **not present in baseline** = regression signal.

### 3d. Interact with primary elements

```bash
playwright-cli -s=migration-inc-[N] snapshot          # read refs
playwright-cli -s=migration-inc-[N] click [ref]
playwright-cli -s=migration-inc-[N] screenshot --filename=.github/migration/screenshots/inc-[N]/[area-name]-after-[action].png
playwright-cli -s=migration-inc-[N] console            # new errors after interaction?
```

### 3e. Scroll and capture

```bash
playwright-cli -s=migration-inc-[N] mousewheel 0 500
playwright-cli -s=migration-inc-[N] screenshot --filename=.github/migration/screenshots/inc-[N]/[area-name]-scrolled.png
```

---

## Step 4 — Close Session

```bash
playwright-cli -s=migration-inc-[N] close
```

---

## Step 5 — Compare Against Baseline

For each area, evaluate every signal:

| Signal | Regression if… |
|--------|---------------|
| **Layout / content** | Screenshot shows missing content, broken layout, or images that were present in baseline |
| **Console errors** | New `error` entries not present in the baseline console record for this area |
| **Network failures** | New 4xx/5xx requests not present in the baseline network record |
| **Navigation** | Route does not resolve, unexpected redirect, or 404 where baseline showed 200 |
| **Interactive elements** | Form fails to submit, button does not respond, data table empty where baseline showed data |

**Assign a status to each area:**

| Status | Meaning |
|--------|---------|
| ✅ No change | All signals match baseline — no regression |
| ⚠️ Changed | Difference found — may be an intentional migration effect or a regression; requires developer confirmation |
| ❌ Broken | Page fails to load, JS error blocks functionality, or critical interaction fails |

> ⚠️ Changed does **not** mean regression automatically. Many visual or structural changes are expected migration outputs (e.g. updated component styles, new layout from target framework). Always ask the developer.

---

## Step 6 — Append to Exploratory Report

Append a new section to **`.github/migration/[APP]-exploratory-report.md`**:

````markdown
---

## POST-INCREMENT [N] — [Increment Name]
**Date:** YYYY-MM-DD
**Increment:** [Name from guide]
**Areas from this increment:** [list]
**Previously-migrated areas checked:** [list]

### Results

| Area | Route | New Console Errors | New Network Failures | vs Baseline | Status | Screenshots |
|------|-------|--------------------|---------------------|-------------|--------|-------------|
| [Area] | /route | None | None | No difference | ✅ No change | [baseline](../baseline/[area]-initial.png) · [now](inc-N/[area]-initial.png) |
| [Area] | /route | None | None | Header layout shifted | ⚠️ Changed | [baseline](../baseline/[area]-initial.png) · [now](inc-N/[area]-initial.png) |
| [Area] | /route | TypeError: x is null | GET /api/data 500 | Page broken | ❌ Broken | [baseline](../baseline/[area]-initial.png) · [now](inc-N/[area]-initial.png) |

### ⚠️ Changes Requiring Developer Confirmation
1. **[Area]** — [what changed] — expected from this increment?

### ❌ Regressions
1. **[Area]** — [what is broken and what the baseline showed]

### Summary
- **Areas verified:** N
- **✅ Clean:** N
- **⚠️ Changed (awaiting confirmation):** N
- **❌ Broken:** N
````

For **FINAL** runs, use this summary block instead:

````markdown
---

## FINAL
**Date:** YYYY-MM-DD
**State:** Migration complete — full baseline re-run

### Full Results
[same table as above, covering all baseline areas]

### Migration Verification Summary
- **Total areas verified:** N
- **✅ Fully clean:** N
- **⚠️ Expected changes confirmed by developer:** N
- **❌ Regressions remaining:** N
````

---

## Step 7 — Present Report and Apply Gates

```
📸 Increment [N] Verification Complete

Areas verified: N
✅ Clean:    N
⚠️ Changed: N — need your confirmation
❌ Broken:  N — regressions detected

Report: .github/migration/[APP]-exploratory-report.md

⚠️ Please confirm — are these changes expected from this increment?
1. [Area] — [what changed]
2. [Area] — [what changed]

❌ Regressions to fix before continuing:
1. [Area] — [what is broken]
```

**Gate behaviour:**
- **❌ Broken** → raise an `OBSERVE` for each broken area in the progress document. **Do not mark the increment done or proceed to the next one until all ❌ items are resolved.**
- **⚠️ Changed** → wait for developer confirmation that the change is expected. If confirmed, note it in the report as "Expected — [reason]". If not confirmed, treat as ❌.
- **✅ All clean** (or all ⚠️ confirmed) → mark the increment done in the progress document and continue.

---

## Notes
- Only new signals count — errors and failures already present in the **baseline** are not regressions.
- The scope grows incrementally: each POST-INCREMENT run covers the current increment's areas **plus** all previously-migrated areas. Never shrink scope mid-migration.
- If a page requires dynamic data (e.g. a populated list), note whether the baseline was captured with the same data state. Differences in data are not regressions.
- `playwright-cli console` and `playwright-cli network` output must always be captured — a pixel-perfect screenshot can hide a broken API call underneath.
