# Test Cases: Overpaid Deletion Workflow & Journal Reversal Integrity

* **Category:** Quality Assurance, Security (RBAC), Financial Accounting, & Data Integrity  
* **Target Scope:** Overpaid Master & Child Payment Module — UI Deletion, Data Visibility Cascading, Direct Link Security, & Journal Reversal  

> **Disclaimer & Data Sanitization Notice**  
> Documented test scenarios, ticket references, and database relations within this repository have been sanitized and generalized for educational and portfolio purposes. Confidential company identifiers and ticket numbers have been replaced.

## Requirement Overview

* **Feature Goal:** Enable `SuperAdmin` users to change Overpaid master records to deleted status directly through the user interface, eliminating the need for manual database modifications.
* **Integrity Constraint:** Deleting a parent Overpaid record must automatically cascade data visibility hiding to child Overpaid Payments, block direct URL/API access, safely void/reverse linked journal entries without leaving orphaned ledger records, and restrict deletion actions strictly to `SuperAdmin` roles.

## Test Execution Matrix

| Test ID | Scenario | Execution Steps | Type / Security Focus | Expected Result | Status | Execution Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-OVP-001** | **Parent Data Visibility (Post-Delete)** | 1. Login as SuperAdmin.<br>2. Execute deletion action on active Overpaid Master record.<br>3. Search record in main table and active filters. | Functional / Data Integrity | Overpaid record is immediately hidden from the main data grid, search queries, and active status filters. | **PASS** | Parent record successfully removed from main index, search grid, and active filters. |
| **TC-OVP-002** | **Child Data Visibility Cascading** | 1. Delete parent Overpaid record containing active child payment records.<br>2. Inspect transaction history, receivable adjustment lists, and settlement dropdowns. | Functional / Data Integrity | All child Overpaid Payment records are automatically hidden from transaction history, settlement dropdowns, and adjustment views. | **PASS** | Child records automatically hidden from detail history and settlement selection menus. |
| **TC-OVP-003** | **Child Direct Access Block** | 1. Attempt direct URL/API access to a child Overpaid Payment whose parent record has been deleted. | Security / Direct Access | System rejects request via direct link/URL and displays a "Data Invalid" notification. | **PASS** | Direct link access blocked and triggers "Data Invalid" response. |
| **TC-OVP-004** | **Parent Journal Reversal Integrity** | 1. Execute deletion on active parent Overpaid record with posted journal entries.<br>2. Inspect linked Journal Info. | Integration / Financial | Associated Journal Info entry is cleanly voided/reversed with zero variance (balanced Debit/Credit), leaving no orphaned journal lines. | **PASS** | Parent journal entry successfully voided with zero ledger drift. |
| **TC-OVP-005** | **Child Journal Reversal Integrity** | 1. Execute deletion on active child Overpaid Payment record that has generated allocation journal entries.<br>2. Inspect linked Journal Info. | Integration / Financial | Allocation/settlement journal for the child record is voided/reversed accurately without invalidating the primary parent journal. | **PASS** | Child allocation journal voided cleanly without affecting parent journal state. |
| **TC-OVP-006** | **Ledger Audit & Trial Balance Check** | 1. Delete parent and child Overpaid records.<br>2. Navigate to `Report Accounting > Report Trial Balance`.<br>3. Inspect UNBALANCED JOURNAL section. | Integration / Regression | Deletion of parent and child records does not populate the Unbalanced Journal report; General Ledger integrity maintains 0 variance. | **PASS** | Trial Balance verified clean with zero unbalanced entries post-deletion. |
