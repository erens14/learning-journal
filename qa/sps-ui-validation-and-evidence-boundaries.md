# QA Lesson Learned: SPS UI Validation and Evidence Boundaries

**Area:** Validation, Financial Data Consistency, and Security-Aware QA

**Scope:** SPS create/edit workflows, detail display, report reconciliation, and limits of UI evidence

## At a Glance

| Item | Summary |
| --- | --- |
| Problem | Broad SPS cases remained incomplete despite successful UI checks. An initial saved-price discrepancy required a controlled retest, and unavailable deletion prevented fixture removal. |
| My contribution | Documentation and evidence review based on a supplied execution report. The report attributes execution to a Codex-assisted browser session; this note does not claim personal manual execution or implementation ownership. |
| Approach | Separate observable UI checks from original-case completion; compare saved values across views; preserve the initial discrepancy and controlled retest separately. |
| Recorded outcome | 18 narrow UI checks passed, one deletion check was blocked, and six follow-up checks remain NOT RUN. The six original cases retain five PARTIAL and one BLOCKED. |
| Security relevance | Distinguishing UI restrictions from server enforcement, identifying missing integrity evidence, and documenting reproducibility without claiming a confirmed vulnerability. |
| Evidence | [SPS UI validation and reconciliation matrix](test-cases/sps-ui-validation-and-reconciliation-test-cases.md), supported by the written reconstructions below. |

## Context

SPS records combine item quantities, prices, tax, receipt state, and payment display. QA must verify that valid changes survive saving and appear consistently in the list, detail view, and related reports. Invalid inputs should not replace valid saved data.

The supplied report documents browser checks on a user-provided test site. Its final scope was SPS; payment testing had been stopped after the scope was narrowed. Payment-state display observations remain relevant to SPS detail, but they do not demonstrate payment-processing correctness.

The form applied 11% PPN automatically, while the original create/edit scenarios expected a zero-tax fixture. Passing the available tax variant therefore did not complete those original scenarios.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Review and portfolio reconstruction of a Codex-assisted UI execution report and controlled input retest |
| Execution date | 13 October 2026, explicitly stated in the supplied report |
| Environment | User-supplied test site accessed through the Codex in-app browser |
| Evidence basis | Recorded form, validation-message, list, detail, SPS Summary, and SPS Detail Report observations |
| Result scope | UI behavior and cross-view consistency for the recorded fixtures; no database, direct-request, concurrency, or build-specific regression proof |

The installed build was unknown. No new application tests were performed to prepare this note. The date comes from the report, not from an edit timestamp or fictional transaction date. Original captures and confidential artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence).

## Finding and Evidence

**Expected behavior:** Valid quantities and prices should persist as entered; invalid inputs should be rejected consistently across Create and Edit. Related views should agree on the same fixture. Lifecycle and authorization claims require evidence beyond disabled or missing controls.

**Actual behavior:** The recorded validation and reconciliation checks passed. The first edit displayed Rp110 before saving but Rp1.100 after reopening. A controlled retest retained Rp110 and reconciled across views. Delete SPS remained unavailable, and broader original cases were incomplete.

**Evidence / reproduction:** The following checkpoints reconstruct supplied observations using generalized entities and public fixture aliases. The amounts came from disposable QA inputs; they are not customer transaction evidence. Detailed review steps and statuses appear in the [test matrix](test-cases/sps-ui-validation-and-reconciliation-test-cases.md#test-execution-matrix).

> **NDA-safe evidence:** The table below reconstructs the source note using generalized conditions. It contains no original application screenshot or confidential artifact and does not represent a new test execution.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| SPS-UI-E01 | Create one Product A item, quantity 10 KL at Rp100, with 11% PPN. | Subtotal Rp1.000, PPN Rp110, total Rp1.110; one matching document visible. | The fixture saved and reopened with these values; paid Rp0 and remaining Rp1.110. Matrix 001. |
| SPS-UI-E02 | Submit a missing product, duplicate products, or quantity/price 0 and -1; compare applicable Create and Edit variants. | Invalid input is rejected with clear validation feedback. | Create required a product and rejected duplicates. Both workflows rejected non-positive quantity and price with `Enter more than 0.` Matrix 002–007 and 011–014. |
| SPS-UI-E03 | Inspect last-row removal and search for the rejected-attempt fixture. | The UI keeps at least one row; rejected attempts do not appear in the list. | Last-row removal was disabled with `An SPS needs at least one item`; the list search returned `No records match these filters.` No database inspection followed. Matrix 008–009. |
| SPS-UI-E04 | Initial edit used accessibility-index targeting; pre-save display showed Rp110 and total Rp1.465,20. | Reopened values match the intended input. | Detail instead displayed Rp1.100 and total Rp14.652. This remained an unconfirmed discrepancy; no reproducible cause was established. See matrix price history. |
| SPS-UI-E05 | Retest by targeting the price field explicitly, entering Rp110, pressing Tab, saving, and reopening. | Quantity 12 and price Rp110 produce subtotal Rp1.320, PPN Rp145,20, and total Rp1.465,20. | Detail retained Rp110,00; list and both reports agreed. Matrix 010. The fixture was corrected; no application fix was reported. |
| SPS-UI-E06 | Cancel invalid edits, then reconcile the final unpaid fixture across list, detail, and both SPS reports. | Saved valid values remain unchanged and all views agree. | Quantity 12 KL, received 0, left 12, price Rp110, subtotal Rp1.320, PPN Rp145,20, total/remaining Rp1.465,20, and paid Rp0 were recorded. Matrix 015–016. |
| SPS-UI-E07 | Inspect readonly header fields and fixed product-row instructions. | UI presents its intended edit restrictions. | SPS number, Company, and Vendor were readonly. The UI described fixed product rows and editable UOM, item reference, quantity, and price. No server-enforcement test followed. Matrix 017. |
| SPS-UI-E08 | Inspect the Actions menu during cleanup, including an unpaid fixture. | Suitable permission should allow eligible fixture deletion; prohibited-state guards require separate verification. | Delete was unavailable for the tested account, including on unpaid SPS. The fixture remained active; paid-specific protection was not established. Matrix 019: BLOCKED. |
| SPS-UI-E09 | Open unpaid, partly paid, and fully paid details. | Detail views open; prices use two decimals; fully paid remaining is zero. | All three views opened, prices used two decimals, and fully paid remaining was Rp0. Legacy-overpaid handling was not checked. Matrix 018. |
| SPS-UI-E10 | Review the missing tax, request, database, receipt, deletion, and overpayment evidence. | Full-case completion requires the intended fixture and direct evidence for each rule. | Zero-tax, empty-item/orphan-data, locked-field server enforcement, below-received quantity, received/GET deletion, and legacy-overpayment checks were unexecuted. Matrix 020–025: NOT RUN. |

**Evidence boundary:** PASS applies to the recorded UI steps only. Search results cannot establish absence of orphan rows, readonly attributes cannot establish request authorization, and a missing Delete control cannot establish a paid/received lifecycle guard. The reconciliation covered one fixture across views, not report-wide aggregates, default filters, exports, or concurrent changes.

**Suspected cause:** Accessibility-index input targeting or input-format handling could be investigated for the initial price discrepancy. Neither was established as the cause. The successful controlled retest alone does not prove an application defect was fixed.

## Impact

An unintended saved price could distort transaction totals and mislead users relying on reports. The observed discrepancy warrants investigation if reproducible; this report does not establish an ongoing application defect or a customer loss.

Unavailable deletion prevented complete fixture cleanup. Incorrectly treating UI restrictions as server protection would also overstate test coverage and leave integrity or authorization failures undetected. Those failures remain potential test concerns, not demonstrated vulnerabilities.

## Testing and Outcome

**Checks performed:** The source session recorded valid creation, missing/duplicate-product validation, zero/negative quantity and price checks across Create and Edit, last-row UI protection, list searching, controlled edit/reopen, canceled-edit preservation, four-view reconciliation, readonly inspection, and payment-state detail display.

**Outcome:** The [matrix](test-cases/sps-ui-validation-and-reconciliation-test-cases.md) separates 18 PASS, one BLOCKED, and six NOT RUN. Its [original-case mapping](test-cases/sps-ui-validation-and-reconciliation-test-cases.md#original-case-mapping) preserves five PARTIAL and one BLOCKED. The initial price observation remains separate from the controlled retest; no confirmed application bug, implementation fix, or particular deployed build is claimed.

The final QA fixture remained active: quantity 12 KL, received 0, left 12, unit price Rp110, and total/remaining Rp1.465,20. Simulated payments had been removed, leaving paid Rp0. This describes the final SPS state without assessing payment processing or account cleanup.

**Proposed improvement:** Record the intended field, entered value, focus change, pre-save calculation, and reopened value during price-entry investigation. Review validation across UI and server paths, and identify the deployed build before making release-specific regression claims. These are recommendations, not completed changes.

**Unresolved follow-up:** Align the zero-tax fixture, obtain suitable Delete access, and prepare received and legacy-overpaid records. Run the six pending cases in an authorized environment with response and persisted-state evidence. Verify paid-state deletion protection once deletion access exists. Design concurrency checks separately, and investigate the price discrepancy if it can be reproduced reliably.

## Lesson Learned

Split broad scenarios into observable checks without erasing their unfinished requirements. Reopen saved data and reconcile related views, while preserving an initial discrepancy separately from a successful retest. UI evidence supports UI claims; server enforcement, database integrity, and deployment correctness need their own verification.
