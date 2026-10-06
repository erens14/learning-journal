# Case Study — Access-Control Boundaries and Data Integrity

**Area:** Authorization and Data Integrity

**Scope:** Role-based edit controls and linked-record modification rules

## At a Glance

| Item | Summary |
| --- | --- |
| Problem | Editing a source record can invalidate dependent transactions unless permissions and dependency rules are enforced. |
| My contribution | Compared edit controls between privileged and ordinary users, checked linked-record restrictions, and documented the observed results. |
| Approach | Role comparison and negative workflow testing, with expected-versus-observed results recorded by test ID. |
| Recorded outcome | Three checks passed; the linked-quantity restriction failed. No successful retest of that failure is recorded. |
| Security relevance | Access-control validation, integrity safeguards, and evidence-limited reporting. |
| Evidence | [Four-case execution matrix](test-cases/rbac-consignment-integrity-test-cases.md). |

## Context

A consignment workflow allowed only a privileged role to edit product, quantity, packaging, and price fields. Even privileged edits had to preserve consistency with linked shipment and order records.

## Execution Context

| Field | Value |
| --- | --- |
| Activity | Role comparison and linked-record restriction checking |
| Evidence basis | Existing four-case QA matrix, summarized with generalized conditions |
| Result scope | Three recorded checks passed and one failed; direct-request authorization and a successful dependency-rule retest remain unverified. |

Original application screenshots and confidential development artifacts are excluded under the [NDA-safe evidence standard](../portfolio-standards.md#nda-safe-portfolio-evidence). Reconstructed examples illustrate the written record; they are not independent execution proof.

## Finding and Evidence

> **Portfolio evidence notice:** This case study summarizes existing sanitized QA records. It contains no original internal screenshots or production identifiers. It is not a newly executed lab.

| Test reference | Recorded observation | What it establishes |
| --- | --- | --- |
| `TC-CONS-001` | Privileged users could edit the expected fields. | The tested UI exposed the privileged edit controls. |
| `TC-CONS-002` | Ordinary users saw locked/read-only fields. | UI restriction passed; server-side direct-request authorization remains unverified. |
| `TC-CONS-003` | Quantity changes were accepted despite active linked records, without the expected warning. | The tested dependency rule failed. This does not establish a privilege-escalation exploit. |
| `TC-CONS-004` | Quantity changes succeeded after dependency cleanup. | The recorded eligible-edit workflow passed. |

**Root cause:** Not confirmed in the published evidence. Missing validation, incorrect relationship checks, or another implementation issue would require investigation.

## Impact

Unrestricted linked-record changes can leave quantities inconsistent across dependent workflows. A disabled UI field also cannot, by itself, demonstrate that the server rejects unauthorized writes.

## Testing and Outcome

**Evidence type:** Sanitized recorded QA observations, summarized in the linked matrix and reconstructed table.

**Outcome:** Preserve the matrix's three PASS results and one FAIL result within their recorded scope. No implementation fix or backend authorization proof is claimed.

**Unexecuted follow-up:** In an authorized test environment, submit a restricted field update directly as an ordinary user. Verify denial and unchanged stored values. Separately retest linked-record restrictions after a confirmed correction.

## Lesson Learned

Test UI permissions, server authorization, and business-data constraints separately. State which layer the evidence proves, and keep unresolved checks visible.
