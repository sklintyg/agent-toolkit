---
description: Verify that written tests reflect real application behaviour by walking each acceptance criterion manually using playwright-cli. Fixes test code when the live UI diverges from test expectations.
input: Confirmed spec (from gather-spec.md) + written test file(s) + environment context file
output: Verification report — all ACs confirmed or test corrections applied. Divergences flagged for developer review.
---

# Skill: Agent Verify

Use this skill when the full test suite cannot be run (testdata server unavailable, CI not set up, etc.), or when you want to confirm real app behaviour before trusting the tests.

The agent drives the live app using playwright-cli, walks each acceptance criterion manually, and compares what it observes against what the tests assert. If there is a divergence, it corrects the test — not the observation.

---

## Step 0 — Load environment context

Load the environment context file for the target app from:
```
.github/agents/playwright/environments/{app-slug}.md
```

Use it to know: how to log in, how to create test data, any known UI quirks and loading patterns.
If the file is missing, stop and ask the developer — do not guess login/navigation steps.

---

## Step 1 — Open the app

```bash
playwright-cli open [base-url]
playwright-cli snapshot
```

Confirm the page is reachable. If not, stop and report with OBSERVE — do not proceed.

---

## Step 2 — Walk each acceptance criterion

For each AC in the confirmed spec, in order:

1. **Set up state** — log in, create test data if needed (use the environment context).
2. **Execute the user flow** — navigate, click, fill as described in the spec.
3. **Observe the result** — snapshot and read the relevant elements.
4. **Take a screenshot** — capture visual evidence of the observed state:
   ```bash
   playwright-cli screenshot --filename=.github/test-output/screenshots/ac{N}-confirmed.png
   ```
   Name the file after the AC number and outcome, e.g. `ac1-confirmed.png`, `ac2-confirmed.png`.
5. **Compare to the test assertion** — check what the written test expects vs. what the UI shows.

Use OBSERVE to flag any AC that cannot be verified via UI alone (e.g. background jobs, API-only side effects).

---

## Step 3 — Apply corrections

When a divergence is found between the live UI and a written test assertion:

1. Take a screenshot of the divergent state before changing anything:
   ```bash
   playwright-cli screenshot --filename=.github/test-output/screenshots/ac{N}-divergence.png
   ```
2. Document the divergence clearly:
   ```
   AC: [criterion]
   Test expected: [what the test asserts]
   UI shows:      [what was actually observed]
   Screenshot:    .github/test-output/screenshots/ac{N}-divergence.png
   ```
3. Update the test to match the observed real behaviour — **never weaken the assertion** to hide a bug. If the app behaviour looks wrong, flag it with OBSERVE for the developer instead of silently correcting the test.
4. Re-walk the AC after correction and take a final screenshot to confirm the corrected state:
   ```bash
   playwright-cli screenshot --filename=.github/test-output/screenshots/ac{N}-corrected.png
   ```

Maximum 2 correction cycles per AC. If still diverging, raise OBSERVE.

---

## Step 4 — Close session

```bash
playwright-cli close
```

---

## Step 5 — Report

```
## Agent Verify Report

### ✅ Confirmed
- AC1: [criterion] — observed: [what was seen]
  Screenshot: .github/test-output/screenshots/ac1-confirmed.png
- AC2: [criterion] — observed: [what was seen]
  Screenshot: .github/test-output/screenshots/ac2-confirmed.png

### 🔧 Corrected
- AC3: [criterion]
  - Was: [original assertion]
  - Now: [corrected assertion]
  - Reason: [what the UI actually showed]
  - Evidence: .github/test-output/screenshots/ac3-divergence.png
  - After fix: .github/test-output/screenshots/ac3-corrected.png

### 🔍 OBSERVE (needs developer input)
- AC4: [criterion] — [why it cannot be verified via UI / suspected app bug]
  Screenshot: .github/test-output/screenshots/ac4-observe.png (if capturable)
```

All screenshots are saved to `.github/test-output/screenshots/` for developer review.

---

## Rules

- Never modify an assertion to paper over incorrect app behaviour — use OBSERVE.
- Every correction must be backed by a direct playwright-cli observation (snapshot or eval output).
- Do not invent or assume UI state — only assert what was explicitly observed.
- If the environment context file is missing, stop at Step 0 — do not guess.
