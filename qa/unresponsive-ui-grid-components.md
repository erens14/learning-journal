# QA Lesson Learned - Event Handler Bindings & Unresponsive UI Components in Data Grids

---

## Scenario

An accounting disbursement module (**Bukti Bank Keluar / BBK**) was deployed featuring a data grid view with several interactive UI components, including:

* Dynamic transaction ID links to open transaction detail modals.
* Header action controls (**SCAN QRCODE** camera scanner and **EXCEL** report export).
* Filter controls (**BBK DATE** month/year datepicker).

The expected behavior was that clicking any interactive UI element would trigger its bound event listener—opening modals, launching the camera scanner, generating report downloads, or expanding filter pickers.

---

## Observation

During test execution, while the main data table successfully loaded records, all secondary UI controls became completely unresponsive (*unclickable UI*):

* Clicking transaction IDs (`ID 560`, `559`, etc.) failed to open detail modals or navigate to detail views.
* Action buttons (**SCAN QRCODE**, **EXCEL**) failed to trigger modal pop-ups or download scripts.
* Interactive inputs (**BBK DATE** picker) failed to expand dropdown controls.

Investigation revealed that while the DOM rendered visually, frontend event listeners failed to attach to dynamically loaded table rows, or JavaScript runtime errors caused silent failures without feedback.

---

## Why This Matters

### User Impact

* Users are completely blocked from viewing transaction details, scanning vouchers, or exporting monthly financial reports for auditing.

### System Impact

* Uncaught frontend exceptions interrupt component lifecycle hooks, preventing dynamic DOM re-rendering and API event triggers.

### Data Impact

* Users cannot extract or reconcile cash disbursement data via Excel exports or filtered date ranges.

### Business Impact

* Operational delays in bank disbursement processing and financial reconciliation workflows.

---

## QA Learning

Testing data grid interfaces must go beyond verifying that table rows display correctly. QA must systematically validate that every button, hyperlink, and filter control fires its underlying event handler and produces visual feedback.

### Validation Points

* Confirm that clicking record identifiers triggers the correct detail view or modal pop-up with matching payload IDs.
* Verify that export buttons (**EXCEL**) trigger API download requests and return valid file buffers.
* Ensure filter controls (**Datepicker**, **Search**) dynamically re-index grid data upon selection change.
* Check browser developer console (F12) for unhandled JavaScript errors (`Uncaught TypeError`, `Undefined Handler`) during UI interactions.

### Edge Cases

* Clicking action links immediately after rapid pagination or filtering before the DOM finishes re-rendering.
* Attempting actions on empty table states or search results with zero records.
* Testing event handler resilience when network requests fail or time out.

### Business Rules

* Every UI control must provide explicit feedback: an active modal, a loading spinner, a file download prompt, or an error alert—never a silent non-response.

---

## UX / System Consideration

* **Event Delegation:** Use event delegation on parent container elements (e.g., `table.addEventListener('click', ...)` instead of binding listeners to individual dynamic rows) to ensure handlers persist after dynamic grid updates.
* **Global Error Handling:** Catch frontend exceptions gracefully and display toast notifications if a component fails to initialize.
* **Affordance & State Indicators:** Ensure interactive elements display appropriate CSS cursors (`cursor: pointer`), active states, and disabled styling when feature permissions are inactive.

---

## Key Takeaway

A visually complete data grid does not equal a functional feature. Quality Assurance must verify that every interactive link, button, and filter input actively executes its event handler and provides clear visual feedback to the user.
