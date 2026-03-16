---
description: Audit a major IDS version upgrade. Tries to fetch release notes from the IDS Storybook, falls back to pasted input, identifies breaking changes, and produces a change map for developer review before any files are edited. The change map is change-centric — one entry per release note item — so the apply skill can independently grep the entire codebase for each change.
input: Target IDS version (e.g. `v9`) — release notes are fetched from the IDS Storybook automatically; paste them manually only if the fetch fails
output: A change map file at `.github/migration/ids-v{new}-change-map.md` — no source files are edited by this skill
---

# Skill: IDS Map Release Changes

## Core philosophy

The change map is a **recipe book of changes**, not a list of files to edit. Each entry describes **one breaking change from the release notes** with a grep pattern, so the apply skill can search the entire codebase fresh. The audit does a handful of example searches to validate patterns and document what it found, but it does not attempt to enumerate every affected file — that is the apply skill's job.

## Steps

### Step 1 — Fetch and parse release notes

Fetch the release notes from the IDS Storybook using playwright-cli. Navigate to:
`https://design.inera.se/?path=/docs/development-changelog-{major}-{minor}--docs`
(e.g. for v9.0: `https://design.inera.se/?path=/docs/development-changelog-9-0--docs`)

If unavailable, ask the developer to paste the release notes manually.

Parse and extract **every item** under:
- **Breaking changes** — component renames, removed props, changed prop types, CSS class renames, HTML structure changes
- **CSS breaking changes** — IDS release notes have a dedicated section; treat each bullet as a breaking change
- **Deprecations** — still work but must be migrated

For each item, note its category: `component-rename` | `prop-removed` | `prop-renamed` | `prop-value-changed` | `css-class-renamed` | `html-structure` | `token-removed` | `event-renamed` | `deprecation`

---

### Step 2 — Translate each item into a change entry

For every breaking change, produce one entry:

```markdown
### C{N}: {Short description}
- **Category**: {category}
- **Release note**: "{exact text from release notes}"
- **Grep for**: `{search pattern to find old code}`
- **Old code**: `{old code snippet}`
- **New code**: `{new code snippet}`
- **Example hits** (run grep during audit to validate — show 1–3 results or "none found"): …
- **Notes**: {special handling, e.g. "check which prop value applies per context"}
```

**Always run the grep** when writing the entry — this validates the pattern is correct and shows where the issue exists. If no hits are found, write "none found" — that means the codebase is already clean for this change.

---

### Step 3 — Apply mandatory extended search rules

These entries are **always** added to the change map regardless of whether the release notes explicitly name them.

#### 3a — Base token removal
When release notes mention removal of base color tokens (e.g. `--IDS-COLOR-X-Y`):
- Grep all `.css`, `.tsx`, `.ts` files (excluding `node_modules`) for `--IDS-[A-Z]` and `--IDS-FORM-` (uppercase = old base token convention)
- Also grep for inline `var(--IDS-COLOR-` strings in JSX/TSX
- Add one change entry per distinct token name found, with the correct semantic replacement looked up from `node_modules/@inera/ids-design/tokens/themes/{theme}-tokens.css`

#### 3b — HTML structure changes
When release notes say "{Component}: Has new HTML" or "Has changed HTML structure":
- Read the installed `node_modules/@inera/ids-design/styles.css` to find the new CSS class hierarchy for that component
- Grep the codebase for the **old** class name used on the wrong element type (e.g. `ids-input` as a className directly on `<input>`)
- Add a change entry showing full old → new HTML structure and search pattern for each old class

For **Input/Select structure changes**, always search for:
- `className.*\bids-input\b` on raw `<input>` elements (old: class on input itself; new: outer wrapper div)
- `ids-select-wrapper` (old outer wrapper class)
- `\bids-select\b` on `<select>` elements (old: class on select; new: use `ids-select__select` inside `ids-select__wrapper`)

#### 3c — Form label structure changes
When release notes mention form label changes:
- Grep for `ids-label-tooltip-wrapper` (old wrapper class → now `ids-label-wrapper`)
- Grep for tooltip icons not wrapped in a `<span class="ids-label__tooltip">` span
- Add change entries for each

#### 3d — Deprecated patterns (always include)
- Grep for `ids-heading-h[1-6]` on raw `<h{n}>` → replace with `<Heading level={n} size="...">`
- Grep for `\biu-[pmtblr][tlrbxy]?-` (Inera Utils spacing classes) → replace with Tailwind utilities

---

### Step 4 — Verify theme assignments

For every app and shared package:
- Check `index.html` `<body>` class: must include `ids--light` (or `ids--dark`) plus the theme class (e.g. `ids--1177-admin`). Just `class="ids"` is broken in v9.
- Check entry CSS: must import `styles.css` **before** the token file
- Confirm `styles.css` + `tokens/themes/*.css` are both present

Add a `### Theme verification` table:

| App | Body class | Token import | Status |
|---|---|---|---|
| app-a | `ids ids--light ids--1177-admin` | `1177-admin-tokens.css` | ✅ |
| app-b | `ids` | `1177-tokens.css` | ⚠️ missing `ids--light` — add it |

---

### Step 5 — List package.json bumps

List every `package.json` in the repo that declares `@inera/ids-react` or `@inera/ids-design`, with old and new version.

---

### Step 6 — Completeness check

Re-read the release notes line by line. For every item, confirm a change entry (by number) covers it. If missing, add it.

```markdown
### Completeness check
- Release note items total: N
- Mapped: N
- Unmapped: [{item}] — {reason, e.g. "runtime behaviour change, no code equivalent"}
```

---

### Step 7 — Save and report

Save to `.github/migration/ids-v{new}-change-map.md`. Do not edit any source files.

End the file with:
> "Run the IDS update version skill to apply these changes."

Tell the developer the file path and ask them to review it before proceeding.

---

## Output Format

```markdown
# IDS v{old} → v{new} Change Map

## package.json bumps
- `apps/foo/package.json` — `^{old}` → `^{new}`

## Changes

### C1: Spinner `light` prop replaced by `variant`
- **Category**: prop-removed
- **Release note**: "Spinner: light has been replaced with variant. Variant 3 is the former light version."
- **Grep for**: `<IDSSpinner` with `light` prop
- **Old code**: `<IDSSpinner light />`
- **New code**: `<IDSSpinner variant="3" />` (primary button) / `variant="2"` (secondary button)
- **Example hits**: `packages/components/src/Button/Button.tsx:23`
- **Notes**: Choose variant based on which button type contains the spinner.

### C2: Input — new HTML wrapper structure
- **Category**: html-structure
- **Release note**: "Input: Has changed HTML structure."
- **Grep for**: `className.*\bids-input\b` on `<input>` elements; also `ids-select-wrapper`; also `\bids-select\b` on `<select>` elements
- **Old code**:
  `<input className="ids-input ids-input--light" />`
- **New code**:
  ```tsx
  <div className="ids-input">
    <div className="ids-input__wrapper">
      <div className="ids-input__input-wrapper">
        <input className="ids-input__input ids-input--light" />
      </div>
    </div>
  </div>
  ```
- **Example hits**: `packages/components/src/form/Input/Input.tsx:45`
- **Notes**: Also update Select wrapper: `ids-select-wrapper` → `ids-select__wrapper`, `ids-select` on `<select>` → `ids-select__select`.

### C3: Base color tokens removed (`--IDS-COLOR-X-Y`)
- **Category**: token-removed
- **Release note**: "All base-tokens --IDS-COLOR-X-Y has been removed."
- **Grep for**: `--IDS-COLOR-` and `--IDS-FORM-PLACEHOLDER`
- **Old code**: `var(--IDS-COLOR-SECONDARY-95)`
- **New code**: `var(--ids-color-surface-background-alternative)` (look up semantic equivalent in `tokens/themes/{theme}-tokens.css`)
- **Example hits**: `apps/rehabstod/src/index.css:32`, `src/graph/TotalSickLeavesGraph.tsx:45`
- **Notes**: Semantic tokens are lowercase `--ids-*`. They adapt to dark mode automatically.

## Theme verification
| App | Body class | Token import | Status |
|---|---|---|---|
| rehabstod | `ids ids--light ids--1177-admin` | `1177-admin-tokens.css` | ✅ |

## Completeness check
- Release note items total: N
- Mapped: N
- Unmapped: [{item}] — {reason}

## Manual Review Required
| Item | Reason |
|---|---|
| ... | ... |
```

---

## Notes

- **Never produce a file-per-file diff.** The change map is change-per-change. Example hits listed during the audit are illustrative, not exhaustive — the apply skill will re-search.
- If a component was removed with no replacement, flag it in Manual Review and stop — do not invent an alternative.
- This skill produces one file only (the change map). All source file edits are handled by `ids-update-version.skill.md`.

## Choosing the next step

After the developer has reviewed the change map, present the two options and ask them to choose: