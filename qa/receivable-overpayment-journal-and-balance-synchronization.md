# QA Lesson Learned — Receivable Overpayment Journal and Balance Synchronization

**Area:** Financial Accounting and Data Integrity
**Scope:** Receivable Payment, Overpaid Balance, General Ledger, and PPh Synchronization

## Context

A receivable payment exceeded the outstanding invoice balance and created an overpaid amount. The incoming bank mutation had already been recorded, so the payment workflow needed to settle the receivable, classify the excess amount correctly, and synchronize the withholding-tax value across the related receivable views.

The source Jira report referenced a specific customer, bank receipt, date, and amount. Those details are generalized here for public portfolio use.

## Finding and Evidence

**Expected behavior:** The bank COA should appear once for the incoming bank mutation. The overpaid allocation should debit `Titipan Uang Angkutan` and credit the corresponding `Piutang Usaha Angkutan` account. After the payment is posted, the receivable should show `Remain = 0`, and the deducted PPh value should appear consistently on the receivable record.

**Actual behavior:** The receivable landing page continued to show a remaining balance despite the posted overpaid payment. The receivable-payment journal displayed the bank COA again instead of only the expected overpaid reclassification accounts. The receivable record also failed to reflect the PPh value already deducted through the payment.

**Evidence / reproduction:** The Jira card included screenshots of the incoming bank mutation, the overpaid receivable listing, the receivable-payment journal, and the unchanged PPh value. The customer identity, bank-receipt number, transaction date, and amount are omitted from this public note. Regression coverage is documented in [Receivable overpayment journal and balance synchronization test cases](test-cases/receivable-overpayment-journal-and-balance-synchronization-test-cases.md).

**Suspected cause (optional):** The root cause was not included in the retest confirmation, so this note records the verified behavior without attributing an implementation cause.

## Impact

- A duplicate bank entry can make the ledger disagree with the actual bank mutation.
- An incorrect remaining balance can leave a fully settled receivable appearing outstanding.
- Missing PPh synchronization can produce inconsistent tax and receivable reporting.
- Incorrect overpaid classification can distort the customer-deposit and accounts-receivable balances used for reconciliation.

## Testing and Outcome

**Checks performed:** The tester retested the reported overpayment flow and confirmed the overpaid payment, single bank entry, required journal accounts, balanced journal, zero remaining balance, and synchronized PPh value. Additional persistence and normal-payment regression scenarios remain documented separately.

**Outcome:** PASS. The tester confirmed that all Jira-reported problems passed retesting on the corrected build. The results are recorded in [Receivable overpayment journal and balance synchronization test cases](test-cases/receivable-overpayment-journal-and-balance-synchronization-test-cases.md).

**Unresolved follow-up (optional):** Execute the additional persistence-after-reload and normal-payment regression cases if those results are required for the release evidence.

## Lesson Learned

Overpaid receivable testing must reconcile one payment across the bank mutation, journal lines, receivable balance, overpaid classification, and withholding-tax state. A successful payment message is insufficient when any dependent financial view remains inconsistent.
