# QA Lesson Learned - Balancing Business Rule Enforcement and Regression Testing

## Scenario

During regression testing, business rule validations were verified after updates to transaction editing restrictions.

The expected workflow was that certain fields would become read-only only when specific business conditions were met, while remaining editable under valid conditions.

---

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Regression checking of conditional edit restrictions |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Reported findings only. This reconstruction adds no new execution result, confirmed root cause, or successful retest. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

The updated validation successfully prevented edits in several scenarios where restrictions were expected.

However, additional testing revealed that some validation rules were applied more broadly than intended.

Examples included:

* Fields became locked even when prerequisite business conditions had not been met.
* Time-based restrictions prevented editing earlier than defined by the business rules.
* Certain fields became permanently read-only regardless of the transaction state.
* Editing permissions did not fully align with the intended business workflow.

These findings indicated that the validation logic was functioning, but its scope was broader than the documented requirements.

---

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| LOCKSCOPE-E01 | Attempt an edit before its locking condition is met | Eligible fields remain editable | Fields became locked before the prerequisite condition was met. |
| LOCKSCOPE-E02 | Compare the permitted editing window with actual availability | Editing remains available until the documented cutoff | Time restrictions blocked edits earlier than expected. |
| LOCKSCOPE-E03 | Compare eligible and restricted transaction states | Read-only behavior follows the transaction state | Some fields remained permanently read-only across states. |

## Impact

Premature locks prevent legitimate corrections and can push users toward manual workarounds. The affected boundary is the transaction's allowed editing window, not simply whether a read-only control appears.

---

## QA Learning

Build a state-and-role matrix that names which fields may change before and after each locking event. Include times immediately around the cutoff and partially completed workflows. Pair each prohibited edit with a corresponding permitted case. These are proposed regression checks, not a successful retest.

---

## UX / System Consideration

Review the implementation against the documented locking event and cutoff. Automate the critical permitted and restricted cases once their expected behavior is agreed.

---

## Key Takeaway

A restriction passes only for its intended state and time boundary; the recorded early-locking failures remain unresolved in this note.
