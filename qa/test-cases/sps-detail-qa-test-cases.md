# Test Cases: SPS Detail Payment Display

**Category:** Quality Assurance  
**Target Scope:** Back Office → SPS → Detail; unit-price and remaining-payment display  
**Environment:** Local

> Documented scenarios, references, and data in this repository must be sanitized for portfolio use. Do not include confidential identifiers, credentials, customer data, or production URLs.

## Preconditions

- A user with permission to view SPS Detail is signed in to the local test environment.
- Sanitized SPS records exist with product prices, grand totals, and payment states covering unpaid, fully paid, and overpaid cases.

## Requirements

**Feature goal:** Display SPS unit prices with two Indonesian currency decimals and show the remaining payment clearly on the detail page.

**Key rules / constraints:** Remaining payment equals grand total minus total paid; positive balances use red text, zero balances use green text, and negative legacy balances display as `Rp 0,00`. No payment data is changed by viewing the page.

## Test Execution Matrix

| Test ID | Scenario | Steps | Test Type | Expected Result | Status | Evidence / Defect |
| --- | --- | --- | --- | --- | --- | --- |
| **TC-SPS-DETAIL-001** | Unit price uses exactly two decimals | 1. Open an SPS Detail record containing a unit price with four stored decimals.<br>2. Inspect the Product Information price column. | Functional | Price displays in Indonesian format with exactly two decimals, for example `Rp 1.000,00`; no third decimal digit is shown. | **NOT RUN** | [Add proof after execution.] |
| **TC-SPS-DETAIL-002** | Unpaid balance is calculated and highlighted | 1. Open an SPS Detail record where grand total is `Rp 1.000,00` and total paid is `Rp 300,00`.<br>2. Inspect the SISA PEMBAYARAN row and payment action. | Functional | Remaining displays `Rp 700,00` with red text, and Tambah Pembayaran is available. | **NOT RUN** | [Add proof after execution.] |
| **TC-SPS-DETAIL-003** | Fully paid SPS shows no outstanding debt | 1. Open an SPS Detail record where grand total equals total paid.<br>2. Inspect SISA PEMBAYARAN and payment status. | Regression | Remaining displays `Rp 0,00` in green, and the LUNAS badge is shown instead of the payment action. | **NOT RUN** | [Add proof after execution.] |
| **TC-SPS-DETAIL-004** | Legacy overpayment is handled safely | 1. Open a sanitized SPS record where total paid exceeds grand total.<br>2. Inspect the remaining value and status. | Edge / Integration | Remaining does not display a negative amount; it displays `Rp 0,00` in green and the record is treated as LUNAS. | **NOT RUN** | [Add evidence or defect reference after execution.] |

## Execution Notes

- Record the execution date, tester, and result context when the matrix is run.
- For failed cases, include the observed behavior and a sanitized defect or ticket reference.
