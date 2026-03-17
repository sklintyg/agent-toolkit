---
description: 'Audit or fix accessibility issues in IDS components or pages. Fetches live Storybook a11y notes, maps findings to WCAG 2.2 AA, and produces a prioritized remediation list before editing anything.'
input: Component file path, page route, or a code snippet to audit
output: Prioritized a11y findings table — no files edited until developer confirms
---

# Skill: IDS Accessibility Audit & Fix

## Rules baseline

Apply all rules from:
- #file: ../../../instructions/accessibility.instructions.md

## Steps

### Step 1 — Identify scope

Ask the developer (or infer from context) what to audit:
- A single component file
- A page / route
- A code snippet pasted inline

If multiple IDS components are involved, list them before proceeding.

### Step 2 — Fetch live Storybook a11y notes

For each distinct IDS component in scope, fetch its Storybook docs using `playwright-cli`:

```
URL pattern: https://design.inera.se/?path=/docs/components-{component-name}--docs
```

Navigate to the URL, look for an **Accessibility** section on the page.  
Record any component-specific ARIA requirements or known limitations not already covered by `accessibility.instructions.md`.

If a component page has no Accessibility section, note `[no Storybook a11y notes]` and continue.

> If playwright-cli is unavailable, skip this step and note `[Storybook fetch skipped — add manually]` in the findings.

### Step 3 — Audit the code

Read the target file(s). Rules are defined in `accessibility.instructions.md` — look for code that does not fullfill accessability requirements. As example but not limited to:

1. `IDSInput` / `IDSSelect` / `IDSCheckbox` / `IDSRadioButton` without a matching `IDSLabel` with `htmlFor`; or `placeholder` used as the only label
2. `IDSButton` / `IDSLink` with only an icon child and no `aria-label`
3. `IDSIcon` or icon-font `<span>` next to visible text without `aria-hidden="true"`
4. `ids-alert--error` / `ids-alert--warning` without `role="alert"`; `ids-alert--info` without `role="status"`
5. `IDSDialog` without `aria-labelledby`
6. Skipped heading levels or raw `<h1>`–`<h6>` instead of `<Heading>`
7. `outline: none` in CSS with no replacement; `tabIndex={0}` on `<div>` or `<span>`
8. Hardcoded `#hex` / `rgb()` color values
9. `<img>` without `alt`
10. Related inputs (checkbox/radio groups) not in `<fieldset>` + `<legend>`; errors not linked via `aria-describedby`
11. WCAG 2.2: sticky/fixed elements that could fully obscure a focused component (2.4.11); touch targets < 24×24px (2.5.8); `aria-label` that replaces rather than includes visible text (2.5.3)
12. Component-specific findings from Step 2

### Step 4 — Build the findings table

Produce a table with one row per issue:

| # | File | Line | Issue | WCAG criterion | Severity | Fix |
|---|---|---|---|---|---|---|
| 1 | `Button.tsx` | 12 | Icon-only `IDSButton` has no `aria-label` | 4.1.2 Name, Role, Value | High | Add `aria-label="Stäng"` |
| 2 | `Form.tsx` | 34 | `placeholder` used as only label | 1.3.1 Info & Relationships | High | Add `IDSLabel` with `htmlFor` |

Severity levels:
- **High** — blocks screen reader or keyboard use entirely (WCAG A/AA fail)
- **Medium** — degrades experience, workaround exists (WCAG AA)
- **Low** — best practice / WCAG AAA

### Step 5 — Wait for confirmation

Show the findings table and ask the developer:
> "Found N issues. Apply all fixes, apply High only, or select specific items?"

Do **not** edit any files until the developer confirms.

### Step 6 — Apply fixes

Apply only the confirmed fixes. For each:
- Make the minimal targeted change.
- Do not refactor surrounding code.
- Add a short inline comment only if the ARIA usage is non-obvious.

After applying, summarize what was changed.

## Output Format

**Audit output (Step 4):**
```
## A11y Audit — {Component or page name}

Storybook notes fetched: {yes / no / skipped}

| # | File | Line | Issue | WCAG | Severity | Fix |
|---|---|---|---|---|---|---|
| … |

Total: {n} High, {n} Medium, {n} Low
```

**After fix (Step 6):**
```
## Applied fixes

- ButtonClose.tsx L12: added aria-label="Stäng"
- Form.tsx L34: added IDSLabel with htmlFor="email"
```

## Notes

- If a fix requires a new IDS component (e.g. replacing a custom dialog), delegate to `ids-component.skill.md`.
- If an IDS component lacks the needed ARIA prop, flag it as `[IDS limitation]` and suggest a native HTML wrapper with the required ARIA attributes alongside the IDS CSS classes.
