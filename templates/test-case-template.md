# Test Cases: [Module / Feature Name]

**Category:** [e.g., Quality Assurance, Security, Integration]
**Target Scope:** [Module, sub-feature, or business boundary]

> Documented scenarios, references, and data in this repository must be sanitized for portfolio use. Do not include confidential identifiers, credentials, customer data, or production URLs.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | [Test design, manual checking, or retesting supported by the source] |
| Evidence basis | [Recorded QA observations, tester-confirmed results, or test design without execution] |
| Result scope | [Test IDs and phase covered by the evidence; remaining checks stay NOT RUN] |

Include a safe environment description only when known. Execution dates and build identifiers are optional; omit unknown fields. Follow the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence).

## Preconditions

- [Required role, account state, feature flag, seed data, or related records.]
- [Required browser, device, API client, or test environment condition.]

## Requirements

**Feature goal:** [Brief description of intended behavior.]

**Key rules / constraints:** [Business rule, data-integrity condition, authorization boundary, or validation requirement.]

## Test Execution Matrix

| Test ID | Scenario | Steps | Test Type | Expected Result | Status | Evidence / Defect |
| --- | --- | --- | --- | --- | --- | --- |
| **TC-[MOD]-001** | [Positive scenario] | 1. Step 1.<br>2. Step 2.<br>3. Step 3. | Functional | [Expected behavior and relevant data state.] | **NOT RUN** | [Add proof after execution.] |
| **TC-[MOD]-002** | [Negative or security scenario] | 1. Step 1.<br>2. Step 2. | Validation / Security | [Expected validation or blocked behavior.] | **NOT RUN** | [Add proof after execution.] |
| **TC-[MOD]-003** | [Edge case or integration scenario] | 1. Step 1.<br>2. Step 2.<br>3. Step 3. | Integration / Regression | [Expected behavior.] | **NOT RUN** | [Add evidence or defect reference after execution.] |

## Execution Notes

- Record the tested condition, expected behavior, observed result, and confirmation scope when the matrix is run.
- For failed cases, include the observed behavior and a portfolio evidence ID or linked sanitized note. Do not publish internal ticket references.
- Preserve the original result and add a separate retest entry when confirmed. Link the retest to the original case or finding; a date is optional when known and safe to disclose.
- A PASS proves only the recorded steps and observations. Record direct-request and data-state evidence separately from UI checks.
- Application screenshots and confidential artifacts are excluded. Use clearly labeled text reconstructions of supplied observations; they do not turn NOT RUN cases into executed tests.
