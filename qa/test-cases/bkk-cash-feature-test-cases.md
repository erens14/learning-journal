# Test Cases: Cash Outflow Voucher (BKK) Approval & GL Integration

* **Category:** Quality Assurance, Financial Workflow, Security (RBAC), & Integration Testing  
* **Target Scope:** Cash Outflow Voucher (*Bukti Kas Keluar / BKK*) Module — Multi-Level Approval, Auto-Numbering, & General Ledger Auto-Posting  

> **Disclaimer & Data Sanitization Notice**  
> Documented test scenarios, ticket references, and database relations within this repository have been sanitized and generalized for educational and portfolio purposes. Confidential company identifiers and ticket numbers have been replaced.

## Requirement Overview

* **Feature Goal:** Implement a dedicated Cash Outflow Voucher (*BKK*) module featuring a 4-stage approval workflow (`Input` $\rightarrow$ `Approved 1` $\rightarrow$ `Approved 2` $\rightarrow$ `Posted`), automatic journal/GL entry generation upon final approval, and UI/UX alignment with existing Bank Outflow Voucher (*BBK*) design standards.
* **Integrity Constraint:** Level 2 approval must be strictly restricted to `SuperAdmin` accounts. Final approval must automatically trigger balanced double-entry postings into the Journal and General Ledger without manual intervention.

## Test Execution Matrix

| Test ID | Scenario | Execution Steps | Type / Security Focus | Expected Result | Status | Execution Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-BKK-001** | **BKK Creation & Auto-Numbering** | 1. Login with Staff/Input role.<br>2. Fill valid cash & account fields.<br>3. Submit new BKK transaction. | Functional / Auto-Numbering | System creates BKK record successfully with accurate auto-generated sequential document numbering. | **PASS** | BKK document created successfully. *(Minor UI Note: Initial list header temporarily displayed legacy "BBK" label instead of "BKK").* |
| **TC-BKK-002** | **Approval Level 1 Execution** | 1. Select BKK transaction in `Input` status.<br>2. Login with Approver 1 role.<br>3. Execute Level 1 Approval. | Functional / Workflow | Document status transitions cleanly from `Input` to `Approved 1`. | **PASS** | Level 1 approval executes successfully. |
| **TC-BKK-003** | **Approval Level 2 & GL Auto-Post** | 1. Select BKK transaction in `Approved 1` status.<br>2. Login with SuperAdmin role.<br>3. Execute Level 2 Approval. | Functional / Integration | Document status updates to `Approved 2` and automatically triggers posting to Journal & General Ledger. | **PASS** | Level 2 approval completes and automatically posts entries to accounting ledgers. |
| **TC-BKK-004** | **General Ledger Balance Verification** | 1. Navigate to General Ledger / Journal view.<br>2. Inspect entries generated from `Approved 2` BKK transaction. | Integration / Financial | Journal and GL entries reflect exact transaction values with strict zero-variance balance (Total Debit = Total Credit). | **PASS** | Balanced double-entry postings verified in GL post-approval. |
| **TC-BKK-005** | **Approval Level 2 RBAC Protection** | 1. Select BKK transaction in `Approved 1` status.<br>2. Attempt Approval 2 action using Non-SuperAdmin account. | Security / RBAC | System blocks Approval 2 action and disables/hides approval controls for Non-SuperAdmin roles. | **PASS** | RBAC restriction successfully enforced for Approval Level 2. |
| **TC-BKK-006** | **UI/UX Consistency Check** | 1. Open BKK list and detail view pages.<br>2. Verify interface layout against BBK module design standards. | Functional / UI/UX | Form fields, tables, and action buttons strictly adhere to the UI/UX layout standards of the BBK module. | **PASS** | Layout and visual components align properly with BBK design standards. |
