# QA Lesson Learned - Implementing Robust Discord Webhooks in Google Apps Script

## Scenario

A Google Forms automation project used Google Apps Script to process user entries and send real-time alerts.

The expected workflow was that once an expense or income entry was submitted via Google Form:

* Apps Script should dynamically route the data into specific monthly sheets formatted as space-free tab names (e.g., `Juli2026`).
* Currency inputs should be automatically handled and formatted using Indonesian locale punctuation (`;`).
* Apps Script should successfully trigger an HTTP POST request to a Discord Webhook to send a real-time notification to the production server.

The feature being tested was the integration of Discord Webhooks, trigger objects, data parsing, and exception handling within the Google Apps Script automation flow.

---

## Observation

During testing, the spreadsheet routing worked, but the automated notification and parsing system revealed several critical bugs and runtime errors:

* Manually clicking the "Run" button inside the Google Apps Script editor threw a fatal `TypeError: Cannot read properties of undefined (reading 'range')` because the script relied on an Event Object (`e`) only generated during live submissions.
* Notifications failed to send silently because a logical guard rail implemented as `if (discordWebhookUrl !== "...")` was misconfigured; the placeholder string was mistakenly changed to the actual webhook URL, resulting in a false `URL !== URL` condition that caused the compiler to skip the entire execution block.
* Inputting text or non-numeric characters into the "Nominal" field caused the script to instantly crash because the native `.toLocaleString("id-ID")` function encountered an unhandled exception when forced onto non-numeric types.
* Standard network request behaviors meant that any external Discord API downtime or network glitch throwing a 400 or 500 error would completely freeze the Apps Script runtime, halting subsequent database tracking operations on Google Sheets.

These findings suggested that the automation flow lacked the necessary isolation, data type validation, and exception handling required for production reliability.

---

## Why This Matters

### User Impact

* Users and testers cannot manually run the script inside the editor without encountering fatal crashes due to undefined trigger parameters.
* Real-time notifications may silently fail to send due to logical placeholder mismatches, hiding critical financial updates from the team.

### System Impact

* A logic glitch in placeholder comparisons completely bypasses the webhook execution block after spreadsheet routing is complete.
* External API outages or network disruptions can completely freeze the runtime, breaking core spreadsheet logging operations.

### Data Impact

* Non-numeric entries in currency fields cause unhandled exceptions that immediately crash the data processing thread.
* Unmuted HTTP exceptions allow external network errors to disrupt the integrity of database entries in Google Sheets.

### Business Impact

* Real-time financial awareness for expense and income tracking becomes unreliable due to silent script failures.
* Production source code requires clean isolation in a dedicated repository to maintain version control and modularity.

---

## QA Learning

Google Apps Script automation testing must extend beyond basic form submission routing and require comprehensive edge-case validation and error isolation.

### Validation Points

* Verify that form inputs route cleanly into space-free monthly tab names (`MonthYear`).
* Confirm that currency inputs are automatically handled using proper Indonesian locale punctuation (`;`).
* Validate that mock functions successfully isolate trigger parameters to allow safe, rapid local debugging inside the editor.
* Ensure the webhook payload triggers instantly on the production Discord server upon new live form submissions.

### Edge Cases

* Manual script execution inside the editor environment where the event trigger object (`e`) is undefined.
* User entry errors where text or non-numeric values are injected into strict currency formatting fields.
* External third-party API downtimes, network glitches, or error status codes (e.g., 400 or 500).
* Hardcoded placeholder conditions matching actual production variables and breaking conditional logic.

### Business Rules

* Google Sheet database operations must always succeed regardless of external notification system availability.
* Currency formatting and type coercion must fail gracefully without halting the core execution thread.
* Clean and production-ready code must be separated from development workflows for reliable deployment.

### System Behavior Expectations

* The main automation functions should handle event parameters seamlessly during both live operations and isolated testing phases.
* Network fetch requests must be completely isolated to prevent external API dependencies from freezing internal script processes.
* Logical conditions must be streamlined to execute immediately following database actions.

---

## UX / System Consideration

Potential improvements include:

* Creating a dedicated local testing and mocking function (`jalankanTesManual()`) at the bottom of the script that pulls the last row of data from the spreadsheet to simulate a form submission safely.
* Removing redundant placeholder `if` statements entirely to streamline code execution directly after spreadsheet routing is complete.
* Wrapping numeric variables inside a `Number()` constructor combined with an `isNaN()` validation guard to gracefully downgrade to a raw string if the number test fails.
* Injecting the `"muteHttpExceptions": true` property into the `UrlFetchApp.fetch()` payload to isolate network requests from core spreadsheet operations.
* Isolating the clean, production-ready source code into a dedicated repository: [View the Clean Implementation Code Here](https://github.com/erens14/automated-expense-tracker-gas).

---

## Key Takeaway

Testing Google Apps Script automations should not end after confirming a basic form routes to a spreadsheet.

QA must also verify how trigger objects handle manual runs, safeguard data type parsing against unhandled validation exceptions, and isolate external HTTP network requests to ensure core database operations remain functional regardless of third-party API availability.
