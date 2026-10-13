<!-- slop-ignore F7 -->
# Test Cases: Sales UI Validation and Invoice Lifecycle

**Category:** Quality Assurance / Data Integrity

**Target Scope:** Sales creation, validation, calculations, Discount, Expense, invoice creation, deletion, and Sales Report reconciliation.

> Documented scenarios, references, and data in this repository must be sanitized for portfolio use. Do not include confidential identifiers, credentials, customer data, or production URLs.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Documentation of a recorded browser test session; no new application execution. |
| Evidence basis | Supplied Sales execution and defect reports, converted into written portfolio reconstructions. |
| Execution date | 13 October 2026, explicitly reported in the source. |
| Environment | Supplied test site, accessed through the Codex in-app browser. |
| Execution attribution | Recorded Codex browser session; this document does not assign personal testing ownership. |
| Result scope | TC-SAL-001 through TC-SAL-006: four PARTIAL and two FAIL against the source matrix's acceptance rules. Follow-up checks remain NOT RUN. |

The installed build is unknown. These results do not establish behavior on a particular deployment or provide release sign-off. See the [NDA-safe evidence standard](../../portfolio-standards.md#nda-safe-portfolio-evidence).

## Preconditions

- The recorded session used authorized, disposable QA fixtures and available Company A, Customer A, Warehouse A, and product selections. These names are generalized aliases.
- Sales A and Sales B each contained Product A, 5 KL at Rp200 per KL, for Rp1,000. Set to Invoice was initially off for Sales A and on for Sales B.
- Sales C contained Product A, 5 KL at Rp200, and Product B, 2 KL at Rp150. PPH was enabled and Set to Invoice was off.
- Sales Date and ETD were 13 October 2026. Type was DO and Transport Only was off. Selecting Type DO does not establish that a delivery-order allocation was created.
- The prices observed in the form included PPN. A zero-tax fixture was not executed.
- No customer payments, saved delivery-order allocations, Shipping records, or Tax Invoices were created. Invoice views were used to inspect the effects of Sales actions.

## Requirements

**Feature goal:** Save valid Sales records, display consistent amounts across related views, and preserve the agreed relationship between Sales and invoices.

**Key rules / constraints:** Reject invalid UI inputs; retain at least one item; reconcile child-record adjustments after reload; and prevent a repeated Set to Invoice action from creating a second active invoice for the same Sales. The source deletion expectation requires blocking an unsafe change or performing an approved reversal. Whether deletion may archive an invoiced Sales while retaining its invoice still needs confirmation from the process owner.

<!-- slop-ignore F7 -->
## Test Execution Matrix

| Test ID | Scenario | Steps | Test Type | Expected Result | Status | Evidence / Defect |
| --- | --- | --- | --- | --- | --- | --- |
| TC-SAL-001 | Create Sales with invoicing off and on | 1. Save Sales A with Set to Invoice off.<br>2. Save Sales B with Set to Invoice on.<br>3. Reopen Sales and the related invoice; compare fields and totals. | Functional / Integration | Valid inputs persist; Sales A has no invoice initially; Sales B has one related invoice at first save. Complete coverage also requires the planned zero-tax fixture and stock-ledger checks. | PARTIAL | Both records saved at Rp1,000; quantity, price, UOM, customer, company, and dates matched input. Zero-tax and ledger checks remain NOT RUN. [SAL-E01](../sales-ui-invoice-duplication-and-deletion-boundaries.md#supporting-ui-observations). |
| TC-SAL-002 | Reconcile tax display and adjusted totals | 1. Save Sales C with two products and PPH enabled.<br>2. Compare Sales detail and report amounts.<br>3. Add and edit Discount and Expense on Sales A; reload and compare totals. | Calculation / Integration | Detail and report agree at displayed precision; Discount and Expense affect the total consistently. Business tax rules and request-level integrity need separate verification. | PARTIAL | Sales C displayed gross Rp1,300, DPP Rp1,171, PPN Rp129, PPH Rp23, and total Rp1,277. Sales A adjustments reconciled after reload. Tax approval and manipulated-request checks remain NOT RUN. [SAL-E02 and SAL-E04](../sales-ui-invoice-duplication-and-deletion-boundaries.md#supporting-ui-observations). |
| TC-SAL-003 | Reject incomplete forms and invalid item inputs | 1. Omit required fields individually and restore each field.<br>2. Enter quantity 0, -1, 1,5, and abc; enter price -1 with quantity 5.<br>3. Attempt to remove the final item row. | Validation / Boundary | The UI rejects the recorded invalid inputs and prevents removal of the final row. Server validation, stock limits, and rollback require additional checks. | PARTIAL | Recorded UI messages rejected missing values, invalid quantities, and negative price; final-row deletion was disabled. Non-numeric text was cleared by the browser. Over-stock quantity, empty-item requests, database integrity, and rollback remain NOT RUN. [SAL-E03](../sales-ui-invoice-duplication-and-deletion-boundaries.md#supporting-ui-observations). |
| TC-SAL-004 | Repeat Set to Invoice using its previously available URL | 1. Save Sales A without an invoice.<br>2. Select Set to Invoice and open Invoice A1.<br>3. Reopen the same action URL in the same session.<br>4. Inspect Sales Report, both invoice details, and Invoice List. | Workflow / Integration | The repeated action returns the existing invoice or rejects the repeat, preserving one active invoice for Sales A. | FAIL | The repeat created Invoice A2. Both invoice details contained Sales A at Rp1,000; the report showed two invoice links. Sequential replay was observed; concurrency and duplicate ledger posting were not tested. [SAL-UI-01 / SAL-E05](../sales-ui-invoice-duplication-and-deletion-boundaries.md#sal-ui-01-duplicate-invoice-on-repeated-action). |
| TC-SAL-005 | Adjust child records and inspect delivery workflow entry points | 1. Add, edit, and remove Discount and Expense on Sales A.<br>2. Submit Sales DO without a DO selection or quantity.<br>3. Open Add Shipping and inspect the selected Sales. | Functional / Integration | Adjustments reconcile; incomplete Sales DO is rejected; Shipping opens with the correct Sales. Valid saves and cross-parent controls need separate coverage. | PARTIAL | Adjustments completed and returned Sales A to Rp1,000; empty Sales DO was rejected; Add Shipping preselected Sales A. Valid DO and Shipping saves, Expedition, and cross-parent mutations remain NOT RUN. One fixture was reused sequentially. [SAL-E04 and SAL-E07](../sales-ui-invoice-duplication-and-deletion-boundaries.md#supporting-ui-observations). |
| TC-SAL-006 | Delete an unpaid Sales with an active invoice | 1. Create Sales B with Set to Invoice on and inspect Invoice B.<br>2. Delete Sales B from Sales List.<br>3. Search Sales List and Sales Report.<br>4. Search Invoice List, reopen Invoice B, and follow its Sales link. | Lifecycle / Integration | Under the source acceptance rule, unsafe deletion is blocked or follows an approved reversal with consistent references and status. Archival behavior needs process-owner agreement. | FAIL | Sales B disappeared from active Sales views. Invoice B remained listed at total/remaining Rp1,000, paid Rp0, with a working Sales link and no visible deleted-state label. This FAIL is against the source rule; archival semantics remain unresolved. [SAL-UI-02 / SAL-E06](../sales-ui-invoice-duplication-and-deletion-boundaries.md#sal-ui-02-sales-removal-with-an-active-invoice). |

## Execution Notes

### Status and evidence boundaries

The six IDs and their results preserve the source mapping: TC-SAL-001, 002, 003, and 005 are PARTIAL; TC-SAL-004 and 006 are FAIL. Successful UI variants do not make a broader case PASS. These are historical results on the supplied site, not a new test run.

Both findings remain open in this documentation. Removing QA invoices during cleanup does not establish a software fix or successful defect retest. No database, direct API, manipulated request, isolated second session, or concurrent execution was recorded. A blank Stock Card column does not prove that stock postings were absent.

### Recorded validation variants

The following table reconstructs the source observations. Header fields were omitted one at a time and restored. Item tests used valid headers, a selected product, and price Rp200 unless stated otherwise.

| Condition | Recorded UI outcome |
| --- | --- |
| Initial incomplete form | Save rejected; first message `Choose a type.`; other required fields also showed messages. |
| Company omitted | `Choose a company.` |
| Customer omitted | `Choose a customer.` |
| Warehouse omitted | `Choose a warehouse.` |
| Sales Date omitted | `Sales Date is required.` |
| ETD Date omitted | `ETD Date is required.` |
| Quantity 0 | `Enter more than 0.` |
| Quantity -1 or 1,5 | `Please enter only digits.` |
| Quantity abc | Browser cleared the non-numeric text; `Enter the quantity.` appeared. Server handling of a non-numeric request was not tested. |
| Product omitted | `Choose a product.`; changing the product also cleared quantity and price, which then showed required messages. |
| Price -1 with quantity 5 | `Please enter only digits.` |
| Remove final item row | Disabled control; help text `A sales order needs at least one item`. |
| Sales DO with no DO selection or quantity | Both fields showed `This field is required.`; the Sales DO table remained empty. |

Changing the product cleared quantity and price. An initial save attempt failed because quantity was empty; saving succeeded after the fields were restored. The source does not classify this as a persistence defect.

### Calculations and report checkpoints

| Checkpoint | Source-reported result |
| --- | --- |
| Sales A / B at creation | 5 KL × Rp200 = Rp1,000, including PPN. Displayed DPP Rp901 and PPN Rp99. |
| Sales C | Rp1,000 + Rp300 = Rp1,300 gross; displayed DPP Rp1,171, PPN Rp129, PPH Rp23, total Rp1,277. |
| Sales A adjustments after each reload | Rp1,000 initially; Discount Rp100: Rp900; Discount edited to Rp80: Rp920; Expense Rp50: Rp970; Expense edited to Rp40: Rp960; Expense removed: Rp920; Discount removed: Rp1,000. |
| Report before cleanup | Sales A and C displayed combined quantity 12 KL and total Rp2,277. Sales A had two invoice links; Sales B was absent. These are fixture-specific observations. |
| Final report after cleanup and refresh | Sales A displayed 5 KL, DPP Rp901, PPN Rp99, total Rp1,000, and one original invoice. Paid Rp0; remaining Rp1,000. |

Rp1,300 / 1.11 is approximately Rp1,171.17. The displayed PPH Rp23 is consistent with approximately 2% of DPP; that rate is an inference, not a confirmed tax rule or stored-precision result. Applying the inferred rate gives approximately Rp1,276.58, displayed as Rp1,277. No rounding defect is established.

The Sales summary briefly retained a previous total after a child-record save. Reconciliation used reloaded detail views and child tables. The cause of the refresh behavior is unverified.

### Unexecuted follow-up coverage

All checks below remain **NOT RUN**. The table records coverage gaps and proposed work; it does not add execution results to the six source cases.

| Related case | Required follow-up |
| --- | --- |
| TC-SAL-001 / 002 | Prepare a zero-tax fixture; confirm business tax rules and rounding precision; reconcile stock ledgers before and after creation. |
| TC-SAL-002 | Manipulate header totals, product IDs, quantity, and category in authorized request tests; verify server recalculation and rejection rules. |
| TC-SAL-003 | Test quantity exceeding available stock, an empty-item request, database integrity, and invoice/stock rollback after rejected saves. |
| TC-SAL-004 | Verify repeated action handling after a confirmed fix; test two isolated sessions, concurrency, and duplicate stock or financial postings. |
| TC-SAL-005 | Use dedicated fixtures for valid Sales DO and Shipping saves; cover Expedition and cross-parent mutation controls. |
| TC-SAL-006 | Agree deletion versus archival semantics; cover paid Sales, used DO/Shipping, stock effects, stored state, and any intended edit path. No Edit action was observed in the menu. |

### Final QA fixture state

The recorded cleanup removed Discount and Expense, the duplicate Invoice A2, Invoice B, and uninvoiced Sales C. Sales B had already been removed from active Sales views. Sales A and its original invoice remained for review at Rp1,000. Cleanup explains the final state; it is not evidence that either finding was fixed. Customer-payment processing stayed outside scope.

Read the [QA lesson and reconstructed defect evidence](../sales-ui-invoice-duplication-and-deletion-boundaries.md) for reproduction steps, business-rule uncertainty, and the limits of UI evidence.
