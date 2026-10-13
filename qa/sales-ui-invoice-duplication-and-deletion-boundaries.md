<!-- slop-ignore F1,F7 -->
# QA Lesson Learned — Sales Invoice Duplication and Deletion Boundaries

**Area:** Workflow Validation / Data Integrity

**Scope:** Sales forms, calculations, Discount and Expense, invoice creation, deletion, and Sales Report reconciliation.

## At a Glance

| Item | Summary |
| --- | --- |
| Problem | Repeating Set to Invoice created a second invoice for one Sales. Deleting another invoiced Sales removed it from active Sales views while its invoice remained visible. |
| My contribution | Review and portfolio documentation of the supplied reports. Application execution is attributed to the recorded Codex browser session; no personal testing or implementation ownership is inferred. |
| Approach | Reconstruct the recorded form checks and reconcile Sales records with linked invoices and reports. Preserve incomplete coverage and business-rule uncertainty. |
| Recorded outcome | Four PARTIAL and two FAIL source cases. Duplicate invoices were observed in the UI. The deletion result failed the source acceptance rule; intended archival behavior needs confirmation. No fix retest was recorded. |
| Security relevance | Repeated-action handling and linked-record lifecycle checks transfer to security-aware QA. Request authorization, database integrity, and concurrency were not tested. |
| Evidence | [Six-case Sales matrix](test-cases/sales-ui-validation-and-invoice-lifecycle-test-cases.md), findings SAL-UI-01 / SAL-UI-02, and written checkpoints SAL-E01 through SAL-E08 below. |

## Context

The supplied reports describe Sales testing on a test site using disposable QA records. The workflow covered creation, validation, tax display, child-record adjustments, and invoicing. Invoice views were inspected to follow the effects of Sales actions. Customer payments, Tax Invoice processing, and separate Expedition testing were outside scope.

Company A, Customer A, Warehouse A, and the product and invoice names below are generalized aliases. Amounts come from the reported synthetic fixtures. Internal screenshots, application URLs, record identifiers, and commit references are excluded.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Documentation and evidence review of an existing browser execution and its defect reports. |
| Evidence basis | Source-reported UI observations, reproduced here as labeled written reconstructions. |
| Execution date | 13 October 2026, supplied explicitly in both reports. |
| Environment | Supplied test site in the Codex in-app browser. |
| Execution attribution | Recorded Codex browser session. This journal conversion performed no application tests. |
| Result scope | Six source cases: four PARTIAL and two FAIL. Findings concern visible Sales/invoice behavior under the tested conditions. |

The installed build is unknown, so the results cannot be assigned to a particular deployment. No database inspection, direct API testing, request manipulation, or two-session test was recorded. See the [portfolio evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence).

## Finding and Evidence

**Expected behavior:** A repeated Set to Invoice action preserves one active invoice for the same Sales. Under the source deletion acceptance rule, an unsafe deletion is blocked or follows an approved reversal that preserves consistent references and status.

**Actual behavior:** Sequential repetition created a second invoice. A separate invoiced Sales disappeared from active Sales views after deletion while its invoice and linked Sales detail remained accessible. The latter behavior needs an agreed archival policy before it can be classified conclusively as incorrect product behavior.

> **NDA-safe evidence:** The following steps and tables reconstruct the supplied reports using generalized QA fixtures. They contain no original application screenshots or confidential artifacts and do not represent a new execution or independent reproduction.

### SAL-UI-01: Duplicate invoice on repeated action

**Evidence ID:** SAL-E05. **Related case:** TC-SAL-004. **Recorded result:** FAIL.

Sales A contained Product A, 5 KL at Rp200 per KL, total Rp1,000, with Set to Invoice initially off. No payment, delivery-order allocation, or Shipping record was present.

1. Save Sales A and confirm Invoice No. displays `Not set`.
2. Follow Set to Invoice from Sales detail. Inspect Invoice A1: one Sales A, total Rp1,000.
3. Reopen the same action URL obtained from that UI link, in the same session.
4. Filter Sales Report by Company A and the source execution date. Open both invoice links and inspect Invoice List.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Source-reported observation |
| --- | --- | --- | --- |
| SAL-E05 | Repeat the previously used Set to Invoice action | Return Invoice A1 or reject the repeat without creating a second active invoice. | Sales Report showed Invoice A1 and A2 for Sales A. Each invoice detail contained the same Sales, quantity, and Rp1,000 total. Invoice A2 also appeared in Invoice List. |

The finding establishes visible invoice duplication after a sequential repeat. It does not establish a concurrency failure, duplicate stock issue, cash-flow posting, or payment effect. Hiding the action link after the first operation did not prevent reuse of its known URL in this session. The implementation cause was not investigated.

Cleanup removed Invoice A2. The refreshed report then showed one original invoice, but the safety of repeating the action was not retested. The defect remains open.

### SAL-UI-02: Sales removal with an active invoice

**Evidence ID:** SAL-E06. **Related case:** TC-SAL-006. **Recorded result:** FAIL against the source acceptance rule; archival semantics unresolved.

Sales B contained Product A, 5 KL at Rp200 per KL, with Set to Invoice on. Invoice B displayed total and remaining Rp1,000, paid Rp0. No payment, Sales DO allocation, or Shipping record was present.

1. Save Sales B and confirm Invoice B contains it once.
2. Use Actions, Delete, and confirm Delete sales from Sales List.
3. Search for Sales B in Sales List and Sales Report.
4. Search Invoice List, reopen Invoice B, and follow its Sales B link.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Source-reported observation |
| --- | --- | --- | --- |
| SAL-E06 | Remove an unpaid Sales with an active invoice | Under the source rule, block an unsafe change or follow an approved reversal with consistent record status. | Deletion was accepted. Sales B disappeared from active Sales views. Invoice B remained listed with total/remaining Rp1,000 and one linked Sales B. The Sales detail opened without a visible deleted-state marker. |

The evidence establishes different visibility across active Sales and Invoice views. It does not prove a physical database orphan, a missing Sales row, or a stock or cash movement. If deletion intentionally archives historical Sales while preserving billing, the process owner must confirm that rule and the expected archive label before closing the finding as accepted behavior.

Invoice B was removed separately during cleanup. This does not demonstrate automatic reversal or a corrected Sales deletion rule.

The source proposes P0 priority for both findings. That remains a proposed triage level, with the second finding dependent on the intended deletion policy; this journal does not claim an approved severity or confirmed financial loss.

### Supporting UI observations

| Evidence ID | Reconstructed checkpoint | Expected behavior | Source-reported observation |
| --- | --- | --- | --- |
| SAL-E01 | Create Sales A with invoicing off and Sales B with it on | Save the entered fields and the selected invoice state. | Both saved at Rp1,000; Sales A initially had no invoice and Sales B had one at first save. Entered quantity, price, UOM, customer, company, and dates matched. |
| SAL-E02 | Save two products with PPH on and compare detail/report | Views agree at their displayed precision; tax-rule approval is separate. | Gross Rp1,300, DPP Rp1,171, PPN Rp129, PPH Rp23, total Rp1,277. The displayed values agreed. |
| SAL-E03 | Omit required values, enter invalid quantity/price, and remove the final item | Reject the tested inputs and keep at least one item. | Required-field and numeric messages appeared; final-row removal was disabled. The browser cleared abc in the numeric input. Server handling was untested. |
| SAL-E04 | Add, edit, and remove Discount and Expense | Reloaded detail reflects the recorded child-record changes. | Totals followed Rp1,000, Rp900, Rp920, Rp970, Rp960, Rp920, then Rp1,000. The summary sometimes retained an earlier value until reload. |
| SAL-E07 | Submit empty Sales DO and open Add Shipping | Reject incomplete DO input; open Shipping for the selected Sales. | Empty Sales DO showed required messages and no row. Add Shipping preselected Sales A. Neither valid workflow was saved. |
| SAL-E08 | Refresh the report after fixture cleanup | Remaining fixture values agree across Sales and invoice views. | Sales A remained at 5 KL, DPP Rp901, PPN Rp99, total Rp1,000, one original invoice, paid Rp0, remaining Rp1,000. |

The [matrix execution notes](test-cases/sales-ui-validation-and-invoice-lifecycle-test-cases.md#recorded-validation-variants) retain the exact messages, calculation checkpoints, and unexecuted variants.

**Evidence boundary:** Form rejection and disabled controls establish UI behavior only. Search visibility does not establish stored-row state. A `-` in the Stock Card column does not establish that all ledgers were unchanged. Other activity occurred on the site during the session, so global document counts were not used to attribute changes to these fixtures.

## Impact

The duplicate-invoice finding broke the tested one-invoice expectation and left two invoice references for the same Sales in the report. The deletion finding left an active invoice referencing a Sales that was absent from active Sales views, without a visible deleted-state marker in its detail. These observations create reconciliation questions for reviewers; duplicate financial postings, actual monetary loss, and unauthorized access were not established.

The tax and adjustment checks show why reconciliation must compare the same fixture at the same displayed precision. Reloaded agreement does not explain the earlier stale summary or confirm stored precision.

## Testing and Outcome

**Checks performed:** Browser checks covered required fields, invalid quantities, negative price, invoice options at creation, and sequential invoice repetition. Discount and Expense were added, edited, and removed on one fixture. Checks also compared deleted Sales with their linked invoices and confirmed rejection of an empty Sales DO; Shipping was opened without saving.

**Outcome:** Preserve four PARTIAL and two FAIL results. There is no recorded implementation fix or defect retest. The two findings remain open for triage and follow-up. The second retains its source FAIL while the deletion policy is clarified.

Prices included PPN. For Sales A, 5 × Rp200 = Rp1,000, displayed as DPP Rp901 plus PPN Rp99. Sales C had gross Rp1,300. Dividing by 1.11 gives approximately Rp1,171.17; displayed PPH Rp23 is consistent with approximately 2% of DPP. This is an inference from the UI, not a confirmed tax rule. The inferred calculation gives approximately Rp1,276.58, displayed as Rp1,277. No rounding failure is established.

Before cleanup, the report showed Sales A and C at combined quantity 12 KL and total Rp2,277; Sales A had two invoice links and Sales B was absent. Cleanup removed the duplicate invoice, Invoice B, uninvoiced Sales C, and Discount/Expense. The final retained Sales A and original invoice explain SAL-E08. No customer-payment processing was tested, and fixture cleanup does not count as a fix.

**Proposed improvements and follow-up:**

- Confirm the deletion/archival contract with the process owner, including whether historical Sales remain billable and how their status should appear. Then retest TC-SAL-006 against that agreed rule.
- Define repeated invoice creation behavior, then verify the implemented guard through sequential replay and isolated-session tests. Database uniqueness, authorization, and concurrency are separate verification targets; the reports do not establish their implementation state.
- Prepare zero-tax, over-stock, paid-Sales, and used-DO/Shipping fixtures. Verify request-level recalculation and validation, cross-parent controls, database integrity, rollback, and stock/financial postings.
- Confirm tax and rounding rules; compare stored precision with display precision when appropriate access is available. Investigate the stale summary separately from the reconciled totals.
- Record a known build for future retests. Preserve these historical failures separately from any later confirmed result.

## Lesson Learned

Follow an action through its related detail views, lists, and reports, including when the action is repeated or a linked record is removed. Keep observed UI behavior separate from stored-data and authorization claims, and agree the lifecycle rule before treating an ambiguous deletion outcome as accepted behavior.
