# IDS Agent

The IDS agent helps developers work with the **Inera Design System** (`@inera/ids-react` and `@inera/ids-design`) — building components correctly, translating Figma designs into IDS implementations, upgrading to new major releases, and auditing accessibility.

---

## Skills

| Skill | File | When to use |
|---|---|---|
| **IDS Component** | `skills/ids-component.skill.md` | Create or modify a component using IDS best practice |
| **Figma → IDS** | `skills/figma-mcp.skill.md` | Translate a Figma frame into IDS implementation plan with JSX and imports |
| **Map Release Changes** | `skills/ids-map-release-changes.skill.md` | Audit a major IDS version — fetches release notes, produces a change map, then routes to the right migration path |
| **Update Version** | `skills/ids-update-version.skill.md` | Apply a confirmed change map to the codebase |
| **Accessibility** | `skills/ids-accessibility.skill.md` | Audit or fix WCAG 2.2 AA issues in IDS components or pages |

---

## Instructions (always active)

These instruction files apply automatically to all `.ts`, `.tsx`, and `.css` files in the repo. The IDS agent also refers to them explicitly.

| Instruction | File | Covers |
|---|---|---|
| **IDS coding rules** | `../../instructions/ids.instructions.md` | Component usage, import patterns, theme setup, wrapper conventions |
| **Accessibility rules** | `../../instructions/accessibility.instructions.md` | WCAG 2.2 AA baseline — semantic HTML, keyboard navigation, ARIA, focus management |

---

## Upgrading to a new major IDS version

Start with the **Map Release Changes** skill (`@ids` → describe the target version). It fetches the release notes from the IDS Storybook, audits all breaking changes, and then presents you with two paths:

### Option A — IDS agent migration
The IDS agent produces a change map and applies all changes. Works entirely within the IDS domain: component renames, prop changes, CSS class updates, token replacements, and version bumps. Works well for simpler migrations and major versions with few changes.

### Option B — Migrator agent migration
For larger upgrades where you want a safety-first, incremental approach. The `@migrator` agent takes over and runs its full Phase 1–3 flow: requirements doc, risk register, agent limitations, migration guide, and small verified increments where every step leaves the app in a buildable state. Choose this when the upgrade is complex or you want an incremental approach.

> The IDS agent will present both options after parsing the release notes and let you choose before any files are touched.
