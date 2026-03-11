---
description: Run Playwright tests using the project's test runner, read results, and iteratively fix failures until all tests pass.
input: Written test file(s) from write-test.md + language/framework detected in write-test.md Step 0
output: All tests passing, with a summary of any fixes applied
---

# Skill: Run and Verify Tests

## Step 0 — Identify the test runner

Use the language and framework detected in `write-test.md` Step 0:

| Language | Run a single file | Run full suite |
|---|---|---|
| TypeScript/JS | `npx playwright test [file] --reporter=line 2>&1` | `npx playwright test --reporter=line 2>&1` |
| Java (Gradle) | `./gradlew test --tests "[FullClassName]" 2>&1` | `./gradlew test 2>&1` |
| Java (Maven) | `mvn test -Dtest="[ClassName]" 2>&1` | `mvn test 2>&1` |
| Python | `pytest [file] -v 2>&1` | `pytest -v 2>&1` |

## Step 1 — Run the tests

Run the specific test file first (faster feedback than the full suite) using the command for the detected language.

Read the terminal output. Identify:
- ✅ Passing tests
- ❌ Failing tests — note the test name, error message, and line number

## Step 2 — Diagnose failures

For each failing test, determine the failure type:

| Failure type | Likely cause | Fix |
|---|---|---|
| `Timeout waiting for locator` | Selector wrong or element not rendered | Update selector; use `codegen` to re-inspect |
| Assertion mismatch | Wrong expected value | Re-check acceptance criterion in spec |
| `net::ERR_CONNECTION_REFUSED` | App not running | Notify developer — do not fix in test |
| `strict mode violation` | Selector matches multiple elements | Add more specific locator |
| Navigation/URL mismatch | Base URL misconfigured | Check config file |
| Java `NullPointerException` in setup | Test setup builder not configured | Check `testSetupBuilder()` chain |
| Python `TimeoutError` | Wrong selector or element not rendered | Update selector |

## Step 3 — Fix and re-run

1. Apply the fix to the test file.
2. Re-run only the failing test using the single-file command from Step 0.
3. Repeat until green. Maximum 3 fix iterations per test — if still failing after 3, use OBSERVE to report the blocker to the developer.

## Step 4 — Full suite confirmation

Once individual tests pass, run the full test file using the single-file command from Step 0 to confirm no regressions.

## Step 5 — Report results

```
## Test Results

### ✅ Passing
- `should [outcome] when [condition]`
- `should [outcome] when [condition]`

### ❌ Blocked (needs developer input)
- `should [outcome] when [condition]` — OBSERVE: [reason it cannot be fixed]

### Fixes Applied
- [test name]: [what was wrong] → [what was changed]
```

## Rules

- Never report a test as passing without CLI confirmation.
- Never modify assertions to make tests pass — only fix selectors, navigation, or setup.
- If the app is not running, stop and notify the developer rather than modifying tests.
- Changing an assertion to match wrong app behaviour is a false positive — flag it with OBSERVE instead.
