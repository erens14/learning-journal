# Test Cases: Side Navigation to Top Navigation

**Category:** Quality Assurance, UI, Authorization, and Regression
**Target Scope:** Web navigation refactor from a side navigation bar to a top navigation bar
**Environment:** Local

> Documented scenarios, references, and data in this repository must be sanitized for portfolio use. Do not include confidential identifiers, credentials, customer data, or production URLs.

## Preconditions

- A fictional `Navigation Administrator` account has access to all test menus.
- A fictional `Restricted Navigation User` account has limited menu access.
- Existing navigation routes and role permissions are available in the test environment.
- Current supported desktop and mobile browsers are available.
- Representative dashboard, list, form, report, and nested-route pages contain sanitized test data.

## Requirements

**Feature goal:** Replace the side navigation bar with a top navigation bar while preserving route behavior, authorization, responsive usability, and access to existing features.

**Key rules / constraints:** Users must see only permitted menus. Direct access to restricted routes must remain blocked by server-side authorization. Removing the side navigation must not leave unused page space. The top navigation must remain readable and operable across supported screen sizes and input methods.

## Test Execution Matrix

| Test ID | Scenario | Steps | Test Type | Expected Result | Status | Evidence / Defect |
| --- | --- | --- | --- | --- | --- | --- |
| **TC-TNAV-001** | Render top navigation for an authorized user | 1. Sign in as `Navigation Administrator`.<br>2. Open the dashboard.<br>3. Inspect the page navigation and content area. | Functional / UI | Top navigation is displayed, side navigation is absent, authorized primary menus remain available, and page content uses the released horizontal space. | **PASS** | Manual check confirmed the top navigation, removed side navigation, available menus, and expanded content layout. |
| **TC-TNAV-002** | Navigate through primary menus | 1. Sign in as `Navigation Administrator`.<br>2. Select each primary top-navigation item.<br>3. Confirm each destination route and page state. | Functional / Regression | Every menu opens its expected page without a broken route, blank page, or unexpected redirect. | **PASS** | Manual check confirmed all tested primary menus opened their expected pages. |
| **TC-TNAV-003** | Open and close a submenu | 1. Open a top-navigation item containing a submenu.<br>2. Select each permitted submenu item.<br>3. Reopen the submenu and click outside it. | Functional / UI | Submenu opens in the correct position, each item routes correctly, and the submenu closes without blocking page interaction. | **PASS** | Manual check confirmed correct submenu opening, routing, and dismissal behavior. |
| **TC-TNAV-004** | Show the active route state | 1. Open a page from the top navigation.<br>2. Inspect its menu and parent-menu state.<br>3. Use browser Back and Forward. | UI / Regression | Current route and relevant parent menu remain visibly identifiable after direct navigation and browser-history changes. | **PASS** | Manual check confirmed the active state remained identifiable during navigation and history changes. |
| **TC-TNAV-005** | Preserve menu and route authorization | 1. Sign in as `Restricted Navigation User`.<br>2. Inspect visible top-navigation items.<br>3. Attempt direct access to a restricted route. | Authorization / Security | Restricted menus are hidden or disabled according to policy, and direct route access is denied by server-side authorization. | **PASS** | Manual check confirmed restricted menus stayed unavailable and restricted direct access was denied. |
| **TC-TNAV-006** | Use navigation at a mobile viewport | 1. Set the viewport width to `390px`.<br>2. Open the mobile navigation control.<br>3. Open a submenu and select a permitted destination. | Responsive / Functional | Navigation remains reachable, readable, and operable. Menus do not overflow, obscure critical controls, or trap the user. | **PASS** | Manual check confirmed mobile navigation remained readable, reachable, and free from blocking overlap. |
| **TC-TNAV-007** | Adapt between tablet and desktop layouts | 1. Open the application at a supported tablet width.<br>2. Resize to a supported desktop width.<br>3. Resize back across the navigation breakpoint. | Responsive / Regression | Layout adapts without duplicate menus, overlap, horizontal scrolling, stale open menus, or leftover side-navigation spacing. | **PASS** | Manual check confirmed clean layout changes across tested viewport sizes. |
| **TC-TNAV-008** | Operate navigation using a keyboard | 1. Use `Tab` and `Shift+Tab` to reach navigation controls.<br>2. Open a submenu using the keyboard.<br>3. Select an item with `Enter`.<br>4. Close the submenu with `Escape` when supported. | Accessibility | Focus remains visible, controls are keyboard reachable, expected keyboard actions work, and focus does not become trapped. | **PASS** | Manual check confirmed visible focus, keyboard access, menu operation, and no focus trap. |
| **TC-TNAV-009** | Preserve representative page layouts | 1. Open sanitized dashboard, list, form, and report pages.<br>2. Compare page width, alignment, and action placement.<br>3. Scroll each page vertically and horizontally. | UI / Regression | Content uses the available width without overlap. Header and menus do not obscure page titles, actions, tables, forms, or report controls. | **PASS** | Manual check confirmed representative pages remained aligned and unobstructed. |
| **TC-TNAV-010** | Preserve refresh and direct-link behavior | 1. Open a permitted nested page using its direct local URL.<br>2. Refresh the browser.<br>3. Inspect page content and navigation state. | Integration / Regression | Nested page reloads successfully, authorization remains enforced, and the correct parent and child navigation state is identifiable. | **PASS** | Manual check confirmed direct links, refresh behavior, authorization, and navigation state. |
| **TC-TNAV-011** | Preserve behavior across supported browsers | 1. Repeat primary-menu and submenu scenarios in each supported browser.<br>2. Compare route behavior, alignment, focus, and menu interaction.<br>3. Record browser-specific differences. | Compatibility / Regression | Navigation behavior and layout remain consistent across supported browsers, with no browser-specific blocker. | **PASS** | Manual check confirmed consistent navigation behavior across tested supported browsers. |
| **TC-TNAV-012** | Refresh permissions after a session change | 1. Sign in as `Navigation Administrator`.<br>2. Sign out completely.<br>3. Sign in as `Restricted Navigation User`.<br>4. Inspect navigation and attempt a previously available route. | Integration / Authorization | Navigation reflects the current user only. Previous-session menus are removed, cached permissions are not reused, and restricted direct access remains denied. | **PASS** | Manual check confirmed navigation refreshed to the current user without permission leakage. |

## Execution Notes

- Tester confirmed that all 12 scenarios passed manual checking.
- Internal screenshots, real routes, account names, and system identifiers are intentionally excluded from this public portfolio document.
- Record execution date, tester, browser, viewport, input method, and result context.
- Confirm the approved menu hierarchy, supported browsers, and responsive breakpoints before execution.
- Use fictional local data and sanitized evidence only.
- For failed cases, record observable behavior and a sanitized defect reference.
