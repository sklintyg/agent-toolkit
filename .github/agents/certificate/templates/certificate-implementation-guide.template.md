---
description: Implementation guide scaffold for a new certificate model. The Certificate agent uses this as a structural reference when working through a specification. Iterations are executed one at a time with tests run after each.
---

# Certificate Implementation Guide — [TYPE]

> Generated from: `[filename]-specification.md`
> Certificate type: `[TYPE]`
> Activation date: `[date]`

---

## Prerequisites
- [ ] Complete specification file provided and validated (all IDs, texts, types, rules present)
- [ ] Access to `certificate-service` module
- [ ] Existing certificate implementations available as reference

---

## Iteration 1: Certificate Model Factory
- [ ] `CertificateModelFactory[TYPE]` created
- [ ] Activation date added to `application-dev.properties`
- [ ] `description` and `detailedDescription` mapped from spec texts
- [ ] Unit tests written and passing

---

## Iteration 2: Categories
- [ ] All categories identified from specification
- [ ] `Category[Name]` classes created with sequential `KAT_x` IDs
- [ ] `Category[Name]Test` classes written and passing

---

## Iteration 3: Element Specifications (per category)

### Category 1 — [Name]
- [ ] `Question[Name]` + `ElementSpecification` created
- [ ] `ElementConfiguration` and `ElementValue` assigned (see Value Generator Mapping Table)
- [ ] Validations added
- [ ] Rules applied (`ElementRuleFactory`, `ElementDataPredicateFactory`)
- [ ] Texts copied verbatim from spec
- [ ] `Question[Name]Test` written and passing

> Repeat for each category. Run tests after completing each full category.

---

## Iteration 4: Testability Fill Service
- [ ] `TestabilityCertificateFillService[TYPE]` created following existing fill service pattern

---

## Iteration 5: Integration Tests
- [ ] `[TYPE]ActiveIT` created and passing
- [ ] `[TYPE]CitizenIT` created and passing
- [ ] `[TYPE]InactiveIT` created and passing

---

## Final Validation
- [ ] All tests pass
- [ ] No remaining TODO comments without developer awareness
- [ ] All texts verified word-for-word against specification
- [ ] Activation date confirmed in `application-dev.properties`
