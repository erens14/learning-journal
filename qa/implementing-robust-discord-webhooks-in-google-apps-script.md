# QA Lesson Learned - Implementing Robust Discord Webhooks in Google Apps Script

## Scenario

A Google Forms automation project used Google Apps Script to process user entries and send real-time alerts.

The expected workflow was that once an expense or income entry was submitted via Google Form:

* Apps Script should dynamically route the data into specific monthly sheets formatted as space-free tab names (e.g., `Juli2026`).
* Currency values should be validated and formatted with Indonesian grouping and decimal punctuation (for example, `1.234,56`). A semicolon (`;`) is a spreadsheet formula separator, not currency punctuation.
* Apps Script should successfully trigger an HTTP POST request to a Discord Webhook to send a real-time notification to the production server.

The feature being tested was the integration of Discord Webhooks, trigger objects, data parsing, and exception handling within the Google Apps Script automation flow.

---

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Form-trigger and webhook reliability checking |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Trigger, input, and notification failures are documented. Suggested error-handling changes and outage checks are not a confirmed regression pass. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

During testing, the spreadsheet routing worked, but the automated notification and parsing system revealed several critical bugs and runtime errors:

* Manually clicking the "Run" button inside the Google Apps Script editor threw a fatal `TypeError: Cannot read properties of undefined (reading 'range')` because the script relied on an Event Object (`e`) only generated during live submissions.
* Notifications failed to send silently because a logical guard rail implemented as `if (discordWebhookUrl !== "...")` was misconfigured; the placeholder string was mistakenly changed to the actual webhook URL, resulting in a false `URL !== URL` condition that caused execution to skip the entire execution block.
* Non-numeric input in "Nominal" was reported to cause a formatting exception. Strings also implement `.toLocaleString()`; without the receiver value and stack trace, this note cannot attribute the exception to non-numeric input alone.
* An unhandled `UrlFetchApp.fetch()` exception can terminate the current execution and skip later statements. HTTP error responses such as 400 or 500 differ from transport failures or timeouts. Outage behavior was not confirmed by the recorded tests.

These findings suggested that the automation flow lacked the necessary isolation, data type validation, and exception handling required for production reliability.

---

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| HOOK-E01 | Run a form-event handler manually without an event object | The manual path supplies a test event or handles its absence | Access to the missing event range caused a runtime error. |
| HOOK-E02 | Compare successful sheet routing with notification delivery | The notification path runs after eligible submissions | A guard comparison skipped the notification block. |
| HOOK-E03 | Submit non-numeric input to the amount field | Invalid input is rejected or handled without an unexpected crash | The note reports an exception after non-numeric input; the failing receiver and call are not established. |

## Impact

### User Impact

* Users and testers cannot manually run the script inside the editor without encountering fatal crashes due to undefined trigger parameters.
* Real-time notifications may silently fail to send due to logical placeholder mismatches, hiding critical financial updates from the team.

### System Impact

* A logic glitch in placeholder comparisons completely bypasses the webhook execution block after spreadsheet routing is complete.
* An unhandled fetch exception can stop the current execution; this does not freeze the Apps Script runtime as a whole.

### Data Impact

* Invalid currency input needs explicit validation. The reported exception does not establish which coercion or formatting call failed.
* If sheet writes occur after a failing fetch, they may be skipped. The existing record does not establish lost or corrupted sheet entries.

### Business Impact

* Real-time financial awareness for expense and income tracking becomes unreliable due to silent script failures.
* Production source code requires clean isolation in a dedicated repository to maintain version control and modularity.

---

## QA Learning

Google Apps Script automation testing must extend beyond basic form submission routing and require comprehensive edge-case validation and error isolation.

### Validation Points

* Verify that form inputs route cleanly into space-free monthly tab names (`MonthYear`).
* Confirm numeric validation and Indonesian currency formatting separately from spreadsheet formula separators (`;`).
* Validate that mock functions successfully isolate trigger parameters to allow safe, rapid local debugging inside the editor.
* Ensure the webhook payload triggers instantly on the production Discord server upon new live form submissions.

### Edge Cases

* Manual script execution inside the editor environment where the event trigger object (`e`) is undefined.
* User entry errors where text or non-numeric values are injected into strict currency formatting fields.
* External third-party API downtimes, network glitches, or error status codes (e.g., 400 or 500).
* Hardcoded placeholder conditions matching actual production variables and breaking conditional logic.

### Business Rules

* Core sheet writes should complete before notification delivery, with each failure reported separately. Notification isolation cannot guarantee that sheet operations themselves succeed.
* Currency formatting and type coercion must fail gracefully without halting the core execution thread.
* Keep implementation code under version control and document validation before deployment.

### System Behavior Expectations

* The main automation functions should handle event parameters seamlessly during both live operations and isolated testing phases.
* Handle HTTP error responses by checking their response codes, and catch transport exceptions separately. Keep notification failure from skipping core sheet writes.
* Logical conditions must be streamlined to execute immediately following database actions.

---

## UX / System Consideration

Potential improvements include:

* Creating a dedicated local testing and mocking function (`jalankanTesManual()`) at the bottom of the script that pulls the last row of data from the spreadsheet to simulate a form submission safely.
* Removing redundant placeholder `if` statements entirely to streamline code execution directly after spreadsheet routing is complete.
* Validate the raw amount before formatting. Reject blank or non-finite values explicitly; `Number()` alone can convert empty input to zero.
* Pass `muteHttpExceptions: true` in the `UrlFetchApp.fetch()` options object, then inspect `getResponseCode()`. Use `try/catch` for transport failures and timeouts; this option does not suppress those failures and is not part of the Discord message payload.
* [Implementation repository](https://github.com/erens14/automated-expense-tracker-gas). The linked code was not inspected here, and no successful regression run or production-readiness assessment is recorded.

---

## Key Takeaway

Testing Google Apps Script automations should not end after confirming a basic form routes to a spreadsheet.

Verify manual-event handling, numeric validation, and notification failures separately. These are proposed regression checks; the record does not establish that the suggested changes passed them.
