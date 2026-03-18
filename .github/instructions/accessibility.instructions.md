---
description: Accessibility (a11y) coding rules — WCAG 2.2 AA baseline for all React/TSX components using the IDS design system.
applyTo: "**/*.{ts,tsx,css}"
---

# Accessibility — Coding Rules

> Baseline: **WCAG 2.2 Level AA**. These rules apply to every `.tsx` file. When performing a focused audit or remediation, use the `ids-accessibility` skill which fetches live Storybook a11y notes on demand.

## WCAG 2.2 additions (beyond 2.1)

WCAG 2.2 adds the following criteria that are most relevant to IDS component work:

| Criterion | Level | Rule |
|---|---|---|
| 2.4.11 Focus Not Obscured (Minimum) | AA | A focused component must not be entirely hidden by sticky headers, overlays, or banners. Ensure scroll containers account for fixed elements. |
| 2.4.13 Focus Appearance | AA | The focus indicator must have a minimum area of the perimeter × 2 CSS pixels and a contrast ratio of 3:1 against adjacent colors. Use `--IDS-COLOR-INTERACTIVE-FOCUS` tokens — never suppress outline. |
| 2.5.3 Label in Name | A | For components with visible text labels, the accessible name must **contain** the visible text (case-insensitive). Do not use an `aria-label` that replaces rather than extends the visible label. |
| 2.5.7 Dragging Movements | AA | Any functionality that uses drag must have a single-pointer alternative (e.g. up/down buttons, keyboard reorder). |
| 2.5.8 Target Size (Minimum) | AA | Interactive targets must be at least 24×24 CSS pixels. IDS button and link components satisfy this — do not shrink them with custom CSS. |
| 3.2.6 Consistent Help | A | If a help mechanism (e.g. contact link, tooltip trigger) appears on multiple pages, it must appear in the same relative order. |
| 3.3.7 Redundant Entry | A | Do not ask users to re-enter information they have already provided in the same session/form flow. |
| 3.3.8 Accessible Authentication (Minimum) | AA | Do not require a cognitive function test (e.g. CAPTCHA, puzzle) without an alternative. BankID is acceptable; image-only CAPTCHAs are not. |

## Semantic HTML

- Use the correct landmark elements: `<main>`, `<nav>`, `<header>`, `<footer>`, `<aside>`, `<section>`. Do not replace these with generic `<div>` containers.
- Never use `<div>` or `<span>` as an interactive element — use the appropriate IDS component (`IDSButton`, `IDSLink`) when one exists; only fall back to a native HTML element (e.g. `<button>`, `<a>`) when no IDS equivalent is available.
- `<section>` must have an accessible name via `aria-labelledby` or `aria-label`; otherwise use `<div>`.

## Headings

- Follow heading order: never skip a level (e.g. `<h1>` → `<h2>`, not `<h1>` → `<h3>`).
- Always use the `<Heading>` wrapper — never raw `<h1>`–`<h6>` with manual class names.
- Each page must have exactly one `<h1>`.
- If a heading level is not annotated, infer it from the surrounding hierarchy — but never skip levels.

```tsx
// Correct
<Heading level={1} size="xl">Page title</Heading>
<Heading level={2} size="l">Section title</Heading>

// Wrong — skips level, raw element
<h1>Page title</h1>
<h3 className="ids-heading-m">Section title</h3>
```

## Interactive element labels

Always provide a text alternative for every interactive element:

| Scenario | Rule |
|---|---|
| Icon-only button | `aria-label` on `IDSButton` (or wrapper) describing the action |
| Icon-only link | `aria-label` on `IDSLink` |
| Button with visible text | No extra `aria-label` needed — visible text is the label |
| Image inside a button | `alt=""` on the image; `aria-label` on the button |

```tsx
// Icon-only button — correct
<IDSButton aria-label="Stäng dialog">
  <IDSIcon name="cross" aria-hidden="true" />
</IDSButton>

// Icon-only button — wrong (no accessible name)
<IDSButton>
  <IDSIcon name="cross" />
</IDSButton>
```

## Images

- Every `<img>` must have `alt`.
- Decorative images (purely visual, add no information): `alt=""`.
- Informative images: `alt` must describe the content, not the file name.
- If an image has no annotation, treat it as decorative (`alt=""`). If it conveys meaning, it must be annotated with an alt-text or description.
- SVG icons and IDS icon spans used as decoration next to visible text: `aria-hidden="true"` on the element.

```tsx
// Informative image
<img src={logo} alt="Inera logotyp" />

// Decorative icon next to text — hide from screen readers
<span className="ids-icon-info" aria-hidden="true" />
<span>Information</span>
```

## Forms

- Every input must have a visible, programmatically associated label — use `IDSLabel` paired with the input by matching `htmlFor` / `id`.
- Never use `placeholder` as the only label; `placeholder` disappears on input and is not reliably announced.
- Group related inputs (checkboxes, radios) in a `<fieldset>` with a `<legend>`.
- Error messages must be linked to the input they describe via `aria-describedby`.

```tsx
// Correct — label associated by id
<IDSLabel htmlFor="personnummer">Personnummer</IDSLabel>
<IDSInput id="personnummer" aria-describedby="personnummer-error" />
{error && <span id="personnummer-error" role="alert">{error}</span>}

// Wrong — placeholder only, no label
<IDSInput placeholder="Personnummer" />
```

## Alerts and status messages

| Component | Required ARIA |
|---|---|
| `IDSAlert` (error/warning/success) | Render with `role="alert"` for urgent messages that interrupt |
| `IDSAlert` (info / non-urgent status) | Use `role="status"` — polite announcement |
| Inline validation error | `role="alert"` on the error element |
| Toast / transient notification | `role="status"` inside a persistent live region in the DOM |

> The `ids-alert` CSS-only component does not add `role` automatically — you must set it.

```tsx
// Urgent error
<div className="ids-alert ids-alert--error" role="alert">…</div>

// Non-urgent status
<div className="ids-alert ids-alert--info" role="status">…</div>
```

## Dialogs

- Always use `IDSDialog` (or the `Dialog` wrapper) — never a custom `<div role="dialog">` implementation.
- Pair `IDSDialog` with `aria-labelledby` pointing to the dialog's heading `id`, and `aria-describedby` if there is a body description.
- Focus must move into the dialog when it opens and return to the trigger element when it closes.
- `Escape` must always close the dialog.

```tsx
<IDSDialog aria-labelledby="confirm-title" aria-describedby="confirm-desc">
  <Heading id="confirm-title" level={2} size="m">Bekräfta borttagning</Heading>
  <p id="confirm-desc">Åtgärden kan inte ångras.</p>
  …
</IDSDialog>
```

## Keyboard navigation

- Never remove or suppress `outline` in CSS without providing an equivalent custom focus indicator.
- All interactive elements must be reachable and operable with keyboard.
- Custom keyboard shortcuts must not conflict with browser or assistive technology shortcuts.
- Modal overlays must trap focus within themselves while open.

```css
/* Wrong — removes focus ring with nothing to replace it */
*:focus { outline: none; }

/* Correct — custom focus style */
*:focus-visible { outline: 2px solid var(--IDS-COLOR-INTERACTIVE-FOCUS); outline-offset: 2px; }
```

## Color and contrast

- Flag any code where information is conveyed by color alone (no text, icon, or pattern paired with it) — raise it as a finding rather than silently accepting it. The underlying fix should come from design.
- Do not hardcode colors with `#hex` or `rgb()` — use IDS CSS custom properties (`--IDS-COLOR-*`) which are tested for contrast.
- Do not override `--IDS-COLOR-*` tokens at component level — only override at `:root` or the theme class level.

## What NOT to do

| Anti-pattern | Correct approach |
|---|---|
| `aria-hidden="true"` on a focusable element | Remove `aria-hidden` or make the element non-focusable (`tabIndex={-1}`) |
| `tabIndex={0}` on a `<div>` to make it "clickable" | Use `IDSButton` or a native `<button>` |
| `<label>` wrapping text but `htmlFor` missing | Always set `htmlFor` matching the input's `id` |
| Hiding skip-navigation link permanently | Keep skip-nav visible on focus: `focus:not(.sr-only)` |
| `role="presentation"` on a data table | Only use on layout tables with no meaningful structure |
| Icon font span without `aria-hidden` next to visible text | Add `aria-hidden="true"` to the icon span |

## IDS-specific notes

- `IDSSpinner` should have `aria-label="Laddar…"` or be inside a live region so screen readers announce loading state.
- `IDSAccordion` manages its own `aria-expanded` — do not override it manually.
- `IDSSelect` handles its own keyboard navigation — do not add extra `onKeyDown` handlers.
