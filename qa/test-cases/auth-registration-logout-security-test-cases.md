# Test Cases: Registration Lockdown & Session Logout Security

* **Category:** Quality Assurance, Security (Authentication), & Session Management  
* **Target Scope:** Authentication Module — Public Register Route Disablement & Logout Session Invalidation  

> **Disclaimer & Data Sanitization Notice**  
> Documented test scenarios, ticket references, and database relations within this repository have been sanitized and generalized for educational and portfolio purposes. Confidential company identifiers and ticket numbers have been replaced.

## Requirement Overview

* **Feature Goal:** Disable public self-registration routes (directing user creation exclusively through developers/administrators) and ensure complete session invalidation upon user logout.
* **Integrity Constraint:** Public `/register` endpoints and UI links must be removed or redirected, and logging out must revoke backend authentication sessions to prevent unauthorized actions via browser history navigation.

## Test Execution Matrix

| Test ID | Scenario | Execution Steps | Type / Security Focus | Expected Result | Status | Execution Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-001** | **Direct Register URL Access** | 1. Open browser in an unauthenticated state.<br>2. Enter `/register` URL in address bar and press Enter. | Functional / Security | System blocks access and redirects user to a static page informing that registration is restricted to developers. | **PASS** | Direct access to `/register` successfully redirected to static page. |
| **TC-AUTH-002** | **Register UI Link Verification** | 1. Navigate to main Login page.<br>2. Check for existence of "Register / Daftar" button or hyperlink. | Functional / UI | Register hyperlink/button is completely removed from the Login page interface. | **PASS** | UI verified clean; no registration links present on Login page. |
| **TC-AUTH-003** | **Standard UI Logout** | 1. Login to application.<br>2. Click **Logout** button/menu item. | Functional / Session | User is logged out, active session is invalidated on server, and user is redirected to Login page. | **PASS** | Normal logout flow executed cleanly. |
| **TC-AUTH-004** | **Browser Back-Button Invalidation** | 1. Login and navigate to Dashboard.<br>2. Click **Logout**.<br>3. Once on Login page, click browser **Back** button.<br>4. Attempt to trigger any UI action. | Security / Session Invalidation | Server revokes session. If cached page renders via browser bfcache, any interactive action immediately forces redirection to Login page. | **PASS** | Back button temporarily renders cached UI, but triggering any action forces immediate redirect to Login page. |
