# QA Lesson Learned — Multi-Tier Approval and Automated Ledger Posting

**Area:** Financial Workflow, Authorization, and Data Integrity

**Scope:** Cash-disbursement approval, automatic numbering, journal posting, and role restrictions

## Context

A cash-disbursement workflow required record creation, first-level approval, restricted final approval, and automatic posting to the journal and general ledger. QA needed to verify the complete state transition rather than test each screen independently.

## Finding and Evidence

**Expected behavior:** Each authorized approval should advance the document by one valid state. Final approval should create balanced accounting entries once. Unauthorized users should not complete the restricted approval.

**Actual behavior:** All six documented execution scenarios passed. Creation, numbering, approval transitions, automatic posting, ledger balance, role restriction, and layout consistency matched the recorded expectations. A minor legacy label was observed during the creation check.

**Evidence / reproduction:** Full execution steps and results are recorded in [Cash outflow approval and GL integration test cases](test-cases/bkk-cash-feature-test-cases.md).

> **Portfolio evidence notice:** The summary below reconstructs the tested workflow with generic terms. It contains no original internal-system screenshot, company identifier, production record, or real financial value.

| Evidence ID | Test reference | Sanitized checkpoint | Recorded result |
| --- | --- | --- | --- |
| APR-E01 | `TC-BKK-001` | Create voucher and verify sequential reference | PASS; minor legacy label noted. |
| APR-E02 | `TC-BKK-002` | Complete first-level approval | PASS; state advanced correctly. |
| APR-E03 | `TC-BKK-003` | Complete restricted final approval | PASS; journal and ledger posting triggered. |
| APR-E04 | `TC-BKK-004` | Compare total debit and total credit | PASS; zero variance recorded. |
| APR-E05 | `TC-BKK-005` | Attempt final approval without required role | PASS; restricted action was blocked. |
| APR-E06 | `TC-BKK-006` | Compare related-module layout conventions | PASS; expected layout consistency recorded. |

**Suspected cause (optional):** Not applicable to the passed workflow. The minor legacy label suggests reused interface text was not fully renamed.

## Impact

Weak approval controls can permit unauthorized cash movement. Partial posting can leave an approved voucher without balanced ledger records. Duplicate references or journal entries can also damage traceability and reconciliation.

## Testing and Outcome

**Checks performed:** Creation, automatic numbering, first and final approval, automated posting, debit-credit balance, role restriction, and interface consistency.

**Outcome:** PASS for the six documented test cases. Results show functional coverage of the reported scope, not proof of every failure mode.

**Proposed improvement (optional):** Keep approval and accounting writes atomic, enforce authorization on the server, lock posted records, and retain an approval audit trail.

**Unresolved follow-up (optional):** Add failure-injection coverage for partial ledger writes, direct API authorization tests, simultaneous numbering, month-boundary numbering, duplicate submission, and posting idempotency.

## Lesson Learned

Financial approval testing must connect workflow state, authorization, numbering, journal creation, and ledger balance. Passing happy-path screens alone does not prove accounting integrity.
