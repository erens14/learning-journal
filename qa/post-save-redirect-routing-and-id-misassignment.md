# QA Lesson Learned - Post-Save Redirect Routing & Entity ID Misassignment

## Scenario

The **Bon Sangu** (Driver Allowance/Cash Advance) module allows logistics coordinators to issue financial disbursement vouchers for driver operational trips.

Upon submitting a newly created Bon Sangu form, the application architecture is designed to complete a `POST` transaction, retrieve the newly generated primary key (`id`), and automatically redirect the user to its specific detail page (`/bon_sangu/view/{id}`).

The expected behavior was that the user would always land on the exact detail view of the newly generated voucher record.

---

## Observation

Prior to the fix, saving a new Bon Sangu triggered a misdirected HTTP redirect—landing the user on the detail view of an incorrect record (e.g., displaying previously created records, cached IDs, or failing to isolate active vs. soft-deleted database sequence IDs).

Following the developer patch, QA executed targeted verification:

1. **New Entity Creation:** Created a fresh Bon Sangu voucher and verified that the post-save redirect route matched the newly generated ID and payload.
2. **Existing Entity Routing Integrity:** Navigated directly to various pre-existing Bon Sangu records (covering both active operational records and soft-deleted `status = 0` records) to ensure routing parameters resolved correctly.

Both scenarios verified **PASSED**, confirming that post-save routing and entity ID binding were fully resolved.

---

## Why This Matters

### User Impact

* Misdirection after saving can cause users to review, print, or approve the wrong financial voucher without realizing they were redirected to a different record.

### System Impact

* Faulty redirect logic often indicates dangerous backend patterns, such as using `MAX(id)` or `LAST_INSERT_ID()` queries across concurrent database sessions instead of returning explicit insert payloads.

### Data Impact

* Risk of unintended secondary data updates (e.g., editing or deleting) being performed on the wrong entity due to UI ID confusion.

### Business Impact

* Operational errors in driver allowance distribution, leading to financial discrepancies in cash advance reporting and disbursement audits.

---

## QA Learning

Testing `CREATE` and `UPDATE` operations requires explicit validation of the post-action navigation flow and HTTP response location headers.

### Validation Points

* **Post-Save URI Alignment:** Verify that the primary key returned in the API response payload matches the route parameter in the browser URL (`/view/{id}`).
* **Session & Concurrency Isolation:** Confirm that concurrent creation requests by multiple users do not cross-assign target redirect IDs.
* **State & Status Isolation:** Ensure that navigation handlers do not resolve soft-deleted records (`status = 0`) when retrieving primary key sequences.

### Edge Cases

* Submitting new creation forms when the immediately preceding record in the sequence was soft-deleted (`status = 0`).
* Rapid double-clicking on the "Save" button to test for duplicate POST execution and route race conditions.
* Direct URL parameter tampering (`/view/{deleted_id}` vs `/view/{active_id}`).

---

## UX / System Consideration

* **Explicit Payload Returns:** API controllers handling `CREATE` methods must explicitly return the newly inserted record ID inside the JSON response payload (`{ "success": true, "data": { "id": 1052 } }`) rather than relying on secondary queries to fetch the "latest" record.
* **Deterministic Frontend Redirection:** The frontend routing handler should construct redirect URLs exclusively using the ID explicitly returned in the API response payload.
* **Route Guard Validation:** Ensure the detail view route (`/view/{id}`) validates record existence and permissions before rendering data to prevent fallback misdirection.

---

## Key Takeaway

A successful database insert is only half the feature; routing the user to the correct entity post-save is critical. QA must always cross-check returned entity IDs across API response payloads, URL parameters, and UI detail views to prevent silent misdirection bugs.
