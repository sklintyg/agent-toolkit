---
description: Audit a major IDS version upgrade. Takes pasted release notes, identifies breaking changes, scans the codebase, and produces a change map for developer review before any files are edited.
input: Pasted release notes from the IDS release (plain text or markdown)
output: A change map file at `.github/migration/ids-v{new}-change-map.md` — no source files are edited by this skill
---

# Skill: IDS Release Audit

## Steps

1. Parse the pasted release notes. Extract:
   - Version bump (e.g. `v7 → v8`)
   - **Breaking changes** — renamed components, removed props, changed prop types, CSS class renames
   - **Deprecations** — props or components that still work but must be migrated
   - **New additions** — note but don't act on unless a change requires adopting a replacement

2. Build a change map from the breaking changes:

```
| Old | New | Type |
|---|---|---|
| IDSFoo | IDSBar | Component rename |
| prop `size="large"` | prop `size="lg"` | Prop value rename |
| ids-card--shadow | ids-card--border-1 | CSS class rename |
```

3. Search the codebase for every affected symbol:
   - Search all source files for old component names, old prop names, and old CSS class strings.
   - Check both `.tsx`/`.ts` files (for React props) and `.css`/`.tsx` files (for class names).
   - Include any shared component wrappers — they may need prop type updates even if downstream usage looks fine.

4. For each match, record the required change in the output — do not edit any files yet:
   - Component renames: note old import + JSX → new import + JSX.
   - Prop renames/value changes: note the JSX attribute change.
   - CSS class renames: note the string in `classNames(...)` that must change.
   - Type changes: note the `type` / `ComponentProps<typeof IDS*>` derivation to update.

5. Also scan for known deprecated patterns and include them in the change map regardless of whether the release notes mention them — a major version bump is the right time to clear these:
   - `ids-heading-h{n}` class (e.g. `ids-heading-h5`) → replace with `<Heading level={n} size="...">` wrapper
   - `iu-pt-*` / `iu-pb-*` / any `iu-*` Inera Utils classes → replace with Tailwind utilities or IDS spacing tokens
   - Raw `<h1>`–`<h6>` with manual IDS class → replace with `Heading` wrapper

6. Note the required version bump for all `package.json` files in the change map:
   - List every `package.json` in the repo that declares `@inera/ids-react` or `@inera/ids-design`.

7. Save the full change map to `.github/migration/ids-v{new}-change-map.md` (e.g. `ids-v9-change-map.md`). Do not edit any source files.
   - Include a `## Manual Review Required` section for anything that cannot be automatically resolved (e.g. behaviour changes, new required props, layout differences).
   - End the file with: "Run the IDS release apply skill to apply these changes."
   - After saving, tell the developer the file path and ask them to review it before proceeding.

## Output Format

```markdown
## IDS v{old} → v{new} Migration

### package.json bumps
- src/app-a/package.json — ^{old} → ^{new}
- src/app-b/package.json — ^{old} → ^{new}
- ...

### Code changes

#### src/components/Button/Button.tsx
- `IDSOldButton` → `IDSButton` (import + JSX)

#### src/pages/Welcome/Welcome.tsx
- prop `size="large"` → `size="lg"` on IDSButton (line N)

### Deprecated pattern cleanup

#### src/feature/Modals/SomeModal.tsx
- `<h5 className="ids-heading-h5 ...">` → `<Heading level={5} size="s">` (line N)

### Manual Review Required
- [description of what needs human judgment]
```

## Notes

- Always process shared component wrappers first — a wrapper fix may resolve many downstream usages automatically.
- If a component was removed with no replacement, flag it in Manual Review and stop — do not invent alternatives.
- This skill produces one file only (the change map). All source file edits are handled by `ids-release-apply.skill.md`.
- The `ids-release-apply.skill.md` skill reads the saved change map file — do not skip saving it.
