---
description: Apply an audited IDS release change map to the codebase. Captures baseline playwright-cli snapshots before making changes, edits all affected files, bumps package.json versions, then takes post-migration snapshots for visual comparison. Must be preceded by ids-map-release-changes.skill.md.
input: Confirmed change map at `.github/migration/ids-v{new}-change-map.md`
output: All required file edits applied + package.json version bumps + Playwright snapshots for developer review
---

> **Note**: This skill is the simple, single-pass option. If the developer has not yet chosen between this and the Migrator agent, refer them back to `ids-map-release-changes` for guidance on which path to take.

# Skill: IDS Update Version

## Steps

0. **Capture baseline snapshots BEFORE making any changes** — this documents the current visual state so regressions can be detected after the migration.

   - Ask the developer to start the dev server if it isn't already running.
   - Use `npx playwright-cli open <url>` for each key route derived from the change map (e.g. start page, login, a page with icons/buttons/alerts).
   - After opening each route, run `npx playwright-cli screenshot --filename baseline-{route}.png --full-page` to save the screenshot.
   - **Important**: Always use `playwright-cli`, never `playwright` or `npx playwright screenshot`.
     - ✅ `npx playwright-cli open http://localhost:5173`
     - ✅ `npx playwright-cli screenshot --filename baseline-start.png --full-page`
     - ❌ `npx playwright screenshot` (wrong tool — it doesn't exist in this project)
   - Save baselines under `.playwright-cli/baselines/`.
   - Note the baseline filenames in your working notes for comparison in step 7.

1. Confirm the developer has reviewed and approved the change map before proceeding.
   - Read the change map from `.github/migration/ids-v{new}-change-map.md`.

2. Process changes from the map one by one — for **each change entry** (C1, C2, C3, …):
   - Read the entry's `Grep for` pattern
   - Search the **entire codebase** (all `.tsx`, `.ts`, `.css` files, excluding `node_modules`) for that pattern
   - Fix every hit found, not just the example hits listed in the change map
   - Process shared component wrappers first — a single fix there may resolve many downstream consumers automatically

3. Work through the full change list in order. For each change:
   - Run the grep against the codebase fresh
   - For each matched file: read the file, apply all required changes from that entry, save
   - If no hits are found, note "already clean" and move on

4. Apply deprecated pattern cleanup from the change map:
   - Replace `ids-heading-h{n}` class + raw `<h{n}>` tag with `<Heading level={n} size="...">`.
   - Replace `iu-*` spacing classes with Tailwind utilities or IDS spacing tokens.

5. Bump `@inera/ids-react` and `@inera/ids-design` in every `package.json` that was listed in the change map:
   - Update the version range to the new major (e.g. `^7.0.0` → `^9.0.0`).

5b. **Scan for remaining removed patterns** — the change map may not be exhaustive. After applying all listed changes, grep the entire codebase for patterns known to be removed in this release. Fix every hit found, even if the file was not in the change map.

   Patterns to search for (adapt based on what the release removed):
   - `IDSIcon[A-Z]` — all old icon components (removed in v8; replaced with `<Icon icon="..." />`)
   - `IDSAlertGlobal` — renamed to `IDSGlobalAlert` in v9
   - `ids-design/themes/` — old theme CSS import path (moved to `ids-design/tokens/themes/` in v9)
   - `noUnderline=` — removed prop on `IDSLink`
   - `large=` — removed prop on `IDSLink`
   - Any other prop or component listed in the release notes as removed

   **Also check all `index.html` body classes** — v9 scopes ALL component CSS to `.ids--light` / `.ids--dark` (v7 used just `.ids`). Any app root still using only `class="ids"` will show zero styling:
   - Search `index.html` files for `class="ids"` without `ids--light`
   - Update to `class="ids ids--light ids--{theme}"` per the theme in use (see `ids.instructions.md` Themes table)
   - Also check that `styles.css` is imported before the token file in each app's entry CSS

   For each hit: read the file, apply the fix, and track the file as an additional edit in the report.

6. Run install and build in the terminal, then fix any errors before proceeding:

   ```bash
   pnpm install
   pnpm build
   ```

   - If `pnpm install` fails (e.g. peer dependency conflicts), resolve them and re-run.
   - If `pnpm build` reports TypeScript or esbuild errors, read the failing files and fix them now.
   - Re-run `pnpm build` after each fix until the build exits cleanly.
   - Only proceed to step 7 once the build succeeds with no errors.
   - Then ask the developer to confirm the dev server is running and provide the port if it wasn't started in step 0.

7. Verify visually using `playwright-cli` — compare post-migration snapshots against the baselines from step 0.

   For each key route:
   ```bash
   npx playwright-cli open http://localhost:{port}/{route}
   npx playwright-cli screenshot --filename after-{route}.png --full-page
   ```

   **Always use `playwright-cli` — never use `npx playwright screenshot` or any other playwright command.**

   Compare each `after-*.png` to its corresponding `baseline-*.png` from step 0:
   - Check that IDS components are visibly styled (buttons, headers, icons, alerts)
   - Check that no layout is broken or unstyled compared to the baseline
   - Note any visual differences as regressions

   Routes to cover (derive from the change map):
   - Start/login page
   - Any page using icons, spinners, alerts, or dialogs that were changed
   - The footer (if LayoutFooter was changed)

8. Report the result:
   - In a .md file
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
- The change map is a starting point, not a complete inventory. Always run step 5b scans — change maps routinely miss usages in helper components, calendar widgets, accordion wrappers, and other non-primary files.
- **IDS v9 body class change**: v7 scoped styles to `.ids`; v9 scopes to `.ids--light` / `.ids--dark`. An app root with only `class="ids"` will have zero styling after upgrading. Always include the body class check in step 5b.
- Playwright verification is visual, not functional — it catches layout/icon regressions, not logic bugs. TypeScript compilation errors must be resolved before Playwright can run.
- **Always use `npx playwright-cli open <url>` and `npx playwright-cli screenshot` — never `npx playwright screenshot`.** The project uses `playwright-cli`, which is a different tool that works via session-based commands.
- Baseline snapshots (step 0) must be taken before any file edits. Without them, you cannot tell whether a visual issue was pre-existing or caused by the migration.
- Never proceed to Playwright without explicit developer confirmation that `pnpm install` succeeded and the dev server is running.
