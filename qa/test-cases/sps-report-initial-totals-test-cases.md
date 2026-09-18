# Test Cases: SPS Report Initial Totals

**Category:** Quality Assurance  
**Target Scope:** Report SPS, Report SPS Detail, and Report SPS Payment initial totals  
**Environment:** Local  

> Documented scenarios, references, and data in this repository must be sanitized for portfolio use. Do not include confidential identifiers, credentials, customer data, or production URLs.

## Preconditions

- An authorized Back Office user can access SPS reports.
- Sanitized current-month SPS transactions, detail records, and payment records exist.
- A modern desktop browser is available.

## Requirements

**Feature goal:** Show accurate report KPI and footer totals immediately when each SPS report first opens.

**Key rules / constraints:** Default date range is current month. Report totals must match displayed rows. Payment totals must follow payment-date-filtered rows.

## Test Execution Matrix

| Test ID | Scenario | Steps | Test Type | Expected Result | Status | Evidence / Defect |
| --- | --- | --- | --- | --- | --- | --- |
| **TC-SPS-REPORT-001** | Initial totals in Report SPS | 1. Open Report SPS.<br>2. Do not click Apply Filter.<br>3. Compare KPI and footer totals with table data. | Functional | Current-month rows load. Quantity, subtotal, grand total, and remaining balance match filtered data. | **NOT RUN** | [Add proof after execution.] |
| **TC-SPS-REPORT-002** | Initial totals in Report SPS Detail | 1. Open Report SPS Detail.<br>2. Do not click Apply Filter.<br>3. Compare footer totals with detail rows. | Functional | Current-month detail rows load. Quantity and subtotal match filtered data. | **NOT RUN** | [Add proof after execution.] |
| **TC-SPS-REPORT-003** | Initial totals in Report SPS Payment | 1. Open Report SPS Payment.<br>2. Do not click Apply Filter.<br>3. Compare KPI and footer totals with payment rows. | Integration / Regression | Invoice value, paid amount, and remaining debt match payment-date-filtered rows. | **NOT RUN** | [Add proof after execution.] |
| **TC-SPS-REPORT-004** | No matching report data | 1. Select a sanitized date range with no SPS records.<br>2. Apply filter.<br>3. Review each SPS report. | Edge Case | Table is empty and all applicable totals show `0,00`. | **NOT RUN** | [Add proof after execution.] |
| **TC-SPS-REPORT-005** | Invalid date range | 1. Select an end date before start date.<br>2. Apply filter. | Validation | System blocks request and shows date-range validation feedback. | **NOT RUN** | [Add proof after execution.] |

## Execution Notes

- Record execution date, tester, browser, and test-data context.
- For failed cases, record observed behavior and sanitized defect reference.
