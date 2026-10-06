# QA Lesson Learned - Report Testing Beyond Data Display

## Scenario

A reporting feature is being tested where users can view, filter, and export operational data.

The main focus is to ensure that the report is not only displaying data correctly, but also supports accurate interaction through filtering, sorting, and exporting.

---

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Report interaction, export, sorting, and filter checking |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Reported findings only. This reconstruction adds no new execution result, confirmed root cause, or successful retest. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

At first glance, the report appears to function correctly because data is displayed as expected.

However, deeper testing reveals inconsistencies in supporting functionalities:

### Export Behavior

- Export functionality behaves inconsistently across different report pages.
- Some reports require user input (e.g., filename) before exporting.
- Some reports export directly without any prompt.
- Certain export actions fail silently or do not generate output files.

### Sorting Behavior

- Sorting is only enabled on specific columns.
- Some columns incorrectly expose sorting functionality.
- Sorting behavior is not always aligned with expected business rules or technical implementation.

### Filter Behavior

- Filters may appear to work but still return incorrect or incomplete datasets.
- Some results include unrelated records despite filter selection.
- Data accuracy is not guaranteed even when UI shows filtered output.

---

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| REPORT-E01 | Compare a visible report with its export action | The export follows the agreed flow and produces output | Some export actions produced no file; prompts differed between reports. |
| REPORT-E02 | Inspect sorting controls and supported fields | Sorting is offered only where supported | Some unsupported columns exposed sorting controls. |
| REPORT-E03 | Compare selected filters with returned records | Every returned record satisfies the selected criteria | Some results included unrelated records. |

## Why This Matters

Reports are commonly used as a basis for operational and business decision-making.

If reporting logic is incorrect, it can lead to:

- Incorrect operational decisions
- Misleading financial or business data
- Inconsistent user interpretation
- Hidden data integrity issues

Even when the UI appears correct, underlying logic may still be wrong.

---

## QA Learning

List what should be verified in similar cases:

- Validation of data accuracy, not just UI presence
- Verification that filters strictly match expected datasets
- Confirmation that sorting behavior aligns with business rules
- Verification of export consistency and file correctness
- Cross-checking behavior across similar report modules for consistency

---

## UX / System Consideration

Optional section for improvement ideas:

- Standardize export behavior across all reporting modules
- Ensure consistent filter and sorting rules across similar reports
- Provide clearer feedback for failed export actions
- Align UI behavior with backend data logic consistently

---

## Key Takeaway

Report testing must go beyond verifying that data is displayed on the screen.

A report can appear correct visually but still be incorrect in terms of filtering, sorting, export behavior, and data accuracy.

True report quality is determined by end-to-end validation of the entire data flow, not just the UI output.
