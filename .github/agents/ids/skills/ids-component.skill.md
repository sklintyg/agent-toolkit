---
description: 'Create or modify IDS components. Covers importing from @inera/ids-react and @inera/ids-design, the wrapper pattern, typing props, and CSS-class-only components.'
input: Component name, desired behavior, target app or package, theme context
output: A ready-to-use .tsx file (and optional .css import) following the IDS wrapper pattern
---

# Skill: IDS Component

## Steps

1. Determine whether the component needs a React wrapper or CSS-only approach:
   - If an `IDS*` React component exists in `@inera/ids-react` → use the wrapper pattern.
   - If IDS only provides CSS classes (e.g. `ids-card`, `ids-heading-*`) → import the stylesheet and apply classes directly.

2. For React wrapper components:
   - Import the `IDS*` primitive from `@inera/ids-react`.
   - Define the props type using the appropriate native HTML element props (e.g. `ButtonHTMLAttributes<HTMLButtonElement>`) combined with `Omit<ComponentProps<typeof IDS*>, 'ref' | 'onclick'>`.
   - Use `forwardRef` for interactive elements (buttons, links, inputs). Use the specific element type in `ForwardedRef<HTML*Element>` to match what the component renders.
   - Spread remaining props onto the IDS component.
   - Set `ComponentName.displayName = 'ComponentName'`.

3. For CSS-only components:
   - Add `import '@inera/ids-design/components/[name]/[name].css'` at the top.
   - Use a `classNames()` utility to compose classes.
   - Map boolean/enum props to BEM modifiers (e.g. `fill > 0 && \`ids-card--fill-${fill}\``).

4. If the component must render differently depending on the active theme, check whether the repo has a theme-switching mechanism (e.g. a `useTheme()` hook or a theme context) and conditionally append theme-specific class overrides.

5. Export from the shared component index if it is intended to be used across the repo.

## Output Format

Place the file in the repo's shared component directory, e.g. `src/components/[ComponentName]/[ComponentName].tsx`.

Follow the wrapper pattern defined in `ids.instructions.md` (Wrapper pattern section). If existing wrappers are present in the repo, match their conventions exactly — they take precedence over the generic example in the instructions.

## Notes

- Check whether a wrapper already exists in the repo's component library before creating a new one.
- Never import `@inera/ids-design` theme CSS inside component files — only per-component CSS is allowed there.
- Prefer `type` imports for React types and IDS component types.
