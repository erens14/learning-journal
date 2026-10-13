# Test Cases: SPS UI Validation and Reconciliation

**Category:** Quality Assurance

**Target Scope:** SPS creation, editing, validation, detail display, and reconciliation across list and reports

> Documented scenarios, references, and data in this repository must be sanitized for portfolio use. Do not include confidential identifiers, credentials, customer data, or production URLs.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Documentation of a recorded Codex-assisted browser session, including a controlled input retest |
| Execution date | 13 October 2026, as stated in the supplied execution report |
| Environment | User-supplied test site accessed through the Codex in-app browser |
| Evidence basis | Supplied SPS UI execution report; public evidence is a written reconstruction of its observations |
| Result scope | TC-SPS-UI-001 through 018: 18 PASS; 019: 1 BLOCKED; 020 through 025: 6 NOT RUN |

The installed build was unknown. These results establish only the observations recorded in that session; they do not establish regression success for a particular deployment. No application tests were executed while preparing this document. Original application screenshots and confidential artifacts are excluded under the [NDA-safe evidence standard](../../portfolio-standards.md#nda-safe-portfolio-evidence).

## Preconditions

- The source session used an account able to create, view, and edit disposable SPS test data. Delete SPS was unavailable for that account.
- Company A, Vendor A, and Product A are generalized entities. `QA-SPS-A` is the successful fixture and `QA-SPS-B` labels rejected create attempts; these public aliases are not original business identifiers.
- Product A selected UOM KL automatically. Initial test quantity was 10 and unit price was Rp100. The observed form applied PPN at 11%; no zero-tax control was found.
- Pending received and legacy-overpayment checks require additional fixtures and suitable permissions. Direct-request and database checks require a separately authorized test environment.

## Requirements

**Feature goal:** Save valid SPS data, reject invalid item inputs, retain valid values after canceled edits, and display consistent quantities and totals across related UI views.

**Key rules / constraints:** Product selection is required; duplicate products and non-positive quantities or prices are rejected. At least one item remains in the create form. For the observed fixture, subtotal equals quantity multiplied by unit price, PPN is 11% of subtotal, and grand total equals subtotal plus PPN. UI field restrictions and action visibility are separate from server enforcement. Payment workflows are outside this matrix's scope.

## Test Execution Matrix

| Test ID | Scenario | Steps | Test Type | Expected Result | Status | Evidence / Defect |
| --- | --- | --- | --- | --- | --- | --- |
| **TC-SPS-UI-001** | Create with 11% PPN | 1. Select valid header values and Product A.<br>2. Enter quantity 10 and price Rp100.<br>3. Save, search for the fixture, and reopen it. | Functional | One matching SPS is visible; subtotal Rp1.000, PPN Rp110, grand total Rp1.110, paid Rp0, and remaining Rp1.110. | **PASS** | Source recorded one matching document and these totals. UI visibility only; [SPS-UI-E01](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-002** | Product is required | 1. Fill valid header values.<br>2. Leave product empty; enter quantity 1 and price Rp100.<br>3. Select Save SPS. | Validation | `Choose a product.` appears and the create form remains open. | **PASS** | Source recorded the validation message and form retention; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-003** | Duplicate product is rejected | 1. Add two Product A rows.<br>2. Set quantity 1 and price Rp100 on each.<br>3. Attempt to save. | Validation | `This product is already on another line.` appears and saving is rejected. | **PASS** | Source recorded duplicate rejection; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-004** | Create rejects zero quantity | 1. Select Product A and price Rp100.<br>2. Enter quantity 0.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears. | **PASS** | Source recorded the message for quantity 0; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-005** | Create rejects negative quantity | 1. Select Product A and price Rp100.<br>2. Enter quantity -1.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears. | **PASS** | Source recorded the message for quantity -1; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-006** | Create rejects zero price | 1. Select Product A and quantity 1.<br>2. Enter price 0.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears. | **PASS** | Source recorded the message for price 0; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-007** | Create rejects negative price | 1. Select Product A and quantity 1.<br>2. Enter price -1.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears. | **PASS** | Source recorded the message for price -1; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-008** | Last item cannot be removed through the UI | 1. Open a create form containing one item row.<br>2. Inspect its removal control and help text. | Boundary / UI | Remove this item is disabled; help states `An SPS needs at least one item`. | **PASS** | Source recorded the disabled control and help text. No empty-item request was sent; [SPS-UI-E03](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-009** | Rejected creates are absent from the list search | 1. Complete the rejected create variants.<br>2. Search for the rejected-attempt fixture. | Regression / UI | No matching document is displayed. | **PASS** | Source recorded `No records match these filters.` This does not prove the absence of database rows or orphan details; [SPS-UI-E03](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-010** | Controlled edit retains the intended price | 1. Target the quantity and price fields explicitly.<br>2. Enter quantity 12 and price Rp110; press Tab.<br>3. Save Changes and reopen detail. | Functional / Retest | Quantity 12, price Rp110,00, subtotal Rp1.320,00, PPN Rp145,20, and grand total Rp1.465,20 are displayed. | **PASS** | Controlled retest recorded these values. Initial price discrepancy is preserved separately in Execution Notes; [SPS-UI-E05](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-011** | Edit rejects zero quantity | 1. Open the valid fixture in Edit.<br>2. Enter quantity 0.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears and saving is rejected. | **PASS** | Source recorded quantity 0 rejection; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-012** | Edit rejects negative quantity | 1. Open the valid fixture in Edit.<br>2. Enter quantity -1.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears and saving is rejected. | **PASS** | Source recorded quantity -1 rejection; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-013** | Edit rejects zero price | 1. Keep quantity 12.<br>2. Enter price 0.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears and saving is rejected. | **PASS** | Source recorded price 0 rejection; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-014** | Edit rejects negative price | 1. Keep quantity 12.<br>2. Enter price -1.<br>3. Attempt to save. | Boundary / Validation | `Enter more than 0.` appears and saving is rejected. | **PASS** | Source recorded price -1 rejection; [SPS-UI-E02](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-015** | Cancel discards invalid edits | 1. Cancel an invalid edit.<br>2. Select Discard changes.<br>3. Reopen detail. | Regression | Saved values remain quantity 12, received 0, left 12, and price Rp110. | **PASS** | Source recorded unchanged valid values after cancellation; [SPS-UI-E06](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-016** | Reconcile the final fixture across views | 1. Use the final fixture after simulated payments were removed.<br>2. Compare list, detail, SPS Summary, and SPS Detail Report. | Integration / UI | One document and one item agree: quantity 12 KL, price Rp110, subtotal Rp1.320, PPN Rp145,20, total and remaining Rp1.465,20, paid Rp0. | **PASS** | Source recorded agreement across all four views. Payment processing itself is outside scope; [SPS-UI-E06](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-017** | Inspect readonly fields and edit restrictions | 1. Open SPS Edit.<br>2. Inspect SPS number, Company, and Vendor readonly attributes.<br>3. Inspect the fixed product-row instruction and editable-field restrictions. | UI / Business Rules | Header fields are readonly. The UI describes fixed product rows and permits UOM, item reference, quantity, and price edits. | **PASS** | Source recorded these UI restrictions, including observation after a QA payment existed. No direct-request enforcement was tested; [SPS-UI-E07](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-018** | Open details in observed payment states | 1. Open unpaid, partly paid, and fully paid SPS details.<br>2. Inspect price formatting and fully paid remaining balance. | Functional / Display | All three detail views open; prices use two decimals and fully paid remaining is Rp0. | **PASS** | Source recorded these display observations. No claim about colors, badges, legacy overpayment, or payment correctness; [SPS-UI-E09](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-019** | Delete SPS through the available account | 1. Inspect the fixture's Actions menu.<br>2. Look for Delete SPS before attempting cleanup. | Lifecycle / Cleanup | An account with suitable permission can initiate deletion of an eligible disposable fixture; lifecycle protection must be checked separately. | **BLOCKED** | Delete was unavailable for the tested account, including on unpaid SPS. No SPS deletion occurred; [SPS-UI-E08](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-020** | Verify the original zero-tax fixture | 1. Obtain a supported zero-tax fixture or configuration.<br>2. Create quantity 10 at Rp100.<br>3. Edit to quantity 12 at Rp110 and compare views. | Functional / Regression | With zero tax, initial total is Rp1.000 and edited total is Rp1.320; saved values and reports agree. | **NOT RUN** | No zero-tax control was found in the observed form. Original create/edit variants remain incomplete; [SPS-UI-E10](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-021** | Reject an empty-item request without orphan data | 1. In an authorized test environment, submit an SPS request without items.<br>2. Inspect the response and persisted header/detail state. | Validation / Data Integrity | Request is rejected; no invalid SPS header or orphan item rows are persisted. | **NOT RUN** | Neither the request nor database verification was performed. Disabled UI removal is insufficient evidence; [SPS-UI-E10](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-022** | Enforce locked fields at the server | 1. Prepare an authorized direct-request test.<br>2. Attempt changes to locked header fields or fixed product rows.<br>3. Compare the response and persisted state. | Security / Business Rules | Prohibited changes are rejected or ignored according to the approved contract; locked values remain unchanged. | **NOT RUN** | Readonly attributes do not establish server enforcement; [SPS-UI-E10](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-023** | Prevent quantity below received | 1. Prepare a disposable fixture with confirmed received quantity.<br>2. Attempt to reduce ordered quantity below received.<br>3. Inspect the response and saved quantities. | Boundary / Data Integrity | Invalid reduction is rejected and valid quantities remain unchanged. | **NOT RUN** | No delivery or goods-receipt fixture was created; [SPS-UI-E10](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-024** | Verify received-record and GET deletion protection | 1. Prepare a received fixture and confirm the approved deletion contract.<br>2. Attempt prohibited deletion through an authorized test request.<br>3. Verify a GET request cannot delete data.<br>4. Inspect persisted state. | Security / Lifecycle | Received-record protection is enforced and GET requests do not mutate or delete the SPS. | **NOT RUN** | Received-state protection, direct deletion requests, and GET deletion were not tested; [SPS-UI-E10](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| **TC-SPS-UI-025** | Verify legacy-overpayment handling | 1. Identify a sanitized fixture with paid amount above grand total.<br>2. Confirm the approved remaining-balance display rule.<br>3. Inspect detail, reports, and dashboard. | Edge / Integration | Views open without calculation errors; displayed balances follow the approved legacy rule and reconcile with fixture data. | **NOT RUN** | A legacy-overpaid fixture was not available or identified. Detail, report, and dashboard handling remain unverified; [SPS-UI-E10](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |

## Execution Notes

### Evidence and status boundaries

The 18 PASS results are narrow UI observations reconstructed from the supplied report. BLOCKED records an unavailable execution path; it is not a confirmed defect. NOT RUN records proposed follow-up coverage. No database inspection, direct API testing, request manipulation, or concurrency testing was performed in the source session.

The first 16 rows retain the source report's successful-check order. Rows 017 and 018 extract additional observations from its original-case mapping. These do not change the status of any existing design matrix.

### Original-case mapping

Original IDs are retained only as source-report references. They do not refer to the separate SPS Detail or Report Initial Totals matrices already in this repository.

| Original test ID | Recorded status | Related UI checks | Remaining evidence gap |
| --- | --- | --- | --- |
| TC-SPS-001 | **PARTIAL** | TC-SPS-UI-001 | Zero-tax creation was not verified; UI-020 remains NOT RUN. |
| TC-SPS-002 | **PARTIAL** | TC-SPS-UI-002 through 009; 011 through 014 | Empty-item request and absence of orphan database details were not verified; UI-021 remains NOT RUN. |
| TC-SPS-003 | **PARTIAL** | TC-SPS-UI-010, 015, 016 | Zero-tax edit was not verified. Initial price discrepancy remains unconfirmed; UI-020 remains NOT RUN. |
| TC-SPS-004 | **PARTIAL** | TC-SPS-UI-017 | Server enforcement and quantity below received were not verified; UI-022 and 023 remain NOT RUN. |
| TC-SPS-005 | **BLOCKED** | TC-SPS-UI-019 | Delete was unavailable. Paid-specific protection was not established; received and GET deletion remain untested under UI-024. |
| TC-SPS-006 | **PARTIAL** | TC-SPS-UI-018 | Legacy-overpaid detail, reports, and dashboard were not verified; UI-025 remains NOT RUN. |

**Original-case total:** five PARTIAL and one BLOCKED. A passing subset does not complete an original case.

### Price observation and controlled retest

| Phase | Recorded input method | Recorded UI outcome | Interpretation |
| --- | --- | --- | --- |
| Initial observation | Input targeted by accessibility index; before Save, price Rp110 and total Rp1.465,20 were displayed. | Reopened detail displayed price Rp1.100 and total Rp14.652. | Discrepancy observed, but root cause and reproducibility were not established; [SPS-UI-E04](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |
| Controlled retest | Target the price field explicitly, enter Rp110, press Tab, save, and reopen. | Price Rp110,00 and total Rp1.465,20; list and both reports matched. | UI-010 passed for this method. This was a fixture correction and retest, not evidence of an application fix; [SPS-UI-E05](../sps-ui-validation-and-evidence-boundaries.md#finding-and-evidence). |

### Calculations and final fixture

- Initial subtotal: `10 × Rp100 = Rp1.000`; PPN: `11% × Rp1.000 = Rp110`; grand total: `Rp1.000 + Rp110 = Rp1.110`.
- Controlled edit subtotal: `12 × Rp110 = Rp1.320`; PPN: `11% × Rp1.320 = Rp145,20`; grand total: `Rp1.320 + Rp145,20 = Rp1.465,20`.
- Initial discrepancy: `12 × Rp1.100 = Rp13.200`; PPN: `Rp1.452`; total: `Rp14.652`. This arithmetic explains the displayed totals, not the cause of the price change.
- Final fixture remained active because Delete SPS was unavailable. Received was 0 and left was 12. Simulated payments had been removed; paid was Rp0 and remaining was Rp1.465,20. Payment processing and account cleanup are not evaluated here.

Before broader regression claims, identify the installed build, align the tax fixture, obtain appropriate deletion access, prepare received/overpaid fixtures, and complete the pending request and database checks. Concurrency needs separate test design and execution.

The supporting [lesson learned](../sps-ui-validation-and-evidence-boundaries.md) explains the evidence boundaries. Neither public document includes the confidential source report or its captures.
