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

## Why This Matters

### User Impact

* Users may be unable to perform legitimate updates during normal business operations.
* Overly restrictive validation can interrupt expected workflows.

### System Impact

* Validation logic that is too restrictive can be as problematic as missing validation.
* Incorrect enforcement may affect multiple transaction scenarios.

### Data Impact

* Necessary transaction corrections may become impossible.
* Users may resort to manual workarounds outside the system.

### Business Impact

* Operational processes may slow down due to unnecessary restrictions.
* Business rules may no longer reflect the intended transaction lifecycle.

---

## QA Learning

Regression testing should verify both restricted and permitted scenarios.

### Validation Points

* Verify when editing should be blocked.
* Verify when editing should still be allowed.
* Confirm that restrictions are triggered only after the required business conditions are met.
* Validate permission rules across different transaction states.

### Edge Cases

* Transactions before and after key business events.
* Time-based validation boundaries.
* Different user roles and permissions.
* Transactions with partial business process completion.

### Business Rules

* Validation should enforce only the intended restrictions.
* Editable fields should remain available until business conditions require them to be locked.
* Permission rules should align with the documented business process.

### System Behavior Expectations

* Data locking should occur only when predefined conditions are satisfied.
* Validation should distinguish between eligible and restricted transactions.
* Regression fixes should preserve existing functionality without introducing unnecessary restrictions.

---

## UX / System Consideration

Potential improvements include:

* Applying validation based on clearly defined business states.
* Expanding regression test scenarios to cover both positive and negative editing cases.
* Reviewing business rule implementation against documented requirements before deployment.
* Using automated regression tests for critical transaction locking logic.

---

## Key Takeaway

Effective regression testing is not only about confirming that restrictions exist—it is also about ensuring they are applied at the correct time.

Business rule validation should prevent unauthorized changes without blocking legitimate user actions that are still permitted by the business process.
