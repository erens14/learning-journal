# QA Lesson Learned - Soft-Deletion Filtering in Multi-Entity Reporting Queries

## Scenario

An Expedition Management module was updated to support soft-deletion / inactivation functionality ("Delete Expedition" workflow). Under this rule, when an expedition entity or its associated delivery mapping (`expedition_shipping_use_do`) is deleted, its status is updated to inactive (`status = 0`) rather than being hard-deleted from the database.

The expected behavior was that any soft-deleted or inactive expedition entries would be automatically filtered out across all downstream reporting views, specifically within the **Franco Column** of the **Delivery Order (DO) Report** module.

---

## Observation

During retesting and data maintenance execution (#1688), soft-deleted expedition records (`expedition_shipping_use_do.status = 0`) continued to appear on the UI layer of the DO Report under the Franco column.

Further technical investigation revealed that while the deletion workflow successfully set `status = 0` in the database, the reporting engine's SQL query lacked an explicit status clause (`WHERE status > 0`) on the joined relational table. As a result, inactive records bled into active operational views.

---

## Why This Matters

### User Impact

* Logistics coordinators see inactive or deleted carrier data in active delivery reports, causing confusion during operational dispatch and shipping planning.

### System Impact

* Downstream report aggregation algorithms process obsolete relational rows, resulting in bloated result sets and unnecessary query execution overhead.

### Data Impact

* Data inconsistency between the database state (`status = 0`) and the UI presentation layer.

### Business Impact

* Displaying inactive expedition carriers in Franco report columns leads to potential misassignment of freight loads and erroneous logistics cost allocation.

---

## QA Learning

Testing a "Delete" or "Inactivate" feature must extend beyond verifying the immediate deletion action. QA must trace soft-deleted entities through every downstream read query, join condition, and reporting module across the application.

### Validation Points

* Confirm that changing an entity status to `status = 0` instantly hides it from active UI screens, dropdown selectors, and generated reports.
* Inspect reporting SQL queries to verify that all `JOIN` statements explicitly enforce active status filters (`WHERE table.status > 0`).

### Edge Cases

* Generating historical DO reports where transactions occurred *before* the expedition was inactivated.
* Querying reports with multi-entity joins where child records are active but the parent entity is marked `status = 0` (and vice versa).
* Switching entity status between active and inactive repeatedly while report filters are cached.

### Business Rules

* Inactive expeditions (`status = 0`) must never appear in operational dispatch reports or active Franco column calculations.
* Soft deletion must preserve historical data integrity without contaminating active operational workflows.

### System Behavior Expectations

* All reporting queries and data access layers must implement global soft-delete scopes or standardized WHERE filter templates.

---

## UX / System Consideration

* **Global Soft-Delete Scopes:** Implement ORM-level global scopes or data access policies that automatically append `status > 0` checks to all relational queries.
* **Regression Test Coverage:** Include reporting module verification in the definition of done (DoD) whenever a deletion or status-state change feature is added.
* **Query Audit Protocol:** Establish a code-review standard ensuring that any SQL `JOIN` involving status-driven tables includes status constraints in the `ON` or `WHERE` clause.

---

## Key Takeaway

Testing soft-deletion is incomplete until every downstream report is verified. Quality assurance must trace soft-deleted records through all relational joins to ensure that `status = 0` flags are universally respected across the entire presentation layer.
