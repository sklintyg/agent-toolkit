---
description: Gather a feature specification before writing any Playwright tests. Ensures every test maps to a real requirement or acceptance criterion.
input: Developer's description of the feature to test
output: A confirmed spec with URL, user flows, and acceptance criteria ready for write-test.md
---

# Skill: Gather Specification

Never write tests without completing this skill first.

## Step 1 — Ask for the specification

Ask the developer to provide (all at once, not one by one):

> 1. **Feature name** — what is being tested?
> 2. **Base URL** — where does the feature live? (e.g. `http://localhost:4200/checkout`)
> 3. **User flows** — what are the key actions a user takes? (step-by-step, in plain language)
> 4. **Acceptance criteria** — what must be true for the feature to be considered working?
> 5. **Edge cases / negative paths** — what should fail gracefully? (optional but recommended)

## Step 2 — Confirm understanding

Restate the spec back to the developer as a structured summary:

```
Feature: [name]
URL: [base url]

Flows:
1. [Flow name] — [short description]
2. [Flow name] — [short description]

Acceptance Criteria:
- AC1: [criterion]
- AC2: [criterion]

Edge Cases:
- EC1: [case]
```

Wait for the developer to confirm or correct before proceeding.

## Step 3 — Map criteria to test cases

For each acceptance criterion, define one test case:

| AC | Test name (should … when …) | Flow |
|---|---|---|
| AC1 | `should [outcome] when [condition]` | Flow 1 |
| AC2 | `should [outcome] when [condition]` | Flow 2 |

Use OBSERVE for any criterion that is ambiguous or cannot be verified via UI alone.

## Output

A confirmed spec table ready to be consumed by `write-test.md`. Do not proceed until the developer approves it.
