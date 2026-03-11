---
name: playwright
description: Lean three-phase Playwright workflow — spec->generate->verify. Use this for focused E2E test writing without the full analysis/strategy pipeline. For exploratory or visual checks against a live URL (without writing tests), invoke the @playwright agent directly and describe what you want to explore.
---

## Instructions for Copilot (orchestrating agent)

**If the developer wants to explore the live app or visually check pages — do not run this workflow.** Instead, tell them: *"For exploratory checks, invoke the `@playwright` agent directly and describe what you want to explore."*

This workflow is for writing and verifying formal Playwright tests only.

When this skill is invoked:
1. Ask the developer for the feature or page to test, and the app URL (required for Phase 3 verification).
2. **Immediately create a todo list** using `manage_todo_list` with all four steps as `not-started`:
   - Step 0 — Environment context
   - Phase 1 — Gather specification
   - Phase 2 — Write tests
   - Phase 3 — Run and verify
3. Mark each step `in-progress` before starting it, `completed` immediately after.
4. **Never bypass developer interaction.** Relay all questions from skills to the developer and wait for answers — do not infer intent from code alone.
5. Present the confirmed spec from Phase 1 and wait for developer approval before writing any tests.

---

All output files are written to **`.github/test-output/`** by default.

---

## Step 0 — Environment context

Before gathering the spec, check whether an environment context file exists for the target app:

**Check path:** `.github/agents/playwright/environments/`

Look for any `.md` file whose name matches the app's hostname slug (e.g. `webcert-devtest.md` for `webcert-devtest.intyg.nordicmedtest.se`).

**If a matching file is found:**
- Load it and silently use it to inform Phases 1–3 (login flow, test data creation, known UI quirks).
- Briefly tell the developer which context file was loaded.

**If no file is found:**
- Inform the developer: *"No environment context file found for this app."*
- Ask them to choose:
  > **Option A** — "I'll provide the details" → ask for login steps, test data creation method, and any known UI quirks, then create the file from the TEMPLATE.
  >
  > **Option B** — "Explore the app for me" → invoke the `gather-env-context` skill using playwright-cli to walk the app, discover the environment, and create the file automatically, then confirm the result with the developer before continuing.

Skill (Option B): #file:../../agents/playwright/skills/gather-env-context.md
Template: #file:../../agents/playwright/environments/TEMPLATE.md

Do not proceed to Phase 1 until the environment context is confirmed.

---

## Phase 1 — Gather specification

Invoke the **playwright** agent and run the gather-spec skill:

> `@playwright gather spec for [feature/page]`

Skill: #file:../../agents/playwright/skills/gather-spec.md

Output: A confirmed spec table — feature name, URL, user flows, acceptance criteria, and edge cases. **Wait for developer approval before proceeding.**

---

## Phase 2 — Write tests

Invoke the **playwright** agent with the confirmed spec:

> `@playwright write tests from confirmed spec`

The agent will:
1. Detect the project's existing language and test conventions (Step 0 of write-test.md)
2. Locate or infer config and test directory
3. Write one test per acceptance criterion in the detected language

Skill: #file:../../agents/playwright/skills/write-test.md

Output: Test file(s) written to the codebase in the project's language and framework.

---

## Phase 3 — Verify

> **Prerequisite:** The application must be running at the target URL.

Ask the developer which verification mode to use:

> **Option A — Agent verify** *(default)*
> The agent drives the live app using playwright-cli, walks each AC manually, and compares observed behaviour against written test assertions. Corrects the tests if the UI diverges. Requires only the app URL.
>
> **Option B — Run test suite**
> The agent executes the project's test runner (Gradle / Jest / pytest), reads pass/fail output, and iteratively fixes code failures. Requires the test runner and any supporting infrastructure (e.g. testdata server) to be running.

If the developer does not specify, default to **Option A**.

---

### Option A — Verify against live UI

Skill: #file:../../agents/playwright/skills/verify-test.md

Output: All ACs confirmed against live UI. Test corrections applied where behaviour diverged. OBSERVE blockers flagged for developer review.

---

### Option B — Run test suite

Skill: #file:../../agents/playwright/skills/run-and-verify.md

Output: All tests passing in the test runner. Fixes applied to selectors/setup. OBSERVE blockers flagged for developer review.
