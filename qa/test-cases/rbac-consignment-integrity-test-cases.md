# Test Cases: RBAC Authorization & Relational Data Integrity

* **Category:** Quality Assurance, Security (RBAC), & Integration Testing  
* **Target Scope:** Consignment (*Titipan*) Module — Field Unlocking & Dependency Constraints  

> **Disclaimer & Data Sanitization Notice**  
> Documented test scenarios, ticket references, and database relations within this repository have been sanitized and generalized for educational and portfolio purposes. Confidential company identifiers and ticket numbers have been replaced.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Recorded QA checking and result documentation |
| Evidence basis | Sanitized recorded QA observations; original internal evidence is not published |
| Result scope | Three PASS and one FAIL as recorded; UI role checks do not establish direct-request authorization |

Original application screenshots and confidential artifacts are excluded. Written observations and labeled reconstructions follow the [NDA-safe evidence standard](../../portfolio-standards.md#nda-safe-portfolio-evidence).

## Requirement Overview

* **Feature Goal:** Allow field modification (`Product`, `Qty`, `Zak/Bags`, and `Price`) on Consignment (*Titipan*) edit forms exclusively for users with the **SuperAdmin** role.
* **Integrity Constraint:** Modifications must respect existing relational dependencies (Expedition, Sales Orders, and Delivery Orders) to prevent data mismatch across modules.

## Status History and Evidence Boundaries

- `TC-CONS-001`, `TC-CONS-002`, and `TC-CONS-004` retain their recorded PASS results within the steps shown.
- `TC-CONS-003` retains its recorded FAIL result. No correction or successful retest is documented; current application behavior is unknown.
- `TC-CONS-002` verifies UI restrictions only. Direct or modified request handling and unchanged stored values need separate execution evidence.
- The [case study](../access-control-boundaries-and-data-integrity.md) summarizes the finding and proposed follow-up. Proposed checks are not additional passing tests.

## Test Execution Matrix

| Test ID | Scenario | Execution Steps | Type / Security Focus | Expected Result | Status | Execution Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-CONS-001** | **Field Unlocking (SuperAdmin)** | 1. Login with **SuperAdmin** role.<br>2. Open active Consignment record edit form. | Functional / Authorization | `Product`, `Qty`, `Zak`, and `Price` fields are unlocked and fully editable. | **PASS** | Edit controls open properly for SuperAdmin. |
| **TC-CONS-002** | **RBAC Protection (Non-SuperAdmin)** | 1. Login with **Non-SuperAdmin** role.<br>2. Navigate to Consignment edit form. | Security / RBAC | `Product`, `Qty`, `Zak`, and `Price` fields remain locked/read-only. | **PASS** | UI fields remained locked/read-only. These steps do not verify server-side enforcement against a direct or modified request. |
| **TC-CONS-003** | **Qty Edit Prevention on Linked Data** | 1. Select Consignment record linked to active Expedition/Sales/DO records.<br>2. Modify `Qty` field.<br>3. Click **Save**. | Integration / Negative Validation | System blocks update and displays warning pop-up preventing Qty modification due to active linked dependencies. | **FAIL** | **[BUG FOUND]** System fails to display warning popup upon saving, allowing Qty modification despite active linked Expedition/Sales/DO data. |
| **TC-CONS-004** | **Qty Edit Post Dependency Cleanup** | 1. Remove/detach related Expedition records.<br>2. Modify `Qty` field on Consignment record.<br>3. Click **Save**. | Integration Testing | Qty modification completes successfully and database updates without relational errors. | **PASS** | Data updates cleanly once dependencies are resolved. |
