# QA Lesson Learned - Monthly Form Router with Dynamic Formulas & Formatting

## Scenario

A Google Sheets automation solution was built using Google Apps Script (GAS) to automatically route Google Form responses into dynamically generated monthly tabs, inject advanced accounting formulas, and apply instant typography formatting.

The expected workflow was that once a Google Form submission occurred:

* The `On-Form-Submit` trigger would fire instantly and automatically evaluate the response timestamp.
* The script would dynamically generate a new monthly tab if a new month was detected, using a space-free naming convention (Format: `MonthYear`, e.g., `Juli2026`).
* The system would inject dynamic local formulas for that specific month's data range, including a Running Balance in Column G, Total Income in Column I, and Total Expenses in Column J.
* Custom typography styling (`Calibri 11` for the data working grid and `Calibri 12 Bold` for Header Row 1) would automatically override default sheet styles.

The feature being tested was the end-to-end reliability of form-triggered sheet mutations, regional localization compliance, dynamic array calculations, and automated typography styling.

---

## Observation

During the testing phase, the automation successfully triggered, but several advanced runtime, logic, and structural bugs were identified from a Quality Assurance perspective:

* **`appendRow` Collision:** Using the native `appendRow` function caused new entries to be pushed all the way down to row 1001. Because the dynamic array formulas (`MAP` & `SCAN`) automatically expand calculation arrays down to the very last row of the sheet (row 1000), `appendRow` falsely assumed those rows were occupied.
* **Localization Formula Parse Error:** Applying a complex nested `LAMBDA` formula via the standard `.setFormula()` function threw a fatal `#FORMULA_PARSE_ERROR`. The function strictly mandates international comma (`,`) syntax, and the Google Sheets engine frequently failed to translate them into local semicolons (`;`) required by the Indonesian regional settings environment.
* **Empty State Calculation Crash:** The initial Running Balance formula utilizing `FILTER` and `INDIRECT` completely crashed with an `#N/A` error whenever a new monthly sheet was initialized because the data area was still completely empty.
* **Sheet Name Syntax Conflicts:** Retaining spaces in monthly tab names (e.g., "Juli 2026") led to downstream formula syntax errors, requiring manual single-quote (`'`) encapsulation when referencing those tabs later on.

---

## Why This Matters

### User Impact

* Users find their newly submitted data pushed to row 1001, making the sheet appear broken or empty at a glance.
* Broken calculations displaying `#FORMULA_PARSE_ERROR` or `#N/A` prevent users from seeing accurate real-time balances, forcing manual troubleshooting.

### System Impact

* Conflicts between automated array expansion engines and row-appending scripts break core sheet mutation flows.
* Automated regional formula translation failures compromise code portability across differing spreadsheet locales.

### Data Impact

* Data alignment fragmentation occurs when values skip thousands of rows, leading to broken data visibility.
* Failure to gracefully handle empty sheet initializations disrupts continuous financial logging.

### Business Impact

* Unreliable automated ledgers undermine corporate accounting integrity and disrupt real-time income or expense reporting.

---

## QA Learning

Sheet automation testing must evaluate how dynamic cell expansions, environmental regional parameters, and programmatic structural styles interact with live user submissions.

### Validation Points

* Verify that new records append cleanly to the true immediate empty row by evaluating the primary column footprint rather than the entire row profile.
* Confirm that complex calculations load gracefully on newly initialized, zero-record datasets without returning errors.
* Validate that custom typography overrides apply seamlessly to both newly generated sheets and newly appended rows.
* Ensure tab names remain space-free to prevent downstream string manipulation failures.

### Edge Cases

* Form submission execution occurring on a completely empty monthly sheet initialization.
* Regional locale mismatches altering required formula array delimiters from commas to semicolons.
* Overlap collisions between script-driven row appends and dynamic `MAP`/`SCAN`/`LAMBDA` cell expansions.

### Business Rules

* The script must retain Indonesian naming conventions (`monthNames`) to natively align with local spreadsheet configurations and form timestamps.
* Local formulas must target dynamic ranges (`D2:D`, `F2:F`) making them 100% dynamic to that specific month's data.
* Financial ledger sheets must remain accessible and functional without requiring manual syntax adjustments.

### System Behavior Expectations

* The system must trigger instantly upon every form submission.
* The script must parse complex nested functions down to local syntax engines error-free.
* Script styling configurations must enforce uniform typography standards across all rows.

---

## UX / System Consideration

Potential improvements and architectural fixes implemented in the final script include:

* **Custom Empty-Row Finder:** Abandoned native `appendRow` in favor of a reverse lookup loop that strictly evaluates Column A (Timestamp) to accurately target the next available row (`nextRow`).
* **Raw Value Delimiter Bypass:** Replaced `.setFormula()` with `.setValue()`, allowing raw text strings pre-formatted with semicolons (`;`) to pass directly into the local Indonesian parser without engine translation failures.
* **Refactored Array Equations:** Replaced the vulnerable `FILTER`/`INDIRECT` logic with a stable `MAP` + `SCAN` + `LAMBDA` combination that handles empty sheet states gracefully.
* **Typography Control Variables:** Centralized font configuration parameters directly inside the script (`namaFont = "Calibri"`, `ukuranData = 11`, `ukuranHeader = 12`) for clean maintenance.
* **Production Source Code Isolation:** The full, clean, and production-ready source code for this automation project has been isolated into a dedicated repository for better version control and modularity. 👉 **[View the Clean Implementation Code Here](https://github.com/erens14/automated-expense-tracker-gas)**

---

## Key Takeaway

Testing programmatic spreadsheet automations should not end at checking if a script triggers successfully. QA must actively validate how structural database mutations collide with dynamic array expansion engines, ensure external syntax calls respect localized regional parameters, and confirm that isolated column validations prevent unexpected row displacement across the sheets.
