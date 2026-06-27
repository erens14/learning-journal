# QA Lesson Learned - Master Data Dependency and Soft Delete Validation

## Scenario

A master data module allowed users to create and delete records successfully.

The expected workflow was that once a record was deleted:

* It should no longer be available for use in related modules.
* The same record should be able to be created again if permitted by the business rules.
* All modules referencing the master data should reflect the updated state.

The feature being tested was the lifecycle of master data records and their impact across dependent modules.

---

## Observation

During testing, the delete operation appeared successful from the user interface.

The deleted record was removed from the master data list, indicating that the deletion process had completed.

However, further validation revealed two inconsistencies:

* Creating a new record with the same name was not allowed because the system still considered the deleted record as existing.
* The deleted record continued to appear in another module that depended on the master data, allowing users to select information that should no longer be available.

These findings suggested that the deletion was not consistently reflected throughout the application.

---

## Why This Matters

### User Impact

* Users may become confused when deleted records continue to appear in other parts of the system.
* Users may be unable to recreate valid master data due to unexpected validation failures.

### System Impact

* Inconsistent synchronization between modules can reduce overall system reliability.
* Different modules may present conflicting information about the same master data.

### Data Impact

* Obsolete records may continue to be referenced by dependent modules.
* Validation rules may incorrectly treat deleted records as active.

### Business Impact

* Inconsistent master data can affect operational processes and reporting.
* Additional manual verification may be required to determine which data is actually valid.

---

## QA Learning

Master data testing should extend beyond basic Create, Edit, and Delete operations.

### Validation Points

* Verify that deleted records are removed from all dependent modules.
* Confirm that uniqueness validation behaves correctly after deletion.
* Validate that only active master data is available for selection.
* Verify synchronization between the master module and related features.

### Edge Cases

* Recreating a record using the same identifier or name.
* Soft delete versus permanent delete behavior.
* Master data referenced by multiple modules.
* Records with existing historical transactions.

### Business Rules

* Deleted records should follow the application's data retention policy.
* Dependent modules should display only valid and active master data.
* Uniqueness validation should align with the intended delete strategy.

### System Behavior Expectations

* Delete operations should be consistently reflected across the application.
* Related modules should synchronize with the latest master data status.
* Validation should correctly distinguish between active and deleted records.

---

## UX / System Consideration

Potential improvements include:

* Synchronizing dependent modules immediately after master data changes.
* Clearly distinguishing active and inactive records where applicable.
* Applying consistent validation logic for soft-deleted records.
* Providing a predictable lifecycle for master data throughout the application.

---

## Key Takeaway

Testing master data should not end after confirming that a record can be created, edited, or deleted.

QA should also verify how master data changes affect dependent modules, validation rules, and overall system consistency to ensure reliable behavior across the entire application.
