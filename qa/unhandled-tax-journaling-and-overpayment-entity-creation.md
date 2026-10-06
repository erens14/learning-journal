# QA Lesson Learned - Unhandled Withholding Tax Journaling & Missing Overpayment Entity Creation

## Scenario

The accounts receivable settlement module (**Receivable Payment**) handles payment posting, tax deductions (PPh 23), and excess payment allocations.

The financial logic dictates two critical side-effects during payment posting:

1. **Withholding Tax Deduction (PPh 23):** When the toggle `"Potong PPh = YA"` is enabled, the payment journal must debit the Withholding Tax Expense account (`PPh 23 = 2% x DPP`) and debit the net cash received into the Bank/Cash account, balancing against the total credit of Accounts Receivable.
2. **Overpayment Handling:** When a payment exceeds the total invoice tag, the system must post the balancing journal entry and automatically generate a new **Overpaid Master Record/Voucher** to track customer credit balances for future settlements.

---

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Payment-side-effect and journal checking |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Reported findings only. This reconstruction adds no new execution result, confirmed root cause, or successful retest. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

During test execution on payment settlements, two separate integration bugs were identified:

* **Issue 1 (PPh 23 Journal Omission):** In the fictional reconstruction `DEMO-INVOICE-001`, enabling withholding omitted the expected tax debit line. The bank entry did not reflect the intended net amount. This summary retains the recorded mismatch without reproducing an internal invoice number or transaction values.
* **Issue 2 (Missing Overpaid Entity):** When processing an overpayment, the GL journal recorded the excess amount, but the application failed to instantiate a new **Overpaid Record** in the master database table.

---

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| TAXPOST-E01 | Post fictional invoice DEMO-INVOICE-001 with withholding enabled | The required withholding line and net bank value are represented | The note records an omitted withholding debit and an incorrect bank value. |
| TAXPOST-E02 | Process a payment with an excess amount | An overpaid credit record accompanies the excess posting | The journal reflected the excess but no overpaid master record was created. |

DEMO-INVOICE-001 is a fictional label. This summary does not claim that a separate overpayment retest covers this earlier finding.

## Why This Matters

### User Impact

* Finance users cannot reconcile bank statement deposits against GL cash entries due to un-deducted tax figures.
* Overpayments made by customers become untrackable in customer balance ledgers due to missing Overpaid vouchers.

### System Impact

* Decoupling GL journal creation from master entity creation creates silent data drift between accounting ledgers and customer relationship modules.

### Data Impact

* Inaccurate tax expense reporting and failure to register customer credit liabilities.

### Business Impact

* Tax compliance risks during financial audits and operational friction during future invoice settlements involving customer credit notes.

---

## QA Learning

Testing payment settlement logic requires verifying both double-entry bookkeeping balances (GL) and secondary domain side-effects (Tax deduction calculations and Master record creation).

### Validation Points

* **Formula & Net-Off Verification:** Validate that PPh 23 deductions calculate strictly against the Taxable Base Amount (DPP), and that `Net Cash Received = Gross Invoice - PPh 23`.
* **Multi-Entity Triggering:** Confirm that payment events exceeding invoice values trigger both `JournalPost()` and `OverpaidMaster.Create()` service methods.
* **Accounting Imbalance Audits:** Verify that total Debit equals total Credit across all lines when tax deductions are activated.

### Edge Cases

* Payment calculations on invoices containing mixed line items (DPP + Non-Taxable Expenses).
* Partial payments combined with active PPh 23 tax deduction toggles.
* Overpayments executed concurrently with PPh 23 tax deductions.

---

## UX / System Consideration

* **Atomic Transaction Boundaries:** Wrap GL posting, tax deduction calculation, and overpaid record generation inside a unified database transaction (`BEGIN...COMMIT`) to ensure all entities are created simultaneously.
* **Explicit Journal Preview:** Provide a pre-posting UI modal showing expected Debit/Credit lines (including PPh 23 and Overpaid lines) before final submission.
* **Backend Event Listeners:** Implement domain event listeners (`PaymentReceivedEvent`) to reliably handle secondary entity creation like Overpaid voucher generation.

---

## Key Takeaway

A financial payment transaction is not complete simply because the General Ledger balances. QA must verify that tax deduction logic accurately reflects net cash entries and that operational side-effects—such as Overpaid entity creation—are committed alongside accounting journals.
