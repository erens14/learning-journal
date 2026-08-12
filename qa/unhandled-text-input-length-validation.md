# QA Lesson Learned - Unhandled Text Input Length Validation

## Scenario

A core master data management module (**Receivable Account List**) enables administrators to create and maintain customer account profiles (`account_name`).

During routine data maintenance, users attempted to update existing account titles by appending location tags (e.g., adding `"PALEMBANG"`) to improve invoice sorting and branch identification.

The expected behavior was that the application would either save the extended name successfully or restrict input at the maximum allowed character limit with a clear UI validation message.

---

## Observation

Upon submitting the updated account name, the application returned a false-positive success response (*"Data updated successfully"*). However, upon refreshing the page or checking the grid, the changes were not saved.

Technical analysis identified a triple-layer validation failure:

1. **Database Layer:** The database column `receivable_account_name` was defined as `VARCHAR(50)`.
2. **Frontend Layer:** The HTML text input field lacked a `maxlength` attribute, allowing unrestricted character input.
3. **Backend API Layer:** The controller lacked payload validation rules (`max:50`) and caught the SQL string truncation error without failing the request, returning an HTTP `200 OK` status code instead of rolling back with an error response.

---

## Why This Matters

### User Impact

* Users receive misleading success feedback while their edits silently fail, resulting in incomplete account names on billing documents.

### System Impact

* Backend APIs mask database constraint exceptions, creating silent failure points that are difficult to trace in application logs.

### Data Impact

* High risk of silent data loss and inconsistency between client state and server storage.

### Business Impact

* Truncated or incorrect customer account titles on legal financial invoices, causing reconciliation delays and compliance audit failures.

---

## QA Learning

Quality assurance testing must validate text inputs end-to-end, ensuring that UI field restrictions, API validation schemas, and database column constraints are fully aligned.

### Validation Points

* **Boundary Value Testing (BVT):** Execute test cases at exact string length boundaries ($N-1$, $N$, $N+1$ characters, where $N$ is the column length limit).
* **Cross-Layer Alignment:** Verify that frontend `maxlength` attributes match backend payload validation rules and database `VARCHAR` lengths.
* **Persistence Verification:** Always verify database records or reload data grids post-submission to confirm actual data persistence.

### Edge Cases

* Updating existing records that are already close to the character limit by appending additional words.
* Copying and pasting text containing hidden trailing whitespace or special characters into text fields.
* Submitting raw API payloads that bypass frontend input controls to test backend validation resiliency.

### Business Rules

* Input strings exceeding allowable limits must be rejected with human-readable error messages (e.g., *"Account name cannot exceed 70 characters"*).

---

## UX / System Consideration

* **Schema Expansion:** Execute a database migration to expand column capacity (e.g., `VARCHAR(50)` $\rightarrow$ `VARCHAR(70)`).
* **Multi-Tier Validation:**
  * **Frontend:** Add `maxlength="70"` to input elements and provide visual character counters ($X/70$).
  * **Backend:** Implement strict request validation rules (e.g., `'account_name' => 'required|string|max:70'`).
  * **API Response:** Ensure database constraint exceptions return HTTP `422 Unprocessable Entity` responses with specific field error details.

---

## Key Takeaway

A UI success notification is invalid without backend data commitment. QA must perform Boundary Value Testing against database schema limits to catch silent data loss caused by missing input length validation across frontend and API layers.
