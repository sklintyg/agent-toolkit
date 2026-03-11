---
description: Apply an audited IDS release change map to the codebase. Edits all affected files, bumps package.json versions, and uses Playwright CLI to snapshot key pages for visual verification. Must be preceded by ids-release.skill.md.
input: Confirmed change map at `.github/migration/ids-v{new}-change-map.md`
output: All required file edits applied + package.json version bumps + Playwright snapshots for developer review
---

# Skill: IDS Release Apply

## Steps

1. Confirm the developer has reviewed and approved the change map before proceeding.
   - Read the change map from `.github/migration/ids-v{new}-change-map.md`.

2. Process shared component wrappers first — changes here cascade to all consumers automatically:
   - Apply component renames (import + JSX).
   - Update prop types and `ComponentProps<typeof IDS*>` derivations.
   - Update CSS class strings in `classNames(...)` calls.

3. Apply changes to each remaining file in the change map:
   - Work file by file, grouped by app.
   - For each file: apply all changes in one edit, not multiple passes.

4. Apply deprecated pattern cleanup from the change map:
   - Replace `ids-heading-h{n}` class + raw `<h{n}>` tag with `<Heading level={n} size="...">`.
   - Replace `iu-*` spacing classes with Tailwind utilities or IDS spacing tokens.

5. Bump `@inera/ids-react` and `@inera/ids-design` in every `package.json` that was listed in the change map:
   - Update the version range to the new major (e.g. `^7.0.0` → `^9.0.0`).

6. Verify visually by delegating to the Playwright agent's exploratory snapshot skill.
   - Follow #file: ../../playwright/skills/exploratory-test.skill.md
   - Pass as input:
     - **Base URL**: the dev server URL (ask the developer to start it first if not already running)
     - **Routes**: all pages that render affected components (derived from the change map — e.g. pages using icons, buttons with spinners, alerts, dialogs, the footer)
     - **Label**: `ids-v{new}` (used to name snapshot files)
   - The skill handles environment context lookup and authentication automatically via #file: ../../playwright/skills/gather-env-context.md

7. Report the result:
   - List every file edited.
   - List every `package.json` bumped.
   - List the Playwright snapshots taken and note any regressions found.
   - Repeat any **Manual Review Required** items from the audit that were not applied.

## Output Format

```markdown
## IDS v{old} → v{new} Applied

### Files edited
- src/components/Button/Button.tsx
- src/pages/Welcome/Welcome.tsx
- ...

### package.json bumps
- src/app-a/package.json — ^{old} → ^{new}
- src/app-b/package.json — ^{old} → ^{new}
- ...

### Visual verification (Playwright)
- ✅ /home — no regressions
- ✅ /patient — no regressions
- ⚠️ /welcome — [describe issue if any]

### Still requires manual review
- [items carried over from the audit]
```

## Notes

- Never skip the shared-wrappers-first order — a missed wrapper will cause downstream type errors.
- Do not apply items listed under Manual Review Required — leave those for the developer.
- If a file has changed since the audit was produced, re-check the diff before applying.
- Playwright verification is visual, not functional — it catches layout/icon regressions, not logic bugs. TypeScript compilation errors must be resolved before Playwright can run.
