---
description: Implement a new Java certificate model from a filled certificate specification — factory, categories, element specifications, rules, validations, tests, and fill service.
input: Filled certificate specification file (type, questions, IDs, texts, types, rules, validations, activation date)
output: CertificateModelFactory[TYPE] with all ElementSpecifications, unit tests per class, integration tests, and TestabilityCertificateFillService
---

# Skill: Create Certificate Model

> **⭐ Never start without a complete specification.** All IDs, codes, and texts must come from
> the spec. If anything is missing, add a constant with a `// TODO:` comment and flag with OBSERVE.

---

## Step 0 — Validate Specification

Before writing any code, confirm the specification contains:

| Field | Required |
|-------|---------|
| PDF type | `TEMPLATE` or `GENERAL` |
| Available on 1177 | `true` / `false` |
| Certificate type | e.g., `FK7804` |
| Activation date | e.g., `2024-06-01` |
| All questions | ID, text, type, rules, validations |

If anything is missing → **OBSERVE**: list the gaps and wait for the developer to provide them
before proceeding.

Also confirm: this is a **new certificate** (not a major version addition — if V2+, use
`add-major-version.md` instead).

---

## Iteration 1 — Set Up Certificate Model Factory

1. Create `CertificateModelFactory[TYPE]` in the appropriate package
   (e.g., `se.inera.intyg.intygstjanst.certificate.service.certificate.model.factory`).
2. Follow the layered architecture: `api`, `application`, `domain`.
3. Add the activation date to `application-dev.properties`:
   ```
   certificate.[lowercase_type].activation-date=[date]
   ```
4. Map description texts exactly from the spec:
   - "Text innan val av intyg" → `description`
   - "Text efter val av intyg" → `detailedDescription`
5. Write unit tests for the factory class.
6. Run tests. Fix failures before continuing.

---

## Iteration 2 — Create All Categories

For each category in the specification:

1. Create `Category[PascalCaseName]` class.
2. Assign IDs: `KAT_1`, `KAT_2`, etc. (categories have no ID in the spec — assign sequentially).
3. Class name = `Category` + PascalCase of the Swedish name. Shorten if too long, keep it understandable.
4. Generate `Category[PascalCaseName]Test`.
5. Use existing category classes in the codebase as the reference pattern — do not invent structure.
6. Run tests after all categories are created.

---

## Iteration 3 — Fill Each Category with Element Specifications

Work through categories **one at a time**. For each category, implement all its questions before
moving to the next. After each category: run tests, fix failures, then proceed.

For each question in the category:

### 3a. Create the Question Class
- Class name = `Question` + PascalCase of the Swedish name.
- Test class = same name + `Test`.

### 3b. Create `ElementSpecification`
- Assign a unique `ElementId`.
- Sub-questions (IDs like `1.2`) must have an `ElementMapping` to the parent (`1.2 → 1`).

### 3c. Assign `ElementConfiguration` and `ElementValue`
Use the **Value Generator Mapping Table** below. Match on the question type and SK code from the spec.

| ElementConfiguration | SK Code | ElementValue | Example Class |
|---|---|---|---|
| `ElementConfigurationTextField` | SK-006 | `ElementValueText` | `QuestionHalsotillstandPsykiska` |
| `ElementConfigurationTextArea` | SK-007 | `ElementValueText` | `QuestionHalsotillstandPsykiska` |
| `ElementConfigurationCheckboxBoolean` | SK-001 | `ElementValueBoolean` | `QuestionSmittbararpenning` |
| `ElementConfigurationRadioBoolean` | SK-002 | `ElementValueBoolean` | `QuestionSmittbararpenning` |
| `ElementConfigurationDropdownCode` | SK-008 | `ElementValueCode` | `QuestionKannedomOmPatienten` |
| `ElementConfigurationRadioMultipleCode` | SK-002 | `ElementValueCode` | `QuestionPrognos` |
| `ElementConfigurationCheckboxMultipleCode` | SK-004 | `ElementValueCodeList` | `QuestionSysselsattning` |
| `ElementConfigurationCheckboxMultipleDate` | SK-004a | `ElementValueDateList` | `QuestionUtlatandeBaseratPa` |
| `ElementConfigurationDate` | SK-005 | `ElementValueDate` | `QuestionNarAktivaBehandlingenAvslutades` |
| `ElementConfigurationDateRange` | SK-005 | `ElementValueDateRange` | `QuestionPeriodVardEllerTillsyn` |
| `ElementConfigurationCheckboxDateRangeList` | SK-004a | `ElementValueDateRangeList` | `QuestionPeriod` |
| `ElementConfigurationDiagnosis` | — | `ElementValueDiagnosisList` | `QuestionDiagnos` |
| `ElementConfigurationMedicalInvestigationList` | — | `ElementValueMedicalInvestigationList` | `QuestionUtredningEllerUnderlag` |
| `ElementConfigurationInteger` | SK-009 | `ElementValueInteger` | `QuestionAntalManader` |
| `ElementConfigurationIcf` | SK-007 | `ElementValueIcf` | `QuestionAktivitetsbegransningar` |
| `ElementConfigurationMessage` | SK-A01–04 | N/A | `MessageNedsattningArbetsformagaStartDateInfo` |
| `ElementConfigurationCategory` | SK-000 | N/A | `CategoryPrognos` |
| `ElementConfigurationVisualAcuities` | — | `ElementValueVisualAcuities` | `QuestionSynkarpa` |

### 3d. Add Validations
Each `ElementValue` type requires a corresponding `ElementValidation`. Follow the pattern from
existing question classes of the same configuration type.

### 3e. Apply Rules
Use the **Rule Mapping Table** below. Map rule descriptions from the spec to the correct factory call.

| Rule Code | Description | Java Class | `ElementRuleType` |
|---|---|---|---|
| SR-001 | Mandatory question | `ElementRuleExpression` | `MANDATORY` |
| SR-002 | Mandatory category | `ElementRuleExpression` | `CATEGORY_MANDATORY` |
| SR-003 | Show question | `ElementRuleExpression` | `SHOW` |
| SR-004 | Hide question | `ElementRuleExpression` | `HIDE` |
| SR-005 | Disable component | `ElementRuleExpression` | `DISABLE` / `DISABLE_SUB_ELEMENT` |
| SR-006 | Prefill question | `ElementRuleExpression` | N/A |
| Max text limit set | Text limit | `ElementRuleLimit` | `TEXT_LIMIT` |

> **mandatory vs. mandatoryExists:** Use `mandatoryExists` for `RadioBoolean` — both `true` and
> `false` are valid answers, and plain `mandatory` only checks for `true`.

Use `ElementRuleFactory` and `ElementDataPredicateFactory` where a matching factory method exists.

### 3f. Handle Show/Hide Rules
If a question has a `SHOW` or `HIDE` rule, it usually also needs a `shouldValidate` field.
Set this up using `ElementDataPredicateFactory`.

### 3g. Copy Texts Verbatim
All texts (labels, descriptions, options) must be copied **word-for-word** from the spec.
No corrections, no paraphrasing.

### 3h. Generate Unit Test
Generate `Question[PascalCaseName]Test` using the corresponding test class from the mapping table
as the reference pattern. Run the test before moving to the next question.

---

## Iteration 4 — Implement TestabilityCertificateFillService

After all element specifications are complete:

1. Create `TestabilityCertificateFillService[TYPE]`.
2. Use existing fill services in the codebase as the reference pattern.

---

## Iteration 5 — Create Integration Tests

Generate:
- `[TYPE]ActiveIT`
- `[TYPE]CitizenIT`
- `[TYPE]InactiveIT`

Use existing integration tests of the same type as reference. Run all integration tests.

---

## Step 6 — Final Validation

1. Run the full test suite — all tests must pass.
2. Scan for any remaining `TODO` comments from missing IDs/codes. List them for the developer.
3. Confirm all texts match the spec word-for-word.
4. Verify the activation date is in `application-dev.properties`.
5. Present summary:
   ```
   ✅ Certificate [TYPE] Implementation Complete

   Classes created: [N]
   Tests created: [N]
   Integration tests: [TYPE]ActiveIT, [TYPE]CitizenIT, [TYPE]InactiveIT
   Fill service: TestabilityCertificateFillService[TYPE]

   Outstanding TODOs (developer action required):
   - [list any missing IDs/codes]
   ```

---

## Notes
- If an SK code or ID is not in the spec, add a named constant with `// TODO: confirm with developer` — never guess a value.
- Always look at existing implementations of the same `ElementConfiguration` type as the pattern reference.
- Use `final var`, `@RequiredArgsConstructor`, streams, and `@PerformanceLogging` following codebase conventions.
- Ensure immutability and separation of concerns between layers.
