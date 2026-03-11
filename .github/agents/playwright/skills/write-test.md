---
description: Write Playwright test files in the project's existing language and framework from a confirmed feature specification.
input: Confirmed spec from gather-spec.md
output: One or more test files ready to run, in the detected language
---

# Skill: Write Playwright Tests

## Step 0 — Detect language and conventions

1. Search for existing test files: `*.spec.ts`, `*.spec.js`, `*IT.java`, `*Test.java`, `*_test.py`, `*_spec.rb`, etc.
2. Read 1–2 representative test files to identify:
   - Language and test framework (e.g., TypeScript/Playwright, Java/JUnit+Playwright, Python/pytest-playwright)
   - Import patterns, base classes, and annotations in use
   - Existing page-object or helper patterns (e.g., `CertificatePage`, `BasePage`)
   - Test data setup approach (fixtures, builders, test setup helpers)
3. Record: `LANG`, `FRAMEWORK`, `TEST_DIR`, `BASE_CLASS` (if any) — use these in all subsequent steps.

> If no existing tests are found, ask the developer which language and framework to use before continuing.

## Step 1 — Locate config and test directory

| Language | Config to look for | What to read |
|---|---|---|
| TypeScript/JS | `playwright.config.ts` / `playwright.config.js` | `baseURL`, `testDir`, `timeout`, `projects` |
| Java | `build.gradle` / `pom.xml` + `test.environment.properties` | base URL, test source dir, dependencies |
| Python | `pytest.ini` / `pyproject.toml` | `testpaths`, `base_url` |

Determine test output location. If absent from config, ask the developer.

## Step 2 — Use codegen for selector discovery (when needed)

If the UI structure is unfamiliar or selectors are unclear, run codegen for the detected language:

**TypeScript/JS:**
```powershell
npx playwright codegen <base-url>
```

**Java (Maven):**
```powershell
mvn exec:java -e -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="codegen <base-url>"
```

**Python:**
```powershell
playwright codegen <base-url>
```

Use codegen output as a reference only — do not copy verbatim. Prefer selectors in this order:
1. `getByRole` — semantic and accessible
2. `getByLabel` / `getByPlaceholder` / `getByText` — readable
3. `getByTestId` — if `data-testid` attributes exist
4. CSS/XPath — only as last resort

## Step 3 — Write the test file

One file per feature. Match the language and structure detected in Step 0.

```

## Rules

- One test per acceptance criterion — never bundle multiple ACs in one test.
- Assertions come from the spec, not from reading the page source.
- No `waitForTimeout` / `Thread.sleep` / `time.sleep` — use Playwright's auto-waiting instead.
- Follow naming: `should [expected outcome] when [condition]`.
- Never hardcode credentials or tokens — use environment variables or the project's test-data builder.
- If the project has a page-object base class, extend it — do not bypass existing conventions.

## Output

Report the files written:

```
## Tests Written
- [path/to/test-file]
  - `should [AC1 outcome] when [condition]`
  - `should [AC2 outcome] when [condition]`
```

Then immediately proceed to `run-and-verify.md`.
