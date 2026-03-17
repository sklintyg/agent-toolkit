---
description: Translate a Figma design into frontend implementation using IDS standards. Reads a Figma frame or screen via MCP and maps every UI element to the correct IDS component, CSS class, or custom code.
input: Figma frame URL or node ID, target app and theme (1177 / 1177-admin / inera-admin)
output: A complete implementation plan — each design element mapped to its IDS equivalent or custom fallback, with JSX structure and import list
---

# Skill: Figma to IDS Implementation

## Steps

1. Connect to Figma MCP and fetch the target frame or node. If MCP is not yet configured, ask the developer to describe or paste the design and proceed from that description, noting `[MCP PENDING]`.

2. Traverse the design tree top-down — layout containers first, then content elements:
   - Identify frames, groups, and layout structures (grid, stack, flex).
   - List every distinct UI element with its visual role (heading, button, input, card, table row, etc.).

3. For each element, map to the IDS equivalent using this priority order:
   - **IDS React component** (`@inera/ids-react`) — use if one exists. Example: button → `IDSButton`, link → `IDSLink`, alert → `IDSAlert`, card → `IDSCard`.
   - **IDS CSS class** (`@inera/ids-design`) — use if no React component exists but IDS provides CSS. Check Storybook for the correct class names and usage pattern for each component.
   - **Tailwind utility** — use for spacing, layout, and visual adjustments not covered by IDS.
   - **Custom component** — only if the element has no IDS or Tailwind equivalent.

4. Note any Figma-specific variant values and translate them to IDS props:
   - Figma visual labels map to semantic IDS props (e.g. "Filled" → `fill={1}`, "Ghost" → no fill, "Small" → `size="s"`).
   - Validate prop names against `@inera/ids-react` TypeScript types — never invent prop names from Figma labels.

5. Check the target theme and flag any elements that need theme-conditional handling via `useTheme()`.

6. Produce the implementation plan:

```
## Layout: [Frame name]
Theme: [1177 | 1177-admin | inera-admin]

### Element map
| Figma element | IDS mapping | Notes |
|---|---|---|
| Page heading | <Heading level={1} size="xl"> | ids-heading-xl |
| Primary action button | IDSButton (via Button wrapper) | |
| Content area | <div className="ids-content"> | import ids-design not needed, class only |
| [element] | [custom / Tailwind only] | No IDS equivalent |

### Imports
import { IDSButton } from '@inera/ids-react'
import '@inera/ids-design/components/card/card.css'
import { Button } from '@/packages/components/src/Button/Button'

### JSX structure (skeleton)
[Rendered JSX outline showing nesting and component choices]
```

7. Flag anything that requires a new wrapper component and note it as a handoff to `ids-component.skill.md`.

## Notes

- IDS component names in Figma may differ from the npm export name — always verify against `@inera/ids-react` exports.
- Tokens follow the format `--IDS-COLOR-*`, `--IDS-SPACING-*`, `--IDS-FONT-*` — don't hardcode color values.
- Never use deprecated patterns: `ids-heading-h{n}`, raw `<h1>`–`<h6>` with manual class, or `iu-*` spacing utilities.
- The goal is maximum IDS coverage — custom code is the last resort, not the first.
