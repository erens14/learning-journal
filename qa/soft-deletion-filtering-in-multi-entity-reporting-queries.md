# QA Lesson Learned - Soft-Deletion Filtering in Multi-Entity Reporting Queries

## Scenario

A shipment-management module was updated to support soft deletion. When a shipment or its associated mapping (represented by the fictional table `shipment_links`) is deleted, its status changes to inactive (`status = 0`) rather than being physically removed from the database.

The active Delivery Order (DO) Report, specifically its **Franco Column**, was expected to exclude inactive shipment relationships. Historical reports need a separate rule defining whether an association is shown as it existed at the transaction date.

---

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Soft-delete propagation and downstream-report checking |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Reported findings only. This reconstruction adds no new execution result, confirmed root cause, or successful retest. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

During retesting and data maintenance, inactive shipment relationships continued to appear in the related report. Internal ticket references are omitted; schema names in this note are generalized examples.

Further technical investigation revealed that while the deletion workflow successfully set `status = 0` in the database, the reporting engine's SQL query lacked an explicit status clause (`WHERE status > 0`) on the joined relational table. As a result, inactive records bled into active operational views.

---

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| SOFT-E01 | Mark a fictional shipment relationship inactive | Its stored status reflects inactivation | The note records that the relationship became inactive. |
| SOFT-E02 | Reload the report containing that relationship | Inactive relationships are excluded from the active report | The inactive entry remained visible in the report. |

## Impact

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

* Verify inactive records are excluded from the operational screens and reports whose business contract requires it; test historical views separately.
* Inspect status predicates and join semantics. For a `LEFT JOIN`, a child-status condition in `ON` can preserve unmatched parents; placing it in `WHERE` can remove them. Choose placement according to the report contract.

### Edge Cases

* Generating historical DO reports where transactions occurred *before* the expedition was inactivated.
* Querying reports with multi-entity joins where child records are active but the parent entity is marked `status = 0` (and vice versa).
* Switching entity status between active and inactive repeatedly while report filters are cached.

### Business Rules

* Inactive expeditions (`status = 0`) must never appear in operational dispatch reports or active Franco column calculations.
* Soft deletion must preserve historical data integrity without contaminating active operational workflows.

### System Behavior Expectations

* Operational queries should consistently enforce their active-record policy. Historical and audit queries need explicit inclusion rules and documented scope overrides.

---

## UX / System Consideration

* **Shared Query Policy:** Reuse active-record scopes where they match operational requirements, with explicit historical/audit access paths. Do not apply the same exclusion to every relational query.
* **Regression Test Coverage:** Include reporting module verification in the definition of done (DoD) whenever a deletion or status-state change feature is added.
* **Query Review:** Check status-driven joins against the report's active/historical policy, including unmatched parents and inactive child or parent records.

---

## Key Takeaway

Trace a soft-delete change into its downstream consumers. Operational exclusion, historical retention, and outer-join behavior need separate expected results.
