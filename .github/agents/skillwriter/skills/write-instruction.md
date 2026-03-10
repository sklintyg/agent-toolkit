---
description: Create a .instructions.md file that applies coding rules automatically to matching files.
input: A set of coding rules and the file patterns they apply to
output: A complete .instructions.md file ready to use
---

# Skill: Write an Instruction File

## Structure

```
---
description: '[What these rules cover and when they apply]'
applyTo: '[glob — e.g. **/*.ts, **/*.{test,spec}.ts, src/domain/**]'
---

# [Title]

Apply these rules when [context, e.g. "writing or reviewing TypeScript files"].

## [Category 1]
- **[Rule]** — [one-line reason]
- **[Rule]** — [one-line reason]

## [Category 2]
- **[Rule]** — [one-line reason]
```

## Rules

- **`applyTo` glob is mandatory** — without it the file is never auto-applied. Use `**` for all files.
- **≤5 categories, ≤15 rules total** — beyond this, split into two instruction files.
- **Each rule needs a reason** — "Use `const` over `let`" is a rule; "because it prevents reassignment bugs" is the reason. Both in one line.
- **Avoid duplicating** rules already in an existing instruction file — check `.github/instructions/` first.
- **Description** should state scope + trigger: "TypeScript coding standards applied to all .ts files."

## Example

```
---
description: 'React component guidelines applied to all .tsx files.'
applyTo: '**/*.tsx'
---

# React Components

## Structure
- **One component per file** — keeps diffs small and imports explicit.
- **Name the file after the component** — `UserCard.tsx` exports `UserCard`.

## Props
- **Define props as a named interface** — avoid inline `{ prop: type }` in function signatures.
- **Never use `any` for props** — use `unknown` and narrow it.
```

## Checklist

- [ ] `applyTo` glob is set and tested against target files
- [ ] description explains both topic and scope
- [ ] no rule is duplicated from an existing instruction file
- [ ] every rule has a one-line reason
- [ ] file saved to `.github/instructions/[name].instructions.md`
