---
description: Explore a web application using playwright-cli and produce an environment context file. Used in Step 0 of playwright-flow when no environment context exists yet.
input: App base URL
output: A populated environment context file saved to .github/agents/playwright/environments/{project-slug}.md
---

# Skill: Gather Environment Context

Invoke this skill when no environment context file exists and the developer wants Copilot to discover the environment automatically.

---

## Step 1 — Open the app and snapshot

```bash
playwright-cli open [base-url]
playwright-cli snapshot
```

Read the snapshot. Identify:
- The page title and URL structure
- Whether a login/auth step is required
- Any test-user selection (dropdowns, buttons, radio groups)
- Any test data creation controls (checkboxes, forms for creating records)

---

## Step 2 — Walk the authentication flow

Interact with the login UI to complete authentication as a default test user.
Document each interaction: what element was clicked, what values were set, any hidden-input workarounds needed.

After login, snapshot again and note:
- Final URL pattern (`/dashboard`, `/certificate/{id}/`, etc.)
- Any IDs or tokens in the URL worth capturing

---

## Step 3 — Discover test data creation

If the app has a built-in test data creation mechanism (common in dev/test environments), document:
- How to trigger it (checkbox, form, API endpoint)
- What parameters are available (type, status, fill level, user, etc.)
- The element selectors/IDs needed

---

## Step 4 — Navigate to a key feature and observe UI patterns

Navigate to at least one primary feature page. Snapshot and note:
- Key buttons and their labels / test-ids
- Modal patterns (how they open, loading states, how to wait for content)
- Any status indicators

---

## Step 5 — Write the context file

Using the TEMPLATE at `.github/agents/playwright/environments/TEMPLATE.md`, produce a populated context file:

```
.github/agents/playwright/environments/{project-slug}.md
```

Where `{project-slug}` is derived from the app hostname (e.g. `webcert-devtest`).

Fill in every section. Under **Known UI Behaviours**, note at least the loading patterns and any hidden-input workarounds discovered.

---

## Step 6 — Confirm with developer

Present a summary of what was discovered and the file path created.
Ask the developer to review and correct anything before the main flow continues.

---

## Output

A reviewed and confirmed environment context file at:
```
.github/agents/playwright/environments/{project-slug}.md
```

The playwright-flow can now use this file for all subsequent phases.
