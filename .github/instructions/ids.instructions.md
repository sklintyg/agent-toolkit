---
description: Coding rules for working with the IDS design system (@inera/ids-react and @inera/ids-design).
applyTo: "**/*.{ts,tsx,css}"
---

# IDS Design System — Coding Rules

## Packages

- `@inera/ids-react` — React components (all prefixed `IDS*`). Import named exports: `import { IDSButton, IDSSpinner } from '@inera/ids-react'`
- `@inera/ids-design` — CSS themes and per-component stylesheets. Import as side effects: `import '@inera/ids-design/components/card/card.css'`

## Component naming

- All IDS primitives are prefixed `IDS` — e.g. `IDSButton`, `IDSLink`, `IDSDialog`, `IDSCard`, `IDSAccordion`.
- Local wrapper components use plain names — e.g. `Button`, `AppLink`, `Dialog`, `Card`.
- Never use raw HTML (`<button>`, `<a>`, `<dialog>`) when an IDS equivalent exists.

## Wrapper pattern

Wrap IDS primitives when you need typed props, local state, or router integration. Follow this shape:

```tsx
import { IDSButton, IDSSpinner } from '@inera/ids-react'
import type { ButtonHTMLAttributes, ComponentProps, ForwardedRef } from 'react'
import { forwardRef } from 'react'

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & Omit<ComponentProps<typeof IDSButton>, 'ref' | 'onclick'>

export const Button = forwardRef(({ children, loading, ...props }: ButtonProps, ref: ForwardedRef<HTMLButtonElement>) => (
  <IDSButton ref={ref} loading={loading} {...props}>
    {loading ? <IDSSpinner light /> : children}
  </IDSButton>
))

Button.displayName = 'Button'
```

Key rules for wrappers:
- Use `forwardRef` when wrapping interactive elements.
- Omit `ref` and native event props that conflict (`onclick` → use `onClick`).
- Spread remaining props onto the IDS component.

## CSS-only components

Some IDS components have no React counterpart — use CSS classes directly with `ids-design`:

```tsx
// Import the stylesheet once per component file
import '@inera/ids-design/components/card/card.css'

// Apply BEM-style class names
<div className="ids-card ids-card--fill-1 ids-card--interactive">
```

Use a `classNames()` utility to compose conditional class names.

## Themes

**IDS v9+ CSS structure** — the old monolithic theme file is split into two required imports:

```css
/* 1. All component styles (scoped to .ids--light / .ids--dark) */
@import '@inera/ids-design/styles.css';
/* 2. CSS custom properties for the chosen theme (scoped to .ids--{theme}.ids--light) */
@import '@inera/ids-design/tokens/themes/inera-admin-tokens.css';
```

| Theme | Token import path | Body classes required |
|---|---|---|
| `1177` | `@inera/ids-design/tokens/themes/1177-tokens.css` | `ids ids--light ids--1177` |
| `inera-admin` | `@inera/ids-design/tokens/themes/inera-admin-tokens.css` | `ids ids--light ids--inera-admin` |

**Critical**: In v9, all component styles are scoped to `.ids--light` or `.ids--dark`. If the app root element (typically `<body>`) only has `class="ids"` (the v7 convention), **no IDS styles will apply at all**. The body element in every `index.html` must include `ids--light` (or `ids--dark`) plus the theme class.

- Import `styles.css` once, then the token file for the chosen theme.
- Apply `inera-admin` theme class conditionally via `useTheme()` hook when a component must differ between themes.
- Override CSS custom properties (`--IDS-*`) at `:root` level only, never inline.

## Typography

Use `Heading` wrapper (not raw `<h1>`–`<h6>`) for consistent sizing:

```tsx
<Heading level={1} size="xl">Page title</Heading>
```

Valid sizes: `xs | s | m | l | xl | xxl`. The class applied is `ids-heading-{size}`.

A `Heading` wrapper maps the `level` and `size` props to `ids-heading-{size}` — use it instead of raw heading tags with manual class names.

## What NOT to do

- Don't import from `@inera/ids-react` inside test files — mock at the module level:
  ```ts
  vi.mock('@inera/ids-react', () => ({
    IDSButton: ({ children, ...props }: React.HTMLAttributes<HTMLButtonElement>) => <button {...props}>{children}</button>,
  }))
  ```
- Don't apply theme CSS imports inside component files — theme belongs in app entry CSS.
- Don't copy-paste IDS CSS class strings from memory — check `@inera/ids-design/components/` for the actual class names.
- Don't mix IDS versions across packages — `@inera/ids-react` and `@inera/ids-design` should always be on the same version.

## Deprecated patterns — never use

| Deprecated | Correct replacement |
|---|---|
| `ids-heading-h1` … `ids-heading-h6` | `ids-heading-{size}` via `<Heading level={n} size="xl">` |
| `iu-pt-*`, `iu-pb-*`, `iu-*` (Inera Utils spacing) | Tailwind utilities or IDS spacing tokens (`--IDS-SPACING-*`) |
| Raw `<h1>`–`<h6>` with manual class | `<Heading level={n} size="...">` wrapper |
| Raw `<button>` / `<a>` when IDS equivalent exists | `IDSButton` / `IDSLink` (or wrapper `Button` / `AppLink`) |
