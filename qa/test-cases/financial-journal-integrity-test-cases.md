# Test Cases: Financial Journaling & Double-Entry Integrity

* **Category:** Quality Assurance, Financial Accounting, & Precision Integration Testing  
* **Target Scope:** General Ledger, Credit Note (CN), Receivable Payment & PPh 23 Tax Withholding  

> **Disclaimer & Data Sanitization Notice**  
> Documented test scenarios, ticket references, customer details, and financial values within this repository have been sanitized and generalized for educational and portfolio purposes. Confidential company identifiers and ticket numbers have been replaced.

## Requirement Overview

* **Feature Goal:** Ensure all automated accounting journal entries (Receivables, Payments, and Credit Notes) maintain strict double-entry balance (Total Debit = Total Credit) and prevent unbalance journal entries in Trial Balance reports.
* **Integrity Constraint:** Credit Note (CN) transactions must dynamically auto-generate matching Debit entry lines; PPh 23 tax withholding must synchronize accurately across views; and multi-tranche partial payments must handle rounding adjustments to guarantee exact zero-balance settlement (Rp 0.00).

## Test Execution Matrix

| Test ID | Scenario | Execution Steps | Type / Security Focus | Expected Result | Status | Execution Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-FINCN-001** | **Balanced Journal Creation** | 1. Create and post new Receivable transaction (PPN Option = YES).<br>2. Inspect generated Journal Info entries. | Functional / Post-Deploy | System generates a balanced 3-line journal entry (Debit Grand Total, Credit DPP, Credit PPN) where Total Debit = Total Credit. | **PASS** | JournalInfo successfully produces 3 balanced ledger lines. |
| **TC-FINCN-002** | **Trial Balance Unbalance Check** | 1. Post new Receivable transaction.<br>2. Navigate to `Report Accounting > Report Trial Balance`.<br>3. Filter target date range and check "Unbalanced Journal" list. | Functional / Integration | Posted transactions do not populate the UNBALANCED JOURNAL section; all entries maintain zero variance between Debit and Credit. | **PASS** | Trial Balance report verified clean with zero unbalanced entries. |
| **TC-FINCN-003** | **PPh 23 Nominal Sync (Phase 1)** | 1. Select active Receivable record.<br>2. Process payment with Withholding PPh 23 = YES.<br>3. Compare PPh amount in Payment vs. Journal Info. | Functional / Regression | PPh 23 withholding amount in Journal Info matches the Payment calculation exactly. | **FAIL** | **[BUG FOUND]** Journal logged PPh nominal at Rp 101,027 (Rp 1,922 variance vs Payment), leaving unintended residual balance in Receivable Info. |
| **TC-FINCN-004** | **PPh 23 Nominal Sync Verification** | 1. Process Receivable transaction with Toggle PPh 23 = YES.<br>2. Verify nominal consistency across Receivable Info, Payment, and Journal Info views. | Functional / Regression | PPh 23 values match consistently across Receivable Info, Payment breakdown, and Journal Info entries. | **PASS** | Re-verification confirmed consistent PPh values across all views post-fix. |
| **TC-FINCN-005** | **Partial Payment Final Settlement** | 1. Select Receivable record with >1 previous partial payments.<br>2. Perform final settlement payment with Auto-Calc and PPh 23 = YES.<br>3. Submit payment. | Functional / Integration | System calculates final payment amount precisely down to decimal digits without rounding calculation drift. | **FAIL** | **[BUG FOUND]** Automated calculation on final settlement leaves a 2-decimal digit variance (overage/shortage) when PPh 23 is enabled. |
| **TC-FINCN-006** | **Zero-Balance Settlement Check** | 1. Execute multi-tranche partial payments on active Receivable.<br>2. Submit final settlement payment using auto-calc with PPh 23 = YES.<br>3. Inspect remaining balance (*Remain*). | Functional / Precision | Automated rounding adjustment applies on final payment, bringing total remaining balance (*Remain*) to exactly Rp 0.00. | **FAIL** | **[BUG FOUND]** Multi-tranche payments fail to zero-out remaining balance, leaving a decimal residual amount instead of exact Rp 0.00. |
