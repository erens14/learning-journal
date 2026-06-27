# QA Lesson Learned - Validation Consistency Between Create and Edit

## Scenario

A feature allowed users to create a record using identical values in two related date fields.

The record was created successfully without any validation errors.

However, when editing the same record, the system rejected the update and displayed a validation message indicating that the two date fields could not contain the same value.

The feature being tested was the validation logic applied during record creation and record modification.

---

## Observation

During testing, validation behavior differed between Create and Edit operations.

The same data input produced different outcomes:

* Create operation accepted the data.
* Edit operation rejected the same data.
* Validation rules appeared to be implemented differently across workflows.

This created an inconsistency in how business rules were enforced throughout the application.

---

## Why This Matters

### User Impact

* Users may become confused when data accepted during creation cannot be modified later.
* Existing records may become difficult or impossible to maintain.

### System Impact

* Inconsistent validation behavior can lead to unpredictable system behavior.
* Different validation logic across operations increases maintenance complexity.

### Data Impact

* Records created under one set of rules may later violate another set of rules.
* Data management becomes more difficult when validation requirements are unclear.

### Business Impact

* Business rules become harder for users and support teams to understand.
* Additional support requests may occur due to unexpected validation failures.

---

## QA Learning

When testing validation rules, verification should not stop at the Create process.

Validation behavior should also be checked across related operations:

* Create
* Edit
* Duplicate
* Import (if available)
* Bulk Update (if available)

### Validation Points

* Consistency of validation rules across operations
* Error message accuracy
* Validation behavior after data modification
* Handling of previously accepted records

### Edge Cases

* Editing records created before validation changes
* Updating records without modifying validated fields
* Duplicate records using the same values
* Importing records with equivalent data

### Business Rules

* Validation rules should remain consistent unless documented business requirements specify otherwise.
* Similar user actions should follow the same business constraints.

### System Behavior Expectations

* Identical input should produce consistent validation outcomes.
* Validation messages should clearly explain the business rule being enforced.
* Users should be able to understand why an action succeeds or fails.

---

## UX / System Consideration

Potential improvements include:

* Centralizing validation logic to ensure consistency across Create and Edit operations.
* Using shared validation rules for related workflows.
* Providing clear documentation when business rules intentionally differ between operations.
* Ensuring validation messages accurately describe the enforced restriction.

---

## Key Takeaway

A successful Create test does not guarantee that the same validation logic has been implemented correctly in Edit functionality.

Validation testing should cover the entire lifecycle of a record to ensure business rules are enforced consistently across all related operations.
