# QA Lesson Learned - Multi-Tier Approval Workflows, Test Architecture & Automated Ledger Posting

## Scenario

A new petty cash disbursement module (**Bukti Kas Keluar / BKK**) was introduced to mirror the existing bank disbursement UI (**BBK**) while introducing a distinct approval-driven financial lifecycle:
$$\text{Input} \longrightarrow \text{Approved 1} \longrightarrow \text{Approved 2 (Super Admin)} \longrightarrow \text{Posted (Journal \& GL)}$$

Key technical requirement attributes include:

* **Dynamic Document Numbering:** Auto-generation following the standard format `BKK No XXX/XX/YY` (Transaction Sequence / Roman Numeral Month / Short Year, e.g., `BKK No 007/VII/26`).
* **Automated Financial Trigger:** Transitioning to **Approved 2** automatically commits corresponding balanced entries into both **Journal Info** and the **General Ledger (GL)** without manual posting interventions.

---

## Test Architecture & Coverage Matrix

To validate both functional workflows and financial integration, QA structured the test suite into a multi-layer verification matrix:

| Test Scenario Focus | Test Case Ref | Key Validation Objective |
| :--- | :--- | :--- |
| **Sequence & Pattern** | `TC-BKK-001`, `TC-BKK-007` | Verifies auto-generation of `BKK No XXX/XX/YY` and month/year boundary transitions (`VII` $\rightarrow$ `VIII`). |
| **Workflow State Machine** | `TC-BKK-002`, `TC-BKK-003` | Validates step-by-step state progression (`Input` $\rightarrow$ `Approved 1` $\rightarrow$ `Approved 2`). |
| **Financial Integration** | `TC-BKK-003`, `TC-BKK-004` | Verifies automated 2-line/3-line balanced entries in Journal Info and General Ledger upon `Approved 2`. |
| **RBAC Security** | `TC-BKK-005` | Enforces authorization gates ensuring non-Super Admin roles cannot trigger level-2 approvals. |
| **UI & Layout Consistency** | `TC-BKK-006` | Ensures UI components align with established BBK interface standards. |

---

## Technical Observations & Risk Analysis

### 1. Atomic Transaction Integrity (Auto-Posting Risk)

Testing **TC-BKK-003** and **TC-BKK-004** revealed that updating a document's status to `Approved 2` and creating financial records in Journal Info and GL must execute within a single atomic database transaction (`BEGIN...COMMIT`). If a GL database write fails, the approval state must roll back to `Approved 1` to prevent orphaned, unposted approved vouchers.

### 2. Privilege Escalation & API Bypassing

Executing **TC-BKK-005** highlighted the importance of testing beyond UI button visibility. Even if the "Approve 2" button is hidden on the web frontend for standard users, QA must verify that sending a direct HTTP `PUT/POST` request to the backend approval endpoint using a non-Super Admin token returns a strict `403 Forbidden` status.

### 3. Date Boundary & Sequence Clashing

In **TC-BKK-007**, boundary testing around month-end transitions confirmed that sequence counters (`XXX`) must either reset or increment cleanly alongside Roman numeral month updates (`XX`). Concurrency handling must be verified so simultaneous submissions at 23:59 do not generate duplicate document numbers.

---

## Why This Matters

### User Impact

* Prevents unauthorized cash disbursements by ensuring financial vouchers cannot bypass mandatory tier-2 authorization.

### System Impact

* Non-atomic posting logic risks creating orphan records—where a BKK voucher is marked as `Approved 2`, but missing corresponding Debit/Credit rows in Journal Info or GL.

### Data Impact

* Incorrect document sequence formatting breaks document traceability and causes financial indexing errors during internal and external audits.

### Business Impact

* Direct financial risk from unrecorded petty cash outflows or inaccurate balance sheet calculations in the General Ledger.

---

## System & Engineering Recommendations

* **Backend Transaction Wrappers:** Wrap state transitions and ledger insertions inside explicit database transaction blocks to ensure zero data divergence between BKK status and General Ledger tables.
* **Backend RBAC Middleware:** Apply role checks strictly at the API controller layer rather than relying on frontend conditional rendering.
* **Immutable Posted State:** Ensure that once a BKK record reaches `Approved 2 / Posted`, all form fields become read-only to preserve financial auditability.
* **Visual Audit Trail:** Display approval timestamps, reviewer IDs, and direct hyperlink references to generated Journal IDs on the BKK detail view.

---

## Key Takeaway

Designing test architecture for workflow-driven financial modules requires testing the complete chain: UI layout, authorization boundaries, dynamic number formatting, and atomic database persistence. Verifying that approval status changes cleanly trigger corresponding accounting entries is essential for preventing silent ledger imbalances.
