# QA Lesson Learned - Export Failures and Filter Isolation Faults in Reporting Modules

## Scenario

An Accounts Receivable reporting module allowed users to filter financial summaries and detailed transaction records using parameters such as date ranges, customer groups, individual customer accounts, and vehicle identifiers.

The expected workflow was that:

* Applying individual or combined filters should strictly restrict the dataset to match only the selected parameters.
* Selecting a parent-level filter (e.g., Customer Group) independently should correctly query and retrieve all associated child records.
* Exporting the filtered report to an Excel spreadsheet should execute successfully and produce a downloadable file matching the UI dataset.

The feature being tested was the query builder logic for single/multi-parameter filtering and the backend document export generator.

---

## Observation

During retesting, the reporting and export features revealed several critical query construction and file generation failures:

* The Excel export function on the primary receivable report consistently failed to generate the output file, returning an execution status of "Failed".
* Filtering by a parent category independently (e.g., selecting a Customer Group without specifying an individual Customer) failed to display the correct data, even though combining both filters worked as expected.
* Field-specific filters on detailed reports (e.g., Vehicle License Plate filter) failed to restrict the query results, continuing to display records belonging to unselected vehicle identifiers alongside the filtered target.

These findings suggested that the reporting engine suffered from broken backend query parameter handling and export execution errors.

---

## Why This Matters

### User Impact

* Users are unable to download Excel reports for offline accounting, financial audits, or record-keeping.
* Users receive misleading or over-inclusive report data when applying isolated filters, leading to confusion during reconciliation.

### System Impact

* Faulty SQL `WHERE` clause construction or parameter binding causes filter dependencies and broad data leakage across parameter boundaries.
* Unhandled backend exceptions during file generation break the export pipeline, resulting in job execution failures.

### Data Impact

* Reports present incorrect, incomplete, or improperly scoped financial data.
* Unfiltered or loosely matched records contaminate specialized detail reports.

### Business Impact

* Unreliable accounts receivable reporting impairs financial tracking, credit management, and executive decision-making.
* Teams are forced to spend extra time manually auditing generated reports to remove unrelated data.

---

## QA Learning

Testing reporting engines and export tools must extend beyond testing combined happy-path scenarios and require rigorous evaluation of parameter isolation and backend file generation.

### Validation Points

* Verify that every filter field functions correctly both independently as a standalone query and in combination with other filters.
* Confirm that the dataset displayed on the user interface matches the exported Excel file row-for-row.
* Validate that entity-specific filters (such as ID numbers or plate numbers) enforce exact-match constraints and do not leak unrelated data.
* Ensure export background jobs complete execution and return valid files across various dataset sizes.

### Edge Cases

* Applying a parent filter (e.g., Category/Group) without populating child filter fields (e.g., Sub-category/Individual Account).
* Executing export operations on large, complex filtered datasets versus zero-result datasets.
* Filtering by alphanumeric strings containing spaces, hyphens, or special characters.
* Testing filter resetting and parameter switching during active user sessions.

### Business Rules

* Independent filters must trigger complete dataset queries for that category without requiring secondary filter inputs.
* Detailed reports must strictly exclude records that do not match the exact filter criteria specified by the user.
* Export outputs must faithfully reflect the active UI filter state without dropping or adding records.

### System Behavior Expectations

* The query builder logic must dynamically construct valid database queries regardless of which optional filter fields are populated.
* The file export engine must handle memory allocation and file formatting gracefully without throwing runtime failures.
* Exact-match filters must apply strict equality constraints in the backend database queries.

---

## UX / System Consideration

Potential improvements include:

* Refactoring backend query builders to use dynamic conditional clauses that do not depend on fixed parameter pairings.
* Implementing exact-match filtering logic for entity identifiers (e.g., vehicle numbers or account IDs) to prevent partial string leaks.
* Providing meaningful error messages or status diagnostics when a background export job encounters a failure.
* Ensuring consistent parameter state management between primary summary reports and secondary detail reports.

---

## Key Takeaway

Testing reporting modules should not stop at verifying that combined filters work during ideal test runs.

QA must systematically test each filter parameter in isolation, verify strict query boundary enforcement for exact-match fields, and confirm that export pipelines generate accurate spreadsheets without backend failures.
