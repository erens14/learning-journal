# QA Lesson Learned — Verifying Cross-Module Data Synchronization

**Area:** Integration and Data Integrity

**Scope:** Transaction creation, dependent-module visibility, and shared-record consistency

## Context

A transaction was created successfully in its source module. The business workflow required the same record to become available in another module that depended on the transaction.

## Finding and Evidence

**Expected behavior:** A successfully stored transaction should appear in every authorized dependent module according to the approved workflow and synchronization timing.

**Actual behavior:** The transaction existed in the source module but did not appear in a related module. This separated successful data creation from successful downstream availability.

**Evidence / reproduction:**

1. Create a transaction with a unique fictional reference.
2. Confirm that the source module stores and displays the record.
3. Open the related module that should consume the record.
4. Search using the same fictional reference and applicable filters.
5. Compare record identity, status, values, and visibility across both modules.

> **Portfolio evidence notice:** This is a sanitized reconstruction using fictional module names, references, and values. It is not an original internal-system screenshot.

| Evidence ID | Reconstructed checkpoint | Expected | Observed finding |
| --- | --- | --- | --- |
| SYNC-E01 | Create `TXN-DEMO-001` in `Source Module` | Record saves and receives a reference | Record was created and visible. |
| SYNC-E02 | Search `TXN-DEMO-001` in `Dependent Module` | Same authorized record appears | Record was not available. |
| SYNC-E03 | Compare source and dependent states | Identity and workflow state remain consistent | Cross-module visibility was inconsistent. |

**Suspected cause (optional):** Synchronization timing, retrieval filters, status eligibility, or authorization rules may affect visibility. No confirmed implementation cause is published.

## Impact

Users may recreate valid transactions, delay dependent work, or rely on manual verification. Conflicting module views also reduce trust in record completeness and workflow status.

## Testing and Outcome

**Checks performed:** Source creation, persistence confirmation, dependent-module search, and cross-module visibility comparison.

**Outcome:** Cross-module visibility finding documented. Public evidence does not claim a completed fix or successful retest.

**Proposed improvement (optional):** Define record-eligibility rules, synchronization timing, and user-facing feedback when dependent availability is delayed.

**Unresolved follow-up (optional):** Retest after correction with multiple transaction types, user roles, statuses, filters, refresh behavior, and any documented synchronization delay.

## Lesson Learned

Successful creation proves only the source write. QA should follow shared data through every dependent module and verify identity, status, values, permissions, and timing.
