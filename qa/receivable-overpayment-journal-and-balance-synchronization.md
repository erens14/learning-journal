# QA Lesson Learned — Receivable Overpayment Journal and Balance Synchronization

**Area:** Financial Accounting and Data Integrity
**Scope:** Receivable Payment, Overpaid Balance, General Ledger, and PPh Synchronization

## At a Glance

| Item | Summary |
| --- | --- |
| Problem | An overpayment left inconsistent journal accounts, remaining balance, and withholding-tax values. |
| My contribution | Retested the reported workflow across payment, journal, and receivable views, and documented confirmed results and remaining checks. |
| Approach | Reconcile one transaction across related records using explicit accounting and balance invariants. |
| Recorded outcome | Six scenarios passed retesting; persistence-after-reload and normal-payment regression remain NOT RUN. |
| Security relevance | Data-integrity validation, evidence correlation, and scoped remediation verification. This was a QA defect investigation, not a security incident. |
| Evidence | [Execution matrix and confirmation boundaries](test-cases/receivable-overpayment-journal-and-balance-synchronization-test-cases.md). |

## Context

A receivable payment exceeded the outstanding invoice balance and created an overpaid amount. The incoming bank mutation had already been recorded, so the payment workflow needed to settle the receivable, classify the excess amount correctly, and synchronize the withholding-tax value across the related receivable views.

The source Jira report referenced a specific customer, bank receipt, date, and amount. Those details are generalized here for public portfolio use.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Defect analysis and tester-confirmed overpayment retesting |
| Evidence basis | Sanitized defect narrative and linked tester-confirmed results |
| Result scope | TC-ROP-001 through TC-ROP-006 passed retesting; TC-ROP-007 and TC-ROP-008 remain NOT RUN. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Finding and Evidence

**Expected behavior:** The bank COA should appear once for the incoming bank mutation. The overpaid allocation should debit `Titipan Uang Angkutan` and credit the corresponding `Piutang Usaha Angkutan` account. After the payment is posted, the receivable should show `Remain = 0`, and the deducted PPh value should appear consistently on the receivable record.

**Actual behavior:** The receivable landing page continued to show a remaining balance despite the posted overpaid payment. The receivable-payment journal displayed the bank COA again instead of only the expected overpaid reclassification accounts. The receivable record also failed to reflect the PPh value already deducted through the payment.

**Evidence / reproduction:** The written record compares the incoming bank entry, overpaid receivable balance, payment journal, and PPh value. The reconstruction below preserves those comparisons without publishing original screenshots, customer details, bank references, or transaction amounts. Regression coverage is documented in [Receivable overpayment journal and balance synchronization test cases](test-cases/receivable-overpayment-journal-and-balance-synchronization-test-cases.md).

**Suspected cause (optional):** The root cause was not included in the retest confirmation, so this note records the verified behavior without attributing an implementation cause.

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| OVERPAY-E01 | Reconcile the incoming bank amount with generated journal lines | The bank entry appears once | The initial note describes a duplicate bank entry; TC-ROP-002 confirms the corrected single-entry retest. |
| OVERPAY-E02 | Inspect the settled receivable balance and withheld tax | Balance is settled and the tax value is consistent across the covered views | The initial values were inconsistent; TC-ROP-005 and TC-ROP-006 confirm the scoped retest. |
| OVERPAY-E03 | Check persistence after reload and a normal-payment comparison | These additional paths retain correct values and behavior | TC-ROP-007 and TC-ROP-008 remain NOT RUN; no result is reconstructed for these checks. |

[Full execution matrix and result boundaries](test-cases/receivable-overpayment-journal-and-balance-synchronization-test-cases.md).

## Impact

- A duplicate bank entry can make the ledger disagree with the actual bank mutation.
- An incorrect remaining balance can leave a fully settled receivable appearing outstanding.
- Missing PPh synchronization can produce inconsistent tax and receivable reporting.
- Incorrect overpaid classification can distort the customer-deposit and accounts-receivable balances used for reconciliation.

## Testing and Outcome

**Evidence type:** Sanitized defect narrative and tester-confirmed retest results from the documented target regression environment. The text reconstruction does not represent a new test execution.

**Checks performed:** The tester retested the reported overpayment flow and confirmed the overpaid payment, single bank entry, required journal accounts, balanced journal, zero remaining balance, and synchronized PPh value. Additional persistence and normal-payment regression scenarios remain documented separately.

**Outcome:** Six scenarios (`TC-ROP-001` through `TC-ROP-006`) passed the tester-confirmed retest on the corrected build. Two additional scenarios (`TC-ROP-007` and `TC-ROP-008`) remain NOT RUN. This is a scoped retest result, not a complete regression pass. The results are recorded in [Receivable overpayment journal and balance synchronization test cases](test-cases/receivable-overpayment-journal-and-balance-synchronization-test-cases.md).

**Unresolved follow-up (optional):** Execute the additional persistence-after-reload and normal-payment regression cases if those results are required for the release evidence.

## Lesson Learned

Overpaid receivable testing must reconcile one payment across the bank mutation, journal lines, receivable balance, overpaid classification, and withholding-tax state. A successful payment message is insufficient when any dependent financial view remains inconsistent.
