# Migrator Agent

Guides code migrations from analysis to verified, production-ready result. Works in three phases:

## How to Trigger

**VS Code — Agent mode** *(recommended)*
1. Open Copilot Chat (`Ctrl+Alt+I` / `Cmd+Alt+I`).
2. Switch to **Agent** mode in the chat panel.
3. Select **migrator** from the agent picker.
4. Describe your migration — e.g. *"Migrate myapp from React 16 to React 18"*.

**VS Code — Skill**
1. Open Copilot Chat.
2. Type `/migrate` — this invokes skill directly.
3. Same guided flow as agent mode.

**GitHub Copilot CLI**

Two different commands available depending on if you want agent or only skill:

```
/agent migrator
/skill migrate
```
---

## Workflow
```
Phase 1 — Plan          Phase 2 — Execute               Phase 3 — Complete
─────────────────       ───────────────────────────────  ──────────────────
Identify migration  →   For each increment:          →   Final build + tests
Analyse coverage        PLAN → IMPLEMENT → VALIDATE       Final exploratory run
Set limits              QUALITY CHECK → EXPLORATORY       Template updates
Assess risks            Update progress doc               Developer sign-off
Write guide
Decide exploratory scope
Capture baseline
```

Three layers, one concern each — nothing bleeds between them.

| Layer | File | What it does |
|-------|------|--------------|
| Prompt | `prompts/migrate.prompt.md` | State detection and routing — the human entry point |
| Agent | `migrator.agent.md` | Orchestration, rules, and output contract |
| Skills | `skills/*.md` | One skill per concern, each doing one job |

The prompt figures out where you are (new migration or resumption) and hands off to the right skill. The agent holds the guardrails that apply to every phase. The skills contain the actual reasoning — what to look for, what traps to avoid, how to decide.

---

## Ways of Working

| Mechanism | What it does |
|-----------|-------------|
| **Limits** | A protected list of files and concerns agreed before any code is touched. Every increment plan is checked against it — a match hard-stops the agent until the developer types **YES**. Overrides are recorded permanently. Prevents the agent from touching things it shouldn't. |
| **Risk Register** | Phase 1 scans the codebase and produces a prioritised risk register (🔴 Critical / 🟡 High / 🔵 Medium) before implementation starts. A 🔴 open risk blocks its increment. Catches surprises early instead of mid-migration. |
| **Templates** | Reusable starting points for requirements, analysis instructions, and the limits document. Encode what questions to ask and what to look for — so each migration builds on the last rather than starting from zero. |
| **Feedback Loop** | Every increment ends with a tagged item: `[TEMPLATE]` (improve a base template), `[PROCESS]` (improve agent behaviour), or `[GUIDE]` (fix this migration only). All `[TEMPLATE]` items are applied automatically at Phase 3. The system gets better with each migration. |
| **OBSERVE** | Any uncertainty or decision requiring developer input is flagged in the progress document and never silently resolved. Keeps the developer in control of what matters. |
| **Baseline + Exploratory** | The running app is photographed before any changes. After each high-risk increment and at completion, the same areas are re-photographed and compared. Catches visual and behavioural regressions that tests cannot. |
| **Quality Hooks** | Pre-push hooks run lint, type checks, and the full test suite before any commit reaches the repo. Hook failure is treated the same as a build failure — nothing moves forward until fixed. |

---

## Files

### Agent

| File | Purpose |
|------|---------|
| `migrator.agent.md` | Agent definition — tools, skill references, key rules, output contract |

### Skills (in execution order)

| File | Phase | Purpose |
|------|-------|---------|
| `skills/plan-migration.md` | 1 | Full Phase 1 orchestration — coverage, limits, risks, guide, progress doc, baseline |
| `skills/assess-risks.md` | 1 | Scans codebase for migration blockers, high-effort risks, and technical debt; produces the risk register |
| `skills/capture-baseline.md` | 1 | Captures screenshots, console state, and network calls of the running app before any code changes |
| `skills/execute-migration.md` | 2 + 3 | Increment workflow: Plan → Implement → Validate → Quality Check → Exploratory → Feedback |
| `skills/verify-increment.md` | 2 + 3 | After each high-risk increment and at Phase 3: compares running app against baseline, gates on ❌ broken areas. Scope can be expanded per increment if new areas are affected. |
| `skills/update-migration.md` | Any | Handles mid-migration corrections — changed requirements, new understanding, OBSERVE resolutions |

### Templates

| File | Purpose |
|------|---------|
| `templates/react-requirements-template.md` | Starting point for React migration requirements documents |
| `templates/react-analysis-template.md` | Starting point for React source analysis instructions |
| `templates/migration-limits-template.md` | Starting point for the protected-files limits document |

### Quality Hooks

| File | Purpose |
|------|---------|
| `.github/copilot/pre-push` | Entrypoint hook — detects Java/TS stack and delegates; blocks push on failure |
| `.github/copilot/hooks/java-quality.sh` | Compile → Checkstyle → SpotBugs → SonarLint (BLOCKER/CRITICAL) → tests |
| `.github/copilot/hooks/ts-quality.sh` | `tsc --noEmit` → ESLint `--max-warnings 0` → Vitest/Jest |

---

## Migration Artifacts (written to `.github/migration/`)

| File | Created in | Purpose |
|------|-----------|---------|
| `instructions/[app]-requirements.md` | Phase 1 Step 2 | What the migration must achieve — highest priority document |
| `instructions/[source]-analysis.instructions.md` | Phase 1 Step 5 | General analysis guide for this migration type |
| `instructions/[app]-[target]-design-choices.md` | Phase 1 Step 3 | Optional: design patterns from a reference app |
| `[app]-migration-limits.md` | Phase 1 Step 2.5 | Protected files/concerns — never touched without explicit YES |
| `[app]-risk-register.md` | Phase 1 Step 6 | Prioritised risks (🔴/🟡/🔵); live document updated throughout Phase 2 |
| `[app]-migration-guide.md` | Phase 1 Step 7 | The increment-by-increment implementation roadmap |
| `[app]-migration-progress.md` | Phase 1 Step 9 | Live tracker — increment status, OBSERVE items, metrics, feedback |
| `[app]-test-coverage-analysis.md` | Phase 1 Step 1 | Optional: coverage baseline and high-risk gaps |
| `[app]-exploratory-report.md` | Phase 1 + 2 | Screenshot-based regression report — baseline, per-increment, and final |
| `screenshots/baseline/` | Phase 1 Step 10 | Baseline screenshots and snapshots |
| `screenshots/inc-[N]/` | Phase 2 Step 4.5 | Per-increment screenshots for comparison |
| `screenshots/final/` | Phase 3 | Final full-run screenshots |
