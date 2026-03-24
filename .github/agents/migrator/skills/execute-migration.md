---
description: Execute the migration in small, quality-gated increments following a Plan → Implement → Validate → Quality Check workflow, updating the progress document after every approved increment. VALIDATE is delegated to validate-increment.md.
input: App-specific migration guide, progress document, and repository source code
output: Migrated source code and an up-to-date progress document
---

# Skill: Execute Migration (Phase 2)

## Prerequisites
- `[APP]-migration-guide.md` — the roadmap (primary reference).
- `[APP]-migration-progress.md` — the live tracker.
- Phase 1 documents approved by developer.

---

## Increment Workflow

Every increment — no matter how small — follows these five steps in order.

```
📋 PLAN → 🔨 IMPLEMENT → ✅ VALIDATE → 🔍 QUALITY CHECK → 💡 FEEDBACK
                                              ↓                    ↓
                                       [Fail] → back       [Pass] → update
                                       to IMPLEMENT         progress doc
```

---

### Step 1 — 📋 PLAN

**Purpose:** Define exactly what this increment will change before writing a single line.

**Actions:**
1. Read the current increment from the migration guide.
2. **Check the risk register** (`[APP]-risk-register.md`) for any 🔴 Critical or 🟡 High risks tagged to this increment.
   - If a 🔴 Critical risk is still **Open**, do not start implementation — ask developer how to proceed.
   - Carry forward any open 🟡 risks as "Potential risks" in the plan output below.
3. Scan the repository to find *all* affected files — the guide provides examples, not complete lists. Use search/grep to verify scope.
4. **Check migration limits** (`[APP]-migration-limits.md`) — cross-reference every file in scope against the protected paths, patterns, and concerns in the limits document.
   - If any match is found → **STOP. Do not present the plan or begin implementation.** Present the 🚫 LIMITS CHECK block below and wait for an explicit **YES** before doing anything else.
   - Each protected item must be approved **individually** — blanket approvals are not accepted.
   - Once approved, append a row to the **Override History** table in `[APP]-migration-limits.md` before continuing.
   - If no limits file exists (developer chose no limits in Phase 1), skip this step.
5. Identify additional risks or unexpected complexities not already in the risk register.
6. Define success criteria.

**If protected items were found in Step 4**, present this block first and wait for **YES** before showing the plan:
```
🚫 LIMITS CHECK — Approval Required

The following protected item(s) would be touched in this increment:
- [protected item] — Protected because: [reason from limits document]

This item is listed in [APP]-migration-limits.md.
Type YES to approve touching it in this increment, or provide alternative instructions.
Silence, "ok", "proceed", or similar are not accepted — you must type YES.
```
Wait for the developer to type **YES**. Once received, record the override in the Override History table of `[APP]-migration-limits.md`, then present the full plan below.

**Present to developer:**
```
📋 PLAN — [Increment Name]

Scope: [what is being migrated/changed]

Files to modify:
- [complete list from repository scan, not just guide examples]

Protected items requiring approval:
- [list any files/concerns matching migration limits with approval status — or "None"]

Changes required:
- [specific changes, patterns, dependencies]

Success criteria:
- [how we verify this increment is complete]

Potential risks:
- [any concerns or edge cases]
```

**Wait for developer approval before proceeding.**

> ⚠️ If the increment involves **renaming or moving files**, split it:
> 1. First increment: update file content in the original location.
> 2. Second increment: move/rename — **only after explicit developer approval of step 1**.

---

### Step 2 — 🔨 IMPLEMENT

Execute the approved plan. Stay within increment scope — do not mix concerns. If unexpected issues arise, complete the increment as best as possible and flag with `OBSERVE`.

---

### Step 3 — ✅ VALIDATE

**Purpose:** Verify the implementation compiles, passes all configured quality checks, and runs.

**How to run:**
Execute `agents/migrator/skills/validate-increment.md` for the current increment.

The skill will:
1. Read `[APP]-quality-gate.md` to determine which commands to run.
2. Run IDE problem check, build, type check, lint, tests, app start, and any custom checks.
3. Handle command errors (config issues) separately from code failures.
4. Produce a VALIDATION report block.

**Gate:**
- ✅ PASS → proceed to Step 4 (QUALITY CHECK).
- ❌ FAIL (code problem) → return to Step 2 (IMPLEMENT) with specific failures, then repeat Step 3.
- ⚠️ Command error (config problem) → blocked until developer updates `[APP]-quality-gate.md`; do not treat as code failure.

---

### Step 4 — 🔍 QUALITY CHECK

**Purpose:** Critically assess whether the changes meet quality standards.

**Review areas:**

| Area | Questions |
|------|-----------|
| **Code quality** | Target framework best practices used? Clean, readable, maintainable? Naming conventions followed? No anti-patterns? |
| **Architecture** | Correct framework patterns? Separation of concerns maintained? Dependencies properly managed? |
| **Requirements compliance** | Matches requirements document? All planned items completed? No shortcuts or tech debt introduced? |
| **Completeness** | Repository-wide scan: any leftover source-framework artifacts? Unused imports cleaned? Deprecated patterns removed? |
| **Limits compliance** | Were any protected items from `[APP]-migration-limits.md` touched? If yes, was an explicit YES recorded in the Override History **before** the change was made? Any unrecorded override is an automatic FAIL. |

**Completeness scan** — always run a search; do not rely on the guide's file examples alone:
```
grep -r "from 'old-library'" src/
```

**Report:**
```
🔍 QUALITY CHECK — [Increment Name]

Code Quality:           [PASS / FAIL] — [observations]
Architecture:           [PASS / FAIL] — [observations]
Requirements Compliance:[PASS / FAIL] — [observations]
Completeness (scan):    [PASS / FAIL] — [scan command + results]
Limits Compliance:      [PASS / FAIL / N/A] — [list any protected items touched; confirm override recorded, or "No protected items in scope"]

Overall: ✅ APPROVED | ⚠️ NEEDS IMPROVEMENT

If NEEDS IMPROVEMENT:
Issues to address:
1. [specific issue]
Recommendations:
- [how to fix]
```

**Gate decision:**
- **✅ APPROVED** → proceed to Step 4.5.
- **⚠️ NEEDS IMPROVEMENT** → return to Step 2 with specific issues, then repeat Steps 3 & 4.

---

### Step 4.5 — 📸 EXPLORATORY TEST (conditional)

**Purpose:** After code quality is confirmed, run a visual + behavioural smoke check of the areas changed in this increment and compare against the baseline. Catches regressions that pass tests but break the running application.

**When to run:**
- **Always** if the increment is tagged 🔴 Critical or 🟡 High risk in the risk register.
- **On request** from developer for any other increment.
- **Skip** only for purely internal refactors with no user-facing change (e.g., renaming a private method, moving a config constant) — confirm with developer before skipping.

**Re-evaluate scope before running:**
The exploratory scope was decided in Phase 1, but re-check it against this increment's PLAN output before proceeding. Expand the scope if:
- Files changed in this increment map to pages/routes **not** in the current baseline scope.
- A risk was discovered during PLAN that wasn't present when scope was originally decided.
- Shared infrastructure (layout, auth, routing, global config) was touched — such changes can affect areas well outside the originally scoped list.

If expansion is needed, present the addition to the developer and capture a baseline screenshot for any new area before running the increment comparison. Update the scope list in the progress document's **Build / Test Status** section.

**How to run:**
Execute `agents/migrator/skills/verify-increment.md` — **POST-INCREMENT** for increment N.

The skill will:
1. Read the increment's PLAN output to derive which areas to explore.
2. Navigate, screenshot, check console errors and network failures for each area.
3. Compare screenshots and signals against the BASELINE captured in Phase 1.
4. Update `[APP]-exploratory-report.md` with a new POST-INCREMENT section.
5. Report any ❌ Broken or ⚠️ Changed items.

**Gate:**
- ❌ Broken items → raise OBSERVE for each, block progress until resolved.
- ⚠️ Changed items → present to developer and wait for confirmation that the change is expected before marking the increment done.
- ✅ All clean → proceed to Step 5.

---

### Step 5 — 💡 FEEDBACK CAPTURE

**Purpose:** Continuously improve the migration process by reflecting after each increment, and
pre-classify learnings so they can be applied automatically to the base templates at migration end.

**Actions:**
- Was the plan accurate? Did scope creep occur?
- Were there unexpected complexities? Better approaches available?
- Was the guide clear enough for this increment? Missing details?
- Could the increment have been structured differently?
- **Were any new risks discovered that were not in the risk register?** If yes → add them to `[APP]-risk-register.md` immediately with status `Discovered in Phase 2`, and tag as `[TEMPLATE]` if the original analysis template should have caught it.
- **Were any existing risks resolved this increment?** If yes → update their status to `Resolved` in `[APP]-risk-register.md`.

**Classify every finding with a tag:**

| Tag | Meaning | Applied to |
|-----|---------|------------|
| `[TEMPLATE]` | A gap or improvement in the base requirements or analysis template | Applied automatically to `agents/migrator/templates/` at Phase 3 completion |
| `[PROCESS]` | An improvement to how the agent runs the workflow (plan, execute, validate, quality check) | Noted for agent skill refinement |
| `[GUIDE]` | A clarification needed only in this migration's app-specific guide | Updated in `[APP]-migration-guide.md` immediately |

**Add to `[APP]-migration-progress.md`:**
```markdown
### Increment [N]: [Name]
**What Went Well:**
- [observations]

**What Could Be Improved:**
- [TEMPLATE] Requirements template missing section on [X] — add to `agents/migrator/templates/[type]-requirements-template.md`
- [TEMPLATE] Analysis template step 3 lacks guidance on [Y] — add to `agents/migrator/templates/[source]-analysis-template.md`
- [PROCESS] Plan step should include [Z] check before implementation starts
- [GUIDE] Guide increment 7 needs clarification on [W]
```

> **Why tagging matters:** At Phase 3 completion the agent automatically collects every `[TEMPLATE]`-tagged item
> from the entire progress document and applies them to the source templates in `agents/migrator/templates/` — no manual step needed.

---

### After Every Approved Increment

1. **Update progress document** (required — not optional):
   - Mark increment ✅ Done.
   - Record files changed, dependencies added/removed.
   - Add any `OBSERVE` items.
   - Update overall completion percentage.
2. **Present summary** to developer and ask for confirmation to proceed to next increment.

---

## Handling OBSERVE Items

When an `OBSERVE` is raised:
1. Stop the current increment.
2. Add the item to the OBSERVE section of the progress document with:
   - Focus area.
   - Description of the decision or question.
   - Status: Pending.
3. Inform the developer and wait for input.
4. Once resolved, mark Resolved and resume.

---

## Phase 3 — Completion

After all guide increments (including cleanup) are marked Done:

### Final Verification
1. Build: must pass.
2. All tests: must pass.
3. Application start: must succeed.

### Final Exploratory Test (mandatory if baseline was captured)

If a BASELINE run exists in `.github/migration/screenshots/baseline/`:

Execute `agents/migrator/skills/verify-increment.md` — **FINAL** phase.

The skill will run the full BASELINE area list against the completed migration, compare every area to the original baseline, and produce a final section in `[APP]-exploratory-report.md`.

Present the report summary to the developer before the satisfaction check. Any ❌ Broken items must be resolved before proceeding.

### Developer Satisfaction Check (always required — never skip)
```
✅ Migration Summary

Completed:
- [all major migration areas]
- Source framework dependencies removed
- Cleanup and optimisation complete
- Build ✅ | Tests ✅ | Application starts ✅

Remaining (if any):
- [known issues or TODOs]

Are you satisfied with the migration? Is there anything else to address?
```

Wait for developer response. If not satisfied, address the feedback before proceeding.

### Automatic Template Update (mandatory — always runs)

After developer satisfaction is confirmed, collect every `[TEMPLATE]`-tagged item from the
**entire** progress document and apply them directly to the source templates in `agents/migrator/templates/`.

**Steps:**
1. Scan `[APP]-migration-progress.md` for all lines tagged `[TEMPLATE]`.
2. Group by target file (requirements template vs. analysis template vs. other).
3. Apply each improvement to the relevant file in `agents/migrator/templates/`:
   - Add missing sections or steps.
   - Clarify ambiguous instructions.
   - Add new patterns or examples discovered during this migration.
   - Remove or correct anything that led to a wrong approach.
4. Report what was changed:

```
🔄 Templates Updated Automatically

agents/migrator/templates/[type]-requirements-template.md:
  + Added section: [section name] — [reason from feedback]
  ~ Clarified: [item] — [what was unclear]

agents/migrator/templates/[source]-analysis-template.md:
  + Added step [N]: [step name] — [reason from feedback]
  ~ Updated step [M]: [what changed]

[PROCESS] items noted (applied to agent skills if systemic):
  - [list]

These improvements are now part of the base templates.
The next migration of this type will start from a better baseline.
```

> If no `[TEMPLATE]` items were captured, state: *"No template improvements identified during this migration."*

---

## Notes
- The migration guide is the primary reference. The progress document adds context but does not override the guide.
- Notify the developer any time an undocumented change to the guide is needed.
- Use `OBSERVE` in the progress document — never silently make design decisions.
- Remove unused dependencies during migration — do not leave dead weight.
