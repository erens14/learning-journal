# QA Lesson Learned — Validation Consistency Between Create and Edit

**Area:** Business Rules and Regression Testing

**Scope:** Create, edit, and record-lifecycle validation

## Context

A feature used two related date fields. The Create workflow accepted identical values, but the Edit workflow rejected the same record because the dates matched.

## Finding and Evidence

**Expected behavior:** The same business rule should produce a consistent result across Create and Edit unless an approved requirement defines different behavior.

**Actual behavior:** Create accepted the values, while Edit rejected the same values. The validation message stated that the dates could not match.

**Evidence / reproduction:**

1. Create a record with both fictional date fields set to `2026-01-15`.
2. Confirm that the record saves successfully.
3. Open the same record in Edit.
4. Submit the unchanged values.
5. Compare the Create and Edit results and validation messages.

> **Portfolio evidence notice:** This is a sanitized reconstruction. Field names, dates, record identifiers, and system details are fictional. No original internal-system screenshot is published.

| Evidence ID | Operation | Sanitized input | Expected consistency | Observed finding |
| --- | --- | --- | --- | --- |
| VAL-E01 | Create | `Start Date = 2026-01-15`, `End Date = 2026-01-15` | Result follows approved date rule | Record was accepted. |
| VAL-E02 | Edit unchanged record | Same fictional values | Result matches Create behavior | Record was rejected with a date-equality validation message. |

**Suspected cause (optional):** Create and Edit may use different validation definitions. The implementation cause and intended business rule were not confirmed in the public evidence.

## Impact

Users can create records that later become impossible to maintain. Inconsistent validation also creates unclear data rules, unpredictable regression behavior, and avoidable support work.

## Testing and Outcome

**Checks performed:** Create and Edit comparison, unchanged-value submission, validation-message review, and record-lifecycle analysis. Duplicate, import, and bulk-update paths should receive the same rule when available.

**Outcome:** Validation inconsistency documented. Final expected behavior requires confirmation of whether equal dates are valid or prohibited. No public fix or retest result is claimed.

**Proposed improvement (optional):** Define one approved business rule and reuse the same server-side validation across Create, Edit, import, and bulk-update paths.

**Unresolved follow-up (optional):** Confirm the intended date rule, correct the inconsistent path, and execute positive, negative, boundary, and regression tests.

## Lesson Learned

A successful Create test does not prove lifecycle consistency. QA should apply the same rule and test data across every operation that can create or modify the record.
