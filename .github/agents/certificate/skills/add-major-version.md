---
description: Add a new major version (V2+) to an existing certificate — analyse common vs. unique elements, create a version lock test for the previous version, build the new factory, and generate tests.
input: New version number, updated certificate specification, and access to the existing certificate implementation
output: Version lock test for the previous version, CertificateModelFactory[TYPE]V[X], common element package, unique V[X] elements, and integration tests
---

# Skill: Add Major Version

> **⭐ Always create a version lock test for the previous version first.** This prevents
> accidental modification of the locked version when common elements are moved.

---

## Step 0 — Validate Input

Confirm:
- The existing certificate type (e.g., `FK7472`)
- The new version number (e.g., `V2`)
- A complete updated specification for the new version

If any is missing → **OBSERVE** and wait.

> **V[X] files must never import from V[X-1] files.** When versions share question names, always
> use the corresponding V[X] version of IDs — never reference V[X-1] files directly.

---

## Step 1 — Generate Version Analysis

Analyse the existing certificate and the new specification to identify:

**Common elements** — identical across all versions (same mappings, rules, config, and texts):
- List each: class name, ID, reason it is common

**Unique elements for V[X]** — new or changed (even a single text change makes it unique):
- List each: class name, ID, what changed

Present the analysis to the developer. **Wait for approval before writing any code.**
If the developer requests changes to the analysis, update and re-present.

---

## Step 2 — Create Version Lock Test for the Previous Version

> ⚠️ This step is **mandatory** before touching any existing code.

1. In `VersionLockTest.java`, add a test for the **previous version** (V[X-1] or the original).
2. Run the test — it will **fail** and generate a snapshot in:
   `src/test/resources/certificate-model-snapshots/`
3. Review the generated JSON snapshot file to confirm it looks correct.
4. Run the test again — it must now **pass**.

This snapshot test will detect any future accidental modification to the locked version.

---

## Step 3 — Move Common Elements

1. Create a `common` package alongside the version packages.
2. Move each identified common element class there — **no version suffix on common elements**.
3. Update all existing imports in V[X-1] to reference the common package.
4. Run all existing V[X-1] tests — they must still pass before continuing.

---

## Step 4 — Build New Certificate Model Factory

1. Create `CertificateModelFactory[TYPE]V[X]`.
2. Add the activation date for the new version to `application-dev.properties`.
3. Include all common elements (from the common package).

---

## Step 5 — Add Unique V[X] Elements

For each unique element identified in Step 1:

1. Create the class with the V[X] suffix on methods and IDs:
   - Class: `Question[Name]V[X]` (if the name conflicts with an existing version)
   - Method: `question[Name]V[X]()`
   - ID constant: `QUESTION_[NAME]_V[X]_ID`
2. If a question is common but uses a version-specific ID as an attribute, pass the ID as a
   constructor/factory parameter — see `QuestionMissbrukProvtagning` as the reference pattern.
3. Generate unit tests for each unique element class (`Question[Name]V[X]Test`).
4. Run tests after each element.

---

## Step 6 — Add Unique Elements to the Factory

Wire all unique V[X] elements into `CertificateModelFactory[TYPE]V[X]` alongside the common elements.

---

## Step 7 — Generate Integration Tests

Create:
- `[TYPE]V[X]ActiveIT`
- `[TYPE]V[X]CitizenIT`
- `[TYPE]V[X]InactiveIT`

Use existing integration tests as the reference pattern. Run all integration tests.

---

## Step 8 — Final Validation

1. Run the **full test suite** including the version lock test from Step 2 — all must pass.
2. Confirm V[X] files have **zero imports from V[X-1] files**.
3. Confirm common elements have no version suffix.
4. Present summary:

```
✅ Major Version [TYPE]V[X] Implementation Complete

Common elements moved: [N] (in common/ package)
Unique V[X] elements created: [N]
Version lock test: [TYPE]V[X-1] locked ✅
Integration tests: [TYPE]V[X]ActiveIT, [TYPE]V[X]CitizenIT, [TYPE]V[X]InactiveIT

Outstanding TODOs (developer action required):
- [list any]
```

---

## Notes
- A question is only common if **everything** is identical: mappings, rules, config, and texts.
  A single text difference makes it a unique V[X] element.
- The version lock snapshot ensures that changes to shared code don't silently break older versions.
- Never skip Step 2 — the version lock test is what makes the common-element refactor safe.
