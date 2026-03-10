---
description: Build all foundation documents needed before touching code — migration type, requirements, analysis instructions, app-specific guide, and progress tracker.
input: Migration type (source → target), app name, and repository access
output: A complete set of documents in .github/migration/ ready to drive Phase 2 implementation
---

# Skill: Plan Migration (Phase 1)

> **⭐ Critical success factor:** The app-specific migration guide produced in Step 7 is the
> heart of the entire migration. A thorough guide makes implementation predictable. Never rush
> Phase 1.

> **🔁 Iterative delivery principle:** Every increment defined in the guide **must** leave the
> app in a buildable, runnable, and testable state — even if only a subset of features are
> migrated. This is non-negotiable. If an increment cannot be made safely self-contained, split
> it further until it can. Increments that cannot be verified build→run→test are a planning
> failure, not an execution problem — address them here in Phase 1.

---

## Step 0 — Identify Migration Type

Ask the developer:

```
🔍 Migration Type Identification

To provide the best guidance, please specify:
1. Source framework/technology: [e.g., React 16, WildFly, Angular 12]
2. Target framework/technology: [e.g., React 18, Spring Boot, React]
3. App name: [used to name all documents, e.g., "myapp"]
4. Reference app (optional): [an existing app built on the target framework to use for design pattern inspiration]

This determines:
- Which requirements and analysis templates to use (see `agents/migrator/templates/`)
- How documents will be named
- What analysis sections to cover
```

Wait for developer response. Record `[SOURCE]`, `[TARGET]`, and `[APP]` for use throughout.

---

## Step 0.5 — Discuss Migration Strategy with Developer

> **Before creating any documents**, align with the developer on the overall approach. This avoids producing a guide that doesn't match their expectations or constraints.

Do a quick codebase survey (directory structure, package manifest, rough file count) to inform the conversation, then present a short summary and open discussion:

```
🗺️ Migration Strategy Discussion — [APP]: [SOURCE] → [TARGET]

Before I start building the plan, I want to align on approach so the guide fits your
situation. Here's what I can see so far:

**Codebase snapshot:**
- [Brief summary: e.g., ~40 components, Redux store, React Router, 3 major feature areas]
- [Rough complexity signal: e.g., heavy custom hooks, legacy class components, thin test suite]

**Key questions:**

1. **Scope** — Is this a full migration or are some areas out of scope / to be tackled separately?

2. **Approach** — Do you have a preferred strategy?
   - Big-bang: migrate everything in one continuous effort
   - Strangler: run old and new side-by-side, migrate area by area (safer for large apps)
   - Feature-flag: gate new implementation behind flags to ship incrementally

3. **Increment size** — How would you like to work?
   - Small and frequent (e.g., 1–3 files per increment, build/run/test between each)
   - Larger batches (e.g., full feature area per increment)
   - Developer-defined (you tell me before each increment)

4. **Build & run constraints** — Are there any known blockers to keeping the app runnable
   between increments? (e.g., shared config not yet migrated, external services, monorepo setup)

5. **Timeline / prioritisation** — Are any areas time-sensitive or must be migrated first?

6. **Known risks or concerns** — Anything you already know will be tricky?

I'll shape the guide, increment sizing, and risk focus around your answers.
```

Wait for developer responses. Record decisions as **Migration Strategy Decisions** at the top of the progress document (Step 9). Do not proceed to Step 1 until you have enough clarity to make meaningful planning decisions.

---

## Step 1 — Analyse Test Coverage (Optional but Strongly Recommended)

**Why:** Establishes a baseline before any code is touched and identifies regressions early.

Ask: *"Would you like to analyse test coverage before we start? Recommended for production apps."*

If **yes**:
1. Run the project's coverage tool (Jest, Istanbul, JaCoCo, pytest-cov, etc.).
2. Identify files/components with coverage < 70%.
3. Flag critical business logic and integration points with no tests.
4. Categorise gaps: Critical / High / Medium / Low.
5. Create **`[APP]-test-coverage-analysis.md`** in `.github/migration/` with:
   - Coverage baseline metrics.
   - Prioritised list of test gaps.
   - High-risk migration areas.
   - `OBSERVE` flags where business logic is unclear.
6. Present findings and ask developer: add critical tests now, add incrementally, or skip.

If **no**: skip to Step 2.

---

## Step 2 — Create or Locate Requirements Document

Check for **`.github/migration/instructions/[APP]-requirements.md`**.

- **Exists** → proceed to Step 3.
- **Does not exist** → ask:
  ```
  📋 Requirements Document Needed

  Options:
  1. Use the template for this migration type (check `agents/migrator/templates/`)
  2. Start from a general template and customise
  3. Create from scratch

  Which would you prefer?
  ```
  Create the document in `.github/migration/instructions/` based on the chosen approach.
  If Step 1 was completed, reference the coverage findings here.

> **Note:** The requirements document has the **highest priority** of all migration documents.
> When requirements conflict with analysis instructions, always follow requirements.

---

## Step 2.5 — Set Migration Limits

**Purpose:** Establish a protected list of files, directories, and concerns that the agent must never change during migration without explicit developer approval. Setting limits now — before the guide is written — ensures that every increment plan is checked against them in Phase 2.

Check for **`.github/migration/[APP]-migration-limits.md`**.

- **Exists** → read it and confirm with the developer:
  ```
  🚧 Migration Limits Loaded

  I'll never touch the following without asking first:

  Protected paths/patterns:
  - [list from file]

  Protected concerns:
  - [list from file]

  Does this look correct? Any additions or changes?
  ```
  Wait for confirmation before continuing.

- **Does not exist** → present the choice:
  ```
  🚧 Migration Limits

  No limits file found for [APP]. You can define files, directories, or concerns I must
  never touch without asking first and receiving an explicit YES from you.

  Options:
  1. Create a limits file from the template (recommended)
     — I'll create `.github/migration/[APP]-migration-limits.md` from
       `agents/migrator/templates/migration-limits-template.md`
  2. Proceed with no limits — I may change any file required for the migration

  Which would you prefer?
  ```
  - If **option 1**: create `.github/migration/[APP]-migration-limits.md` from the template, then ask the developer to fill in their protected items. **Wait for them to confirm the file is ready before proceeding.**
  - If **option 2**: record "No limits defined" in the progress document and continue.

> **Rule for Phase 2:** Once limits are set, every increment's PLAN step must cross-reference the
> list of planned files against `[APP]-migration-limits.md`. Any match requires an explicit
> **YES** from the developer before the increment can proceed. See `execute-migration.md`.

---

## Step 2.6 — Verify Quality Hooks

**Purpose:** Ensure the Copilot pre-push quality gate is in place before any code changes are made. The hooks run automatically before every agent push and block it if linting, type checking, or tests fail.

Check for **`.github/copilot/pre-push`** and **`.github/copilot/hooks/`** in the repository.

- **Both exist** → confirm with the developer:
  ```
  ✅ Quality Hooks Found

  Pre-push hook: .github/copilot/pre-push
  Java checks:   .github/copilot/hooks/java-quality.sh
  TS checks:     .github/copilot/hooks/ts-quality.sh

  These will run automatically before every agent push and block it if
  Checkstyle, SpotBugs, SonarLint (BLOCKER/CRITICAL), tsc, ESLint, or tests fail.

  Does this look correct? Any additions (e.g. a custom SonarLint config path)?
  ```
  Wait for confirmation before continuing.

- **Missing or incomplete** → present the choice:
  ```
  ⚠️ Quality Hooks Missing

  No pre-push quality gate found at .github/copilot/.
  Without hooks, lint errors, type errors, and SonarLint issues can slip through on every push.

  Options:
  1. Copy the example hooks from .github/copilot/ into this repository
     — pre-push (entrypoint), hooks/java-quality.sh, hooks/ts-quality.sh
     — I'll confirm the scripts are in place before any code changes
  2. Skip — proceed without quality hooks (not recommended)

  Which would you prefer?
  ```
  - If **option 1**: copy `.github/copilot/pre-push` and `.github/copilot/hooks/` into the target repository. Confirm the scripts are executable. **Wait for developer confirmation they are in place before continuing.**
  - If **option 2**: record "No quality hooks configured" under Risks in the progress document and continue.

> **Note:** SonarLint and SpotBugs are skipped gracefully if not installed — they do not block setup.

---

## Step 3 — Gather Inspiration Document (Optional)

Ask: *"Do you have an existing app built on [TARGET] that I can analyse for design patterns?"*

- **Yes** → developer runs Prompt 1.1 (see `.github/prompts/migrate.prompt.md`) to produce
  `[APP]-[target]-design-choices.md` and places it in `.github/migration/instructions/`.
  Wait for confirmation the document is available.
- **No** → skip to Step 4.

---

## Step 4 — Enhance Requirements Document

**Input:**
- `[APP]-requirements.md` (Step 2)
- `[APP]-[target]-design-choices.md` (Step 3, if available)
- `[APP]-test-coverage-analysis.md` (Step 1, if available)

**Action:** Review and enhance the requirements document with:
- Application-specific insights from the inspiration doc (if available).
- Test coverage risk areas (if Step 1 was completed).
- Clarifications of any vague or generic sections.

**Output:** Updated `[APP]-requirements.md`. Present changes to developer and wait for approval.

---

## Step 5 — Generate General Analysis Instructions

**Input:** Analysis template from `agents/migrator/templates/` (e.g., `react-analysis-template.md`) as scaffold.

**Action:**
1. Use the template structure as a base.
2. Customise for the specific `[SOURCE] → [TARGET]` migration (adjust section names, tooling, patterns).
3. Ensure sections cover the full migration surface for this type (dependencies, data layer, services/components, API/routing, configuration, testing, logging, security, cleanup).
4. Write so the document can be placed in any similar repository as standalone analysis instructions for an AI agent.

**Output:** `[SOURCE]-analysis.instructions.md` in `.github/migration/instructions/`.

**Follow-up:** After generating, ask developer: *"Should I review the instructions independently
and check if anything is missing?"* (Prompt 2 follow-up from `.github/prompts/migrate.prompt.md`.)

---

## Step 6 — Assess Migration Risks 🔍

> Run risk analysis before writing the guide so that risks shape increment ordering and OBSERVE flags — not the other way around.

**Input:**
- Repository source code
- `[APP]-requirements.md` (Step 4)
- `[SOURCE]-analysis.instructions.md` (Step 5)
- `[APP]-test-coverage-analysis.md` (Step 1, if available)

**Action:** Execute the `assess-risks` skill (`agents/migrator/skills/assess-risks.md`):
1. Scan for removed and deprecated APIs between `[SOURCE]` and `[TARGET]`.
2. Audit all third-party dependencies for compatibility with `[TARGET]`.
3. Identify technical debt in files that *will be touched* during migration (not the whole codebase).
4. Find architectural violations — inverted dependencies, framework-coupled domain logic, implicit global state.
5. Cross-reference with test coverage: any 🔴 / 🟡 risk in under-covered files is elevated one severity level.
6. Rate each planned migration area: 🔴 High / 🟡 Medium / 🟢 Low.

**Output:** `[APP]-risk-register.md` in `.github/migration/`.

**Present findings:**
- Show the summary table (Critical / High / Medium counts).
- Call out any 🔴 Blockers immediately — ask developer: resolve before migration starts, or as the first action in the affected increment?
- Wait for developer confirmation before proceeding to Step 7.

---

## Step 7 — Generate App-Specific Migration Guide ⭐

> ⚠️ **MANDATORY ITERATIVE STEP.** Do not rush. Quality here determines Phase 2 success.

**Input:**
- `[APP]-requirements.md` (Step 4)
- `[SOURCE]-analysis.instructions.md` (Step 5)
- `[APP]-risk-register.md` (Step 6) ← **Use this to order increments and place OBSERVE flags**
- `[APP]-test-coverage-analysis.md` (Step 1, if available)
- Full repository codebase

**Action — one analysis area per iteration:**
1. Follow the section structure from `[SOURCE]-analysis.instructions.md`.
2. For each area (dependencies, data/state layer, service/business layer, API/component layer, configuration, testing, logging, security, cleanup):
   - Analyse that area in depth across the repository.
   - Document every file that needs changing, every dependency to add/remove, every config change.
   - Provide specific before/after code patterns.
   - Mark uncertainties with `OBSERVE`.
   - Present findings and wait for developer confirmation before the next area.
3. After all areas are analysed, compile into **`[APP]-migration-guide.md`** in `.github/migration/`.

**Guide structure requirements:**
- Divided into clear, self-contained **increments** (not just analysis areas).
- Increments ordered so foundational changes come first (dependencies, config → features → cleanup).
- **Each increment must leave the app in a buildable, runnable, and testable state.** This is the primary constraint when deciding how to slice work. If an increment cannot satisfy this, split it until it can. Flag any unavoidable exception with `OBSERVE` and provide a concrete mitigation plan.
- Each increment specifies: scope, files affected, dependencies to add/remove, config changes, and **mandatory verification steps** (build command, start/smoke test, relevant unit/integration tests to run).
- Verification steps are not optional — they are the exit criteria for the increment and must be specific enough to run without interpretation.
- Final increments must include **cleanup and optimisation** (remove deprecated patterns, dead code, legacy dependencies).

**Output:** `[APP]-migration-guide.md` — the Phase 2 roadmap.

---

## Step 8 — Verify Guide Quality (Quality Gate)

**Input:** `[APP]-migration-guide.md` + `[APP]-requirements.md`

**Analyse against this checklist:**

| Area | Checks |
|------|--------|
| Coverage | All layers analysed; every file to change identified; all dependencies listed; cleanup steps included |
| Increment structure | Logical order; **every** increment leaves the app buildable, runnable, and testable (not just functional in theory); verification steps are specific commands/tests — not vague descriptions; any increment that cannot be self-contained is split or has an `OBSERVE` with mitigation |
| Detail level | Specific code patterns; not vague; requirements referenced; target framework best practices applied |
| OBSERVE flags | All uncertainties marked; design decisions flagged |
| Requirements alignment | Follows requirements doc; testing, logging, naming conventions applied |

**Present assessment:**
```
📊 Guide Quality Analysis

✅ Strengths: ...
⚠️ Gaps: ...
🔄 Recommended iterations: ...
📈 Completeness: X/10 | Detail: X/10 | Ready: Yes/No
```

Ask developer: **Proceed to Step 9** or **iterate on specific areas** (return to Step 7)?

---

## Step 9 — Generate Progress Document

**Input:** Verified `[APP]-migration-guide.md`

**Create `[APP]-migration-progress.md`** in `.github/migration/` with:

1. **Migration Strategy Decisions** — record the agreed answers from Step 0.5: scope, approach (big-bang / strangler / feature-flag), increment size preference, build/run constraints, prioritisation, and known risks.
2. **Status Overview** — overall % complete, current phase, last updated.
3. **Increment Tracking** — all increments from the guide with status:
   - ✅ Done · 🔄 In Progress · ⏸️ Blocked · ⏹️ Not Started
4. **Risk Register Summary** — link to `[APP]-risk-register.md`; list all 🔴 Critical risks with current status (Open / In Progress / Resolved).
5. **OBSERVE Items** — focus area, description, status (Pending / Resolved).
6. **Build / Test Status** — last build result, test results, application startup.
7. **Metrics** — files changed, dependencies added/removed, tests migrated.
8. **Improvement Feedback** — empty section, populated during Phase 2.

**Output:** `[APP]-migration-progress.md` — Phase 2 can now begin.

---

## Step 10 — Capture Exploratory Baseline (Recommended)

> Run before any code is changed. This is the visual and behavioural truth anchor for all post-increment comparisons.

**Ask the developer:**
```
📸 Exploratory Baseline

Before Phase 2 begins, I can take a visual + behavioural baseline of the running application
using playwright-cli — screenshots, console errors, and network calls for each main area.

This makes it easy to spot regressions after each increment: I'll compare the new state
against this baseline and flag anything that changed.

Is the application running and accessible? If yes, what is the base URL?
(Skip if the app cannot be run locally or in a dev environment)
```

If developer confirms the app is running:

1. **Derive the exploratory scope** from the migration guide and risk register before opening the browser. Not every part of the app needs a baseline — only areas that will actually be touched or are at risk of regression. Use this filter:

   | Include | Exclude |
   |---------|---------|
   | Pages/routes whose files appear in any increment's scope | Static informational pages with no logic being migrated |
   | Flows backed by services, components, or configs being migrated | Admin/internal tooling untouched by migration |
   | Areas flagged 🔴 or 🟡 in the risk register | Entire app sections with zero migration surface |
   | Shared UI (navigation, layout, auth) — changes here affect everything | Rarely-used flows in increments rated 🟢 Low risk |

   Present the scoped area list to the developer and confirm before capturing:
   ```
   🗺️ Exploratory Scope — [N] areas selected for baseline

   In scope (will be captured + compared after each relevant increment):
   - [Area] → [route] — reason: [changed in increment N / 🔴 risk / shared layout]
   - [Area] → [route] — reason: [...]

   Excluded (no migration surface):
   - [Area] — reason: [static page / untouched service / 🟢 low risk increment]

   Does this look right? Any areas to add or remove?
   ```
   Wait for developer confirmation, then execute `agents/migrator/skills/capture-baseline.md` with this agreed scope.

2. Output: `.github/migration/screenshots/baseline/` + `[APP]-exploratory-report.md`.
3. Add baseline run summary and the agreed scope list to the progress document's **Build / Test Status** section.

If developer skips: record "Exploratory baseline not captured" in the progress document and continue.

---

## Notes
- Replace `[APP]`, `[SOURCE]`, `[TARGET]` throughout with the actual values from Step 0.
- All documents go in `.github/migration/` (guide, progress, coverage analysis) or
  `.github/migration/instructions/` (requirements, design choices, analysis instructions).
- Never proceed to Phase 2 until the developer has approved the guide and progress document.
