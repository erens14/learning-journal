# QA Lesson Learned — Requirement Gathering Reveals More Than Bugs

**Area:** Requirement Analysis and Process Quality

**Scope:** User interviews, workflow gaps, reporting needs, and cross-module consistency

## Context

Users described operational problems encountered during daily work. The QA objective was to distinguish software defects from missing requirements, inefficient workflows, performance concerns, and enhancement requests before proposing technical changes.

## Finding and Evidence

**Expected behavior:** Each reported problem should be linked to a business objective, classified correctly, and converted into a testable requirement or investigation question.

**Actual behavior:** User feedback included more than defects. Findings covered manual work, missing information, report limitations, performance concerns, cross-module inconsistencies, and master-data needs.

**Evidence / reproduction:** The following traceability sample demonstrates how raw feedback can become structured QA work.

> **Portfolio evidence notice:** This is a sanitized reconstruction using fictional workflows. It contains no original internal-system screenshot, company name, user identity, or production value.

| Evidence ID | Reconstructed user concern | Classification | QA clarification or evidence needed |
| --- | --- | --- | --- |
| REQ-E01 | “I repeat the same entry in two screens.” | Workflow inefficiency | Map both steps, identify duplicate fields, and confirm system ownership. |
| REQ-E02 | “The report becomes slow for a full month.” | Performance requirement | Define dataset size, acceptable response time, filters, and export format. |
| REQ-E03 | “A saved transaction is missing from another module.” | Possible integration defect | Trace record creation, synchronization timing, permissions, and retrieval rules. |
| REQ-E04 | “We need another master-data option.” | Feature request | Confirm business owner, allowed values, dependencies, and lifecycle rules. |

**Suspected cause (optional):** Several concerns lacked measurable acceptance criteria or a shared understanding of the end-to-end workflow.

## Impact

Incorrect classification can produce the wrong fix, hide genuine defects, or add features that do not solve the operational problem. Missing acceptance criteria also makes testing and stakeholder approval unreliable.

## Testing and Outcome

**Checks performed:** Workflow mapping, problem classification, affected-module review, business-objective clarification, dependency identification, and acceptance-criteria drafting.

**Outcome:** Findings were converted into clearer investigation questions and testable categories. This note does not claim that every requested improvement was approved or implemented.

**Proposed improvement (optional):** Use a requirement traceability record containing the user problem, business goal, classification, acceptance criteria, owner, and linked tests.

**Unresolved follow-up (optional):** Obtain stakeholder approval for each business rule and measurable non-functional requirement before development begins.

## Lesson Learned

Users usually report pain, not system diagnoses. QA should identify the underlying business objective before classifying a concern or designing a test.
