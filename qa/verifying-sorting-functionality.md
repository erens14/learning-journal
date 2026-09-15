# QA Lesson Learned — Verifying Sorting Functionality

**Area:** Reporting and Data Validation

**Scope:** Table sorting, filtering, pagination, and export behavior

## Context

A reporting module allowed users to sort several table columns in ascending or descending order. Testing needed to confirm that sorting changed only the display order and continued to work with filters, pagination, and exports.

## Finding and Evidence

**Expected behavior:** Every visible sorting control should return correctly ordered rows without changing the filtered dataset. Unsupported columns should not display sorting controls.

**Actual behavior:** Some columns sorted correctly, while others returned empty results or triggered an application or query error. Some unsupported columns also displayed sorting controls.

**Evidence / reproduction:**

1. Open a report containing multiple rows and pages.
2. Record the initial row count and active filters.
3. Sort each supported column in ascending and descending order.
4. Compare row order, row count, active filters, pagination, and exported output.
5. Check whether unsupported columns expose sorting controls.

> **Portfolio evidence notice:** This is a sanitized reconstruction using fictional column names and generalized outcome descriptions. It is not an original internal-system screenshot.

| Evidence ID | Reconstructed check | Expected | Observed finding |
| --- | --- | --- | --- |
| SORT-E01 | Sort `Reference` ascending and descending | Rows follow correct lexical order | Sorting worked as expected. |
| SORT-E02 | Sort a joined or calculated column | Rows remain visible in correct order | Report returned an error or empty result. |
| SORT-E03 | Apply a status filter, then sort | Filter and matching row count remain unchanged | Some sorting actions cleared the visible result. |
| SORT-E04 | Inspect an unsupported action column | No sorting control appears | Sorting control was visible despite unsupported behavior. |

**Suspected cause (optional):** Column mappings or server-side query definitions may differ between supported and unsupported fields. No confirmed root cause is published.

## Impact

Incorrect sorting can hide valid rows, disrupt report analysis, and reduce confidence in exported or paginated results. Query errors can also block users from accessing operational information.

## Testing and Outcome

**Checks performed:** Individual column sorting, ascending and descending behavior, result visibility, error behavior, and sorting-control visibility.

**Outcome:** Finding documented. Public evidence does not claim that every affected column was fixed or retested.

**Proposed improvement (optional):** Maintain an explicit allowlist of sortable fields and map each UI control to a validated server-side column.

**Unresolved follow-up (optional):** Retest every supported column after correction. Include filters, pagination, exports, and null values, then attach sanitized results without internal screenshots or production data.

## Lesson Learned

Sorting is a reporting workflow, not an isolated UI action. QA should verify order, dataset stability, filters, pagination, exports, and supported-field boundaries together.
