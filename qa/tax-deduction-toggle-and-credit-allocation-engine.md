# QA Lesson Learned - Multi-Invoice Settlement, Tax Deduction Toggle, and Credit Allocation Engine

## Scenario

An Accounts Receivable (AR) payment module was enhanced to mirror sales cash-receipt workflows, allowing users to settle multiple outstanding invoices within a single payment transaction.

The expected workflow was that:

* Users can search and select multiple receivable invoices in a single payment form with real-time total and variance calculation.
* An optional Tax Withholding (e.g., PPh 23) toggle (`Yes` / `No`) automatically calculates tax obligations based on the Net Taxable Amount (DPP) and posts the corresponding debit entry to the tax expense account in the General Ledger (GL).
* Overpayments (paying an amount greater than the total invoice value) automatically generate a new customer credit voucher (Overpaid record) in addition to posting GL entries.
* Users can apply multiple existing overpayment credit vouchers to settle new receivable transactions.
* Partial payments calculate tax deductions proportionally based on the amount actually paid, rather than the total invoice balance.

The feature being tested was the end-to-end multi-line settlement logic, dynamic tax calculation engine, automated overpayment voucher creation, and General Ledger journal generation.

---

## Observation

During retesting, while the multi-invoice grid layout and basic full payment flows worked as expected, several critical accounting, UI, and backend logic failures were identified:

* **Missing GL Tax Journal Entries:** When the tax deduction toggle was set to `YES`, the generated GL journal failed to create the Debit line for the Tax Expense account, posting only the net bank receipt against total receivable credit.
* **Unrecorded Customer Overpayments:** When payment amounts exceeded the total invoice balance, the system posted the accounting journal but failed to generate a corresponding Overpaid credit voucher record in the system database.
* **UI Limitation on Credit Application:** The form restricted users to selecting only one Overpaid voucher per transaction, lacking a multi-selection grid or row-addition functionality for credit usage.
* **Tax Calculation Distortion on Partial Payments:** Partial payment settlements initially required explicit proportional recalculation to ensure tax withholding was computed strictly as a percentage of the paid DPP amount rather than the full invoice DPP.

These findings revealed that multi-line payment processing lacked comprehensive integration between UI grid arrays, dynamic tax calculation hooks, and automated credit voucher creation engines.

---

## Why This Matters

### User Impact

* Users cannot reconcile bank statements accurately because bank debit entries fail to reflect net cash received after tax withholdings.
* Excess payments made by customers vanish from operational credit tracking, forcing manual offline workarounds to trace customer balances.
* Users are unable to combine multiple small credit vouchers to settle larger invoices in a single workflow.

### System Impact

* Failure to trigger secondary database entities (Overpaid vouchers) creates orphaned accounting journals unlinked to operational master data.
* Restricting credit voucher inputs to single records breaks functional symmetry with multi-invoice selection components.

### Data Impact

* General Ledger entries become unbalanced or omit mandatory tax liability/expense accounts.
* Unallocated customer credit balances lead to inaccurate AR aging reports and distorted customer ledgers.

### Business Impact

* Inaccurate tax deduction logging exposes the organization to compliance risks and financial audit penalties.
* Poor visibility into customer overpayment credits hurts customer relations and delays invoice settlements.

---

## QA Learning

Testing complex financial settlement engines requires verifying multi-entity grid interactions, conditional tax rule triggers, and downstream GL journal integrity simultaneously.

### Validation Points

* Confirm that enabling tax withholding toggles generates a balanced, three-way GL entry: `(D) Bank/Cash`, `(D) Tax Expense`, and `(K) Accounts Receivable`.
* Verify that payments exceeding invoice totals automatically generate both a balanced GL entry and a valid, reusable Overpaid voucher record.
* Validate that partial payments scale tax withholding dynamically against the actual settled portion ($2\% \times \text{Paid DPP}$).
* Ensure multi-selection components behave consistently across all data types (invoices, payment methods, and credit vouchers).

### Edge Cases

* Submitting payments where the total value exceeds the combined invoice balance across multiple receivables.
* Partial payments executed on invoices with mixed line items (e.g., taxable goods combined with non-taxable expense reimbursements).
* Applying multiple overpayment credit vouchers whose combined total exceeds or equals the targeted invoice amount.
* Switching the tax withholding toggle back and forth during active data entry to test calculation re-indexing.

### Business Rules

* Tax withholding must always reduce the expected cash receipt while preserving total AR settlement value.
* Overpayments must issue traceable customer credit vouchers immediately upon payment posting.
* Partial payments must calculate tax deductions strictly against the portion of DPP being settled in the current transaction.

### System Behavior Expectations

* The settlement UI must update totals, tax estimates, and variances dynamically upon any row addition, deletion, or amount modification.
* Backend GL engines must validate that total debits equal total credits before committing settlement transactions.
* The application must support array inputs for both incoming invoices and outgoing credit vouchers.

---

## UX / System Consideration

Potential improvements include:

* **Backend GL Mapping Fix:** Update the accounting generator service to map tax deduction accounts dynamically whenever the withholding flag is set to active.
* **Automated Credit Creation Trigger:** Implement an automated event listener that spawns an Overpaid voucher whenever $Total\ Paid > Total\ Invoices$.
* **Credit Array Grid Component:** Expand the Overpaid credit selection UI from a single dropdown into a dynamic grid array matching the Receivable Invoice selection table.
* **Dynamic Partial Tax Formula:** Enforce formula-driven tax calculations linked to the line-item input field ($Tax = Percentage \times Paid\ DPP$).

---

## Key Takeaway

Testing financial settlement features must go beyond basic payment recording. QA must trace every transaction through the entire accounting pipeline—verifying that multi-line UI selections accurately drive dynamic tax calculations, issue downstream credit vouchers, and generate perfectly balanced GL journals.
