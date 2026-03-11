---
description: Navigate a running web app to a set of routes, authenticate using an environment context file, take snapshots of each page, and report any visible regressions. Use when you need a quick visual check after code changes — not for writing or verifying Playwright tests.
input: Base URL + list of routes to snapshot + reason for the check (e.g. "after IDS v9 upgrade")
output: One snapshot per route, stored in `.github/test-output/snapshots/`, plus a regression report
---

# Skill: Exploratory Snapshot

Use this skill for lightweight visual verification after significant code changes — component upgrades, CSS migrations, design system bumps. It navigates, authenticates, snapshots, and reports. It does not write or run tests.

---

## Step 0 — Load environment context

Load the environment context file from:
```
.github/agents/playwright/environments/{app-slug}.md
```

Use it for: base URL (if not already provided), authentication flow, known UI quirks and loading patterns.
If the file is missing, run the `gather-env-context.md` skill first, then return here.

---

## Step 1 — Open and authenticate

```bash
playwright-cli open [base-url]
```

Follow the authentication steps from the environment context file exactly.
Snapshot after login to confirm the authenticated state before proceeding.

---

## Step 2 — Snapshot each route

For each route in the provided list:

1. Navigate to the route:
   ```bash
   playwright-cli goto [base-url]/[route]
   ```
2. Wait for content to settle (check environment context for known loading patterns).
3. Take a snapshot:
   ```bash
   playwright-cli snapshot --filename=.github/test-output/snapshots/[label]-[route-slug].yaml
   ```
4. Scan the snapshot for obvious regressions:
   - Missing elements that should be present (icons, buttons, labels)
   - Broken layout indicators (overlapping elements, empty containers)
   - Error states or loading spinners that never resolved

If a regression is found, stop immediately and report it — do not continue to the next route.

---

## Step 3 — Close and report

```bash
playwright-cli close
```

Produce a report in this format:

```markdown
### Exploratory Snapshot — [label] — [date]

| Route | Result | Notes |
|---|---|---|
| /home | ✅ OK | |
| /patient | ✅ OK | |
| /welcome | ⚠️ Regression | [describe what was wrong] |
```

List all snapshot file paths. Flag any regressions clearly — do not silently skip.

---

## Notes

- This skill is visual only — it does not assert data correctness or run automated tests.
- If a page requires test data to show meaningful UI, follow the test data creation steps from the environment context before navigating.
- Snapshots are YAML accessibility trees, not screenshots. Use `playwright-cli screenshot` only when you need a pixel-level view of an issue.
- For test correctness verification (comparing live UI against written test assertions), use `agent-verify.md` instead.
