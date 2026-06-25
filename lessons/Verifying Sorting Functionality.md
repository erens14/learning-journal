# QA Lesson Learned - Verifying Sorting Functionality

## Scenario

A reporting module provided sorting functionality on multiple table columns.

Some columns worked correctly when sorted, while others caused unexpected behavior such as:

* Empty table results
* Application errors
* Failed data retrieval

## Observation

Not every column in a report necessarily requires sorting functionality.

During testing, it is important to verify:

* Which columns are intended to support sorting
* Whether sorting returns the correct data order
* Whether sorting causes unexpected errors
* Whether sorting affects filtering or pagination

## Why This Matters

Sorting appears to be a simple feature, but it often depends on:

* Database column availability
* Query generation
* Joins between multiple tables
* Backend validation

A missing or incorrectly mapped column can cause the entire report query to fail.

## QA Learning

When testing report pages:

1. Verify each sortable column individually.
2. Confirm the sorted result is logically correct.
3. Test ascending and descending order.
4. Verify sorting after applying filters.
5. Verify sorting together with pagination.
6. Check whether non-sortable columns incorrectly display sorting controls.

## Testing Pattern

Filter Data
→ Sort Ascending
→ Sort Descending
→ Change Page
→ Export Result
→ Verify Data Consistency

## Key Takeaway

Testing a report should focus not only on whether data is displayed, but also on whether supporting features such as sorting, filtering, pagination, and export continue to work correctly when combined.

Even small features like column sorting can expose underlying query or data mapping issues that are not visible during normal usage.
