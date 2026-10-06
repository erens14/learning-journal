# QA Lesson Learned - Verifying Business Rules and Data Locking

## Scenario

A business application allowed users to edit transaction data after critical business events had already occurred.

The feature being tested was the edit functionality of transaction records after they had progressed through various stages of the business workflow.

The expected behavior was that certain fields should become read-only or locked once predefined business conditions were met, such as payment completion, delivery processing, approval, or expiration of the allowed modification period.

---

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Edit-control checking across business states |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Reported findings only. This reconstruction adds no new execution result, confirmed root cause, or successful retest. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

During testing, several transaction fields remained editable even after critical business events had occurred.

Examples included:

* Customer information remained editable after payment was recorded.
* Customer information could still be modified after the allowed editing period had expired.
* Products could be changed to different product categories.
* Quantities remained editable after delivery processing had begun.
* Product prices could still be modified after payment had been completed.

Technically, the edit functionality worked as designed.

However, the issue was not whether editing was possible, but whether editing should still be permitted according to the application's business rules.

---

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| STATELOCK-E01 | Attempt customer or price edits after payment | Fields governed by the payment lock remain read-only | Customer and price fields remained editable. |
| STATELOCK-E02 | Attempt quantity changes after delivery processing starts | The delivery dependency prevents prohibited changes | Quantity remained editable. |
| STATELOCK-E03 | Attempt editing after the permitted time window | The time-based rule prevents further changes | Customer data could still be modified. |

## Why This Matters

### User Impact

* Users may unintentionally modify finalized transactions.
* Incorrect changes can create confusion during daily operations.

### System Impact

* Critical business processes may become inconsistent if data remains editable beyond the intended workflow.
* Downstream modules may process outdated or invalid information.

### Data Impact

* Historical transaction data may lose accuracy.
* Relationships between operational and financial records may become inconsistent.

### Business Impact

* Financial discrepancies may occur.
* Audit trails become less reliable.
* Business reports may no longer accurately reflect completed transactions.
* Operational processes may require additional manual reconciliation.

---

## QA Learning

When testing edit functionality, verification should extend beyond confirming whether a field can be modified.

### Validation Points

* Verify which fields should become read-only after specific business events.
* Confirm that data locking is enforced consistently.
* Validate edit permissions based on transaction status.
* Verify that dependent transactions prevent unauthorized modifications.

### Edge Cases

* Transactions with completed payments.
* Transactions with generated invoices.
* Transactions with completed delivery processes.
* Approved transactions.
* Transactions exceeding the allowed modification period.

### Business Rules

* Critical transaction data should become locked after predefined business events.
* Editing permissions should follow documented business policies.
* Related transactions should preserve data integrity throughout the business process.

### System Behavior Expectations

* Fields should automatically become read-only when locking conditions are met.
* Business rule enforcement should remain consistent across all transaction workflows.
* Users should receive appropriate feedback when attempting to edit locked data.

---

## UX / System Consideration

Potential improvements include:

* Clearly indicating when a transaction has entered a locked state.
* Displaying informative messages explaining why editing is no longer permitted.
* Applying centralized business rule validation to ensure consistent data locking across all modules.
* Providing audit logs for authorized changes to protected data.

---

## Key Takeaway

Testing edit functionality should focus not only on whether changes are technically possible, but also on whether they are permitted according to the business process.

Effective QA requires validating that data becomes appropriately protected as transactions progress through their lifecycle, ensuring business rules, data integrity, and system consistency are maintained.
