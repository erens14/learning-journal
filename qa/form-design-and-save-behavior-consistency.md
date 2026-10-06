# QA Lesson Learned - Form Design and Save Behavior Consistency

## Scenario

During testing of a multi-section form, each section had its own individual **Save** button, while there was also a global **Submit** button at the bottom of the page.

When users filled in more than one section, they needed to manually click **Save** for each section.

However, if users directly clicked **Submit** without saving each section individually, some data was not persisted.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Multi-section form persistence checking |
| Evidence basis | Existing QA observations; the evidence summary below reconstructs them with generalized conditions |
| Result scope | Reported findings only. This reconstruction adds no new execution result, confirmed root cause, or successful retest. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Observation

The system had two different save mechanisms:

* Section-level Save (per form section)
* Global Submit (for the entire page)

This created inconsistency in data persistence behavior.

As a result:

* Users had to perform repetitive save actions.
* There was a risk of missing saved data if only Submit was used.
* User workflow became less efficient and prone to error.

## Portfolio Evidence

**Reconstruction notice:** These checkpoints summarize observations already described in this note. Conditions and example references are generalized or fictional. No original screenshot, internal log, or new test run is represented.

| Evidence ID | Reconstructed checkpoint | Expected behavior | Observation recorded in the source note |
| --- | --- | --- | --- |
| SAVE-E01 | Fill multiple sections and use only the global Submit action | The global submission follows the documented persistence contract | Some entered data was not persisted. |
| SAVE-E02 | Compare global Submit with section-level Save controls | Users can identify which action commits each section | Separate Save actions were required, creating an inconsistent submission workflow. |

## Why This Matters

In multi-section forms, inconsistent save behavior can lead to:

* Partial data loss
* User confusion about which action is required
* Unnecessary repetitive actions
* Higher chance of human error

The save mechanism should be predictable and aligned with user workflow.

## QA Learning

When testing forms with multiple sections, it is important to verify:

* Whether data is saved per section or as a whole
* Whether Submit includes all unsaved data
* Whether users are required to perform redundant actions
* Whether the UI behavior matches user expectations

## UX Consideration

A better design approach is to ensure:

* A single, consistent save mechanism (either per section or global)
* Or automatic aggregation of all form data on Submit

This reduces complexity and improves usability.

## Key Takeaway

Form design should minimize redundant user actions.

In multi-section forms, saving behavior must be consistent so users do not need to repeatedly perform manual saves to ensure data is not lost.
