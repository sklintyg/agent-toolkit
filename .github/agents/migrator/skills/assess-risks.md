---
description: Scan a repository for migration risks — technical debt, incompatible patterns, missing tests in high-risk areas, and breaking changes in the target framework — before any code is changed.
input: Repository source code, requirements document, and general analysis instructions
output: A prioritised Risk Register document that informs increment ordering and OBSERVE flags in the migration guide
---

# Skill: Assess Migration Risks

## Purpose
Identify problems *before* the migration guide is written so that risks are baked into
increment ordering, OBSERVE flags, and mitigation steps — not discovered mid-implementation.

---

## Risk Categories

### 🔴 Critical — Migration Blockers
Issues that will break the migration or the application if not addressed first.

| Risk Type | Signals to Look For |
|-----------|-------------------|
| **Removed API** | Usage of an API that is deleted in the target version (e.g., `ReactDOM.render` removed in React 18, `javax.*` removed in Jakarta EE 9) |
| **No equivalent in target** | A third-party library with no React 18 / Spring Boot / equivalent — and no maintained alternative exists |
| **Circular dependency** | Module A imports B imports A — will fail after refactoring |
| **God class / God component** | A single class or component with > 500 LOC and mixed concerns — must be split before migration can succeed safely |
| **Missing tests on core flows** | Critical user flows or business logic with 0% test coverage — regressions will be invisible |
| **Framework-coupled domain logic** | Domain/business logic directly importing framework annotations (e.g., `@Autowired` inside a domain entity, `useState` inside a utility function) — hard to migrate in isolation |

### 🟡 High — Significant Effort or Risk
Won't block migration outright but will cause major complications if not planned for.

| Risk Type | Signals to Look For |
|-----------|-------------------|
| **Deprecated API (still works, removed in target)** | APIs marked `@Deprecated` in source that are removed or changed in target (e.g., `componentWillMount`, `findDOMNode`, `string refs`) |
| **Incompatible third-party library** | Library version that does not support the target framework — needs upgrade or replacement |
| **High complexity + no tests** | Functions with cyclomatic complexity > 10 and no test coverage — migration changes are unverifiable |
| **Technical debt accumulation** | Large blocks of commented-out code, `TODO`/`FIXME` comments in files being migrated, multiple workarounds stacked on each other |
| **Implicit global state** | Shared mutable module-level state, global variables, or singletons — behaviour may change under the target framework's lifecycle |
| **Mixed architectural layers** | Business logic in controllers/components, database calls in domain objects — requires refactoring alongside migration |
| **Custom implementation of target-native feature** | Hand-rolled dependency injection, custom routing, custom state management that the target framework provides natively — must be removed, not migrated |
| **Outdated build tooling** | Build tool version incompatible with target framework (e.g., Webpack 3 with React 18, Gradle < 7 with Spring Boot 3) |

### 🔵 Medium — Manageable with Planning
Adds work or uncertainty but is unlikely to derail the migration.

| Risk Type | Signals to Look For |
|-----------|-------------------|
| **Large file count in affected area** | > 50 files in a single migration increment — risk of missed files or inconsistent application |
| **Inconsistent patterns** | Same problem solved in multiple different ways across the codebase — must standardise during migration |
| **Environment-specific hardcoding** | URLs, credentials, or config values hardcoded (not in env vars) — will break in different environments post-migration |
| **Untranslatable test framework** | Tests written for a framework with no direct equivalent in the target (e.g., Enzyme with no React Testing Library equivalent) |
| **External system coupling** | Tight coupling to external APIs or services that will need stub/mock updates during testing |
| **Missing documentation** | Undocumented complex business logic in files being migrated — high `OBSERVE` flag probability |

---

## Steps

### 1. Scan for Removed and Deprecated APIs
- Search for known removals and deprecations between `[SOURCE]` and `[TARGET]`.
- Use the requirements document and analysis instructions as the source of truth for what changes.
- List every file and symbol affected.

### 2. Audit Third-Party Dependencies
- Cross-reference all dependencies against `[TARGET]` compatibility.
- Flag: incompatible (no support), deprecated (supported but discouraged), needs major version bump (breaking changes).
- Identify any dependency with **no maintained alternative** — these are blockers.

### 3. Identify Technical Debt in Migration-Affected Files
- Focus only on files that *will be changed* during migration (do not report debt in untouched files).
- Look for: god classes, deep nesting, commented-out code, `TODO`/`FIXME`, workarounds, duplicated logic.
- Rate each: will it **block** migration, **complicate** it, or just **add noise**?

### 4. Find Architectural Violations
- Check for inverted dependencies (domain importing infrastructure, components calling DB directly).
- Check for framework-coupled domain logic.
- Check for implicit global state.
- These must be resolved *before* or *as part of* migration, not after.

### 5. Cross-Reference Test Coverage
- If a test coverage analysis exists (`[APP]-test-coverage-analysis.md`), overlay it with the risk findings.
- Any 🔴 or 🟡 risk in a file with < 70% coverage is **elevated one severity level**.
- Highlight these: they are the highest-probability regression sources.

### 6. Assess Increment-Level Risk
- For each planned migration area (from the analysis instructions), rate the overall risk:
  - 🔴 High risk — blockers present, must address before or as first action in this increment.
  - 🟡 Medium risk — significant issues, need mitigation steps in guide.
  - 🟢 Low risk — no major concerns found.

---

## Output Format

Create **`[APP]-risk-register.md`** in `.github/migration/`:

````markdown
# Migration Risk Register — [APP]
**Migration:** [SOURCE] → [TARGET]
**Date:** YYYY-MM-DD
**Status:** Active (updated as risks are resolved during Phase 2)

---

## Summary

| Severity | Count | Action Required |
|----------|-------|----------------|
| 🔴 Critical | N | Must resolve before or at start of affected increment |
| 🟡 High | N | Mitigation steps added to guide |
| 🔵 Medium | N | Noted in guide, handled in place |

---

## 🔴 Critical Risks

### RISK-001: [Short title]
**Category:** Removed API / God Class / Missing Tests / etc.
**Location:** `src/path/to/file.ts` (line X or component/class name)
**Description:** [What the risk is and why it's a blocker]
**Impact:** [What breaks if this is not addressed]
**Mitigation:** [Concrete action — e.g., "Split into UserAuthService and UserProfileService before Increment 3"]
**Increment Affected:** [Which guide increment this must precede or be part of]
**Status:** Open

---

## 🟡 High Risks

### RISK-002: [Short title]
...

---

## 🔵 Medium Risks

### RISK-003: [Short title]
...

---

## Resolved Risks
_(Moved here during Phase 2 as each risk is addressed)_
````

---

## How Risks Feed Into the Migration Guide

After producing the risk register, the following must happen before Step 6 (guide generation):

1. **🔴 Critical risks** → Add a dedicated **pre-increment** or **first-action** step in the guide for each blocker. Do not let a critical risk be hidden inside a larger increment.
2. **🟡 High risks** → Add mitigation steps and `OBSERVE` flags to the relevant increments in the guide.
3. **🔵 Medium risks** → Note in the relevant increment's "Potential risks" section.
4. **Increment ordering** → If a risk in area B is a blocker for area C, area B must precede area C in the guide's increment sequence.

Present the risk register to the developer and wait for confirmation before proceeding to Step 6.

---

## Notes
- Focus on files that **will be changed**. Do not report risks in stable, untouched parts of the codebase.
- A risk with no known mitigation must become an `OBSERVE` item immediately.
- Update the risk register status during Phase 2 as each risk is resolved — it is a live document.
- If a risk is discovered **during** Phase 2 (not caught here), add it to the register and tag as `[TEMPLATE]` in the feedback section so the analysis template is updated to catch it next time.
