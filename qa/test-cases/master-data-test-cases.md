# Test Cases: Standard Master Data Lifecycle (CRUD)

* **Category:** Quality Assurance & Functional Testing  
* **Target Scope:** Master Data Modules (CRUD, Soft Delete, Restore, PDF Export)  

> **Disclaimer & Data Sanitization Notice**  
> Documented test scenarios, API endpoints, ticket references, and database schema representations within this repository have been fully sanitized, anonymized, and generalized for educational and portfolio purposes. No proprietary business logic, sensitive production data, or company-confidential information are disclosed.

## Overview

Standardized test case documentation for verifying Master Data modules in enterprise web applications. The testing scope covers the full data lifecycle: record creation (*Create*), input validation, searching and filtering (*Read*), data modification (*Update*), soft deletion (*Soft Delete*), data recovery (*Restore*), and document exporting (*Export PDF*).

## Test Execution Matrix

| Test ID | Scenario | Execution Steps | Type | Expected Result |
| :--- | :--- | :--- | :--- | :--- |
| **TC-MD-01** | **Create (Insert)** | 1. Open Add/Create form.<br>2. Fill all required & optional fields with valid data.<br>3. Click **Save**. | Functional | Data is successfully saved, a success notification appears, and the new record displays in the active data table. |
| **TC-MD-02** | **Create (Validation)** | 1. Open Add/Create form.<br>2. Leave required fields blank.<br>3. Click **Save**. | Functional | Form submission is blocked and system displays inline validation error messages for missing fields. |
| **TC-MD-03** | **Create (Unique)** | 1. Enter an existing Code/Name already present in the database.<br>2. Click **Save**. | Functional | Submission is rejected with a duplicate key constraint error message. |
| **TC-MD-04** | **Read (List & Filter)** | 1. Open Index/List page.<br>2. Test Search bar and Filter controls.<br>3. Navigate through pages (**Pagination**). | Functional | Data displays accurately based on search/filter keywords, and pagination operates smoothly. |
| **TC-MD-05** | **Update (Edit)** | 1. Click **Edit** on a target row.<br>2. Modify record attributes.<br>3. Click **Update**. | Functional | Data changes save successfully in the UI and database, and the `updated_at` timestamp is updated. |
| **TC-MD-06** | **Delete (Soft Delete)** | 1. Click **Delete** on target row.<br>2. Confirm modal dialog. | Functional | Record is removed from the main active table, and the database populates the `deleted_at` timestamp column. |
| **TC-MD-07** | **Restore Data** | 1. Make sure data's `status` is `DELETED`.<br>2. Click **Restore** on targeted item. | Functional | Record restores successfully and status back to `ACTIVE` in the index table |
| **TC-MD-08** | **Export PDF** | 1. Open detail page for specific data entry.<br>2. Click **Export PDF** button. | Functional | PDF file downloads with clean layout, and total row count matches the active UI grid filter. |
